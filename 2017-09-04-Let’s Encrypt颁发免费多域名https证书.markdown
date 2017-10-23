---
layout: post        
title:  "Let’s Encrypt颁发免费多域名https证书"
date:   2017-09-04 18:51:06 +0800
categories: Linux   
image:              
tags:  Linux https 
toc: true           
comments: true      
author:            
---

## Install

The thing about CentOs 6.x ( Centos 6.5, 6.6, 6.7 etc ) is it comes with Python 2.6 where as Let’s Encrypt supports Python 2.7+ only. But, installing Python 2.7 in Centos 6.x is pretty simple.

Installing Python 2.7 in  Centos 6.x (This step is only for Centos 6.x)

```
# Install Epel Repository
yum install epel-release

# Install IUS Repository
rpm -ivh https://rhel6.iuscommunity.org/ius-release.rpm

# Install Python 2.7 and Git
yum --enablerepo=ius install git python27 python27-devel python27-pip python27-setuptools python27-virtualenv -y
```

```
mv /usr/bin/python /usr/bin/python.bak # which python: /usr/bin/python
cp /usr/bin/python2.7 /usr/bin/python
```

```
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
```

certbot-auto accepts the same flags as certbot; it installs all of its own dependencies and updates the client code automatically.

## Get Started

for example I use nginx, my OS is CentOS 6.8 and Python version is 2.6.6.


```
sudo ./path/to/certbot-auto --nginx -d dcmmcc.tk -d blog.dcmmcc.tk -d ss.dcmmcc.tk --nginx-server-root=/etc/nginx/vhost certonly
```

将启动cerbot的向导。向导会让你输入你的域名，并要求验证你对这个域名的拥有权。验证方式有两种：

在你当前的https服务器（必须使用443端口）上放置一个验证文件；
向导自己开启一个临时的https服务器（此时不能有其他进程占用443端口）进行验证；
如果一切顺利certbot将自动完成证书的颁发并且将证书和私钥放置于/etc/letsencrypt/live/<你的域名>下面。

It will take a few minutes ( > 15 minutes in my host(CPU E3 with 128m RAM))

It will ask you to provide an email-id. Give a valid email ID you have access to. In case you lost the certificates, you can regain them using the email id. So, it is important to use a valid email ID

Now, it will show you the terms of service, accept it and press enter.

That’s it. You have retrieved the required SSL certificate and key for your domain. All we have to do is set it up in Apache.

注意：联系人email地址要填写真实有效的，letsencrypt会在证书在过期以前发送预告的通知邮件。 申请成功后，会显示以下Congratulations信息:

```
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/dcmmcc.tk/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/dcmmcc.tk/privkey.pem
   Your cert will expire on 2017-12-03. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot-auto
   again. To non-interactively renew *all* of your certificates, run
   "certbot-auto renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

```

证书的保存位置在：

```
/etc/letsencrypt/live/demo.mydomain.com/
```

You can see that all the .pem files are actually symlinks. We will use the symlinks because every time we update the certificates, we don’t have to edit the configurations.

So, according to the letsencrypt documentation, the .pem files are as follows ( Copied from the Letsencrypt documentation without any shame 😉 )

privkey.pem :

Private key for the certificate. This must be kept secret at all times! Never share it with anyone, including Let’s Encrypt developers. You cannot put it into a safe, however – your server still needs to access this file in order for SSL/TLS to work.

This is what Apache needs for SSLCertificateKeyFile,

cert.pem :

Server certificate only. This is what Apache needs for SSLCertificateFile.

chain.pem :

All certificates that need to be served by the browser excluding server certificate, i.e. root and intermediate certificates only.

This is what Apache needs for SSLCertificateChainFile.

fullchain.pem :

All certificates, including server certificate. This is concatenation of chain.pem and cert.pem.

## 查看证书有效期的命令

openssl x509 -noout -dates -in /etc/letsencrypt/live/[demo.mydomain.com]/cert.pem

## 设置定时任务自动更新证书

letsencrypt证书的有效期是90天，但是可以用脚本去更新。

```
# 更新证书
certbot renew --dry-run 
# 如果不需要返回的信息，可以用静默方式：
certbot renew --quiet
```

注意：更新证书时候网站必须是能访问到的

```
# 可以使用crontab定时更新，例如：
# 每月1号5时执行执行一次更新，并重启nginx服务器
00 05 01 * * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```

## 应用实例：配置nginx使用证书开通https站点

1. 生成Perfect Forward Security（PFS）键值

```
mkdir /etc/ssl/private/ -p
cd /etc/ssl/private/
openssl dhparam 2048 -out dhparam.pem
```

* Perfect Forward Security（PFS)是个什么东西，中文翻译成`完美前向保密`，一两句话也说不清楚，反正是这几年才提倡的加强安全性的技术。如果本地还没有生成这个键值，需要先执行生成的命令。

* 生成的过程还挺花时间的，喝杯咖啡歇会儿吧。

2. 配置nginx站点，例如`/etc/nginx/conf.d/vhost/blog.conf`，样例内容如下：

```
server {
listen 80;
server_name blog.dcmmcc.tk;
rewrite ^ https://$server_name$request_uri? permanent;
}
server {
  listen 443 ssl;
  

  # letsencrypt生成的文件
  ssl_certificate /etc/letsencrypt/live/dcmmcc.tk/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/dcmmcc.tk/privkey.pem;

  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets on;

  ssl_dhparam /etc/ssl/private/dhparam.pem;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  # 一般推荐使用的ssl_ciphers值: https://wiki.mozilla.org/Security/Server_Side_TLS
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128:AES256:AES:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
}
```

then, 

```
service nginx restart
```

if sudo service nginx restart give you something like this:

```
Stopping nginx:                                            [FAILED]
Starting nginx: nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] still could not bind()
```

then kill the process manually by their port:

`sudo fuser -k 80/tcp` (or use whatever port you are using)

alternatively, kill the processes by their ID:

```
ps -ef |grep nginx
kill <pid>
```

## Reference

1. [https://digitz.org/blog/lets-encrypt-ssl-centos-7-setup/](https://digitz.org/blog/lets-encrypt-ssl-centos-7-setup/)
2. [https://jayyang.win/free-lets-encrypt-multi-domain-ssl/](https://jayyang.win/free-lets-encrypt-multi-domain-ssl/)
3. [https://ruby-china.org/topics/31942](https://ruby-china.org/topics/31942)