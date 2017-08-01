# Ansible

----



[TOC]

## Ansible简介

### Ansible是什么

Ansible是新出现的自动化运维工具，基于Python开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。ansible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。

2015年RedHat收购了Ansible，并且将其多个平台自动化部署方案切换到Ansible。

Ansible官网 https://www.ansible.com/

Ansible帮助文档：http://docs.ansible.com/

RedHat 中国的Ansible支持页面：https://www.redhat.com/zh/technologies/management/ansible

### Ansible的优势及特性

Ansible作为一个自动化运维工具，优势总共有一下几点：

* 轻量级：无需在客户端安装 **agent** ，并且也不需要启动服务。
* 配置灵活：Ansible基于SSH工作，可使用系统或自定义模块满足更为灵活的需求。
* 语法简洁：配置语言采用 **yaml** ，用来定义多条任务，语法更为简洁，Ansible简单易懂的自动化语言允许使用人员在很短的时间内完成自动化项目的部署。

### Ansible的基本结构

* Ansible的核心管理主机：亦可以称为 **管理节点** ，用来管理其他的受控节点。

* 系统模块：Ansible本身自带一些模块，提供一些常用的功能。

* 扩展模块：若Ansible的系统模块无法满足批量化管理的特定需求，则可以添加一些扩展模块。

* 插件：完成模块功能的补充。

* 主机组：用来定义实际管理维护的主机服务器。

* 剧本（playbooks）：用来定义多条任务，由Ansible统一去执行。


## 安装 Ansible

对于Ansible来说，实际批量化管理的操作都是基于 **ssh** 完成的。并且作为一个轻量级的自动化运维工具，它并不需要走一个C/S的模型，也不需要启动服务，仅需要在一台管理节点上面安装对应的软件即可直接使用。由于这个特性，Ansible就避免了像其他自动化运维工具那样（如Puppet），考虑升级版本造成的影响。目前只要机器上安装了 Python 2.6 以上版本，都可以运行Ansible。主机可以是 Red Hat, Debian, CentOS, OS X, BSD等系统，遗憾的是目前不支持Windows系统做控制主机。

下载地址：http://releases.ansible.com/ 或 https://github.com/ansible/

在我们实验环境中采用的是1.9.2的版本，以servera作为ansible的管理节点。

