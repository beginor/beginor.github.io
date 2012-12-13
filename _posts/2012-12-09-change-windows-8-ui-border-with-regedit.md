---
layout: post
title: 通过注册表调整 Windows 8 窗口边框宽度
description: Windows 8 的窗口界面已经不再有半透明的 Aero 效果， 但是窗口的边框还是那么宽，在这个流行窄边框的时代， 显得是那么的格格不入， 本文介绍通过修改注册表调整 Windows 8 的窗口宽度。
tags: [参考]
---

Windows 8 的窗口界面已经不再有半透明的 Aero 效果， 但是窗口的边框还是那么宽，在这个流行窄边框的时代， 显得是那么的格格不入， 本文介绍通过修改注册表调整 Windows 8 的窗口宽度。

先看看 Windows 8 默认的边框， 很宽的， 和 Windows 7 的一样宽， 但是没有 Areo 效果， 总觉得有点儿难看， 如下图：

![Windows 8 默认窗口边框](/assets/post-images/windows8-default-border.png)

按下快捷键 `Win + R` ， 输入 `regedit` ， 打开注册表编辑器， 找到 `HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics`， 如下图所示：

![通过注册表调整 Windows 8 窗口边框宽度](/assets/post-images/Change_Window_Border_Size_Windows_8.png) 

需要修改这两个键 `BorderWidth` 和 `PaddedBorderWidth` ， 它们的默认值分别是 -15 和 -60 ， 分别双击这两个键， 将它们的值都改为 0 ， 然后关闭注册表编辑器。

接下来需要注销一下， 重新登录之后再进到桌面模式， 就会看到所有窗口的边框都已经变窄了：

![修改过的 Windows 8 窗口边框](/assets/post-images/windows8-thind-border.png)

如果想恢复默认的边框， 只要把这两个注册表键的值改回其默认值即可。 