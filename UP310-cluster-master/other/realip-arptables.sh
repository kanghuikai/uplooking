#!/bin/bash
VIP=192.168.0.100
RIP=192.168.0.x
DGW=172.25.0.254
DGWMAC=52:54:00:00:00:fe

arptables -F
arptables -A IN -d $VIP -j DROP
arptables -A OUT -s $VIP -j mangle --mangle-ip-s $RIP
/sbin/ifconfig eth0:1 $VIP netmask 255.255.255.0 up

arp -s $DGW  $DGWMAC
/sbin/route add default gw $DGW

#/sbin/route add -host $VIP dev eth0:1
#sysctl -p
#end
