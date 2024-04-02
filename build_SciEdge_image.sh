#!/bin/bash

GIT_ROOT=$HOME/SciEdge


ctr=sciedge_image
buildah_run_command="sudo buildah run --net=host"

sudo buildah from --name $ctr docker://rockylinux:8
$buildah_run_command $ctr -- dnf -y module enable ruby:2.7
$buildah_run_command $ctr -- dnf -y module enable nodejs:14
$buildah_run_command $ctr -- dnf install -y dnf-plugins-core systemd
$buildah_run_command $ctr -- dnf install -y epel-release
$buildah_run_command $ctr -- dnf config-manager --set-enabled powertools
$buildah_run_command $ctr -- yum install -y https://yum.osc.edu/ondemand/2.0/ondemand-release-web-2.0-1.noarch.rpm
$buildah_run_command $ctr -- dnf install -y ondemand vim openssh-server python3 findutils nc
$buildah_run_command $ctr -- dnf install -y mod_auth_openidc
$buildah_run_command $ctr -- dnf install -y mod_authnz_pam mod_proxy_html openldap-clients
sudo buildah run $ctr -- ln -s /usr/bin/python3 /usr/bin/python
$buildah_run_command $ctr -- python -m pip install virtualenv
$buildah_run_command $ctr /bin/bash -c 'curl https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo > /etc/yum.repos.d/turbovnc.repo'
$buildah_run_command $ctr -- dnf install -y turbovnc
sudo buildah run $ctr -- mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.off
sudo buildah run $ctr -- mkdir /var/log/apache_testing
# This section adds the ability to make system users that can login
# for debugging
sudo buildah run $ctr /bin/bash -c 'echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /etc/httpd/conf.modules.d/55-authnz_pam.conf'
sudo buildah run $ctr -- cp /etc/pam.d/sshd /etc/pam.d/ood
sudo buildah run $ctr -- chmod 640 /etc/shadow
sudo buildah run $ctr -- chgrp apache /etc/shadow
# add groupadd and useradd bits here if you want to make hardcoded local users
# end of local linux user bits

sudo buildah run -v $GIT_ROOT/etc/ood:/etc/ood:Z $ctr -- /opt/ood/ood-portal-generator/sbin/update_ood_portal
sudo buildah run -v $GIT_ROOT/etc/ood:/etc/ood:Z $ctr -- mv /etc/httpd/conf.d/ood-portal.conf.new /etc/httpd/conf.d/ood-portal.conf

# sample flask app not needed here on the prod machine
#sudo buildah run -v $GIT_ROOT/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z $ctr -- bash -c 'cd /var/www/ood/apps/sys/Flask && ./setup.sh'

sudo buildah run $ctr -- systemctl enable httpd


sudo buildah commit $ctr $ctr