```shell
[root@servera ansible]# ls
ansible-1.9.2-1.el7.noarch.rpm
ansible-inventory-grapher-1.0.1-2.el7.noarch.rpm
ansible-lint-2.0.1-1.el7.noarch.rpm
python-crypto-2.6.1-1.el7.x86_64.rpm
python-ecdsa-0.11-3.el7.noarch.rpm
python-httplib2-0.7.7-3.el7.noarch.rpm
python-jinja2-2.7.2-2.el7.noarch.rpm
python-keyczar-0.71c-2.el7.noarch.rpm
python-paramiko-1.15.1-1.el7.noarch.rpm
[root@servera ansible]# yum -y localinstall *.rpm
Loaded plugins: langpacks
Examining ansible-1.9.2-1.el7.noarch.rpm: ansible-1.9.2-1.el7.noarch
Marking ansible-1.9.2-1.el7.noarch.rpm to be installed
Examining ansible-inventory-grapher-1.0.1-2.el7.noarch.rpm: ansible-inventory-grapher-1.0.1-2.el7.noarch
Marking ansible-inventory-grapher-1.0.1-2.el7.noarch.rpm to be installed
Examining ansible-lint-2.0.1-1.el7.noarch.rpm: ansible-lint-2.0.1-1.el7.noarch
Marking ansible-lint-2.0.1-1.el7.noarch.rpm to be installed
Examining python-crypto-2.6.1-1.el7.x86_64.rpm: python-crypto-2.6.1-1.el7.x86_64
Marking python-crypto-2.6.1-1.el7.x86_64.rpm to be installed
Examining python-ecdsa-0.11-3.el7.noarch.rpm: python-ecdsa-0.11-3.el7.noarch
Marking python-ecdsa-0.11-3.el7.noarch.rpm to be installed
Examining python-httplib2-0.7.7-3.el7.noarch.rpm: python-httplib2-0.7.7-3.el7.noarch
Marking python-httplib2-0.7.7-3.el7.noarch.rpm to be installed
Examining python-jinja2-2.7.2-2.el7.noarch.rpm: python-jinja2-2.7.2-2.el7.noarch
Marking python-jinja2-2.7.2-2.el7.noarch.rpm to be installed
Examining python-keyczar-0.71c-2.el7.noarch.rpm: python-keyczar-0.71c-2.el7.noarch
Marking python-keyczar-0.71c-2.el7.noarch.rpm to be installed
Examining python-paramiko-1.15.1-1.el7.noarch.rpm: python-paramiko-1.15.1-1.el7.noarch
Marking python-paramiko-1.15.1-1.el7.noarch.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package ansible.noarch 0:1.9.2-1.el7 will be installed
---> Package ansible-inventory-grapher.noarch 0:1.0.1-2.el7 will be installed
---> Package ansible-lint.noarch 0:2.0.1-1.el7 will be installed
---> Package python-crypto.x86_64 0:2.6.1-1.el7 will be installed
---> Package python-ecdsa.noarch 0:0.11-3.el7 will be installed
---> Package python-httplib2.noarch 0:0.7.7-3.el7 will be installed
---> Package python-jinja2.noarch 0:2.7.2-2.el7 will be installed
--> Processing Dependency: python-babel >= 0.8 for package: python-jinja2-2.7.2-2.el7.noarch
rhel_dvd                                                 | 4.1 kB     00:00     
(1/2): rhel_dvd/group_gz                                   | 134 kB   00:00     
(2/2): rhel_dvd/primary_db                                 | 3.4 MB   00:00     
--> Processing Dependency: python-markupsafe for package: python-jinja2-2.7.2-2.el7.noarch
---> Package python-keyczar.noarch 0:0.71c-2.el7 will be installed
--> Processing Dependency: python-pyasn1 for package: python-keyczar-0.71c-2.el7.noarch
---> Package python-paramiko.noarch 0:1.15.1-1.el7 will be installed
--> Running transaction check
---> Package python-babel.noarch 0:0.9.6-8.el7 will be installed
---> Package python-markupsafe.x86_64 0:0.11-10.el7 will be installed
---> Package python-pyasn1.noarch 0:0.1.6-2.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package         Arch   Version      Repository                            Size
================================================================================
Installing:
 ansible         noarch 1.9.2-1.el7  /ansible-1.9.2-1.el7.noarch          7.0 M
 ansible-inventory-grapher
                 noarch 1.0.1-2.el7  /ansible-inventory-grapher-1.0.1-2.el7.noarch
                                                                           13 k
 ansible-lint    noarch 2.0.1-1.el7  /ansible-lint-2.0.1-1.el7.noarch      61 k
 python-crypto   x86_64 2.6.1-1.el7  /python-crypto-2.6.1-1.el7.x86_64    2.3 M
 python-ecdsa    noarch 0.11-3.el7   /python-ecdsa-0.11-3.el7.noarch      290 k
 python-httplib2 noarch 0.7.7-3.el7  /python-httplib2-0.7.7-3.el7.noarch  213 k
 python-jinja2   noarch 2.7.2-2.el7  /python-jinja2-2.7.2-2.el7.noarch    3.0 M
 python-keyczar  noarch 0.71c-2.el7  /python-keyczar-0.71c-2.el7.noarch   564 k
 python-paramiko noarch 1.15.1-1.el7 /python-paramiko-1.15.1-1.el7.noarch 5.2 M
Installing for dependencies:
 python-babel    noarch 0.9.6-8.el7  rhel_dvd                             1.4 M
 python-markupsafe
                 x86_64 0.11-10.el7  rhel_dvd                              25 k
 python-pyasn1   noarch 0.1.6-2.el7  rhel_dvd                              91 k

Transaction Summary
================================================================================
Install  9 Packages (+3 Dependent packages)

Total size: 20 M
Total download size: 1.5 M
Installed size: 24 M
Downloading packages:
(1/3): python-markupsafe-0.11-10.el7.x86_64.rpm            |  25 kB   00:00     
(2/3): python-pyasn1-0.1.6-2.el7.noarch.rpm                |  91 kB   00:00     
(3/3): python-babel-0.9.6-8.el7.noarch.rpm                 | 1.4 MB   00:00     
--------------------------------------------------------------------------------
Total                                              3.4 MB/s | 1.5 MB  00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : python-crypto-2.6.1-1.el7.x86_64                            1/12 
  Installing : python-babel-0.9.6-8.el7.noarch                             2/12 
  Installing : python-pyasn1-0.1.6-2.el7.noarch                            3/12 
  Installing : python-keyczar-0.71c-2.el7.noarch                           4/12 
  Installing : python-ecdsa-0.11-3.el7.noarch                              5/12 
  Installing : python-paramiko-1.15.1-1.el7.noarch                         6/12 
  Installing : python-httplib2-0.7.7-3.el7.noarch                          7/12 
  Installing : python-markupsafe-0.11-10.el7.x86_64                        8/12 
  Installing : python-jinja2-2.7.2-2.el7.noarch                            9/12 
  Installing : ansible-1.9.2-1.el7.noarch                                 10/12 
  Installing : ansible-lint-2.0.1-1.el7.noarch                            11/12 
  Installing : ansible-inventory-grapher-1.0.1-2.el7.noarch               12/12 
  Verifying  : python-keyczar-0.71c-2.el7.noarch                           1/12 
  Verifying  : python-markupsafe-0.11-10.el7.x86_64                        2/12 
  Verifying  : python-jinja2-2.7.2-2.el7.noarch                            3/12 
  Verifying  : python-crypto-2.6.1-1.el7.x86_64                            4/12 
  Verifying  : python-httplib2-0.7.7-3.el7.noarch                          5/12 
  Verifying  : ansible-lint-2.0.1-1.el7.noarch                             6/12 
  Verifying  : python-ecdsa-0.11-3.el7.noarch                              7/12 
  Verifying  : ansible-inventory-grapher-1.0.1-2.el7.noarch                8/12 
  Verifying  : python-pyasn1-0.1.6-2.el7.noarch                            9/12 
  Verifying  : python-babel-0.9.6-8.el7.noarch                            10/12 
  Verifying  : python-paramiko-1.15.1-1.el7.noarch                        11/12 
  Verifying  : ansible-1.9.2-1.el7.noarch                                 12/12 

Installed:
  ansible.noarch 0:1.9.2-1.el7                                                  
  ansible-inventory-grapher.noarch 0:1.0.1-2.el7                                
  ansible-lint.noarch 0:2.0.1-1.el7                                             
  python-crypto.x86_64 0:2.6.1-1.el7                                            
  python-ecdsa.noarch 0:0.11-3.el7                                              
  python-httplib2.noarch 0:0.7.7-3.el7                                          
  python-jinja2.noarch 0:2.7.2-2.el7                                            
  python-keyczar.noarch 0:0.71c-2.el7                                           
  python-paramiko.noarch 0:1.15.1-1.el7                                         

Dependency Installed:
  python-babel.noarch 0:0.9.6-8.el7    python-markupsafe.x86_64 0:0.11-10.el7  
  python-pyasn1.noarch 0:0.1.6-2.el7  

Complete!
```


