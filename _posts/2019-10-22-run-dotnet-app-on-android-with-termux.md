---
layout: post2
title: 在安卓手机上通过 Termux 运行编译/运行 .NET 应用
description: 介绍如何在安卓手机上通过 Termux 来编译运行 .NET 应用
keywords: termux, android, mono, .net,
tags: [教程]
---

## Termux 简介

Termux 可谓安卓上的开发神器， 注意， 不是开发安卓应用， 是在安卓手机上做开发的神器， 它的官方简介如下：

> **Termux** is an **Android terminal emulator and Linux environment app** that works directly with no rooting or setup required. A minimal base system is installed automatically - additional packages are available using the APT package manager.

简单说它就是一个带有最小化 Linux 系统环境的终端模拟器， 支持 APT 包管理器， 可以通过 `apt` 命令安装自己需要的 Linux 应用。

如果还没有接触过 Termux ，可以看一下这篇 <a href="http://www.huangpan.net/posts/ji-ke/2019-08-19-termux.html" target="_blank">《Termux 学习笔记》</a> ， 介绍的非常全面。

Termux 自带了很多常用的应用， 不仅包括 `git`， `wget`， `curl` 等常用的工具软件， 而且也有 `nodejs`， `phtyon`， `perl`， `cmake`， `clang` 等开发软件， 如果要在手机上运行 nodejs 进行前端开发的话， 只需要在 Termux 中输入 `apt install nodejs` 即可。

## 安装 Mono 环境

作为一名 .NET 开发者， 也希望能够在安卓手机上运行 .NET 应用， 不过目前 Termux 并没有自带相关的程序包， 所以安装起来稍微有一些麻烦。 安卓系统是基于 Linux 系统的， 而 Linux 系统上的 .NET 实现是 Mono 。 已经有热心网友 [IanusInferus](https://github.com/IanusInferus) 成功在 [Termux 上编译安装 mono](https://github.com/IanusInferus/termux-mono) 了， 并且提供了编译好的 [termux-mono](https://github.com/IanusInferus/termux-mono/releases) 下载。

在手机上安装编译好的 `termux-mono` ， 只需要在手机上输入如下命令：

```sh
cd $PREFIX
wget https://github.com/IanusInferus/termux-mono/releases/download/v20191019/mono-termux.6.4.0.198.tar.xz
tar Jxf mono-termux.6.4.0.198.tar.xz
rm mono-termux.6.4.0.198.tar.xz
```

然后在 `~/.bash_profile` 文件中添加一行， 将 mono 添加到 `$PATH` 变量:

```sh
export PATH=$PREFIX/local/bin:$PREFIX/bin:$PREFIX/bin/applets:$PATH
```

完成之后，可以退出 termux 再打开， 分别输入 `mono --version` 验证一下， 在手机上的截图如下所示：

![mono --version](/assets/post-images/Screenshot_20191020-193852_Termux.png)

## 编译运行 .NET 应用

在手机上编译一个 `Hello world` 应用试一下， 截图如下：

![.net hello world with termux on android](/assets/post-images/Screenshot_20191020-203459_Termux.png)

## 其它扩展

Termux 有很强的扩展性， 比如可以安装 `htop` 来查看系统资源， 如下图所示：

![htop](/assets/post-images/Screenshot_20191022-153852_Termux.png)
