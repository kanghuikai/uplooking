
[toc]

# keepalived简介

## keepalived历史简介

keepalived是一个使用Ｃ语言写的路由软件，其主要功能是在linux平台上简单高效的实现一个高可用与负载均衡架构，负载均衡主要依赖于linux上知名的ipvs模块，而高可用部分主要依赖于vrrp协议。



## keepalived优点

* 部署及使用简单
* 功能强大，实现高可用与负载均衡
* 非常轻量级
* 高效切换
* 自带报警机制


# keepalived原理


## keepalived功能模块

### core模块

keepalived的核心，复杂主进程的启动和维护，全局配置文件的加载解析等

### check模块

负责healthchecker(健康检查)

### ipvs 模块（负载均衡时使用）

IPVS (IP Virtual Server)是linux内核中实现的负载均衡模块，主要实现４层负载均衡，能够接收tcp/udp请求，并将这些请求以负载均衡方式分发至其他主机。

### vrrp协议

虚拟路由冗余协议(Virtual Router Redundancy Protocol，简称VRRP)是由IETF提出的解决局域网中配置静态网关出现单点失效现象的路由协议。vrrp协议可以从一组路由器中选举出一台主路由器，关联至虚拟路由作为默认网关，主路由失效时，通过再次选举，将备用路由器关联至虚拟路由作为默认网关。

## keepalived工作过程

keepalived启动后，核心模块core会加载配置文件并启动相关keepalived进程，根据配置文件中vrrp定义，在多台keepalived服务器中选举出主服务器，主服务器会绑定虚拟ＩＰ，接收并处理用户请求，备用机keepalived进程会周期化检测主服务器状态，一旦发现主服务器状态不正确，则会抢占虚拟ＩＰ，接手主服务器工作，处理用户请求。

> 如果主服务器对外状态正常，内部与备用机链路出问题，以至备用机尝试抢占主服务器工作，则会出现冲突。该问题在高可用集群中称之为脑裂，此问题keepalived暂时未有比较完善的解决方法。

# keepalived配置简介

## 安装keepalived

RHEL发行版本自带keepalived安装包，可以直接通过yum方式安装。

```shell
[root@lvs1-f0 ~]# yum install keepalived -y
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package keepalived.x86_64 0:1.2.7-3.el6 will be installed
-->
 Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================
 Package                   Arch                  Version                       Repository         Size
=======================================================================================================
Installing:
 keepalived                x86_64                1.2.7-3.el6                   LB                174 k

Transaction Summary
=======================================================================================================
Install       1 Package(s)

Total download size: 174 k
Installed size: 526 k
Downloading Packages:
keepalived-1.2.7-3.el6.x86_64.rpm                                               | 174 kB     00:00     
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : keepalived-1.2.7-3.el6.x86_64                                                       1/1 
HA/productid                                                                    | 1.7 kB     00:00     
LB/productid                                                                    | 1.7 kB     00:00     
server/productid                                                                | 1.7 kB     00:00     
  Verifying  : keepalived-1.2.7-3.el6.x86_64                                                       1/1 

Installed:
  keepalived.x86_64 0:1.2.7-3.el6                                                                      

Complete!
```

查看包文件