## 配置Ansible

### ssh的基本配置

Ansible是基于ssh来实现批量化的配置，Ansible1.2.1及其之后的版本都会默认启用公钥认证。于是我们可以先来配置下ssh基于公钥的认证。

servera依旧作为管理节点，serverb作为受控节点。在这里我们使用密钥方式来保证servera和serverb的连接。

```shell
[root@servera ansible]# ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
d9:48:14:26:81:aa:8d:45:6b:7e:99:d4:7f:14:5a:ae root@servera.pod0.example.com
The key's randomart image is:
+--[ RSA 2048]----+
|     .o.+.       |
|  . .  +  o      |
| . o .  .+ .     |
|  = . ...+o      |
| B . o .So.      |
|o o +   E .      |
|   .     .       |
|                 |
|                 |
+-----------------+
```

```shell
[root@servera ansible]# ssh-copy-id root@172.25.0.11
The authenticity of host '172.25.0.11 (172.25.0.11)' can't be established.
ECDSA key fingerprint is 0b:1f:3b:13:2e:d2:10:53:4c:3d:c8:f4:86:24:d3:5e.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@172.25.0.11's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@172.25.0.11'"
and check to make sure that only the key(s) you wanted were added.

[root@servera ansible]# ssh root@172.25.0.11
Last login: Thu Oct 13 11:07:40 2016 from 172.25.0.250
[root@serverb ~]# exit
logout
Connection to 172.25.0.11 closed.
```

