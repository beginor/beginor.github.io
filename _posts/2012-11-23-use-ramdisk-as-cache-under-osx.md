---
layout: post
title: 在 Mac OS X 中创建和使用内存盘
description: 在 Windows 系统上一直使用 ImDisk 创建内存盘作为缓存， 将系统临时目录、 浏览器缓存等设置到内存盘， 这样做的好处是很明显的, 现在转到 Mac OS X 平台， 当然也要使用内存盘了， 在 OS X 系统上， 创建和使用内存盘比较容易的， 而且不需要借助第三方软件， 只是设置稍微繁琐一些， 在 OS X 系统上创建和使用内存盘的步骤如下
tags: [OSX]
---

在 Windows 系统上一直使用 ImDisk 创建内存盘作为缓存， 将系统临时目录、 浏览器缓存等设置到内存盘， 这样做的好处是很明显的：

1、 内存盘不用定时清理， 系统重启就自动清空  
2、 读写内存的速度是非常快的， 程序运行速度也会加快很多

现在转到 Mac OS X 平台， 当然也要使用内存盘了， 在 OS X 系统上， 创建和使用内存盘比较容易的， 而且不需要借助第三方软件， 只是设置稍微繁琐一些， 在 OS X 系统上创建和使用内存盘的步骤如下：

1、 打开 AppleScript Editor（找不到的可以直接用 Spotlight 搜索）；

2、 输入下面的脚本：

	do shell script "
	if ! test -e /Volumes/\"Ramdisk\" ; then
	diskutil erasevolume HFS+ \"RamDisk\" `hdiutil attach -nomount ram://1048576`
	fi
	"

注意： ram://1048576 表示内存盘大小， 对应 512M (1024 * 2 * 512) 的内存盘，  如果需要自定义大小， 根据这个公式计算。 1G 就要 1024 * 2 * 1024 ， 2G 依次类推。 内存盘不是越大越好， 也不是越小越好， 要根据自己的内存容量选择合适的大小。 我的 MBP 4G 内存， 创建 512M 内存盘。

3、 将这个脚本保存为应用程序， 如下图所示：

![Save as App](/assets/post-images/create-ram-disk-sava-as-app.png)

保存好之后， 可以先执行一下， 看有没有挂载一个名称为 RamDisk 的内存盘， 加载好了如下图所示：

![RamDisk Quick Look](/assets/post-images/ramdisk-quick-look.png)

4、 接下来需要把缓存目录设置到内存盘， 打开一个命令行窗口， 在命令行窗口输入下面的命令：

	sudo rm -rf ~/Library/Caches
	ln -s /Volumes/RamDisk/ ~/Library/Caches

先删除自己用户目录下的缓存目录，再将 ~/Library/Caches 链接到 /Volumes/RamDisk/ ， 完成之后测试一下， 随便打开一个程序， 看看 RamDisk 下面有没有生成对应的临时目录， 如果有， 就表示成功了， 如果没有， 就要再自己检查一下步骤了。

5、 将 RamDisk 设置为启动项， 打开 System Preference/Users & Groups ， 选择自己的用户名， 点击 Login Items ， 添加第 2 步保存的应用即可。

**注意问题**

1、 系统运行中不要 unmount ramdisk ， 否则可能会出现不可预料的后果；  
2、 如果用的是 SSD 硬盘， 就不要再设置内存盘了， SSD 的速度已经很快了；