---
layout: post
title: 使用 Intel HAXM 为 Android 模拟器加速，媲美真机
description: Android 模拟器一直以运行速度慢著称， 本文介绍使用 Intel HAXM 技术为 Android 模拟器加速， 使模拟器运行度媲美真机， 彻底解决模拟器运行慢的问题。
tags: [Android]
---

## 使用 Intel HAXM 为 Android 模拟器加速，媲美真机

Android 模拟器一直以运行速度慢著称， 本文介绍使用 Intel HAXM 技术为 Android 模拟器加速， 使模拟器运行度媲美真机， 彻底解决模拟器运行慢的问题。

Intel HAXM (Hardware Accelerated Execution Manager) 使用基于 Intel(R) Virtualization Technology (VT) 的硬件加速， 因此需要 CPU 支持 VT ， 而且仅限于 Intel CPU， 与 AMD CPU 无缘， Intel HAXM 的描述如下：

-    使用 Intel VT 技术；
-    为 Android x86 虚拟设备的模拟运行提供硬件加速；
-    与 Android SDK 集成；

硬件需求如下：

-    支持 VT-x, EM64T 以及 Execute Disable Bit 的 Intel 处理器；
-    至少 1GB 可用内存

支持的操作系统：

-    Windows 7 (32/64-bit)
-    Windows Vista (32/64-bit)
-    Windows XP (32-bit only)
-    OS X 10.6 or 10.7 (32/64-bit)

## 下载并安装 Intel HAXM 扩展

启动 Android SDK Manager， 在 Package 列表的最下面就是要用到的 Intel HAXM 扩展， 打勾， 下载， 不用去 Intel 的网站， 如下图：

![下载并安装 Intel HAXM 扩展][image1]

下载 HAXM 之后， 需要运行安装程序来进行安装， HAXM 下载的目录是 `android-sdk\extras\intel\Hardware_Accelerated_Execution_Manager` , 运行 `IntelHaxm.exe` 进行安装， 屏幕提示，一步一步安装即可。

## 下载 Android x86 镜像

Android SDK Manager 中已经有了 4.1.2 的 x86 镜像， 因此选择 4.1.2 x86 镜像， 如下图所示：

![下载 Android x86 镜像][image2]

## 使用 Android x86 镜像

新建或者编辑 Android 模拟器， 将模拟器 CPU/ABI 设置为 `Intel Atom X86` ， 如下图所示：

![配置 Android 模拟器使用 x86 系统镜像][image3]

如果上面的步骤都没有出错， 现在， Android 模拟器运行的速度几乎可以媲美真机了， 再也不用羡慕 MAC 平台上的 iOS 模拟器。

[image1]: /assets/post-images/select-install-intel-x86-haxm-in-sdk-manager.png
[image2]: /assets/post-images/select-download-android-x86-sys-image.png
[image3]: /assets/post-images/config-android-emulator-to-use-x86-system-image.png

