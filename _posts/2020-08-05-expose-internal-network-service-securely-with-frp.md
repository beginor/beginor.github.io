---
layout: post2
title: 使用 frp 安全的暴露内网服务
description: 介绍如何使用 frp 安全的暴露内网服务
keywords: frp frps frpc, 安全, 内网服务, 内网穿透
tags: [参考,教程]
---

[frp](https://github.com/fatedier/frp) frp 是一个可用于内网穿透的高性能的反向代理应用，支持 tcp, udp 协议，并且为 http 和 https 应用协议提供了额外的能力。

最近需要将内网的一些服务转发出来， 在自己的电脑上随时可用， 于是就研究了 frp 的文档， 操作记录如下。

## frp 服务器配置

要使用 frp 进行内网穿透， 必须有一台有互联网 IP 的服务器， 否则没办法架设 frp 服务器。 服务器上根据操作系统安装 frp 的服务端， frps ， 配置如下：

```ini
[common]
bind_addr = 0.0.0.0
bind_port = 7000
bind_udp_port = 7001
log_file = /usr/frp/frps.log
# trace, debug, info, warn, error
log_level = info
log_max_days = 3

# set dashboard_addr and dashboard_port to view dashboard of frps
# dashboard_addr's default value is same with bind_addr
# dashboard is available only if dashboard_port is set
dashboard_addr = 0.0.0.0
dashboard_port = 7500

# dashboard user and pwd for basic auth protect, if not set, both default value is admin
dashboard_user = admin
dashboard_pwd = dashbord_password

# auth
authentication_method = token
token = frp_server_token
```

配置完成之后， 在服务端用下面的命令可以启动 frp 服务端：

```bash
/usr/frp/frps -c /usr/frp/frps.ini
```

## 内网服务配置

内网服务器上根据操作系统， 下载对应的 frp 客户端 frps ， 以 ssh 服务为例， 配置文件如下：

```ini
[common]
server_addr = server_ip_or_name
server_port = 7000
# for authentication
token = frp_server_token
# decide if exit program when first login failed, otherwise continuous relogin to frps
# default is true
login_fail_exit = false

[internal_ssh]
type = stcp
sk = internal_ssh_sk
use_encryption = true
use_compression = true
local_ip = 127.0.0.1
local_port = 22
```

> 注意， 这里使用的是 stcp 模式， 没有使用 tcp 模式， 更加安全。 因为 tcp 模式会将内网服务端口直接暴露在互联网， 风险比较大。

配置文件编写好之后， 在内网服务器上运行下面的命令， 启动 frp 客户端：

```bash
/usr/frp/frpc -c /usr/frp/frpc.ini
```

## 客户端配置

通过 stcp 模式进行穿透的服务， 需要在客户端计算机上也运行一个 frp 的客户端 frpc， 配置如下所示：

```ini
[common]
server_addr = server_ip_or_name
server_port = 7000
# for authentication
token = frp_server_token

[internal_ssh_visitor]
type = stcp
role = visitor
sk = internal_ssh_sk
server_name = internal_ssh
use_encryption = true
use_compression = true
bind_ip = 127.0.0.1
bind_port = 1022
```

> 注意： visitor 中配置的 `sk` 和 `server_name` 必须与内网服务器上的 frpc 的配置一致， 而且 `bind_ip` 只能是 `127.0.0.1` 。

配置文件保存之后， 在客户端计算机上也运行下面的命令， 启动 frp 客户端：

```bash
/usr/frp/frpc -c /usr/frp/frpc.ini
```

现在， 在命令行窗口输入下面的命令， 就可以连接到内网服务器的 ssh 服务了：

```bash
ssh -p 1022 user@127.0.0.1
```