```shell
[root@lvs2-f0 ~]# rpm -ql keepalived
/etc/keepalived
/etc/keepalived/keepalived.conf
/etc/rc.d/init.d/keepalived
/etc/sysconfig/keepalived
/usr/bin/genhash
/usr/sbin/keepalived
/usr/share/doc/keepalived-1.2.7
/usr/share/doc/keepalived-1.2.7/AUTHOR
/usr/share/doc/keepalived-1.2.7/CONTRIBUTORS
/usr/share/doc/keepalived-1.2.7/COPYING
/usr/share/doc/keepalived-1.2.7/ChangeLog
/usr/share/doc/keepalived-1.2.7/README
/usr/share/doc/keepalived-1.2.7/TODO
/usr/share/doc/keepalived-1.2.7/keepalived.conf.HTTP_GET.port
/usr/share/doc/keepalived-1.2.7/keepalived.conf.IPv6
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SMTP_CHECK
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SSL_GET
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SYNOPSIS
/usr/share/doc/keepalived-1.2.7/keepalived.conf.fwmark
/usr/share/doc/keepalived-1.2.7/keepalived.conf.inhibit
/usr/share/doc/keepalived-1.2.7/keepalived.conf.misc_check
/usr/share/doc/keepalived-1.2.7/keepalived.conf.misc_check_arg
/usr/share/doc/keepalived-1.2.7/keepalived.conf.quorum
/usr/share/doc/keepalived-1.2.7/keepalived.conf.sample
/usr/share/doc/keepalived-1.2.7/keepalived.conf.status_code
/usr/share/doc/keepalived-1.2.7/keepalived.conf.track_interface
/usr/share/doc/keepalived-1.2.7/keepalived.conf.virtual_server_group
/usr/share/doc/keepalived-1.2.7/keepalived.conf.virtualhost
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.localcheck
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.lvs_syncd
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.routes
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.scripts
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.static_ipaddress
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.sync
/usr/share/man/man1/genhash.1.gz
/usr/share/man/man5/keepalived.conf.5.gz
/usr/share/man/man8/keepalived.8.gz
/usr/share/snmp/mibs/KEEPALIVED-MIB.txt
```

包文件简介

主配置文件

> /etc/keepalived/keepalived.conf

服务脚本

> /etc/rc.d/init.d/keepalived

程序启动命令

> /usr/sbin/keepalived

相关帮助文件 

> /usr/share/doc/keepalived-1.2.7
/usr/share/doc/keepalived-1.2.7/AUTHOR
/usr/share/doc/keepalived-1.2.7/CONTRIBUTORS
/usr/share/doc/keepalived-1.2.7/COPYING
/usr/share/doc/keepalived-1.2.7/ChangeLog
/usr/share/doc/keepalived-1.2.7/README
/usr/share/doc/keepalived-1.2.7/TODO
/usr/share/doc/keepalived-1.2.7/keepalived.conf.HTTP_GET.port
/usr/share/doc/keepalived-1.2.7/keepalived.conf.IPv6
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SMTP_CHECK
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SSL_GET
/usr/share/doc/keepalived-1.2.7/keepalived.conf.SYNOPSIS
/usr/share/doc/keepalived-1.2.7/keepalived.conf.fwmark
/usr/share/doc/keepalived-1.2.7/keepalived.conf.inhibit
/usr/share/doc/keepalived-1.2.7/keepalived.conf.misc_check
/usr/share/doc/keepalived-1.2.7/keepalived.conf.misc_check_arg
/usr/share/doc/keepalived-1.2.7/keepalived.conf.quorum
/usr/share/doc/keepalived-1.2.7/keepalived.conf.sample
/usr/share/doc/keepalived-1.2.7/keepalived.conf.status_code
/usr/share/doc/keepalived-1.2.7/keepalived.conf.track_interface
/usr/share/doc/keepalived-1.2.7/keepalived.conf.virtual_server_group
/usr/share/doc/keepalived-1.2.7/keepalived.conf.virtualhost
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.localcheck
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.lvs_syncd
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.routes
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.scripts
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.static_ipaddress
/usr/share/doc/keepalived-1.2.7/keepalived.conf.vrrp.sync
/usr/share/man/man1/genhash.1.gz
/usr/share/man/man5/keepalived.conf.5.gz
/usr/share/man/man8/keepalived.8.gz

snmp监控定义文件 

> /usr/share/snmp/mibs/KEEPALIVED-MIB.txt

## keepalived配置文件简介

全局配置

global_defs {
    notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc  
      }
 notification_email_from Alexandre.Cassen@firewall.loc {
      smtp_server 192.168.200.1
     smtp_connect_timeout 30
     router_id LVS_DEVEL 
}


> notification_email 故障发生时给谁发邮件通知。
notification_email_from 通知邮件从哪个地址发出。
smpt_server 通知邮件的smtp地址。
smtp_connect_timeout 连接smtp服务器的超时时间。
enable_traps 开启SNMP陷阱（Simple Network Management Protocol）。
router_id 标识本节点的字条串，通常为hostname，但不一定非得是hostname。故障发生时，邮件通知会用到。

