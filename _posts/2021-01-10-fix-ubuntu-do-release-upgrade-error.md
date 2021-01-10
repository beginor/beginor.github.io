---
layout: post2
title: 修复 Ubuntu 无法进行版本更新的错误
description: 修复 Ubuntu 无法进行版本更新的错误
keywords: ubuntu, do-release-upgrade, failed to connect, meta-release-lts, ssl
tags: [Linux, 参考]
---

将 Ubuntu 服务器从 18.04 升级到 20.04 ， 在执行 `do-release-upgrade` 时提示无法检查新版本， 完整的错误信息如下：

```txt
Checking for a new Ubuntu release
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings
There is no development version of an LTS available.
To upgrade to the latest non-LTS develoment release
set Prompt=normal in /etc/update-manager/release-upgrades.
```

于是先用 ping 命令测试网络连接性：

```shell
ping -c 4 changelogs.ubuntu.com

PING changelogs.ubuntu.com (91.189.88.185) 56(84) bytes of data.
64 bytes from 91.189.88.185 (91.189.88.185): icmp_seq=1 ttl=46 time=235 ms
64 bytes from 91.189.88.185 (91.189.88.185): icmp_seq=2 ttl=46 time=237 ms
64 bytes from 91.189.88.185 (91.189.88.185): icmp_seq=3 ttl=46 time=235 ms
64 bytes from 91.189.88.185 (91.189.88.185): icmp_seq=4 ttl=46 time=235 ms

--- changelogs.ubuntu.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3001ms
rtt min/avg/max/mdev = 234.613/235.262/237.087/1.054 ms
```

可以 ping 通， 网络是没问题的。 用 curl 测试一下 <https://changelogs.ubuntu.com/meta-release-lts> ， 看是不是 Ubuntu 的 changelogs 服务器问题

```shell
curl https://changelogs.ubuntu.com/meta-release-lts

Dist: dapper
Name: Dapper Drake
Version: 6.06 LTS
Date: Thu, 01 Jun 2006 9:00:00 UTC
Supported: 0
Description: This is the Dapper Drake release
Release-File: http://old-releases.ubuntu.com/ubuntu/dists/dapper/Release
ReleaseNotes: http://changelogs.ubuntu.com/EOLReleaseAnnouncement
UpgradeTool: http://old-releases.ubuntu.com/ubuntu/dists/dapper/main/dist-upgrader-all/current/dapper.tar.gz
UpgradeToolSignature: http://old-releases.ubuntu.com/ubuntu/dists/dapper/main/dist-upgrader-all/current/dapper.tar.gz.gpg
```

可以用 curl 获取到内容， changelogs 服务器看来也是没问题的。

因为是用 https 访问 changelogs 服务器， 突然想到会不会是因为 https 证书没有同步的导致的呢？ 于是再尝试刷新一下服务器上的证书：

```sh
sudo update-ca-certificates --verbose --fresh
export SSL_CERT_DIR=/etc/ssl/certs
```

刷新完 https 证书之后， 再次运行 `do-release-upgrade` ， 还是提示同样的错误。

经过一番搜索， 发现修改 `MetaRelease.py` 文件可以忽略证书的错误

```shell
sudo nano /usr/lib/python3/dist-packages/UpdateManager/Core/MetaRelease.py
```

修改内容如下：

```diff
from __future__ import absolute_import, print_function

+ import ssl
+ ssl._create_default_https_context = ssl._create_unverified_context

import apt
import apt_pkg
```

保存修改过后的 `MetaRelease.py` ， 再次运行 `do-release-upgrade` ， 终于可以进行更新了。
