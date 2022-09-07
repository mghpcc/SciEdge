#!/bin/bash

ctr=ondemand_image

buildah from --name $ctr docker://rockylinux:8

buildah run $ctr -- dnf -y module enable ruby:2.7
buildah run $ctr -- dnf -y module enable nodejs:12
buildah run $ctr -- dnf install -y dnf-plugins-core systemd
buildah run $ctr -- dnf install -y epel-release
buildah run $ctr -- dnf config-manager --set-enabled powertools
buildah run $ctr -- yum install -y https://yum.osc.edu/ondemand/2.0/ondemand-release-web-2.0-1.noarch.rpm
buildah run $ctr -- dnf install -y ondemand vim openssh-server python3 findutils nc 
buildah run $ctr -- dnf install -y mod_auth_openidc
buildah run $ctr -- dnf install -y mod_authnz_pam openldap-clients
buildah run $ctr -- ln -s /usr/bin/python3 /usr/bin/python
buildah run $ctr -- python -m pip install virtualenv

buildah run $ctr /bin/bash -c 'curl https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo > /etc/yum.repos.d/turbovnc.repo'
buildah run $ctr -- dnf install -y turbovnc

buildah run $ctr -- mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.off
buildah run $ctr -- mkdir /var/log/apache_testing

# This section adds the ability to make system users that can login
# for debugging 
buildah run $ctr /bin/bash -c 'echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /etc/httpd/conf.modules.d/55-authnz_pam.conf'
buildah run $ctr -- cp /etc/pam.d/sshd /etc/pam.d/ood
buildah run $ctr -- chmod 640 /etc/shadow
buildah run $ctr -- chgrp apache /etc/shadow
# add groupadd and useradd bits here if you want to make hardcoded local users
# end of local linux user bits



buildah run -v $HOME/podman-ood/etc/ood:/etc/ood:Z $ctr -- /opt/ood/ood-portal-generator/sbin/update_ood_portal
buildah run -v $HOME/podman-ood/etc/ood:/etc/ood:Z $ctr -- mv /etc/httpd/conf.d/ood-portal.conf.new /etc/httpd/conf.d/ood-portal.conf


buildah run -v $HOME/podman-ood/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z $ctr -- bash -c 'cd /var/www/ood/apps/sys/Flask && ./setup.sh'

buildah run $ctr -- systemctl enable httpd


buildah commit $ctr $ctr
