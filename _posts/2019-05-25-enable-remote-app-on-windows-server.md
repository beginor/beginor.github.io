---
layout: post2
title: 在 Windows 系统上启用远程应用
description: 介绍一种通过修改注册表的方法启用 Windows 远程应用
keywords: remote desktop, remote app, mstsc
tags: [参考]
---

需要一个远程桌面 App 进行演示， 安装 Windows 远程桌面服务太折腾， 需要安装域控制器， 再部署一整套的远程服务， 太折腾了， 如果只是演示的话， 没必要那么折腾。

本文介绍一种通过修改注册表来启用远程应用的方法， 可以用于远程应用演示。

## 在 Windows 上允许远程桌面访问

这个没什么好说的， 非常简单， 在`系统属性`中设置`允许远程连接到此计算机`即可。

## 修改注册表， 创建远程应用

- 打开注册表编辑器， 导航到 `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList` 节点；
- 找到 `TSAppAllowList`， 将 `fDisableAllowList` 的值改为 `1` ；
- 在 `TSAppAllowList` 节点下， 新建 `项 (K)` ， 名称为 `Applications` ;
- 在 `Applications` 节点下， 新建 `项 (K)` ， 名称任意， 比如 `Notepad` ；
- 在 `Notepad` 节点下， 新建 `字符串值 (S)` ， 名称为 `Name` ， 值为 `Notepad` ；
- 在 `Notepad` 节点下， 新建 `字符串值 (S)` ， 名称为 `Path` ， 值为 `C:\Windows\System32\notepad.exe` ；

> 可以在 `Applications` 节点下创建任意多的节点， 理论上如果程序没有限制， 都可以作为远程应用；

## 编辑 RDP 文件， 使用远程应用

- 打开 Windows 附件中的 `远程桌面连接` 程序， 输入服务器的地址， 确认能够连接到服务器的远程桌面；
- 将远程桌面连接保存为 rdp 文件（`显示选项` -> `另存为 ...`）； 
- 用记事本打开保存的 rdp 文件， 做如下修改：
  - 将 `remoteapplicationmode:i:0` 修改为 `remoteapplicationmode:i:1` ；
  - 将 `multimon:i:0` 修改为 `multimon:i:1` ；
  - 添加设置 `remoteapplicationprogram:s:Notepad` ；
  - 添加设置 `disableremoteappcapscheck:i:1` ；
  - 添加设置 `alternate shell:s:rdpinit.exe` ；
- 保存 rdp 文件。

现在， 双击打开 rdp 文件， 就可以自动打开服务器上的记事本程序了。

## 设置 RDP 超时时间

当关闭远程应用时， 服务器并不会立刻终止远程会话， 因此需要在服务器上设置远程会话超时时间

- 搜索 `gpedit.msc` ， 打开组策略编辑器；
- 依次找到 `计算机配置` -> `管理模板` -> `Windows 组件` -> `远程桌面服务` -> `远程桌面会话主机` -> `会话时间限制`
- 将 `设置活动但空闲的远程桌面服务会话的时间限制` 配置为 `已启用` ， 将空闲会话限制设置为 `1 分钟` 。

这样， 当用户关闭远程应用 1 分钟之后， 就会自动注销。

## 参考

- [RDP Settings for Remote Desktop Services](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ff393699(v%3dws.10))
- [How to enable RemoteApp (via RDP 7.0) within VirtualBox or VMWare running Windows 7, Vista SP1+ or Windows XP SP3](http://geekswithblogs.net/twickers/archive/2009/12/18/137048.aspx)
- [Overview of .rdp file settings](https://www.donkz.nl/overview-rdp-file-settings/)
- [RemoteApp Tool](https://sites.google.com/site/kimknight/remoteapptool)