* ansible的配置，配置主目录/etc/ansible

ansible.cfg为主配置文件。hosts定义了主机组相关的内容。

```shell
[root@servera ansible]# cd /etc/ansible/
[root@servera ansible]# ls
ansible.cfg  hosts  roles
```


* 变更ansible.cfg

```shell
[root@servera ansible]# vim ansible.cfg
private_key_file=/root/.ssh/id_rsa   # 定义ssh信任文件所在位置
```

* 定义inventory文件（定义主机组）

```shell

[root@servera ansible]# vim /etc/ansible/hosts

# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups
[webserver]
172.25.0.11
172.25.0.12

```

测试（可以通过以下指令做简单的测试，具体操作后续分析）：

```shell
[root@servera .ssh]# ansible webserver -m command -a 'uptime'
172.25.0.11 | success | rc=0 >>
 22:14:11 up 56 min,  2 users,  load average: 0.21, 0.15, 0.10

172.25.0.12 | success | rc=0 >>
 22:14:12 up 39 min,  2 users,  load average: 0.08, 0.03, 0.05
​````

有些时候我们可能会遇到一个问题，如果有个主机重新安装并在“known_hosts”中有了不同的key值记录，这会提示一个错误信息直到被纠正为止。如果有个主机没有在“known_hosts”中被初始化将会导致在交互使用Ansible或定时执行Ansible时对key信息的确认提示。如果你想禁用此项行为并明白其含义,你能够通过编辑 /etc/ansible/ansible.cfg来实现。

​```shell
[root@servera ansible]# ls
ansible.cfg  hosts  roles
[root@servera ansible]# vim ansible.cfg 
[defaults]
host_key_checking = False
[root@servera ansible]# pwd
/etc/ansible
```

----

## 常用Ansible模块

Ansible可以通过模块的方式来完成一些原理的管理工作，可以通过ansible-doc -l查看到所有自带的模块。 ansible-doc -s 模块名 可以用来查看具体模块对应的用法。

这里主要讲一些常用的模块。

### setup模块

用来收集远程主机的基本信息

```shell
ansible webserver -m setup
172.25.0.12 | success >> {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.0.12", 
            "172.25.0.12", 
            "192.168.1.12"
        ], 
        "ansible_all_ipv6_addresses": [
            "fe80::5054:ff:fe01:c", 
            "fe80::5054:ff:fe00:c", 
            "fe80::5054:ff:fe02:c"
        ], 
    	...... # 以下内容省略
    	......
    	......