vrrp实例配置

 vrrp_instance VI_1 {
      state MASTER
      interface eth0
      virtual_router_id 51 
      priority 100 
      advert_int 1 
      authentication {
          auth_type PASS  
           auth_pass 1111   
   }
      virtual_ipaddress { 
          192.168.200.100
          192.168.200.101
          192.168.200.102
      }
  }


> state 可以是MASTER或BACKUP
> virtual_router_id 取值在0-255之间，用来区分多个instance的VRRP组播。
> priority 用来选举master的
> advert_int 发VRRP包的时间间隔
> authentication 认证区域
> virtual_ipaddress vip
> 

vrrp脚本

vrrp_script check_httpd {
	script "/bin/check_httpd.sh"
	interval 5
	weight -50
}

> script 自定义脚本
> interval 间隔
> weight  脚本运行错误后减去的优先值

lvs配置

virtual_server 192.168.200.100 443 {  
      delay_loop 6  
      lb_algo rr    
      lb_kind NAT   
      persistence_timeout 50 
      protocol TCP  
      real_server 192.168.201.100 80 { 
          weight 1  
          TCP_CHECK {  
              connect_timeout 3 
              nb_get_retry 3 
              delay_before_retry 3 
          }
      }
  }

> delay_loop 延迟轮询时间
> lb_algo 后端调试算法，推荐wlc
> lb_kind LVS调度类型NAT/DR/TUN
> real_server 真正提供服务的服务器
> weight 权重。
> digest/status_code 分别表示用genhash算出的结果和http状态码。
> connect_timeout,nb_get_retry,delay_before_retry分别表示超时时长、重试次数，下次重试的时间延迟。



# 配置基于keepalived的apache HA

本例中使用lvs1与lvs2做ＨＡ

## 初始化环境

* 主机名配置
	* 案例中实验机分别为lvs1-f0.example.com , lvs2-f0.example.com
	* 实验过程其他人请跟据实际状况更改主机名
* 网络配置
	* 停止NetworkManager服务，以保证网络稳定性
	* 配置相关静态ＩＰ
	* 实验机有３块网卡，eth0为公网网卡，可在不同物理机上相互访问，ＨＡ案例暂时只需要一块网卡，所以配置eth0，并关闭eth1,eth2
	* 案例中lvs1的eth0网卡IP为172.25.0.14，　lvs2的eth0网卡IP为172.25.0.15
* 安装源配置
* 其他配置

##### 启动虚拟机

```shell
[kiosk@foundation0 Desktop]$ rht-vmctl  start lvs1
Downloading virtual machine definition file for lvs1.
######################################################################## 100.0%
Downloading virtual machine disk image up310-lvs1-vda.qcow2
######################################################################## 100.0%
Creating virtual machine disk overlay for up310-lvs1-vda.qcow2
Downloading virtual machine disk image up310-lvs1-vdb.qcow2
######################################################################## 100.0%
Creating virtual machine disk overlay for up310-lvs1-vdb.qcow2
Starting lvs1.
[kiosk@foundation0 Desktop]$ rht-vmctl  start lvs2
Downloading virtual machine definition file for lvs2.
######################################################################## 100.0%
Downloading virtual machine disk image up310-lvs2-vda.qcow2
######################################################################## 100.0%
Creating virtual machine disk overlay for up310-lvs2-vda.qcow2
Downloading virtual machine disk image up310-lvs2-vdb.qcow2
######################################################################## 100.0%
Creating virtual machine disk overlay for up310-lvs2-vdb.qcow2
Starting lvs2.
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.14
Warning: Permanently added '172.25.0.10' (RSA) to the list of known hosts.
Last login: Mon Nov 14 14:41:22 2016 from 172.25.0.250
```

##### lvs1环境初始化配置

