---
layout: post2
title: Ubuntu 挂载网络共享存储详解
description: 详细介绍如何在 Ubuntu 系统下挂载网络共享存储
keywords: ubuntu, linux, mount, cifs, cifs-utils, samba
tags: [Linux, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

最近要在 Ubuntu 系统上挂载共享存储并进行一些备份和服务迁移， 没想到居然也还有一些坑， 于是记录如下。

## 安装 cifs-utils 工具

首先， `cifs-utils` 一定要安装， 系统自带的 `mount` 命令虽然也能用， 但是选项不多， 或者说不够多。 在 Ubuntu 系统上， 安装命令为：

```sh
sudo apt install cifs-utils
```

## 创建凭证文件

先创建一个凭证文件， 保存访问共享存储使用的用户名和密码， 这样会安全一些， 如果要多次挂载共享存储， 也可以共用这个凭证文件。

先创建 `/etc/credentials` 目录，

```sh
sudo mkdir /etc/credentials
```

编辑 `/etc/credentials/test` 文件， 保存共享存储的用户信息。

```sh
sudo nano /etc/credentials/test
```

这个文件的内容如下：

```
username=server_username
password=user_password
domain=domain
```

设置这个文件的所有者和权限，

```sh
sudo chown root:root /etc/credentials/test
sudo chmod 600 /etc/credentials/test
```

## 测试挂载共享存储

现在尝试使用这个凭证文件来测试挂载共享存储，将 `//192.168.0.2/test` 挂载到 `/mnt/test` 目录， 命令为：

```sh
sudo mount -t cifs -o credentials=/etc/credentials/test //192.168.0.2/test /mnt/test
```

如果没有错误提示， 则表示挂载成功。

> 如果没有安装 `cifs-utils` ， 就会出现错误提示， 因为不支持 `credentials` 参数。

但是这样挂载的目录 `/mnt/test` 下的目录、文件的所有者属于 root 用户， 只有 root 能正常使用， 其它用户必须通过 sudo 命令才能使用。 而当服务无法使用 root 用户时， 就无法直接使用共享存储了。

通过查阅 [mount.cifs](https://linux.die.net/man/8/mount.cifs) 的帮助信息， 发现在挂载共享目录时还可以指定用户ID、用户组ID、文件及目录模式。

查询当前用户的ID信息可以直接使用 `id` 命令， 比如：

```sh
id

uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),120(lpadmin),131(lxd),132(sambashare),998(docker)
```

其它用户的可以命令 `grep username /etc/passwd` 来查找

```sh
grep ubuntu /etc/passwd

ubuntu:x:1000:1000:ubuntu,,,:/home/ubuntu:/bin/bash
```

找到用户的 `uid` 和 `gid` 之后， 就可以在挂载命令时指定挂载目录下的文件所有者， 也可以同时指定目录及文件的权限， 命令如下：

```sh
sudo mount -t cifs -o credentials=/etc/credentials/test,uid=1001,gid=1002,dir_mode=0755,file_mode=0755,iocharset=utf8 //192.168.0.2/test /mnt/test
```

这样挂载的目录 `/mnt/test` ， uid 为 1000 的用户可以直接使用， 不需要再借助 `sudo` 。

## 自动挂载共享存储

如果要在系统启动时自动挂载共享存储， 需要将挂载信息保存在 `/etc/fstab` 文件中， 在文件中添加下面的内容， 和上面的命令差不多：

```sh
# <file system>     <mount point>   <type>  <options>       <dump>  <pass>
//192.168.0.2/test  /mnt/test       cifs    credentials=/etc/credentials/test,uid=1001,gid=1002,dir_mode=0755,file_mode=0755,iocharset=utf8 0 0
```

保存 `/etc/fstab` 文件之后， 用 `mount` 命令测试一下

```sh
mount /mnt/test
```

如果没有任何错误提示， 就可以正常使用了。