```

### ping模块 

用来查看远程主机的运行状态

````shell
[root@servera ansible]# ansible webserver -m ping
172.25.0.12 | success >> {
    "changed": false, 
    "ping": "pong"
}

172.25.0.11 | success >> {
    "changed": false, 
    "ping": "pong"
}
````

### file模块

用来设置文件的属性，用-a指定选项。 

file模块相关选项如下：

| 参数      |                                          |
| ------- | ---------------------------------------- |
| force   | 强制，有两个选项：yes或no                          |
| group   | 定义文件/目录的所属组                              |
| mode    | 定义文件/目录的权限                               |
| owner   | 定义文件/目录的属主                               |
| path    | 必选项，定义文件/目录的路径                           |
| src     | 被链接的源文件路径，只应用于state=link的情况              |
| dest    | 被链接到的路径，只应用于state=link的情况                |
| recurse | 递归设置文件的属性，只对目录有效                         |
| state   | 定义文件/目录的参数，常用参数如下：                       |
|         | directory：如果目录不存在，就创建目录                  |
|         | file：即使文件不存在，也不会被创建                      |
|         | link：创建软链接                               |
|         | hard：创建硬链接                               |
|         | touch：如果文件不存在，则会创建一个新的文件，如果文件或目录已存在，则更新其最后修改时间 |
|         | absent：删除目录、文件或者取消链接文件                   |

以下例子展示了在多台受控主机上使用file模块创建文件的方式：

```shell
[root@servera ansible]# ansible server -m file -a 'state=touch owner=student group=student mode=444 path=/tmp/testfile'
172.25.0.12 | success >> {
    "changed": true, 
    "dest": "/tmp/testfile", 
    "gid": 1000, 
    "group": "student", 
    "mode": "0444", 
    "owner": "student", 
    "secontext": "unconfined_u:object_r:user_tmp_t:s0", 
    "size": 0, 
    "state": "file", 
    "uid": 1000
}

172.25.0.11 | success >> {
    "changed": true, 
    "dest": "/tmp/testfile", 
    "gid": 1000, 
    "group": "student", 
    "mode": "0444", 
    "owner": "student", 
    "secontext": "unconfined_u:object_r:user_tmp_t:s0", 
    "size": 0, 
    "state": "file", 
    "uid": 1000
}

[root@serverb ~]# ll /tmp/testfile 
-r--r--r--. 1 student student 0 Oct 21 06:01 /tmp/testfile

```

### command模块

用以ssh的方式，在远程主机上执行命令

例子如下：

````shell
[root@servera ansible]# ansible server -m command -a 'ls -l /etc/hosts'
172.25.0.12 | success | rc=0 >>
-rw-r--r--. 1 root root 324 Oct 21 05:55 /etc/hosts

172.25.0.11 | success | rc=0 >>
-rw-r--r--. 1 root root 324 Oct 21 05:54 /etc/hosts
````

### copy模块

将对应的文件复制至远程主机

| 参数             | 说明                                       |
| -------------- | ---------------------------------------- |
| backup         | 将源文件备份。                                  |
| dest           | 必选项。要将源文件复制到的远程主机的绝对路径，如果源文件是一个目录，那么该路径也必须是个目录 |
| directory_mode | 递归设定目录的权限，默认为系统默认权限                      |
| force          | 如果目标主机包含该文件，但内容不同，如果设置为yes，则强制覆盖，如果为no，则只有当目标主机的目标位置不存在该文件时，才复制。默认为yes |
| src            | 被复制到远程主机的本地文件，可以是绝对路径，也可以是相对路径。如果路径是一个目录，它将递归复制。在这种情况下，如果路径使用“/”来结尾，则只复制目录里的内容，如果没有使用“/”来结尾，则包含目录在内的整个内容全部复制，类似于rsync。 |

示例：

```shell
[root@servera ansible]# ansible server -m copy -a 'src=/etc/hosts dest=/tmp/hosts mode=444'
172.25.0.12 | success >> {
    "changed": true, 
    "checksum": "69f4c26657963dc7d4fcf97c24f78e1f9e9e971f", 
    "dest": "/tmp/hosts", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "1b2b40d5fb755dad0d1f8c5e7ab07ff4", 
    "mode": "0444", 
    "owner": "root", 
    "secontext": "unconfined_u:object_r:admin_home_t:s0", 
    "size": 324, 
    "src": "/root/.ansible/tmp/ansible-tmp-1477049366.36-247610647111921/source", 
    "state": "file", 
    "uid": 0
}

172.25.0.11 | success >> {
    "changed": true, 
    "checksum": "69f4c26657963dc7d4fcf97c24f78e1f9e9e971f", 
    "dest": "/tmp/hosts", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "1b2b40d5fb755dad0d1f8c5e7ab07ff4", 
    "mode": "0444", 
    "owner": "root", 
    "secontext": "unconfined_u:object_r:admin_home_t:s0", 
    "size": 324, 
    "src": "/root/.ansible/tmp/ansible-tmp-1477049366.35-135289460451279/source", 
    "state": "file", 
    "uid": 0
}

