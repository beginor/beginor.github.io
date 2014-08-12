---
layout: post
title: Xamarin Studio 比 Visual Studio 2013 好用的三个功能
description: 
tags: [Xamarin]
keywords: Xamarin Studio, nuget, shared project, reference
---

Xamarin Studio 最近发布了 5.2 版本， 带来了一些相当棒的特性， 其中有一些特性甚至
超越了 Visual Studio 2013， 接下来就介绍我认为最棒的并且比 VS2013 要好用的三个特
性：

## NuGet 包管理

Visual Studio 对 NuGet 包的管理是通过对话框来管理的， 如下图所示：

![Visual Studio NuGet 包管理对话框](/assets/post-images/vs-nuget-dialog.png)

对 NuGet 包的添加、 更新、 删除等操作都在这个对话框内完成， 不过缺点也是每次都得
打开这个对话框。 Xamarin Studio 提供一些更加人性化的管理方式， 一部分功能可以通
过上右键下文菜单来管理， 不需要打开包管理对话框。

**自动检查更新**

打开一个带有 NuGet 包引用的项目时， Xamarin Studio 会自动检查项目引用的包有没有新
版本， 如果有新版本， 则会在对应的节点上提示新版本， 如下图所示：

![自动检查更新](/assets/post-images/xs-nuget-auto-check-update.png)

**一键更新还原**

![更新还原](/assets/post-images/xs-nuget-update-restore.png)

**重新指定目标**

![重新指定目标](/assets/post-images/xs-nuget-retarget.png)

## Shared Project 项目

**创建 Shared Project **

![创建 Shared Project](/assets/post-images/xs-shared-project-support.png)

## 项目引用

![项目引用分类](/assets/post-images/xs-reference-category.png)

![项目引用分类](/assets/post-images/xs-reference-category-2.png)