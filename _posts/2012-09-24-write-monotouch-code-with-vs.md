---
title: 让 VS 编译 MonoTouch 项目源文件不再出错
description: 使用MonoTouch做iOS开发，通常会相应的建立两个项目，一个是MonoDevelop项目，在OSX下使用，一个是VS项目，在Windows下使用，VS项目在添加MonoTouch项目的CS源文件之后，经常编译出错，而且如果安装了Resharper之类的插件之话，也会得到一大堆错误信息，本文提供了一个比较好的解决方案。
layout: post
tags: [MonoTouch]
---

使用 MonoTouch 做 iOS 开发， 由于 MonoDevelop 和 VS 2010 相比， 功能差的太多， 通常会相应的建立两个项目， 一个是 MonoDevelop 项目， 在 OSX 下使用， 一个是 VS 项目， 在 Windows 下使用， 在 Windows 系统下进行编码， 之后再在 OSX 下进行调试。 不过， 默认的 VS 项目在添加 MonoTouch 项目的 CS 源文件之后， 经常编译出错， 而且如果安装了 Resharper 之类的插件之话， 也会得到一大堆错误信息， 令人感觉非常恶心。 经过一番研究发现是因为 VS 不能引用 MonoTouch 的几个核心 dll 文件导致的， 包括 mscorlib.dll ， System.dll ， System.Core.dll 等， 找到原因之后， 对应的解决方法就有了。

## 1、新建类库项目

新建项目， .Net Framework 选择 4.0 或以上， 项目类型选择类库项目， 项目名称为 MonoTouchLib ， 如下图所示：

![test](/assets/post-images/new-lib-proj.png)

## 2、设置项目编译属性

编辑项目属性， 选择 build 选项卡， Configuration 选择 All Configurations ， 点击右下角的 advanced 按钮， 在弹出的 Advanced Build Setting 对话框中勾选 Do not reference mscorlib.dll ， 如下图所示：

![test](/assets/post-images/adv-build-setting.png)

## 3、修改项目文件

右击 MonoTouchLib 项目， 在上下文菜单选择 Unload Project ， 再次右击， 选择 Edit MonoTouchLib.csproj ， 按照下图对项目文件进行修改：

![test](/assets/post-images/change-proj-file.png)

## 3、导出项目模版

修改好之后， 保存并重新加载项目即可。 把这个项目导出为项目模板， 以后就不用每次都重复设置了。

如果再要引用其它的 MonoTouch 组件， 可以尝试直接添加引用， 如果发现引用路径不正确的话， 还按照这个方法进行修改。

这样修改过后的项目， 不仅可以顺利编译 MonoTouch 项目的源文件， Resharper 也不再提示错误。