#!/bin/bash
# Zabbix requested parameter
ZBX_REQ_DATA="$1"
# Zabbix requestes Url (change it according to your situation)
ZBX_REQ_URL="http://www.test.com/nginx_status"

# Get nginx status
if [ -e $PWD/nginx_status ]
then
	rm -f $PWD/nginx_status
fi
wget $ZBX_REQ_URL &> /dev/null
i=1
while read LINE
do
	NGINX_STATS[$i]=$LINE
	i=$(($i+1))
done < /tmp/nginx_status

#Output results according to different requests

case $ZBX_REQ_DATA in
  active_connections)   echo "${NGINX_STATS[1]}" | cut -f3 -d' ';;
  accepted_connections) echo "${NGINX_STATS[3]}" | cut -f1 -d' ';;
  handled_connections)  echo "${NGINX_STATS[3]}" | cut -f2 -d' ';;
  handled_requests)     echo "${NGINX_STATS[3]}" | cut -f3 -d' ';;
  reading)              echo "${NGINX_STATS[4]}" | cut -f2 -d' ';;
  writing)              echo "${NGINX_STATS[4]}" | cut -f4 -d' ';;
  waiting)              echo "${NGINX_STATS[4]}" | cut -f6 -d' ';;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0

