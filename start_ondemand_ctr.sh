#!/bin/bash

#This is a wrapper to start the pod and containers

podman pod create --name=ood_pod -p 8080:80 -p 8443:443 

SSL_CERT_ROOT_PATH=/etc/letsencrypt


# This is for starting the demo vnc container
#podman pod create --name=test -p 5901:5901 -p 6901:6901 -p 8080:80 -p 8443:443 
#podman run -d --pod=test ubuntu-vnc-xfce

podman run -d --tz=America/New_York -v $HOME/podman-ood/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH -v $HOME/podman-ood/etc/ood:/etc/ood:Z --pod=ood_pod --name ondemand_ctr ondemand_image

