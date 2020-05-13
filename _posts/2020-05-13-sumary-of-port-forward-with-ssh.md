---
layout: post2
title: SSH 端口转发小结
description: 介绍三种常用 ssh 端口转发
keywords: ssh, portforward, gatewayports, proxy, tcp turnel
tags: [Linux, SSH, 参考]
---

Linux 的 SSH 服务不仅仅能够远程登录和管理，还可以在本地计算机和服务器之间建立 TCP 通道， 实现代理、内网穿透、暴露内网服务等功能，简单可靠。

## 动态端口转发

将向本地指定端口发送的请求通过 SSH 服务器向外转发。 比如将 SSH 服务器作为一个代理服务器。

```bash
#!/bin/bash -e
ssh -C -T -N -D 127.0.0.1:8088 ubuntu@192.168.6.67
```

> 将 `127.0.0.1:8088` 作为一个 SOCKS4/5 的代理， 比如 `curl --proxy socks5://127.0.0.1:8088 https://www.google.com` 。

参数说明：

- `C` 请求压缩所有数据；
- `T` 禁用模拟终端；
- `N` 不执行远程指令， 常用于仅做端口转发；
- `D [local_ip:]port` 动态端口转发， 实现代理服务器， 支持 SOCKS4 和 SOCKS5 协议；

## 本地端口转发

将远程服务器的指定端口通过 SSH 服务器转发到本地计算机端口。 比如将内网服务器的远程桌面 (192.168.6.71:3389) 经过 SSH 服务器 (192.168.6.67) 转发到本地计算机的 3390 端口 (127.0.0.1:3390) 。

```bash
#!/bin/bash -e
ssh -C -T -N -L 127.0.0.1:3390:192.168.6.71:3389 ubuntu@192.168.6.67
```

> 访问 `127.0.0.1:3390` 就等于访问 `192.168.6.71:3389` 。

参数说明：

- `C` 压缩所有数据；
- `T` 禁用模拟终端；
- `N` 不执行远程指令， 常用于仅做端口转发；
- `L [local_ip:]local_port:remote_ip:remote_port` 本地端口和远程服务器IP端口的 TCP 隧道；

## 远程端口转发

将本地计算机的指定端口经过 SSH 服务器转发到远程服务器的指定端口。 比如将本地局域网计算机的服务 (IIS、NGINX、DB) 等经过 SSH 服务器暴露出去。

```bash
#!/bin/bash -e
ssh -T -N -R 192.168.6.67:9090:127.0.0.1:9090 ubuntu@192.168.6.67
```

> 访问 `192.168.6.67:9090` 就等于访问 `127.0.0.1:9090` 。

参数说明：

- `C` 压缩所有数据；
- `T` 禁用模拟终端；
- `N` 不执行远程指令， 常用于仅做端口转发；
- `R [ssh_server_ip:]ssh_server_port:local_ip:local_port` SSH 服务器到本地/局域网计算机的的 TCP 隧道；

> 如果不成功， SSH 服务可能默认没有启用远程端口转发， 需要编辑 SSH 服务器上的 `/etc/ssh/sshd_confif` 文件， 添加或者编辑 `GatewayPorts yes` 选项， 并重启 sshd 服务。

