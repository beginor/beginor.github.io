---
layout: post
title: 在 Mac OS X 上安装和配置 Wine
description: 在 Mac OS X 上安装和配置 Wine, WineTricks
keywords: Mac, OS X, HomeBrew, Brew, Wine, Winetricks
tags: [OSX, 教程]
---

Windows 上也有很多优秀的工具软件是 Mac 上没有的， 装虚拟机的话太浪费， 而且效率不高， 幸好可以通过 Wine 来运行 Windows 程序， 通过 HomeBrew 使得 Wine 的安装非常容易， 通过 WineTricks 来配置 Wine 也没有多大困难， 下面是我在 Mac 上安装和配置 Wine 的纪录。

## 安装 Wine 和 WineTricks

这一步推荐通过 [HomeBrew](http://brew.sh/) 进行安装， 命令如下：

```sh
brew install wine
brew install winetricks
```

装完之后先运行一下 `winecfg` 命令， 初始化配置， 什么也不用做， 每个标签页都点开看一下， 最后按 `OK` 按钮退出。

```sh
winecfg
```

## 安装常用的控件

需要从墙外网站下载很多文件， 所以开启 HTTP 代理是必须的， 我的代理设置如下

```sh
export HTTP_PROXY=127.0.0.1:8787
export HTTPS_PROXY=127.0.0.1:8787
```

接下来就是输入这些命令， 安装这些常用的控件， 不知道这些控件是做什么的， 请自行 Google ：

```sh
winetricks cmd
winetricks comctl32
winetricks comctl32ocx
winetricks comdlg32ocx
winetricks riched30
winetricks richtx32
winetricks mdac28
winetricks jet40
winetricks mfc42
winetricks msxml6
winetricks vb6run
winetricks vcrun2003
winetricks vcrun2005
winetricks vcrun2008
winetricks vcrun2012
winetricks vcrun2013
winetricks vcrun2015
winetricks vcrun6sp6
```

## 中文字体

当然是安装文泉驿了， 要求不要太高， 能显示就行了：

```sh
winetricks wenquanyi
winetricks fakechinese
```

## 系统设置

将 DirectDrawRenderer 设置为 opengl ， 据说会高效一些， 还有开启字体平滑：

```sh
winetricks ddr=opengl
winetricks fontsmooth=rgb
```

用 wine 运行 windows 程序时， 会在控制台输出大量的调试信息， 将下面的命令添加到 `.bash_profile` 可以禁用 wine 的调试输出：

```sh
export WINEDEBUG=-all
```
