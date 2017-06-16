---
layout: post
title: 从源代码编译安装 MonoDevelop 记录 
description: 介绍如何从源代码编译安装 MonoDevelop 开发工具
keywords: xamarin, monodevelop, build, source code
tags: [Xamarin, Mono]
---

Xamarin 官方源里面的 MonoDevelop 版本是 5.10 ，与官方发布的 Xamarin Studio 6.1 相比， 很多新特性不支持， 主要包括：

- 对 C# 6 语法支持的不够完善；
- 不支持 NUnit 3；
- 不支持 [roslyn](https://github.com/dotnet/roslyn) 编译器；

搜遍了官方的源， 包括 alpha 、 nightly 、 ci 通道， 都找不到编译好的 MonoDevelop 包， 在 launchpad 上也找不到第三方的 ppa 源， 看来只能自己动手编译 MonoDevelop 了。

**如果还没有安装 Mono ， 则需要添加 Xamarin 的 apt 源**， 代码如下：

```sh
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
sudo apt-get update
```

> Xamarin 官方源提供的 Mono 已经很新了， 而且更新也很及时， 没必要从源代码编译。

**添加必须的编译工具以及本地类库**

```sh
sudo apt install git-core autoconf automake cmake  libtool libssh2-1-dev zlib1g-dev
```

**安装 Mono 以及编译 MonoDevelop 的需要用到的依赖项**

```sh
sudo apt install mono-devel referenceassemblies-pcl fsharp gnome-sharp2 libglade2.0-cil-dev monodoc-base
```

**克隆 `MonoDevelop` 的源代码** 这一步可能需要很长的时间， 小水管的要沉得住气才行。

```sh
git clone -b cycle8-GM https://github.com/mono/monodevelop.git monodevelop
git submodule update --init --recursive
```

> 建议不要直接克隆 `master` 分支， 而是克隆 `release` 标签下已经归档的分支， 因为 `master` 分支上的可能会编译出错。

**配置下载好的源代码**， 准备编译

```sh
./configure --profile=stable
```

> 这一步可能会弹出缺少什么的错误， 不过没关系， 通过 `apt search` 命令可以找到， 然后执行 `apt install` 安装就行了。

**配置成功的截图**如下：

![Configure Success](/assets/post-images/configure-success.png)

看到类似这样的截图之后， 就可以继续了， 否则还得继续检查需要的库。 然后编译运行， 首次运行需要下载很多 nuget 包， 同样需要很长时间。

```sh
make run
```

> 如果网络不好的话， make 可能会出错， 重试几次。

编译成功之后， 运行截图如下：

![MonoDevelop](/assets/post-images/mono-develop-6.1.png)

试运行几次， 没有错误就可以直接安装了。

```sh
sudo make install
```
