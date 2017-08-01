# nginx性能优化#

### nginx版本号的隐藏###

有些时候，我们可通过以下命令查看到对应访问服务器的版本号：

```shell
[root@workstation ~]# curl -I www.abc.com
HTTP/1.1 200 OK
Server: nginx/1.8.0
Date: Wed, 28 Dec 2016 02:31:04 GMT
Content-Type: text/html
Content-Length: 4
Last-Modified: Wed, 28 Dec 2016 02:23:20 GMT
Connection: keep-alive
ETag: "58632218-4"
Accept-Ranges: bytes
```

一般情况下，软件的漏洞信息和特定版本是相关的，因此，获取到软件版本号对攻击者来说是很有意义的。

所以我们会采用以下操作，隐藏掉我们nginx的版本号：

```shell
[root@servera conf.d]# vim /etc/nginx/nginx.conf 
http{
  ....
  server_tokens off;
}
[root@servera conf.d]# systemctl restart nginx

```

访问查看：

```shell
[root@workstation ~]# curl -I 172.25.0.10
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 28 Dec 2016 03:03:13 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 21 Apr 2015 15:36:55 GMT
Connection: keep-alive
ETag: "55366e97-264"
Accept-Ranges: bytes
```

---

### nginx的模型调整###

Nginx支持多种处理连接的方法（I/O复用方法），这些方法可以通过use参数来指定。

select：标准方法。该方法为编译时默认采用的方法，可以通过--with-select_module或者--without-select-module来选择是否启用这个模块。

poll：标准方法。该方法为编译时候默认采用的方法，可以使用配置参数 –with-poll_module 和 –without-poll_module 来选择是否启用这个模块。

kqueue – 高效的方法，使用于 FreeBSD 4.1+, OpenBSD 2.9+, NetBSD 2.0 和 MacOS X. 使用双处理器的MacOS X系统使用kqueue可能会造成内核崩溃。

epoll – 高效的方法，使用于Linux内核2.6版本及以上系统。

rtsig – 可执行的实时信号，使用于Linux内核版本2.2.19以后的系统。默认情况下整个系统中不能出现大于1024个POSIX实时(排队)信号。这种情况对于高负载的服务器来说是低效的；所以有必要通过调节内核参数 /proc/sys/kernel/rtsig-max 来增加队列的大小。可是从Linux内核版本2.6.6-mm2开始， 这个参数就不再使用了，并且对于每个进程有一个独立的信号队列，这个队列的大小可以用 RLIMIT_SIGPENDING 参数调节。当这个队列过于拥塞，nginx就放弃它并且开始使用 poll 方法来处理连接直到恢复正常。

/dev/poll – 高效的方法，适用于 Solaris 7 11/99+, HP/UX 11.22+ (eventport), IRIX 6.5.15+ 和 Tru64 UNIX 5.1A+。

eventport – 高效的方法，适用于 Solaris 10，为了防止出现内核崩溃的问题，有必要安装这个安全补丁。

一般情况下，在linux我们会优先选择epoll的I/O多路复用的模型。

对于select模型来说，单个进程所打开的FD是有限制的，默认值是2048，对于处理大量请求的应用来说该数据难免有些捉襟见肘。要解决这个问题可以采用以下方案：

一：可以选择修改nginx里的FD_SETSIZE这个值，然后重新编译内核，不过该方案会带来网络效率的下降。

二：可以选择多进程的解决方案(传统的 Apache方案)，不过虽然linux上面创建进程的代价比较小，但进程间数据同步远比不上线程间同步的高效，所以也不是一种完美的方案。

所以，我们可以考虑采用epoll模型。epoll模型没有这个限制，它所支持的FD上限是最大可以打开文件的数目，这个数字一般远大于2048。我们这里可以查看一下/proc/sys/fs/file-max文件里的对应数值，一般来说这个数值和系统物理内存关系很大，在1GB内存的机器上大约是10万左右。

