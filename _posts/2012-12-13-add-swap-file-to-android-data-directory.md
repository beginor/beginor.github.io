---
layout: post
title: 在 Android 的 /data 目录下添加虚拟内存
description: Android 的 /data 目录使用手机内部存储存取速度比 SD 卡要快， 在空间足够的情况下， 应该是添加虚拟内存的首选， 本文讲述如何在 /data 目录下添加虚拟内存。
tags: [Android]
---

## 在 Android 的 /data 目录下添加虚拟内存

Android 系统上添加虚拟内存已经不是什么新鲜事了， 很多手机都支持， 通常都是将虚拟内存添加到 SD 卡上， 不过由于 SD 卡的的读写速度有速度限制， 再加上如果不是用高速的 SD 卡的话， 将虚拟内存添加到 SD 卡上的效果就不是很明显了， 其实还有一个地方可以添加虚拟内存， 那就是 /data 目录。 为什么把虚拟内存添加到 /data 目录呢， 原因如下：

### 1、 /data 目录有足够的的剩余空间容纳虚拟内存

几乎所有的 Android 手机都支持 App2SD 或者 App2Ext ，  将应用安装到 SD 卡之后， /data 目录剩余的空间比较大， 是足以容纳下虚拟内存需要的空间。

### 2、 存取速度比 SD 卡要快

/data 目录使用手机内部的 flash 存储器， 内置存储比外加的 SD 卡品质要好很多， 读写速度也比 SD 卡要快很多。

鉴于以上的两个优点， 将虚拟内存添加到 /data 目录应该是首选， 以我手上的 Moto Milestone 为例， 由于手机很旧， 只有 256 内存， 如果想运行最新的 CM9 或者 CM10 的话， 内存明显紧张， 好在最新版的 CM10 安装之后将很多系统文件都移动到了 /sd-ext 分区， /data 目录下剩余空间达 160M 多， 因此可以考虑在 /data 目录下添加 64M 的虚拟内存。 

原来在 /sd-ext 分区启用虚拟内存的脚本为：

	#!/system/bin/sh

	# turn swap if it file exists /sd-ext/swap.swp
	if [ -e /sd-ext/swap.swp ];
	then
		busybox swapon /sd-ext/swap.swp
	fi;

脚本很简单， 检查一下如果 /sd-ext 目录下存在 swap.swp 文件的话， 就将它挂载为虚拟内存。 现在就将 swap.swp 文件复制到 /data 目录下， 并将脚本修改为：

	#!/system/bin/sh

	# turn swap if it file exists /data/swap.swp
	if [ -e /data/swap.swp ];
	then
		busybox swapon /data/swap.swp
	fi;

运行发现不能挂载虚拟内存， 得到的提示是：

	swapon: /data/swap.swp: Invalid argument

看来不能按照原来的方式添加虚拟内存， 经过一番搜索， 在 xda 论坛上找到了[解决方法](http://forum.xda-developers.com/showthread.php?t=586750)， 就是将 swap.swp 文件模拟成一个设备， 然后将这个设备挂载为虚拟内存， 最终挂载虚拟内存的脚本如下：

	#!/system/bin/sh

	# turn swap if it file exists /data/swap.swp
	if [ -e /data/swap.swp ];
	then
		losetup /dev/block/loop0 /data/swap.swp
		busybox swapon /dev/block/loop0
	fi;

将这个脚本复制到 /data/local/userinit.d 目录或者保存为 /data/local/userinit.sh ， 重启手机就可以自动挂载虚拟内存了。