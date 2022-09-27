#!/bin/bash

#This is a wrapper to start the pod and containers

podman pod create --name=ood_pod -p 8080:80 -p 8443:443 

SSL_CERT_ROOT_PATH=/etc/letsencrypt

GIT_ROOT=$HOME/ERN-Remote-Scientific-Instrument

podman run -d --tz=America/New_York -v $GIT_ROOT/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH:Z -v $GIT_ROOT/etc/ood:/etc/ood:Z -v $GIT_ROOT/etc/group:/etc/group:Z -v $GIT_ROOT/etc/passwd:/etc/passwd:Z -v /home:/home:Z --pod=ood_pod --userns=host --name ondemand_ctr ondemand_image /usr/sbin/init