设置方式：

启用epoll模型：

```shell
events {
    ...
    use epoll;
    ...
}


```

设置每个进程的最大文件打开数：

```shell
events {
   use epoll;
   work_rlimit_nofile 10240;  # 该值最大为65535，理论值应该是最多打开文件数（ulimit -n）与nginx进程数相除，但是nginx分配请求并不是那么均匀，所以最好与ulimit -n的值保持一致。
   ...
}
```

---

### nginx的进程优化###

调整每个进程的最大连接数：

nginx总并发连接数= nginx worker数 *  worker_connections

```shell
events {
	use epoll;
	worker_connections  1024;
	work_rlimit_nofile 10240;
}
```

进程和cpu核数绑定：

为了充分利用多核CPU，我们常常在一台server上会启动多个进程。而为了减少反复构建场景的操作，有必要为每个进程指定其所运行的CPU。

```shell
user  nginx;
worker_processes  2;
worker_cpu_affinity 0010 0001;  # 一般情况下，worker_processes和需要绑定的核数数量保持一致

```

这里使用的是第一个核及第二个核。不使用cpu0的原因也是避免和关键进程或者和别的一堆进程挤在一起。

----

### nginx热部署###

为什么nginx支持热部署？这和其并发模型有着密不可分的关系。当通知nginx重读配置文件的时候，master进程会进行语法错误的判断。如果存在语法错误的话，返回错误，不进行装载。

如果配置文件没有语法错误，那么nginx也不会将新的配置调整到所有worker中。而是先不改变已经建立连接的worker，等待worker将所有请求结束之后，将原先在旧的配置下启动的worker杀死，然后使用新的配置创建新的worker。

nginx支持在线升级的原因也很好理解了，其原理就是首先我们先会替换master进程，同时我们替换的master是与老版本的worker兼容的。下一步就是保持还有连接的worker进程，待其老去退休，进行替换。

如果要使用热部署的功能的话，使用以下命令来控制nginx的进程。

```shell
[root@serverb nginx]# ps -ef | grep nginx
root      1814     1  0 03:53 ?        00:00:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     1815  1814  0 03:53 ?        00:00:00 nginx: worker process
root      1819  1570  0 03:53 pts/0    00:00:00 grep --color=auto nginx
[root@serverb nginx]# vim /etc/nginx/nginx.conf 
[root@serverb nginx]# nginx -s reload
[root@serverb nginx]# ps -ef | grep nginx
root      1814     1  0 03:53 ?        00:00:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     1839  1814  0 03:57 ?        00:00:00 nginx: worker process
nginx     1840  1814  0 03:57 ?        00:00:00 nginx: cache manager process
nginx     1841  1814  0 03:57 ?        00:00:00 nginx: cache loader process
root      1843  1570  0 03:57 pts/0    00:00:00 grep --color=auto nginx
```

可以看到在这个过程当中，master进程的进程号是不会发生变更的。实际当修改配置文件后，执行命令nginx -s reload，bash会给master发送一个SIGHUB信号，master会把SIGHUB信号发送给各个worker，各个worker在接受到该信号时，如果该worker处于忙状态，则先将手里的工作做完后再挂掉，重新加载修改后的配置文件来生成一个新的worker，如果该worker处于闲状态，则立刻挂掉，重新启动。

当然，根据原理，直接使用HUP信号来重新加载配置文件也可以：

```shell
[root@serverb nginx]# ps -ef | grep nginx
root      1814     1  0 03:53 ?        00:00:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     1839  1814  0 03:57 ?        00:00:00 nginx: worker process
nginx     1840  1814  0 03:57 ?        00:00:00 nginx: cache manager process
nginx     1841  1814  0 03:57 ?        00:00:00 nginx: cache loader process
root      1843  1570  0 03:57 pts/0    00:00:00 grep --color=auto nginx
[root@serverb nginx]# vim /etc/nginx/nginx.conf 
[root@serverb nginx]# kill -HUP 1814
[root@serverb nginx]# ps -ef | grep nginx
root      1814     1  0 03:53 ?        00:00:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     1889  1814  0 04:01 ?        00:00:00 nginx: worker process
root      1891  1570  0 04:01 pts/0    00:00:00 grep --color=auto nginx
```



