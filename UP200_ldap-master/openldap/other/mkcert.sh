#!/bin/bash

myhostname="$(hostname)"
ca_name="ca.uplooking.com"
ca_key_pass="uplooking"
ca_dir="/etc/pki/CA"
openssl_conf_file="/etc/pki/tls/openssl.cnf"

hostname | grep -q '^localhost$'
[ $? -eq 0 ] && echo "Don't use localhost , reset your hostname." && exit

init_ca_dir()
{
	mkdir /etc/pki/CA/{certs,crl,newcerts} -p
	chmod 0700 /etc/pki/CA/
	chmod 0700 /etc/pki/CA/{certs,crl,newcerts}
	touch /etc/pki/CA/index.txt
	echo 01 > /etc/pki/CA/serial
}

init_ca_cnf()
{
	sed -i 's%^certificate.*%certificate = $dir/my-ca.crt%' $openssl_conf_file
	sed -i 's%^crl\>.*%crl = $dir/my-ca.crl%' $openssl_conf_file
	sed -i 's%^private_key\>.*%private_key = $dir/private/my-ca.key%' $openssl_conf_file
	sed -i 's%^countryName_default\>.*%countryName_default = CN%' $openssl_conf_file
	sed -i 's%^#stateOrProvinceName_default%stateOrProvinceName_default%' $openssl_conf_file
	sed -i 's%^stateOrProvinceName_default\>.*%stateOrProvinceName_default = shanghai%' $openssl_conf_file
	sed -i 's%^localityName_default\>.*%localityName_default = shanghai%' $openssl_conf_file
	sed -i 's%^0.organizationName_default\>.*%0.organizationName_default = uplooking sh. Company Ltd%' $openssl_conf_file
	sed -i 's%^#organizationalUnitName_default%organizationalUnitName_default%' $openssl_conf_file
	sed -i 's%^organizationalUnitName_default\>.*%organizationalUnitName_default = Certificate  Information technology%' $openssl_conf_file
	grep -q '^commonName_default\>' $openssl_conf_file  && sed -i "s%^commonName_default\>.*%commonName_default = $ca_name%" $openssl_conf_file || sed -i "152acommonName_default = $ca_name" $openssl_conf_file
}

create_ca_keys()
{
	echo "create the keys: my-ca.key,my-ca.crt"
	echo "the keys will save in : /etc/pki/CA/ and /etc/pki/CA/private/"
	cd /etc/pki/CA/
	( umask 077 ; openssl genrsa -out private/my-ca.key  -passout pass:$ca_key_pass -des3 2048 &> /dev/null )
	openssl req -new -x509 -key private/my-ca.key  -days 365 -batch -passin pass:$ca_key_pass > my-ca.crt
	echo "create finished , please check."
	exit 0
}


check_ca_keys()
{
	if [ ! -f /etc/pki/CA/private/my-ca.key -o ! -f /etc/pki/CA/my-ca.crt ]
	then
		echo "you should create ca keys first."
		echo "please run : bash $(basename $0) --create-ca-keys"
		exit 88
	fi
}

init_ldap_cnf()
{
	sed -i "s%^commonName_default\>.*%commonName_default = $myhostname%" $openssl_conf_file
}

create_ldap_key()
{
	echo "create the keys: ldap_server.key,ldap_server.crt"
        echo "the keys will save in : /etc/pki/CA/"
	cd /etc/pki/CA/
	openssl genrsa 1024 > ldap_server.key 2> /dev/null
	openssl  req -new -key ldap_server.key -out ldap_server.csr -batch &> /dev/null
	openssl  ca -config /etc/pki/tls/openssl.cnf  -batch -passin pass:$ca_key_pass -out ldap_server.crt -infiles ldap_server.csr &> /dev/null
	echo "create finished , please check."
	exit 0
}

myhelp()
{
	cat << ENDF
usage: bash $(basename $0) [option]
option:
--help			show help
--create-ca-keys	create keys for CA
--create-ldap-keys	create keys for ldap server(you should create ca keys first)
--del-keys		delete keys for CA & ldap
ENDF

	exit 8
}

del-keys()
{
	find /etc/pki/CA/ -type f -exec rm -f {}  \;
}


case $1 in
	--del-keys)
	del-keys;
	;;
	--create-ca-keys)
	[ ! -f $openssl_conf_file.default ] && /bin/cp $openssl_conf_file $openssl_conf_file.default
	init_ca_dir;
	init_ca_cnf;
	create_ca_keys;
	;;
	--create-ldap-keys)
	check_ca_keys;
	init_ldap_cnf;
	create_ldap_key;
	;;
	*)
	myhelp
	;;
esac
	





