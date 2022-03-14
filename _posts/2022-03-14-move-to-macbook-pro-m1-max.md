---
layout: post2
title: 迁移到 MacBook Pro M1 Max
description: post description
keywords: macbookpro, m1max, wechat, log, docker, virtual machine, homebrew, shell
tags: [参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

记录从 MacBook Pro 2015 迁移到 MacBook Pro 2021 M1 时进行的一系列的折腾。

## 安装常用软件的 Arm 版本

虽然借助苹果的 Rosetta 转译程序， 可以直接运行原来的 x64 应用， 但是效率不高， 因此安装对应的 Arm 版本的软件才是最佳的选择。

从 AppStore 上下载的应用， 基本上已经都是通用 (Universal) 应用了， 只需要在新电脑上重新下载即可。 而不是在 AppStore 上下载的软件， 则只能自己去官方网站上寻找对应的 Arm 版本。

Rosetta 在最近几年内还是需要的， 毕竟有很多旧的软件还不支持 Arm 。

## 迁移微信的聊天记录

这个软件令人比较头疼， 但是又不得不安装， 而且没有官方的迁移方法， 只能手工按照下面的方法迁移：

1. 在新电脑上用 AppStore 安装微信， 打开登录一次；
2. 将旧电脑上的目录 `~/Library/Containers/WeChat` 直接用 AirDrop 发送到新电脑；
3. 在新电脑上将接收到的目录覆盖相同位置的目录， 应该也是 `~/Library/Containers/WeChat`；

> 也可以用同样的办法迁移 QQ 的聊天文件， 或者说从 AppStore 下载的软件都可以用这种方法进行迁移，当然这个没有试过， 仅仅测试了微信和QQ。

## 迁移项目文件

项目中有很多临时文件， 特别是 `node_modules` 目录， 占用大量的空间， 不仅复制过去非常的耗时， 而且就算复制过去了也不能直接使用， 因此把它们清理掉再迁移。

### 批量清理 node_modules 目录

查找制定目录下全部的 node_modules 目录并打印大小

在 Linux 和 Mac 上， 输入命令

```sh
find . -name "node_modules" -type d -prune -print | xargs du -chs
```

在 Windows 上，可以这样

```shell
FOR /d /r . %d in (node_modules) DO @IF EXIST "%d" echo %d"
```

### 将找到的 node_modules 目录删除

在 Linux 和 Mac 上， 输入命令

```sh
find . -name "node_modules" -type d -prune -print -exec rm -rf '{}' \;
```

在 Windows 上， 可以这样

```shell
FOR /d /r . %d in (node_modules) DO @IF EXIST "%d" rm -rf "%d"
```

如果有 Powershell ， 还可以这样

```powershell
Get-ChildItem -Path "." -Include "node_modules" -Recurse -Directory | Remove-Item -Recurse -Force
```

可以使用同样的办法来删除编译生成的临时文件，比如 `bin` 、 `obj` 、 `class` 、 `dist`  、`logs` 等临时目录；

清理完这些临时目录文件， 项目目录由 30G 缩减为 10G ， 然后再用 AirDrop 发送到新电脑即可。

> 上面清理目录的命令来自 [How to Delete ALL node_modules folders on your machine](https://trilon.io/blog/how-to-delete-all-nodemodules-recursively) ， 其中 Windows 和 Powershell 版本的没有经过测试。

## 全新安装 Homebrew

这个本来按照官网的命令可以直接安装就可以了， 但是由于目前的网络环境不佳直接导致无法克隆 `homebrew/core` 下来， 最后找到的办法是将环境变量 `HOMEBREW_CORE_GIT_REMOTE` 设置为 `git@github.com:Homebrew/homebrew-core.git` ， 即使用 ssh 地址才可以顺利克隆下来。

安装 Homebrew 的第三方 Cask 时， 也可以指定 git 代码库的地址， 比如：

```sh
brew tap beeftornado/rmtree git@github.com:beeftornado/homebrew-rmtree.git
```

接下来就是继续安装 Homebrew 下的包， 和原来的用法一致。

## Docker

DockerDesktop for Mac 已经适配 M1， 不过原来的 x64 镜像（特别是数据库）几乎都不能用， 不过大部分 Linux 镜像都有 Arm 版本， 碰到没有的也可以自己编译一个出来， 使用上影响不大。

但是编译出来的镜像也是 Arm 架构的， 不能直接部署到 x64 服务器上使用， 虽然可以强制性指定 `--platform linux/x64` 编译出 x64 版本的镜像， 但是又不能直接测试和使用， 看来还是不能完全脱离 Intel 机器。

## 虚拟机

试过 UTM 、 VMWare Fusion 、 Parallel Desktop ， 只能安装 Arm 版本的系统， 对 Linux 支持的比较好， Windows 的支持其实都一般， 毕竟官方是不支持虚拟 Windows 系统的。

如果确实想运行一些 Windows 软件的话， 还有一个选择，那就是 Wine 和 CrossOver ， Wine 只能运行 64 位的 Windows 软件， 而 CrossOver 则实现了 Wine32on64 ， 可以在运行 32 位的 Windows 软件， 只是版本稍微低一些。

Wine 和 CrossOver 可以使用第三方的 Homebrew 公示 [Gcenx/homebrew-wine](https://github.com/Gcenx/homebrew-wine) 来安装，也可以在 [releases](https://github.com/Gcenx/homebrew-wine/releases) 页面直接下载， 如果想尝试最新的 wine-devel  以及 wine-staging ， 则可以在 [Gcenx/macOS_Wine_builds](https://github.com/Gcenx/macOS_Wine_builds/releases) 下载。

> 最新的 wine-devel 内置 VKD3D (用 VulkanAPI 实现 Windows 的 DirectX) 对 Windows 游戏支持的比较好， 可以抽时间试一下前段时间白嫖的古墓丽影四部曲。

## USB 扩展

虽然有 HDMI 接口， 可以直接连接 HDMI 接口显示器、投影仪、电视机之类的， 但是如果需要连接 USB 键鼠 (虽然是键线分离的，但一般不能通过 USB Type-C 直接连接) 和 U 盘之类的话，OTG 线或扩展坞还是需要一个的。

不想买扩展坞的话，也许买一个带全功能 USB Type-C 的显示器是更好的选择， 比如 Dell 的 U2421E 。