```

### 更多模块

ansible-doc -l可以罗列ansible所有模块名称

ansible-doc -s 模块名，可以用来查看对应模块的实际用法。

举例：

```shell
[root@servera ansible]# ansible-doc -s at
less 458 (POSIX regular expressions)
Copyright (C) 1984-2012 Mark Nudelman

less comes with NO WARRANTY, to the extent permitted by law.
For information about the terms of redistribution,
see the file named README in the less distribution.
Homepage: http://www.greenwoodsoftware.com/less
- name: S c h e d u l e   t h e   e x e c u t i o n   o f   a   c o m m a n d   o r   s c r i p t   f i l e   v i a   t h e   a t   c o m m 
  action: at
      command                # A command to be executed in the future.
      count=                 # The count of units in the future to execute the command or script file.
      script_file            # An existing script file to be executed in the future.
      state                  # The state dictates if the command or script file should be evaluated as present(added) or absent(deleted).
      unique                 # If a matching job is present a new job will not be added.
      units=                 # The type of units in the future to execute the command or script file.
(END)


```

以上方式可以称为 adhoc的方式来运行ansible，适用于单行命令的场景。但如果涉及到多条任务同时执行，则请看下节内容。

## Ansible playbooks

我们使用 adhoc 时，主要是使用 /usr/bin/ansible 程序执行任务，而使用 playbooks 时，更多是将之放入源码控制之中，用之推送你的配置或是用于确认你的远程系统的配置是否符合配置规范。playbooks也属于ansible核心的一个部分，用来定义一系列ansible要去执行的任务。

play主要的功能就是将实现归并为一组的主机装扮成实现通过ansible的task定义好的角色，所谓task就是调用ansible的模块。而所谓的playbooks就是将多个play统一去完成。简单来说，playbooks 是一种简单的配置管理系统与多机器部署系统的基础，非常适合于复杂应用的部署。

### playbook的组成部分

* 受控节点hosts（主机组）

* 运行用户身份：remote_user

* 变量部分vars，后续任务中可以采用一些变量

* 任务部分tasks：具体执行什么样的任务

* 后续任务部分handlers：定义task完成后需要调用的任务。

### yaml的语法格式

对于 Ansible,，每一个 YAML 文件都是从一个列表开始。列表中的每一项都是一个键值对， 通常它们被称为一个 “哈希” 或 “字典”。所以, 我们需要知道如何在 YAML 中编写列表和字典。YAML 还有一个小的怪癖，所有的 YAML 文件(无论和 Ansible 有没有关系)开始行都应该是 ---。这是 YAML 格式的一部分， 表明一个文件的开始。

列表中的所有成员都开始于相同的缩进级别，并且使用一个“- ”作为开头(一个横杠和一个空格)：

下面是一种基本的 task 的定义，service moudle 使用 key=value 格式的参数，这也是大多数 module 使用的参数格式：

```shell
tasks:
  - name: make sure apache is running
    service: name=httpd state=running
```



举例1：安装httpd并启动服务

```shell
[root@servera ansible]# vim test.yml 
- hosts: server # 定义主机组
  remote_user: root # 在 Ansible 1.4 以后才改为 remote_user，原先参>数为user
  tasks:  # 定义实际执行的任务
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: ensure apache is running
    service: name=httpd state=started
```

执行yml方法：

```shell
[root@servera ansible]# ansible-playbook test.yml

PLAY [server] ***************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is at the latest version] ******************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is running] ********************************************** 
changed: [172.25.0.12]
changed: [172.25.0.11]

PLAY RECAP ******************************************************************** 
172.25.0.11                : ok=3    changed=1    unreachable=0    failed=0   
172.25.0.12                : ok=3    changed=1    unreachable=0    failed=0   
```



练习：使用ansible的playbook在受控节点上安装mariadb-server，并启动mariadb服务



答案：

```shell
- hosts : server
  remote_user: root
  tasks:
     - name: install mariadb-server
       yum: name=mariadb-server state=present
     - name: start service
       service: name=mariadb state=started enabled=yes
