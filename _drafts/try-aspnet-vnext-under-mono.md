---
layout: post
title: 在 mono 下尝试 ASP.NET MVC vNext
description: 
keywords: asp.net vnext, mono, mvc vnext
tags: [Mono, MVC, Linux]
---

## 从源代码编译最新版本的 mono

网上已经有很多从源代码安装 mono 的资料了， 所以就不再啰嗦了， 没有做过的可以参考这两篇文章：

- [在 Ubuntu Server 上安装配置 Mono 生产环境][2]
- [CentOS 6.3下 安装 Mono 3.2 和Jexus 5.4][3]

推荐用 git 从源代码获取 mono 源代码的方式来编译安装， 以后更新也很方便。 我获取 mono 最新版
源代码编译安装之后， 版本信息如下图所示：

![Mono v3.6.1](/assets/post-images/mono-v3.6.1.png)

对于某些 linux 发行版， 可能还没有下列网站的 https 证书， 因此需要导入并同步一下几个网站的
https 证书， 否则无法继续后面的 asp.net vNext 的安装 （参考自 [ASP.NET vNext on OSX and Linux][1]）。

    sudo certmgr -ssl -m https://go.microsoft.com
    sudo certmgr -ssl -m https://nugetgallery.blob.core.windows.net
    sudo certmgr -ssl -m https://nuget.org
    sudo certmgr -ssl -m https://www.myget.org
    mozroots --import --sync

## 安装 KVM 和 K 运行时环境

通过下面的命令来安装 KVM 和 K 运行时：

    # 克隆 aspnet_home
    git clone https://github.com/aspnet/Home.git aspnet_home
    # 切换到下载目录， 并执行 kvmsetup.sh
    cd aspnet_home
    ./kvmsetup.sh
    # 将 ~/.kre/kvm/kvm.sh 添加到 $PATH 环境变量
    source ~/.kre/kvm/kvm.sh
    # 更新 kvm
    kvm upgrade

## 运行示例程序

微软在 [https://github.com/aspnet/Home][4] 提供了三个示例程序， 分别是 `samples` 目录下的
`ConsoleApp` 、 `HelloWeb` 和 `HelloMVC` ， 接下来分别运行这三个程序。

### 运行命令行程序 ConsoleApp

按照 ReadMe.md 中的提示， 依次输入下面的命令， 运行 ConsoleApp ：

    cd aspnet_home/samples/ConsoleApp
    kpm restore
    k run

没有错误的话， 能看到下面的 `Hello World` 输出。

![ConsoleApp](/assets/post-images/k-runtime-hello-world.png)

再输入 `export KRE_TRACE=1` ， 再次运行 `k run` ， 则可以看到详细的诊断信息， 如下图所示：

![ConsoleApp](/assets/post-images/k-runtime-hello-world-with-trace.png)

到现在一直都是按照 ReadMe.md 中的说明进行的， 是不是有点儿小兴奋呢？ 别急， 继续运行剩下的两个
示例程序。

### 运行 web 应用程序 HelloWeb 和 HelloMvc

微软并没有在 ReadMe.md 这两个例子中给出在 mono 环境下运行的方法， 按照上面的方法， 切换到例子
所在的目录， 并执行 `kpm restore` 和 `k web` ， 果然提示出错， 无法运行： 

![HelloWeb HelloMvc](/assets/post-images/k-run-hello-web-and-hello-mvc-fails.png)

<div class="alert alert-danger">
在 mono 上运行 asp.net vNext 只能到此为止了， 目前这个错误无解， 或者我还没找到 。。。
</div>

[1]: http://graemechristie.github.io/graemechristie/blog/2014/05/26/asp-dot-net-vnext-on-osx-and-linux/ "ASP.NET vNext on OSX and Linux"
[2]: http://beginor.github.io/2013/10/15/install-and-config-mono-on-ubuntu-server.html "在 Ubuntu Server 上安装配置 Mono 生产环境"
[3]: http://www.cnblogs.com/shanyou/p/3218611.html "CentOS 6.3下 安装 Mono 3.2 和Jexus 5.4"
[4]: https://github.com/aspnet/Home "asp.net Home"