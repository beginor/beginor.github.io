---
layout: post2
title: 安装 Docker 环境
description: 在 Ubuntu 系统下安装 Docker 环境
keywords: Docker, Ubuntu
tags: [Docker, Linux]
---

## Docker 简介

Docker 是一个开源的应用容器引擎， 让开发者可以打包他们的应用以及依赖包到一个可移植的容器中， 然后发布到任何流行的 Linux 机器上， 也可以实现虚拟化。 容器是完全使用沙箱机制，相互之间不会有任何接口。

![Whale Logo](/assets/post-images/whale-logo332.png)

Docker 的理念是交付运行环境如同海运， OS 如同一个货轮， 每一个在 OS 基础上的软件都如同一个集装箱， 用户可以通过标准化手段自由组装运行环境， 同时集装箱的内容可以由用户自定义， 也可以由专业人员制造。 这样， 交付一个软件， 就是一系列标准化组件的集合的交付， 如同乐高积木， 用户只需要选择合适的积木组合， 并且在最顶端署上自己的名字(最后个标准化组件是用户的 app )。

![docker](/assets/post-images/docker-group.png)

## 安装 Docker 运行时

### 用户权限

安装 Docker 需要 `sudo` 或 `root` 权限， 推荐使用 `sudo` ， 如果你的账户没有权限， 请使用下面的命令来添加：

```sh
sudo usermod -a -G sudo $USER
```

### 使用 Docker 官方源安装

1、 设置 Docker CE 仓库

在 Ubuntu 系统上设置 Docker CE 仓库。 使用 `lsb_release -cs` 命令打印你的 Ubuntu 版本的名字， 比如： `xenial` 或者 `trusty` 。

```sh
sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl
```

```sh
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

```sh
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
```

```sh
sudo apt-get update
```

2、 获取 Docker CE

使用下面的命令安装最新版本的 Docker CE ：

```sh
sudo apt-get install -y docker-ce
```

3、 测试 Docker CE 安装

在命令行窗口， 输入下面的命令：

```sh
sudo docker --version
```

如果安装成功， 输出如下所示：

```
Client:
 Version:      17.03.1-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:10:36 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.03.1-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:10:36 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

### 将用户添加到 docker 用户组

现在可以使用 docker 了， 不过每次都要使用 `sudo` 行， 在生产环境也还可以接受， 但是在自己的开发环境下也这这样就太不爽了， 解决方法就是将当前用户添加到 docker 用户组， 方法如下：

1、 如果没有 `docker` 组， 则先创建一个：

```sh
sudo groupadd docker
```

2、 将当前用户添加到 `docker` 用户组：

```sh
sudo usermod -aG docker $USER
```

3、 注销并重新登录， 在输入 `docker version` 测试一下， 如果出现和上面一致的信息， 则表示成功了。

现在， 总算是可以开心的玩 Docker 了！
