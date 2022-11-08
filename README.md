## Podman Containerized Open OnDemand Template

This is a template for spinning up OOD in a container using OpenID connect for SSO authentication to map to a local user from an email. For demo sake, the local user mapping are simplistic but with some additions/tweaks is close to what I use in production for multiple deployments

I have done my best to inline comment in the various custom scripts and config files. As a result this readme is more aimed at what you need to do before deployment, the various files one needs to know about for changes/customizations and how to build and start the pod.

The container stand-up instructions assume you are working as root and have the root of this git in `$HOME`.


#### Prerequisits

1. Public IP with DNS
2. Apache server
3. ssl certificate (this example uses letsencrypt)
4. OIDC ClientID and Secret from an upstream OpenID Connect IDP like Globus or CiLogon

#### Setup Host Machine Security and Limits
 
Turning off selinux is the easiest thing to do but bad form so instead you must set the following:

	* `setsebool -P container_manage_cgroup true`
	* `setsebool -P httpd_can_network_relay 1`
	* `setsebool -P httpd_can_network_connect 1`
  


#### Setup Hosts Apache Config

I have provided example configs in the `etc` dir for both Ubuntu style apache2.conf and RHEL style httpd.

The only changes needed for either should be to sed replace `<hostname>` with your actual hostname. 

You may also need to change the pathing to your hosts ssl keys if not using letsencrypt like I am in this example.


#### Register App with CiLogon or Globus

All you need to know about your environment when registering with an IDP is your redirect URI which is traditionally just `/oidc` off the root of your FQDN i.e. `https://ood.myinstitution.org/oidc`

Make sure when registering the App to ask for the `openid` and `email` scope.

* Globus is self serving so you can just go to `https://auth.globus.org/v2/web/developers` and register your app

* CiLogon requires reaching out to the admins: https://cilogon.org/oauth2/register

#### Customize OOD config 

In `etc/ood/config` you will find `ood-portal.yml`. This file is used during build time to generate the apache config for Open OnDemand.

The needed tweaks are the following:

* set `servername:` the same as the hostname of the host machine
* tweak the ssl paths so they match what they are on the host
* set `oidc_provider_metadata_url:` to what your upstream IDP's well-known url is, for Globus, it is https://auth.globus.org/.well-known/openid-configuration
* set `oidc_client_id:` to what your IDP has provided for your client
* set `oidc_client_secret:` to what your IDP provided as a secret

#### Allow ssl cert readability for local user

If you are not using the standard letsencrypt cert location you need to tweak the script `start_ondemand_ctr.sh` so that the volume mounts are correct. In that script, set the `SSL_CERT_ROOT_PATH` accordingly


#### Build the image and start the pod

Now you can run `./build_ood.sh`

Next, edit GIT_ROOT in start_ondemand_ctr.sh if the root of the git is not `~/ERN-Remote-Scientific-Instrument`

To start the pod for the first time, do `./start_ondemand_ctr.sh`

You can get a shell inside the running container with `podman exec -it ondemand_ctr bash`

#### Users and Groups

The template provides the basic /etc/passwd and /etc/group that is would be made during the building of the image and container. These get mounted into the container at run time along with /home. 

At this point, manually create users inside the container based on their upstream ldap info, i.e. match gid, uid, and make them a /home dir. The passwd and group changes are maintained across restarts and rebuilds as the passwd and group files are volume mounted into the container.

The user_map_script runs inside the container as a shim between the OpenID token response from your IDP and what Open OnDemand's Apache receives as standard input. When a successful authentication is done through the upsteam IDP, the (ascii encoded) email address of the authenticated user is passed to the user_map_script shim as stdin. As the user_map_script base is written here, it attempts to map the provided username (pulled from the email) to one in ldap via the ldapsearch command. It then tries to map that to a local linux user in the container, pulled from /etc/passwd. If that fails, it drops down to try and map a user to one in the flat file `/etc/ood/bin/usermap`. If any of the matches succeed the script then simply echos the username to stdout and apache/nginx PUN's take over.

Modifications to this script to suite each environment are expected. 

This process basically confirms the 2 things needed for an authorized and ultimately successful login: 

  1. The email in the OpenIDC response matches the email of a user in LDAP
  2. A local Linux user matches the uid of the ldap user that matched to the OpenIDC provided email 


#### Edit VNC Redirect in Flask App

Currently the Flask app that handles the redirect to a vnc server is very simple. To change where the button redirects to, edit the `var/www/ood/apps/sys/Flask/templates/index.html`, and simply change the href. Expansion and customization of this is also encouraged.

![](https://github.com/mghpcc/ERN-Remote-Scientific-Instrument/blob/main/Screenshot_2022-11-08_14-54-58.png)
