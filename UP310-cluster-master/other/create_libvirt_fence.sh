#!/bin/bash
if [ ! -z "$1" ] ; then
	ssh root@f$1 "yum install fence-virt fence-virtd fence-virtd-multicast fence-virtd-libvirt -y"
	ssh root@f$1 "mkdir -p /etc/cluster && wget http://classroom.example.com/cluster/fence_xvm.key -O /etc/cluster/fence_xvm.key && chmod 0600 /etc/cluster/fence_xvm.key && restorecon -Rv /etc/cluster && setfacl -m u:kiosk:r-- /etc/cluster/fence_xvm.key "
	ssh root@f$1 "wget http://classroom.example.com/cluster/fence_virt.conf -O /etc/fence_virt.conf && chmod 0600 /etc/fence_virt.conf && restorecon -Rv /etc/fence_virt.conf "
	ssh root@f$1 "systemctl enable fence_virtd && systemctl start fence_virtd "
fi
