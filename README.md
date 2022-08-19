## Podman Containerized Open OnDemand Template

This is a template for spinning up OOD in a container using OpenID connect for SSO authentication to map to a local user from an email. For demo sake, the local user mapping are simplistic but with some additions/tweaks is close to what I use in production for multiple deployments

I have done my best to inline comment in the various custom scripts and config files. As a result this readme is more aimed at what you need to do before hand to deploy this, the various files one needs to know about so changes/customizations can be made and how to build and start the containers and pod.

The container stand-up instructions assume you are working as a local user (not root) and have the root of this repo in `$HOME`.

** NOTE: This containerization currently only uses a local user inside the container which is made during the container build process. LDAP and user creation are being worked on now**

#### Prerequisits

1. Public IP with DNS
2. Apache server
3. ssl certificate (this example used letsencrypt)
4. local user on hostmachine to run the container rootless
5. OIDC ClientID and Secret from an upstream OpenID Connect IDP like Globus or CiLogon

#### Setup Host Machine Security and Limits
 
Turning off selinux is the easiest thing but generally bad form so instead you must set the following:

	* `setsebool -P container_manage_cgroup true`
	* `setsebool -P httpd_can_network_relay 1`
	* `setsebool -P httpd_can_network_connect 1`

Many organizations have UID and GID's that are in the hundreds of thousands. To allow for +65k UID/GID's, increase the subuid and subgid limit for the user that is running the container by editing `/etc/subuid` and `/etc/subgid`. Then you need to kill the pause process running for the user whos suibuid and subgid you changed my running `podman system migrate`.  


#### Setup Hosts Apache Config

I have provided example configs in the `etc` dir for both Ubuntu style apache2.conf and RHEL style httpd.

The only changes needed for either should be to sed replace `<hostname>` with your actual hostname. 

You may also need to change the pathing to your hosts ssl keys if not using letsencrypt like I am in this example.


#### Register App with CiLogon or Globus

All you need to register is to know your redirect URI which should just be `/oidc` off the root of your hostname i.e. `https://ood-dev.mghpcc.org/oidc`

Make sure to register the App to ask for the `openid` and `email` scope.

* Globus is self serving so you can just go to `https://auth.globus.org/v2/web/developers` and register your app

* CiLogon requires reaching out to the admins: https://cilogon.org/oauth2/register

#### Customize OOD config 

In `etc/ood/config` you will find `ood-portal.yml`. This file is used during build time to generate the apache config for OnDemand that will live in the container.

The needed tweaks are the following:

* set `servername:` the same as the hostname of the host machine
* tweak the ssl paths so they match what they are on the host
* set `oidc_provider_metadata_url:` to what your upstream IDP's well-known url is
* set `oidc_client_id:` to what your IDP has provided for your client
* set `oidc_client_secret:` to what your IDP provided

#### Allow ssl cert readability for local user

`chgrp` the ssl certs so that the local user that will run the container can read them

If you are not using the standard letsencrypt cert location you need to tweak the script `start_ondemand_ctr.sh` so that the volume mounts are correct. In that script, set the `SSL_CERT_ROOT_PATH` accordingly


#### Build the image and start the pod

Now you can `./build_ood.sh`

Next, edit GIT_ROOT in start_ondemand_ctr.sh if the root of the git is not `~/ERN-Remote-Scientific-Instrument`

To start the pod for the first time, do `./start_ondemand_ctr.sh`

You can get a shell inside the running container with `podman exec -it ondemand_ctr bash`

#### Users and Groups

The template provides the basic /etc/passwd and /etc/group that is would be made during the building of the image and container. These get mounted into the container at run time along with /home. 

At this point, manually create users inside the container based on their upstream ldap info, i.e. match gid, uid, and make them a /home dir. The passwd and group changes are maintained across restarts and rebuilds as the passwd and group files are volume mounted into the container.

The user_map_script runs inside the container upon a successful upstream IDP login. The script pulls the username from the email provided in the OpenIDC response and runs an LDAPSEARCH. At the same time, the script runs a getent locally trying to find a local user with the same username. Finally, it compares the ldapsearch response to the localuser search and if it gets a match, it returns the username to OOD where it should then be able to spin up the per-user-nginx bits. 

This process basically confirms the 2 things needed for an authorized and ultimately successful login: 

  1. The email in the OpenIDC response matches the email of a user in LDAP
  2. A local Linux user matches the uid of the ldap user that matched to the OpenIDC provided email 

I also maintain the ability to map to a manually maintained usermap file for now although this can be turned off if the only users that should be able to login are in ldap.

#### Edit VNC Redirect in Flask App

In the file `var/www/ood/apps/sys/Flask/templates/index.html`, simply edit 

----PENDING---- Add to me
