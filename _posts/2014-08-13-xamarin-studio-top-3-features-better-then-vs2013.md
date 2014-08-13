---
layout: post
title: Xamarin Studio 比 Visual Studio 2013 好用的三个功能
description: 
tags: [Xamarin]
keywords: Xamarin Studio, nuget, shared project, reference
---

Xamarin Studio 最近发布了 5.2 版本， 带来了一些相当棒的特性， 其中有一些特性甚至超越了
Visual Studio 2013， 接下来就介绍我认为最棒的并且比 VS2013 要好用的三个特性：

## NuGet 包管理

Visual Studio 对 NuGet 包的管理是通过对话框来管理的， 如下图所示：

![Visual Studio NuGet 包管理对话框](/assets/post-images/vs-nuget-dialog.png)

对 NuGet 包的添加、 更新、 删除等操作都在这个对话框内完成， 不过缺点也是每次都得打开这个对话
框。 Xamarin Studio 提供一些更加人性化的管理方式， 一部分功能可以通过上右键下文菜单来管理，
不需要打开包管理对话框。

**自动检查更新**

打开一个带有 NuGet 包引用的项目时， Xamarin Studio 会自动检查项目引用的包有没有新版本， 如
果有新版本， 则会在对应的节点上提示新版本， 如下图所示：

![自动检查更新](/assets/post-images/xs-nuget-auto-check-update.png)

**一键更新还原**

当引用的 nuget 包有新版本时， 可以直接在包的节点上点击右键， 选择更新， 或者在包目录上右键，
选择更新全部有新版本的包， 而不必像 Visual Studio 那样打开  NuGet 包管理对话框， 如下图所
示：

![更新还原](/assets/post-images/xs-nuget-update-restore.png)

如果需要的包需不是最新版本的， 只要修改一下 `packages.config` 文件里的对应包的版本号， 同样
右键选择 “还原 (Restore) ” 即可。

这一点与 Visual Studio 比起来还是方便很多的， 得打开包管理控制台， 输入这样一条命令才行：

``` ps
PM> Install-Package package-id -Version package-version
```

**重新指定目标**

如果你在项目中使用了便携式类库项目 (PCL Library Project) ， 调整了类库的目标之后， 对应的
nuget 包也要重新添加， 在 Visual Studio 中， 是通过删除重新添加来实现的， 或者输入命令：

``` ps
update-package -reinstall
```

但是在 Xamarin Studio 中， 只需要点击一下右键， 选择 “ReTarget” 即可， 如下图所示：

![重新指定目标](/assets/post-images/xs-nuget-retarget.png)

## Shared Project 项目

Visual Studio 中的 Shared Project 让多项目中的文件链接成为历史， 但是只支持 WinPhone 和
WinStore 两种项目类型， 其它项目类型 (Web, Library, PCL, Silverlight, WPF ...) 都不支
持， 真是让人不爽， 不是不能支持， 只是不让你用而已， 其实就是一句 `MSBuild` 指令而已， 手工
编辑一下项目文件就行。

**创建 Shared Project **

然而， Xamarin Studio 则提供了比较广泛的 Shared Project 项目支持， 可以单独创建 Shared
Project， 所有项目类型都可以引用 Shared Project ， 如下图所示：

![创建 Shared Project](/assets/post-images/xs-shared-project-support.png)

这一点还是非常赞的。

## 项目引用

Xamarin Studio 还有一点比较好的是对项目引用的分类， 来自包的引用单独作为一组， 这样看起来更
加清晰：

![项目引用分类](/assets/post-images/xs-reference-category.png)

特别是对于便携式类库项目， 这样的分类看起来非常清楚：

![项目引用分类](/assets/post-images/xs-reference-category-2.png)

以上三个功能是我认为最好的， 比 Visual Studio 做的要好的三个特性， 当然 Xamarin Studio
还有很多很好的特性， 就不再列举了， 希望这个开源的 IDE 能越来越好用！