```shell
[root@rhel6 ~]# vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=lvs1-f0.example.com
[root@rhel6 ~]# service NetworkManager stop
Stopping NetworkManager daemon:                            [  OK  ]
[root@rhel6 ~]# chkconfig NetworkManager off
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"

IPADDR=172.25.0.14
NETMASK=255.255.255.0
GATEWAY=172.25.0.254
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth1"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"
[root@rhel6 ~]# vi /etc/yum.repos.d/cluster.repo
[HA]
name=HA
baseurl=http://172.25.254.254/content/rhel6.5/x86_64/dvd/HighAvailability
enabled=1
gpgcheck=0
[LB]
name=LB
baseurl=http://172.25.254.254/content/rhel6.5/x86_64/dvd/LoadBalancer
enabled=1
gpgcheck=0
[root@rhel6 ~]# yum makecache
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
HA                                                                              | 3.9 kB     00:00     
HA/group_gz                                                                     | 4.0 kB     00:00     
HA/filelists_db                                                                 |  38 kB     00:00     
HA/primary_db                                                                   |  43 kB     00:00     
HA/other_db                                                                     |  32 kB     00:00     
LB                                                                              | 3.9 kB     00:00     
LB/group_gz                                                                     | 2.1 kB     00:00     
LB/filelists_db                                                                 | 3.9 kB     00:00     
LB/primary_db                                                                   | 7.0 kB     00:00     
LB/other_db                                                                     | 2.8 kB     00:00     
server                                                                          | 3.9 kB     00:00     
server/group_gz                                                                 | 204 kB     00:00     
server/filelists_db                                                             | 3.8 MB     00:00     
server/primary_db                                                               | 3.1 MB     00:00     
server/other_db                                                                 | 1.6 MB     00:00     
Metadata Cache Created
[root@rhel6 ~]# iptables -F
[root@rhel6 ~]# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@rhel6 ~]# vi /etc/selinux/config 
SELINUX=disabled
[root@rhel6 ~]# reboot
```

##### lvs2环境初始化配置

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.15
Warning: Permanently added '172.25.0.15' (RSA) to the list of known hosts.
Last login: Mon Nov 14 14:41:22 2016 from 172.25.0.250

[root@rhel6 ~]# vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=lvs2-f0.example.com
[root@rhel6 ~]# service NetworkManager stop
Stopping NetworkManager daemon:                            [  OK  ]
[root@rhel6 ~]# chkconfig NetworkManager off
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"

