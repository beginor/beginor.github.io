---
layout: post
title: Sony Z13 系列笔记本安装 NVIDIA 官方最新版显卡驱动程序
description: Sony Z13 系列笔记本的驱动程序一直停留在 2010 年的版本， 在 Windows 7 下工作正常， 最近升级到了 Windows 8 ， 这个版本的驱动程序无法正常工作了， 由于 Z13 是 2010 年的产品， Sony 根本不打算提供 Windows 8 系统的驱动， 于是只好开始折腾， 想办法安装 NVIDIA 官方的驱动程序。 经过不懈的折腾， 总算搞好了， 现在总结如下：
tags: [教程]
---

Sony Z13 系列笔记本的驱动程序一直停留在 2010 年的版本， 在 Windows 7 下工作正常， 最近升级到了 Windows 8 ， 这个版本的驱动程序无法正常工作了， 由于 Z13 是 2010 年的产品， Sony 根本不打算提供 Windows 8 系统的驱动， 于是只好开始折腾， 想办法安装 NVIDIA 官方的驱动程序。 经过不懈的折腾， 总算搞好了， 现在总结如下：

**注意：** 1 和 2 两步仅仅针对 Windows 7、8 ， 如果你的系统还是 Windows XP ，则直接忽略。

### 1、 破解 Sony 的 BIOS 高级菜单 ###

Sony 笔记本的 BIOS 锁定了高级菜单， 屏蔽了很多高级的功能， 包括显卡切换策略， 因此必须先破解高级菜单才能继续。

英文教程在[这里](http://forum.notebookreview.com/sony/473226-insyde-hacking-new-vaio-z-advanced-menu-bios-44.html#post7932873)，现整理如下：

#### 准备工作 ####

**FreeDOS 启动 U 盘**

为什么是 DOS ？ 因为在 DOS 下可以直接读写 BIOS ， 下载 [UNetbootin](http://unetbootin.sourceforge.net/) ， 并根据提示做一个 FreeDos 启动 U 盘， 这个对于技术宅来说， 不是什么问题。

做好启动 U 盘之后， 下载这个 [FLASHZ1.EXE](http://computercowboy.com/downloads/FLASHZ1.EXE) ， 保存到 U 盘的根目录， 后面将使用这个工具在 FreeDOS 下读写 BIOS。

**Portable Python** 

修改 BIOS 的工具就是用 Python 编写的， 所以需要 Python 环境， 访问 [Portable Python](http://www.portablepython.com/wiki/Download) ， 下载 2.7.x 的最新版本并安装到 U 盘上。 

安装好之后， 下载 [advanced_menu.py](http://forum.notebookreview.com/attachments/sony/48026d1270415701-insyde-hacking-new-vaio-z-advanced-menu-bios-advanced_menu.zip) , 把压缩包的内容解压到 Portable Python 安装目录下的 App 目录内。

**修改 BIOS ，打开高级菜单**

重启， 选择从 FreeDOS 启动， 一切按照默认选项启动， 不要选择任何选项。 FreeDOS 启动之后， U 盘的盘符应该是 C： ， 切换到 C： ， 输入下面的命令提取 BIOS 文件：

	Flash t dump.rom /g

提取之后， 重启到 Windows 系统， 将 dump.rom 复制到 App 目录， 打开 Python 命令行， 并切换到 App 目录， 输入下面的命令修改提取的 BIOS 文件：

	python advanced_menu.py dump.rom new.rom

**注意：** 检查这个命令的输出， 如果有任何的错误信息， 就不要继续， 否则笔记本真的会变砖。

如果命令没有提示任何错误， 将声称的 new.rom 复制到 U 盘的根目录， 重启到 FreeDOS ， 输入下面的命令刷入修改过的 BIOS 文件：

	Flash t new.rom /f

如果你的 RP 很好的话， 一切 OK ， 重启笔记本， 按 F2 进入到 BIOS ， 就可以看到高级菜单了， 包括很多高级选项， 比如： 风扇控制、 内存运行频率、显卡切换策略等。

浏览过之后需要将显卡切换策略设置成 `Static` ， 默认的策略是 Auto ， 即根据操作系统自动选择， 如果安装的是 Windows XP 系统， 则自动切换为 `Static`， 如果是 Windows 7 或者 8， 则自动切换为 `Dynamic` 。 不过我们现在要固定设置成 `Static` 。

	VGA Switching Policy" = "Static"

### 2、 启用系统的驱动测试模式 ###

以管理员身份启动命令行窗口， 输入下面的命令

	bcdedit -set loadoptions DISABLE_INTEGRITY_CHECKS
	bcdedit -set TESTSIGNING ON


### 3、 安装 NVIDIA 最新版驱动 ###

访问 NVIDIA 的支持网站， 下载支持 [GT330](http://www.nvidia.cn/object/product_geforce_gt_330m_cn.html) 的[最新驱动程序](http://www.geforce.cn/drivers/results/55125)， 并解压到一个临时目录， 还需要做一些修改才能直接安装。

根据[这里](http://forum.notebookreview.com/sony/602497-latest-vpc-z1-330m-drivers-bios-hack-people.html)的提示， 打开 Display.Driver 目录下的 /nvszc.inf 文件， 查找：

	%NVIDIA_DEV.0A29.02% = Section010, PCI\VEN_10DE&DEV_0A29&SUBSYS_9067104D

替换为：

	%NVIDIA_DEV.0A29.02% = Section010, PCI\VEN_10DE&DEV_0A2B&SUBSYS_905A104D

这一修改理论上对 Z11/Z12/Z13/Z14 都可用， 但是我无法确认。

保存修改过的文件， 运行安装程序安装显卡驱动。

GT330 是比较旧的显卡， 安装最新的驱动程序在性能上应该没有什么提升， 但是可以在 Windows 8 下面正常工作， 可以更好的支持 WebGL 以及 OpenCL ， 支持 OpenGL 3.3， 对于开发者来说， 有一定的意义。 同时也会丧失一些功能， 比如双显卡自动切换， 要么选择 Speed 模式， 要么选择 Stamina 模式， 切换显卡模式需要重启。 而且根据亮度自动调整显示器亮度的功能也可能会确实， 需要手工调整亮度。