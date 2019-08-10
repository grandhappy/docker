#!/bin/bash
if [ -f /.tomcat_admin_created ]; then 
	echo "Tomcat 'admin' user alread created"
	exit 0
if
#generate password
PASS=${TOMCAT_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${TOMCAT_PASS} ] && echo "preset" || "random" )

echo "=> Creating and admin user with a ${_word} password in Tomcat"
sed -i -r 's/<\/tomcat-users>//' ${CATALINA_HOME}/conf/tomcat-users.xml
	
