#!/bin/bash

INPUT=$(echo $1 | sed -r 's/(.*)%40/\1@/')
USERNAME=$(echo $INPUT | awk -F@ '{print $1}')

if [ $? -eq 0  ]; then

	#Can check ldap here if ldap is configured
	# LDAPUSER=$(ldapsearch -x uid=$USERNAME | grep "uid:" | awk '{print $2}') 
	# test this against local users or usermap
	# if true, return mapped username with $(echo "USERNAME")

	for line in $(cat /etc/ood/bin/usermap); do
		email=$(echo $line | awk -F, '{print $1}')
		local_user=$(echo $line | awk -F, '{print $2}')

		if [[ "$email" == "$INPUT" ]]; then
			echo "$local_user"
			exit 0
		fi
	done

else
        echo "$1,$INPUT,$USERNAME" >> /var/log/apache_testing/output
        exit 1
fi

