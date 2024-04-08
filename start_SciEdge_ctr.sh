#!/bin/bash

#This is a wrapper to start the pod and containers

SSL_CERT_ROOT_PATH=/etc/letsencrypt

GIT_ROOT=$HOME/SciEdge

podman run --privileged -d --network=host --tz=America/New_York -v $GIT_ROOT/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask -v $SSL_CERT_ROOT_PATH:$SSL_CERT_ROOT_PATH -v $GIT_ROOT/etc/ood:/etc/ood -v $GIT_ROOT/etc/group:/etc/group -v $GIT_ROOT/etc/passwd:/etc/passwd -v /home:/home --userns host --name sciedge_ctr sciedge_image /usr/sbin/init
