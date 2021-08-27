---
layout: post2
title: Windows 远程桌面优化设置
description: 关于 Windows 远程桌面优化设置
keywords: windows, remote desktop, regedit, gpedit
tags: [参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## 修改默认端口 (可选)

1. 启动注册表编辑器 （在“搜索”框中键入 regedit）;
2. 导航到以下注册表子项：`HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp` ;
3. 查找端口号 (PortNumber) ;
4. 单击“编辑”>“修改” ，然后单击“十进制” ;
5. 键入新端口号，然后单击 “确定”;
6. 关闭注册表编辑器， 然后重新启动计算机;

> 下次使用远程桌面连接连接到此计算机时，必须键入新端口。 如果正在使用防火墙，请确保将防火墙配置为允许连接到新端口号。

## 调整帧率

1. 启动注册表编辑器;
2. 定位到键值 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations`;
3. 新建 `DWORD (32位) 值`， 名称为 `DWMFRAMEINTERVAL`;
4. 设置值为 10 进制的 `15` 或者 16 进制的 `F` ;

## 开启显卡加速以及 H264 编码

1. 启动组策略编辑器 (在“搜索”框中键入 gpedit.msc) ；
2. 依次找到 `计算机配置` -> `管理模板` -> `Windows 组件` -> `远程桌面服务` -> `远程桌面会话主机` -> `远程会话环境` ；
3. 设置 `将硬件图形适配器应用于所有远程桌面服务会话` 为启用；
4. 设置 `配置远程桌面连接的 H.264/AVC 硬件编码` 为启用；
5. 设置 `为远程桌面连接设置 H.264/AVC 444 图形模式的优先级` 为启用；
6. 设置 `为远程桌面连接使用 WDDM 图形显示驱动程序` 为启用；
7. 将 `RemoteFx for Windows Server` 下的 `配置 Remote FX` ， `使用 Remote FX 时优化视觉体验`， `为远程桌面服务优化视觉体验` 选项设置为启用；

> 比较消耗资源， 建议有独立显卡的电脑来才开启这些选项。 如果有 Nvidia 的显卡的话， 可以试试 MoonLight 串流。

## 重启电脑

重启之后， 再次使用远程桌面将会显著提升远程桌面的体验。
