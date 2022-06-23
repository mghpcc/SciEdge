#!/bin/bash

ctr=ondemand_image

buildah from --name $ctr docker://rockylinux:latest

buildah run $ctr -- dnf -y module enable ruby:2.7
buildah run $ctr -- dnf -y module enable nodejs:12
buildah run $ctr -- dnf install -y dnf-plugins-core
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

# This is needed to allow the local user "testuser" to map
buildah run $ctr /bin/bash -c 'echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /etc/httpd/conf.modules.d/55-authnz_pam.conf'
buildah run $ctr -- cp /etc/pam.d/sshd /etc/pam.d/ood
buildah run $ctr -- chmod 640 /etc/shadow
buildah run $ctr -- chgrp apache /etc/shadow
# end of local linux user bits

# This creates a local user for the demo, better to mount home and setup ldap inside to map users
buildah run $ctr -- groupadd testuser
buildah run $ctr -- useradd -g testuser testuser


buildah run -v $HOME/podman-ood/etc/ood:/etc/ood:Z $ctr -- /opt/ood/ood-portal-generator/sbin/update_ood_portal
buildah run -v $HOME/podman-ood/etc/ood:/etc/ood:Z $ctr -- mv /etc/httpd/conf.d/ood-portal.conf.new /etc/httpd/conf.d/ood-portal.conf


buildah run -v $HOME/podman-ood/var/www/ood/apps/sys/Flask:/var/www/ood/apps/sys/Flask:Z $ctr -- bash -c 'cd /var/www/ood/apps/sys/Flask && ./setup.sh'

# It is bad form to run chained commands in an entrypoint but ideally this is how the startup process would go
#buildah config --entrypoint "/opt/ood/ood-portal-generator/sbin/update_ood_portal && /usr/sbin/htcacheclean -P /run/httpd/htcacheclean/pid -d 15 -p /var/cache/httpd/proxy -l 100M &  /usr/sbin/httpd -DFOREGROUND" $ctr


buildah config --entrypoint "/usr/sbin/httpd -DFOREGROUND" $ctr

# this is for building a debug version, this allows you to `podman exec -it $ctr bash` in.
#buildah config --entrypoint "sleep infinity" $ctr

buildah commit $ctr $ctr
