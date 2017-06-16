---
layout: post
title: 在 Ubuntu 系统上配置 Nginx Git 服务器 
description: 在 Ubuntu 14.04 服务器上使用 Nginx 和 git-http-backend 搭建 git 服务
keywords: git, git-http-backend, nginx, ubuntu
tags: [Git, Linux, Nginx]
---

多年前发表过一篇[在 Windows 系统上配置 Apache Git 服务器](https://beginor.github.io/2013/03/01/config-apache-git-server-on-windows.html)的博文， 主要是用 Apache 的 Basic 认证 ＋ git-http-backend 实现， 现在需要在公司的 vps 上再部署一个类似的简单 git 服务器， 这次的软件环境如下：

- Ubuntu 14.04.4 LTS
- nginx/1.4.6 (Ubuntu)
- git version 1.9.1

使用 `git-http-backend` 搭建 git 服务的原理都是类似的， 主要是利用 web 服务器 (apache/nginx) 进行用户认证， 并将用户信息传递给 CGI 程序 `git-http-backend` ， 从而实现通过 http 完成 git 操作。

## 安装 git-core、 nginx 和 fcgiwrap

输入下面的命令安装需要的这三个软件包：

```sh
apt-get install git-core nginx fcgiwrap
```

## 配置 nginx

我的目的是在 nginx 的默认网站下添加一个虚拟目录 `/git/` ， 通过访问 `/git/xxx.git` 的形式来访问服务器上的 `xxx.git` 代码库， 这就需要修改一下 nginx 默认网站的配置文件 `/etc/nginx/sites-available/default` ， 添加下面的信息：

```
# 配置以 /git 开始的虚拟目录
location ~ /git(/.*) {
    # 使用 Basic 认证
    auth_basic "Restricted";
    # 认证的用户文件
    auth_basic_user_file /etc/nginx/passwd;
    # FastCGI 参数
    fastcgi_pass  unix:/var/run/fcgiwrap.socket;
    fastcgi_param SCRIPT_FILENAME /usr/lib/git-core/git-http-backend;
    fastcgi_param GIT_HTTP_EXPORT_ALL "";
    # git 库在服务器上的跟目录
    fastcgi_param GIT_PROJECT_ROOT    /var/git-repos;
    fastcgi_param PATH_INFO           $1;
    # 将认证用户信息传递给 fastcgi 程序
    fastcgi_param REMOTE_USER $remote_user;
    # 包涵默认的 fastcgi 参数；
    include       fastcgi_params;
    # 将允许客户端 post 的最大值调整为 100 兆
    max_client_body_size 100M;
}
```

## 创建 nginx 认证用户文件

参考 nginx [ngx http auth basic module](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html) ， 用户认证文件格式如下：

```
# comment
name1:password1
name2:password2:comment
name3:password3
```

可以使用 `htpasswd` 命令创建用户， 如果服务器上没有这个命令的话， 可以输入命令 `apt-get install apache2-utils` 来安装这个命令， 安装了这个命令之后， 就可以使用它来创建认证用户了， 比如要创建用户 user1， 输入命令如下：

```sh
htpasswd /etc/nginx/passwd user1
```

然后根据提示输入密码就可以了。

## 创建 git 代码库

上面配置的 git 跟目录是 `/var/git-repos` ， 我们在这个目录下初始化一个空的代码库， 命令如下：

```sh
cd /var/git-repos
git init --bare test.git
```

注意检查一下 test.git 的权限， 如果权限不足的话， 使用这个命令设置一下权限：

```sh
chmod a+rw -R test.git
```

## 重启 nginx 并测试

输入命令重启 nginx 并测试 git 服务：

```sh
nginx -s reload
git clone https://server-name/git/test.git
```