IPADDR=172.25.0.15
NETMASK=255.255.255.0
GATEWAY=172.25.0.254
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth1"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"
[root@rhel6 ~]# vi /etc/yum.repos.d/cluster.repo
[HA]
name=HA
baseurl=http://172.25.254.254/content/rhel6.5/x86_64/dvd/HighAvailability
enabled=1
gpgcheck=0
[LB]
name=LB
baseurl=http://172.25.254.254/content/rhel6.5/x86_64/dvd/LoadBalancer
enabled=1
gpgcheck=0
[root@rhel6 ~]# yum makecache
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
HA                                                                              | 3.9 kB     00:00     
HA/group_gz                                                                     | 4.0 kB     00:00     
HA/filelists_db                                                                 |  38 kB     00:00     
HA/primary_db                                                                   |  43 kB     00:00     
HA/other_db                                                                     |  32 kB     00:00     
LB                                                                              | 3.9 kB     00:00     
LB/group_gz                                                                     | 2.1 kB     00:00     
LB/filelists_db                                                                 | 3.9 kB     00:00     
LB/primary_db                                                                   | 7.0 kB     00:00     
LB/other_db                                                                     | 2.8 kB     00:00     
server                                                                          | 3.9 kB     00:00     
server/group_gz                                                                 | 204 kB     00:00     
server/filelists_db                                                             | 3.8 MB     00:00     
server/primary_db                                                               | 3.1 MB     00:00     
server/other_db                                                                 | 1.6 MB     00:00     
Metadata Cache Created
[root@rhel6 ~]# iptables -F
[root@rhel6 ~]# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@rhel6 ~]# vi /etc/selinux/config 
SELINUX=disabled
[root@rhel6 ~]# reboot
```

##### 配置lvs1为主服务器

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.14
Last login: Mon Nov 14 14:41:32 2016 from 172.25.0.250
[root@lvs1-f0 ~]# yum install keepalived -y
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package keepalived.x86_64 0:1.2.7-3.el6 will be installed
-->
 Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================
 Package                   Arch                  Version                       Repository         Size
=======================================================================================================
Installing:
 keepalived                x86_64                1.2.7-3.el6                   LB                174 k

Transaction Summary
=======================================================================================================
Install       1 Package(s)

Total download size: 174 k
Installed size: 526 k
Downloading Packages:
keepalived-1.2.7-3.el6.x86_64.rpm                                               | 174 kB     00:00     
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : keepalived-1.2.7-3.el6.x86_64                                                       1/1 
HA/productid                                                                    | 1.7 kB     00:00     
LB/productid                                                                    | 1.7 kB     00:00     
server/productid                                                                | 1.7 kB     00:00     
  Verifying  : keepalived-1.2.7-3.el6.x86_64                                                       1/1 

Installed:
  keepalived.x86_64 0:1.2.7-3.el6                                                                      

Complete!
[root@lvs1-f0 ~]# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
[root@lvs1-f0 ~]# vi /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
        root@classroom.example.com
   }
   notification_email_from root@lvs1-f0.example.com
   smtp_server 172.25.254.254
   smtp_connect_timeout 30
   router_id lvs1-f0.example.com
}

vrrp_script check_httpd {
	script "/bin/check_httpd.sh"
	interval 5
	weight -50
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 100
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        172.25.0.100/24
    }
    track_script {
	check_httpd
    }
}

[root@lvs1-f0 ~]# vi /bin/check_httpd.sh
#!/bin/bash

/etc/init.d/httpd status &> /dev/null

if [ $? -ne 0 ]
then
        /etc/init.d/httpd start || exit 1
fi

exit 0
[root@lvs1-f0 ~]# chmod a+x /bin/check_httpd.sh 
[root@lvs1-f0 ~]# echo lvs1-f0.example.com > /var/www/html/index.html
[root@lvs1-f0 ~]# service keepalived start
Starting keepalived:                                       [  OK  ]
```

检查vip与脚本是否已经生效

```shell
[root@lvs1-f0 ~]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:00:00:0a brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.14/24 brd 172.25.0.255 scope global eth0
    inet 172.25.0.100/24 scope global secondary eth0
    inet6 fe80::5054:ff:fe00:a/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:01:00:0a brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:02:00:0a brd ff:ff:ff:ff:ff:ff
[root@lvs1-f0 ~]# service httpd status
httpd (pid  1793) is running...
```

测试web访问

```shell
[root@foundation0 ~]# links http://172.25.0.100 -dump 1
   lvs1-f0.example.com
```


配置lvs2为从服务器

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.15
Last login: Mon Nov 14 14:50:47 2016 from 172.25.0.250
[root@lvs2-f0 ~]# yum install keepalived -y
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package keepalived.x86_64 0:1.2.7-3.el6 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================
 Package                   Arch                  Version                       Repository         Size
=======================================================================================================
Installing:
 keepalived                x86_64                1.2.7-3.el6                   LB                174 k

Transaction Summary
=======================================================================================================
Install       1 Package(s)

Total download size: 174 k
Installed size: 526 k
Downloading Packages:
keepalived-1.2.7-3.el6.x86_64.rpm                                               | 174 kB     00:00     
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : keepalived-1.2.7-3.el6.x86_64                                                       1/1 
HA/productid                                                                    | 1.7 kB     00:00     
LB/productid                                                                    | 1.7 kB     00:00     
server/productid                                                                | 1.7 kB     00:00     
  Verifying  : keepalived-1.2.7-3.el6.x86_64                                                       1/1 

Installed:
  keepalived.x86_64 0:1.2.7-3.el6                                                                      

Complete!

[root@lvs2-f0 ~]# vi /etc/keepalived/keepalived.conf 
! Configuration File for keepalived