```

举例2：变更httpd配置文件

Handlers 也是一些 task 的列表，通过名字来引用，它们和一般的 task 并没有什么区别，Handlers 是由通知者进行 notify,，如果没有被 notify，handlers 不会执行，不管有多少个通知者进行了 notify，等到 play 中的所有 task 执行完成之后，handlers 也只会被执行一次.

```shell
- hosts: server # 定义主机组
  remote_user: root # 在 Ansible 1.4 以后才改为 remote_user，原先参数为user
  tasks:  # 定义实际执行的任务
  - name: ensure apache is at the latest version
    yum: name=httpd state=latest
  - name: ensure apache is running
    service: name=httpd state=started
  - name: change httpd config file
    copy: src=/tmp/www.abc.com.conf dest=/etc/httpd/conf.d/www.abc.com.conf
    notify:
          - restart apache
  handlers:
   - name: restart apache
     service:  name=httpd state=restarted
```

执行结果如下：

```shell
[root@servera ansible]# ansible-playbook  test.yml 

PLAY [server] ********


********************************************************* 

GATHERING FACTS *************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is at the latest version] ******************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is running] ********************************************** 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [change httpd config file] ********************************************** 
ok: [172.25.0.12]
changed: [172.25.0.11]

NOTIFIED: [restart apache] **************************************************** 
changed: [172.25.0.11]

PLAY RECAP ******************************************************************** 
172.25.0.11                : ok=5    changed=2    unreachable=0    failed=0   
172.25.0.12                : ok=4    changed=0    unreachable=0    failed=0  
```



## Ansible变量

在Ansible里面会有许多种设置变量的方式。

在使用变量之前最好先知道什么是合法的变量名。变量名可以为字母，数字以及下划线。变量始终应该以字母开头， “foo_port”是个合法的变量名。”foo5”也是，“foo-port”，“foo port”，“foo.port” 和 “12”则不是合法的变量名。

### 定义playbook中的变量

定义的方式如下：

```shell
- hosts: server # 定义主机组
  vars:
        server_name: www.efg.com  # 定义变量
  remote_user: root # 在 Ansible 1.4 以后才改为 remote_user，原先参数为user
  tasks:  # 定义实际执行的任务
  - name: ensure apache is at the latest version
    yum: name=httpd state=latest
  - name: ensure apache is running
    service: name=httpd state=started
  - name: change abc config file
    copy: src=/tmp/www.abc.com.conf dest=/etc/httpd/conf.d/www.abc.com.conf
    notify:
          - restart apache
  - name: change efg config file
    copy: src=/tmp/{{server_name}}.conf dest=/etc/httpd/conf.d/{{server_name}}.conf # 通过{{变量名}}来引用变量
    notify:
          - restart apache
  handlers:
   - name: restart apache
     service:  name=httpd state=restarted
```

执行结果如下：

```shell
[root@servera ansible]# ansible-playbook test.yml 

PLAY [server] ***************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is at the latest version] ******************************** 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [ensure apache is running] ********************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [change abc config file] ************************************************ 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [change efg config file] ************************************************ 
changed: [172.25.0.12]
changed: [172.25.0.11]

NOTIFIED: [restart apache] **************************************************** 
changed: [172.25.0.11]
changed: [172.25.0.12]

PLAY RECAP ******************************************************************** 
172.25.0.11                : ok=6    changed=2    unreachable=0    failed=0   
172.25.0.12                : ok=6    changed=2    unreachable=0    failed=0  
```

使用copy模块无法将变量传递到配置文件里，在这里，我们可以使用到ansible里面的模板功能

```shell
- hosts: server # 定义主机组
  vars:
        server_name: www.efg.com
        nametem: www.lucky.com
  remote_user: root # 在 Ansible 1.4 以后才改为 remote_user，原先参数为user
  tasks:  # 定义实际执行的任务
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: ensure apache is running
    service: name=httpd state=started
  - name: change abc config file
    copy: src=/tmp/www.abc.com.conf dest=/etc/httpd/conf.d/www.abc.com.conf
    notify:
          - restart apache
  - name: change efg config file
    copy: src=/tmp/{{server_name}}.conf dest=/etc/httpd/conf.d/{{server_name}}.conf
    notify:
          - restart apache
  - name: test
    template: src=/tmp/lucky.conf dest=/etc/httpd/conf.d/lucky.conf
    notify:
    	  - restart apache
  handlers:
   - name: restart apache
     service:  name=httpd state=restarted

