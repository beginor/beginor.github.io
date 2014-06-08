---
layout: post
title: 在 mono 下尝试 ASP.NET MVC vNext
description: 
keywords: asp.net vnext, mono, mvc vnext
tags: [Mono, MVC, Linux]
---

## 从源代码编译最新版本的 mono

![Mono v3.6.1](/assets/post-images/mono-v3.6.1.png)

    sudo certmgr -ssl -m https://go.microsoft.com
    sudo certmgr -ssl -m https://nugetgallery.blob.core.windows.net
    sudo certmgr -ssl -m https://nuget.org
    sudo certmgr -ssl -m https://www.myget.org
    mozroots --import --sync

## Installing KVM and the K Runtime Environment

    curl https://raw.githubusercontent.com/graemechristie/Home/KvmShellImplementation/kvmsetup.sh | sh && source ~/.kre/kvm/kvm.sh && kvm upgrade

- download kvm.sh and save it in ~/.kre/kvm/kvm.sh
- add the command to run kvm.sh on every login to bash/zsh.
- kvm.sh will then be run via the source command. This adds the kvm command to the current shell.
- run kvm upgrade. This will download the latest KRE package, extract it to .kre/packages and add the bin folder to your path.

## Run asp.net Home 

### ConsoleApp

### HelloWeb

### HelloMvc

## MVC vNext



[1]: http://graemechristie.github.io/graemechristie/blog/2014/05/26/asp-dot-net-vnext-on-osx-and-linux/ "ASP.NET vNext on OSX and Linux"
[2]: http://beginor.github.io/2013/10/15/install-and-config-mono-on-ubuntu-server.html "在 Ubuntu Server 上安装配置 Mono 生产环境"
[3]: http://www.cnblogs.com/shanyou/p/3218611.html "CentOS 6.3下 安装 Mono 3.2 和Jexus 5.4"