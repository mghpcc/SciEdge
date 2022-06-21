## Podman Containerized Open OnDemand Template

This is a template for spinning up OOD in a container using OpenID connect for SSO authentication to map to a local user from an email. For demo sake, the local user mapping are simplistic but with some additions/tweaks is close to what I use in production for multiple deployments

I have done my best to inline comment in the various custom scripts and config files. As a result this readme is more aimed at what you need to do before hand to deploy this, the various files one needs to know about so changes/customizations can be made and how to build and start the containers and pod.

The container stand-up instructions assume you are working as a local user (not root) and have the root of this repo in `$HOME`.

#### Prerequisits

1. Public IP with DNS
2. Apache server
3. ssl certificate (this example used letsencrypt)
4. local user on hostmachine to run the container rootless
5. OIDC ClientID and Secret from an upstream OpenID Connect IDP like Globus or CiLogon

#### Setup Hosts Apache Config

I have provided example configs in the `etc` dir for both Ubuntu style apache2.conf and RHEL style httpd.

The only changes needed for either should be to sed replace `<hostname>` with your actual hostname. 

You may also need to change the pathing to your hosts ssl keys if not using letsencrypt like I am in this example.

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

To start the pod for the first time, do `./start_ondemand_ctr.sh`

After that, you can restart the pod with `podman pod restart ood_pod`

To get a shell in the container to debug, user `podman exec -it ondemand_ctr bash`