---

### fastcgi的参数优化###

```shell
#指定连接到后端fastcgi的超时时间
fastcgi_connection_timeout 300;
#向fastcgi传送请求的超时时间，这个值是指已经完成两次握手向后fastcgi传送请求的超时时间
fastcgi_send_timeout 300;
#指定接收fastcgi应答请求的超时时间，这个值是指已经完成两次握手后接收fastcgi应答的超时时间
fastcgi_read_timeout 300;
#指定读取fastcgi应答第一部分需要多大的缓冲区，这个值表示将使用1个64KB的缓冲区读取应答的第一部分（应答头），可以设置为fastcgi_buffers选项指定的缓冲区大小。
fastcgi_buffer_size 64k; 
#指定本地需要多少和多大的缓冲区来缓冲fastcgi的应答请求，如果一个php脚本所产生的页面大小为256KB，那么会为其分配4个64KB的缓冲区来缓冲；如果页面大小大于256KB，那么大于256KB的部分会缓存到fastcgi_temp指定的路径中，但是这并不是好方法，因为内存中的数据处理速度要快于硬盘。
fastcgi_buffers 4 64k;
#fastcgi繁忙的时候给多大，建议为fastcgi_buffers的两倍
fastcgi_busy_buffers_size 128k;
#在写入fastcgi_temp_path时将用多大的数据块，默认值是fastcgi_buffers的两倍，如果设置过大，可能会报502错误
fastcgi_temp_file_write_size 128k;
#表示开启fastcgi缓存并为其指定一个名称。开启缓存非常有用，可以有效降低cpu的负载，并且防止502错误发生
fastcgi_cache oldboy_nginx;
#用来指定应答代码的缓存时间，实例中的值将200和302应答模式缓存一个小时
fastcgi_cache_valid 200 302 1h;
#将其它应答为1分钟
fastcgi_cache_valid any 1m;
#缓存在fastcgi_cache_path指令inactive参数值时间内的最少使用次数
fastcgi_cache_min_uses 1;
```

---

### nginx多实例###

添加额外服务用户

```shell
[root@servera ~]# useradd carol
```

将nginx主配置文件复制到对应用户家目录下

```shell
[root@servera ~]# cp /etc/nginx/nginx.conf  /home/carol/
```

修改配置文件

```shell
[root@servera carol]# vim /home/carol/nginx.conf 
user  carol;
worker_processes  2;
worker_cpu_affinity 0010 0001;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    use epoll;
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/carol.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server_tokens off;
server {
    listen       8000;  # 必须要起80以外的端口，避免和已有进程冲突
    server_name  www.carol.com;
        root /var/www/html/carol.com;
        index index.html;
        }
}

```

启动服务

```shell
[root@servera ~]# nginx -c /home/carol/nginx.conf
[root@servera ~]# ps -ef | grep nginx
root     27940     1  0 01:30 ?        00:00:00 nginx: master process /usr/sbinnginx -c /etc/nginx/nginx.conf
nginx    27941 27940  0 01:30 ?        00:00:00 nginx: worker process
nginx    27942 27940  0 01:30 ?        00:00:00 nginx: worker process
root     28022     1  0 01:36 ?        00:00:00 nginx: master process nginx -c /home/carol/nginx.conf
carol    28023 28022  0 01:36 ?        00:00:00 nginx: worker process
carol    28024 28022  0 01:36 ?        00:00:00 nginx: worker process
root     28026 27881  0 01:36 pts/1    00:00:00 grep --color=auto nginx
```

