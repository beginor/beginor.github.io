---
layout: post2
title: 使用 frp 安全的暴露内网服务
description: 介绍如何使用 frp 安全的暴露内网服务
keywords: frp frps frpc, 安全, 内网服务, 内网穿透
tags: [参考,教程]
---

## frp 服务器配置

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

## 内网服务配置

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

## 客户端配置

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