[root@servera tmp]# cat lucky.conf 
<VirtualHost *:80>
	ServerName {{ nametem }}
	DocumentRoot /var/www/html/lucky.com
</VirtualHost>
[root@servera tmp]# 

```

执行结果如下

```shell
[root@servera ansible]# ansible-playbook test.yml 

PLAY [server] ***************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is at the latest version] ******************************** 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [ensure apache is running] ********************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [change abc config file] ************************************************ 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [change efg config file] ************************************************ 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [test] ****************************************************************** 
changed: [172.25.0.11]
changed: [172.25.0.12]

PLAY RECAP ******************************************************************** 
172.25.0.11                : ok=6    changed=1    unreachable=0    failed=0   
172.25.0.12                : ok=6    changed=1    unreachable=0    failed=0   

[root@serverb conf.d]# cat lucky.conf 
<VirtualHost *:80>
	ServerName www.lucky.com
	DocumentRoot /var/www/html/lucky.com
</VirtualHost>
```



### 获取facts变量

之前提到过一个模块setup，能够获取到每台主机自己的参数

这些变量也是可以直接在模板中拿来引用的。

```shell

- hosts: server # 定义主机组
  vars:
        server_name: www.efg.com
        nametem: www.lucky.com
  remote_user: root # 在 Ansible 1.4 以后才改为 remote_user，原先参数为user
  tasks:  # 定义实际执行的任务
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: ensure apache is running
    service: name=httpd state=started
  - name: change abc config file
    copy: src=/tmp/www.abc.com.conf dest=/etc/httpd/conf.d/www.abc.com.conf
    notify:
          - restart apache
  - name: change efg config file
    copy: src=/tmp/{{server_name}}.conf dest=/etc/httpd/conf.d/{{server_name}}.conf
    notify:
          - restart apache
  - name: lucky
    template: src=/tmp/lucky.conf dest=/etc/httpd/conf.d/lucky.conf
    notify:
          - restart apache
  - name: test
    template: src=/tmp/server.conf dest=/etc/httpd/conf.d/server.conf
    notify:
          - restart apache
  handlers:
   - name: restart apache
     service:  name=httpd state=restarted
     
[root@servera tmp]# cat server.conf 
<VirtualHost *:80>
	ServerName {{ ansible_nodename }}
	DocumentRoot /var/www/html/{{ ansible_nodename }}
</VirtualHost>

```

执行结果如下

```shell
[root@servera ansible]# ansible-playbook  test.yml 

PLAY [server] ***************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is at the latest version] ******************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [ensure apache is running] ********************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [change abc config file] ************************************************ 
ok: [172.25.0.11]
ok: [172.25.0.12]

TASK: [change efg config file] ************************************************ 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [lucky] ***************************************************************** 
ok: [172.25.0.12]
ok: [172.25.0.11]

TASK: [test] ****************************************************************** 
changed: [172.25.0.11]
changed: [172.25.0.12]

NOTIFIED: [restart apache] **************************************************** 
changed: [172.25.0.11]
changed: [172.25.0.12]

PLAY RECAP ******************************************************************** 
172.25.0.11                : ok=8    changed=2    unreachable=0    failed=0   
172.25.0.12                : ok=8    changed=2    unreachable=0    failed=0 
```

查看配置结果

```shell
[root@serverb conf.d]# cat server.conf 
<VirtualHost *:80>
	ServerName serverb.pod0.example.com
	DocumentRoot /var/www/html/serverb.pod0.example.com
</VirtualHost>

```

