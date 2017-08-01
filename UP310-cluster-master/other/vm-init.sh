#!/bin/bash


#===hostname===
hostname > /etc/hostname

#====selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#===time zone
timedatectl set-timezone Asia/Shanghai

#==== default gw
echo 'GATEWAY=192.168.0.10' >> /etc/sysconfig/network-scripts/ifcfg-eth1

#=== disable eth0
sed -i 's/ONBOOT=yes/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-eth0

#=== disable NM===
systemctl  disable NetworkManager

#==== hosts
sed -i '/172.25.105.83.*/d' /etc/hosts

cat >> /etc/hosts << ENDF
192.168.0.10 servera.pod0.example.com servera
192.168.0.11 serverb.pod0.example.com serverb
192.168.0.12 serverc.pod0.example.com serverc
192.168.0.13 serverd.pod0.example.com serverd
192.168.0.14 servere.pod0.example.com servere
192.168.0.15 serverf.pod0.example.com serverf
192.168.0.16 serverg.pod0.example.com serverg
192.168.0.17 serverh.pod0.example.com serverh
192.168.0.18 serveri.pod0.example.com serveri
192.168.0.19 serverj.pod0.example.com serverj
ENDF

#====disable ssh dns
echo "UseDNS no" >> /etc/ssh/sshd_config

reboot