global_defs {
   notification_email {
        root@classroom.example.com
   }
   notification_email_from root@lvs2-f0.example.com
   smtp_server 172.25.254.254
   smtp_connect_timeout 30
   router_id lvs2-f0.example.com
}

vrrp_script check_httpd {
        script "/bin/check_httpd.sh"
        interval 5
        weight -50
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 100
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        172.25.0.100/24
    }
    track_script {
        check_httpd
    }
}


[root@lvs2-f0 ~]# vi /bin/check_httpd.sh
#!/bin/bash

/etc/init.d/httpd status &> /dev/null

if [ $? -ne 0 ]
then
	/etc/init.d/httpd start || exit 1
fi

exit 0
[root@lvs2-f0 ~]# chmod a+x  /bin/check_httpd.sh
[root@lvs2-f0 ~]# service keepalived start
Starting keepalived:                                       [  OK  ]
[root@lvs2-f0 ~]# echo lvs2-f0.example.com > /var/www/html/index.html
[root@lvs2-f0 ~]# service keepalived start
Starting keepalived:                                       [  OK  ]
```

检查一下ip，目前vip在主服务器，从服务器并不会有vip

```shell
[root@lvs2-f0 ~]# ip add show 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:00:00:0b brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.15/24 brd 172.25.0.255 scope global eth0
    inet6 fe80::5054:ff:fe00:b/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:01:00:0b brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:02:00:0b brd ff:ff:ff:ff:ff:ff

```

停止lvs1以便测试高可用

```shell
[kiosk@foundation0 Desktop]$ rht-vmctl  poweroff lvs1
Powering off lvs1.
osk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   lvs2-f0.example.com

```

登录lvs2查看vip绑定

```shell
[root@lvs2-f0 ~]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:00:00:0f brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.15/24 brd 172.25.0.255 scope global eth0
    inet 172.25.0.100/24 scope global secondary eth0
    inet6 fe80::5054:ff:fe00:f/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:01:00:0f brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:02:00:0f brd ff:ff:ff:ff:ff:ff
```

启动lvs1测试是否会自动回切服务

```shell
[kiosk@foundation0 Desktop]$  rht-vmctl  start lvs1
Starting lvs1.

[kiosk@foundation0 Desktop]$ ssh root@172.25.0.14
Last login: Mon Nov 14 15:40:38 2016 from 172.25.0.250
[root@lvs1-f0 ~]# service keepalived start
Starting keepalived:                                       [  OK  ]

