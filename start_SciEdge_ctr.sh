#!/bin/bash

#This is a wrapper to start the pod and containers

SSL_CERT_ROOT_PATH=/etc/letsencrypt

GIT_ROOT=$HOME/SciEdge

sudo podman run -d --network=host --tz=America/New_York -v $GIT_ROOT/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask -v $GIT_ROOT/var/www/ood/apps/sys/dashboard/config/locales:/var/www/ood/apps/sys/dashboard/config/locales -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH -v $GIT_ROOT/etc/ood:/etc/ood -v $GIT_ROOT/etc/group:/etc/group -v $GIT_ROOT/etc/passwd:/etc/passwd -v /home:/home --userns host --name SciEdge_ctr SciEdge_image /usr/sbin/init

