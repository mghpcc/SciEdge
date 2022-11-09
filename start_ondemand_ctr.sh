#!/bin/bash

#This is a wrapper to start the pod and containers

#podman pod create --name=ood_pod -p 80 -p 443 

SSL_CERT_ROOT_PATH=/etc/letsencrypt

GIT_ROOT=$HOME/ERN-Remote-Scientific-Instrument

#podman run -d  -p 8080:80 -p 8443:443 --tz=America/New_York -v $GIT_ROOT/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH:Z -v $GIT_ROOT/etc/ood:/etc/ood:Z -v $GIT_ROOT/etc/group:/etc/group:Z -v $GIT_ROOT/etc/passwd:/etc/passwd:Z -v /home:/home:Z --userns host --name ondemand_ctr ondemand_image /usr/sbin/init
podman run -d --network=host --tz=America/New_York -v $GIT_ROOT/var/www/ood/apps/sys/Aquilos:/var/www/ood/apps/sys/Aquilos:Z -v $GIT_ROOT/var/www/ood/apps/sys/Relion:/var/www/ood/apps/sys/Relion:Z -v $GIT_ROOT/var/www/ood/apps/sys/EMAN2:/var/www/ood/apps/sys/EMAN2:Z -v $GIT_ROOT/var/www/ood/apps/sys/Cryosparc:/var/www/ood/apps/sys/Cryosparc:Z -v $GIT_ROOT/var/www/ood/apps/sys/Arctica:/var/www/ood/apps/sys/Arctica:Z -v $GIT_ROOT/var/www/ood/apps/sys/dashboard/config/locales:/var/www/ood/apps/sys/dashboard/config/locales:Z -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH:Z -v $GIT_ROOT/etc/ood:/etc/ood:Z -v $GIT_ROOT/etc/group:/etc/group:Z -v $GIT_ROOT/etc/passwd:/etc/passwd:Z -v /home:/home:Z --userns host --name ondemand_ctr ondemand_image /usr/sbin/init