[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   lvs1-f0.example.com
```

# 配置keepalived+lvs(NAT方式)

本案例使用lvs1,lvs2做为分发设备，vip为172.25.0.100/24绑定于eth0接口，dip为192.168.122.254/24绑定于eth2接口。node1,node2为Server节点。

> 配置之前请停止lvs1,lvs2上的httpd服务，以防止前一实验配置与当前实验配置冲突。

环境初始化

* 除了eth0以外，分发设备再配置eth2做为内网网卡
* 分发设备安装ipvsadm包
* 分发设备打开ip_forward转发参数
* Servera节点关闭eth0,打开eth2，并配置dip为网关
* Server节点启动web服务

lvs1初始化配置

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.14
Last login: Mon Nov 14 15:45:51 2016 from 172.25.0.250
[root@lvs1-f0 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2 
DEVICE=eth2
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"

IPADDR=192.168.122.44
NETMASK=255.255.255.0
[root@lvs1-f0
 ~]# service network restart
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:  Determining if ip address 172.25.0.14 is already in use for device eth0...
                                                           [  OK  ]
Bringing up interface eth2:  Determining if ip address 192.168.122.44 is already in use for device eth2...
                                                           [  OK  ]
[root@lvs1-f0 ~]# yum install ipvsadm -y
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package ipvsadm.x86_64 0:1.26-2.el6 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================
 Package                 Arch                   Version                       Repository          Size
=======================================================================================================
Installing:
 ipvsadm                 x86_64                 1.26-2.el6                    LB                  41 k

Transaction Summary
=======================================================================================================
Install       1 Package(s)

Total download size: 41 k
Installed size: 78 k
Downloading Packages:
ipvsadm-1.26-2.el6.x86_64.rpm                                                   |  41 kB     00:00     
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : ipvsadm-1.26-2.el6.x86_64                                                           1/1 
  Verifying  : ipvsadm-1.26-2.el6.x86_64                                                           1/1 

Installed:
  ipvsadm.x86_64 0:1.26-2.el6                                                                          

Complete!

[root@lvs1-f0 ~]# vi /etc/sysctl.conf 
net.ipv4.ip_forward = 1
[root@lvs1-f0 ~]# sysctl  -p
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
error: "net.bridge.bridge-nf-call-arptables" is an unknown key
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
```

lvs2初始化配置

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.15
Last login: Mon Nov 14 15:52:18 2016 from 172.25.0.250
[root@lvs2-f0 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2 
DEVICE=eth2
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"
IPADDR=192.168.122.45
NETMASK=255.255.255.0
[root@lvs2-f0 ~]# service network restart 
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:  Determining if ip address 172.25.0.15 is already in use for device eth0...
                                                           [  OK  ]
Bringing up interface eth2:  Determining if ip address 192.168.122.45 is already in use for device eth2...
                                                           [  OK  ]
[root@lvs2-f0 ~]# vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
[root@lvs1-f0 ~]# sysctl  -p
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
error: "net.bridge.bridge-nf-call-arptables" is an unknown key
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

```

初始化并配置node1

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.10
Last login: Thu Jul  2 16:02:25 2015 from 172.25.0.250
[root@rhel6 ~]# vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=node1-f0.example.com
[root@rhel6 ~]# service NetworkManager stop
Stopping NetworkManager daemon:                            [  OK  ]
[root@rhel6 ~]# chkconfig NetworkManager off
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth1"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"
IPADDR=192.168.122.40
NETMASK=255.255.255.0
GATEWAY=192.168.122.254
[root@rhel6 ~]# echo node1-f0.example.com > /var/www/html/index.html
[root@rhel6 ~]# chkconfig httpd on
[root@rhel6 ~]# iptables -F
[root@rhel6 ~]# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@rhel6 ~]# reboot
```

初始化并配置node2

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.11
Last login: Thu Jul  2 16:02:25 2015 from 172.25.0.250
[root@rhel6 ~]# vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=node2-f0.example.com
[root@rhel6 ~]# service NetworkManager stop
Stopping NetworkManager daemon:                            [  OK  ]
[root@rhel6 ~]# chkconfig NetworkManager off
[root@rhel6 ~]#  vi /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
TYPE=Ethernet
ONBOOT=no
NM_CONTROLLED=no
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth1"
[root@rhel6 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth2"
IPADDR=192.168.122.41
NETMASK=255.255.255.0
GATEWAY=192.168.122.254
[root@rhel6 ~]# echo node2-f0.example.com > /var/www/html/index.html
[root@rhel6 ~]# chkconfig httpd on
[root@rhel6 ~]# iptables -F
[root@rhel6 ~]# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@rhel6 ~]# reboot

Broadcast message from root@rhel6
	(/dev/pts/0) at 16:17 ...

The system is going down for reboot NOW!
```

配置lvs1主分发设备

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.14
Last login: Mon Nov 14 16:17:53 2016 from 172.25.0.250
[root@lvs1-f0 ~]# genhash -s 192.168.122.40 -p 80 -u /index.html
MD5SUM = a7a34e8c9eb06be805252cee76751e7f

[root@lvs1-f0 ~]# genhash -s 192.168.122.41 -p 80 -u /index.html
MD5SUM = bdc30c39c443f293dbb5567ecf178464

[root@lvs1-f0 ~]# service keepalived stop
Stopping keepalived:                                       [  OK  ]
[root@lvs1-f0 ~]# service httpd stop
Stopping httpd:                                            [  OK  ]
[root@lvs1-f0 ~]# vi /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
        root@classroom.example.com
   }
   notification_email_from root@lvs1-f0.example.com
   smtp_server 172.25.254.254
   smtp_connect_timeout 30
   router_id lvs1-f0.example.com
}


vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 100
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        172.25.0.100/24
    }
}

vrrp_instance VI_2 {
    state MASTER
    interface eth2
    virtual_router_id 101
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        192.168.122.254/24
    }
}

virtual_server 172.25.0.100 80 {
    delay_loop 6
    lb_algo wlc
    lb_kind NAT
    nat_mask 255.255.255.0
    persistence_timeout 0
    protocol TCP

    real_server 192.168.122.40 80 {
        weight 1
        HTTP_GET {
            url {
              path /
              digest a7a34e8c9eb06be805252cee76751e7f
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 192.168.122.41 80 {
        weight 1
        HTTP_GET {
            url {
              path /
              digest bdc30c39c443f293dbb5567ecf178464
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }

}

[root@lvs1-f0 ~]# service keepalived start
Starting keepalived:                                       [  OK  ]
```

检查分发规则与虚拟ip是否生效

```shell
[root@lvs1-f0 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.25.0.100:80 wlc
  -> 192.168.122.40:80            Masq    1      0          0         
  -> 192.168.122.41:80            Masq    1      0          0         
[root@lvs1-f0 ~]# ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:00:00:0e brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.14/24 brd 172.25.0.255 scope global eth0
    inet 172.25.0.100/24 scope global secondary eth0
    inet6 fe80::5054:ff:fe00:e/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:01:00:0e brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:02:00:0e brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.44/24 brd 192.168.122.255 scope global eth2
    inet 192.168.122.254/24 scope global secondary eth2
    inet6 fe80::5054:ff:fe02:e/64 scope link 
       valid_lft forever preferred_lft forever

```

配置从分发设备

```shell
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.15
Last login: Mon Nov 14 15:53:42 2016 from 172.25.0.250
[root@lvs2-f0 ~]# vi /etc/keepalived/keepalived.conf 
! Configuration File for keepalived

global_defs {
   notification_email {
        root@classroom.example.com
   }
   notification_email_from root@lvs2-f0.example.com
   smtp_server 172.25.254.254
   smtp_connect_timeout 30
   router_id lvs2-f0.example.com
}


vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 100
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        172.25.0.100/24
    }
}

vrrp_instance VI_2 {
    state BACKUP
    interface eth2
    virtual_router_id 101
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass uplooking
    }
    virtual_ipaddress {
        192.168.122.254/24
    }
}

virtual_server 172.25.0.100 80 {
    delay_loop 6
    lb_algo wlc
    lb_kind NAT
    nat_mask 255.255.255.0
    persistence_timeout 0
    protocol TCP

    real_server 192.168.122.40 80 {
        weight 1
        HTTP_GET {
            url {
              path /
              digest a7a34e8c9eb06be805252cee76751e7f
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 192.168.122.41 80 {
        weight 1
        HTTP_GET {
            url {
              path /
              digest bdc30c39c443f293dbb5567ecf178464
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }

}

[root@lvs2-f0 ~]# service keepalived restart
Stopping keepalived:                                       [  OK  ]
Starting keepalived:                                       [  OK  ]
```


测试高可用与负载均衡

```shell
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node2-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node1-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node2-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
[kiosk@foundation0 Desktop]$ rht-vmctl  poweroff lvs1
Powering off lvs1..
[kiosk@foundation0 Desktop]$ ssh root@172.25.0.15 "ip add show"
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:00:00:0f brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.15/24 brd 172.25.0.255 scope global eth0
    inet 172.25.0.100/24 scope global secondary eth0
    inet6 fe80::5054:ff:fe00:f/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 52:54:00:01:00:0f brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:02:00:0f brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.45/24 brd 192.168.122.255 scope global eth2
    inet 192.168.122.254/24 scope global secondary eth2
    inet6 fe80::5054:ff:fe02:f/64 scope link 
       valid_lft forever preferred_lft forever
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node2-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node1-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node2-f0.example.com
[kiosk@foundation0 Desktop]$  links http://172.25.0.100 -dump 1
   node1-f0.example.com

```