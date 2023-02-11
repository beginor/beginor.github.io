---
layout: post2
title: 修复 Ubuntu 2204 Wi-Fi 热点无法连接问题
description: 本文说明如何修复 Ubuntu 2204 Wi-Fi 热点无法连接问题
keywords: Ubuntu, wifi-hotspot, wpa_supplicant
tags: [Linux, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

Ubuntu 升级到 Ubuntu 22.04 之后， 系统自带的 Wi-Fi 热点功能就不能用了， 共享的热点无法连接， 应该是 `wpa_supplicant-2.10` 导致的 (<https://blog.incompetent.me/2022/07/27/workaround-ubuntu-22-04-hotspot-stops-working/>) ， 目前最容易的做法就是将这个包降级至 `wpa_supplicant-2.9` ， 然后就一切正常， 记录如下。

## 添加降级所需的旧的存储库

使用 nano 编辑 `/etd/apt/source.list` 文件：

```sh
sudo nano /etc/apt/sources.list
```

将下面的配置添加到文件的结尾， 并保存：

```
deb http://old-releases.ubuntu.com/ubuntu/ impish main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ impish-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ impish-security main restricted universe multiverse
```

## 降级 wpasupplicant

运行下面的命令， 获取软件包更新并执行降级：

```sh
sudo apt update
sudo apt --allow-downgrades install wpasupplicant=2:2.9.0-21build1
```

将 `wpasupplicant` 标记为保持旧版本， 暂不更新：

```sh
sudo apt-mark hold wpasupplicant
```

标记之后， 执行 `sudo apt upgrade` 时就不会更新这个包了。

运行 `wpa_supplicant -v` ， 看一下输出， 不出意外的话， 应该看到如下提示：

```
wpa_supplicant -v
wpa_supplicant v2.9
Copyright (c) 2003-2019, Jouni Malinen <j@w1.fi> and contributors
```

降级完成之后， 重启系统， 再创建 Wi-Fi 热点就应该正常工作了。

> 同样的问题也可能出现在 Manjaro 21.3 、 Fedora 36 等包含了 `wpa_supplicant-2.10` 的 Linux 发行版中， 理论上都可以用这个方法解决。

## 使用命令行来管理无线网卡以及热点

目前的 Linux 系统一般都会使用 Network Manager 来管理网卡， Network Manager 提供了 nmcli 命令行工具来管理无线网卡， 通过它可以更加优雅的远程开关热点。

- 查看无线网络列表

  ```sh
  nmcli device wifi
  ```

- 开启无限网卡的 Wi-Fi 信号

  ```sh
  sudo nmcli radio wifi on
  ```

- 关闭无线网卡的 Wi-Fi 信号

  ```sh
  sudo nmcli radio wifi off
  ```

- 开启热点

  ```sh
  sudo nmcli device wifi hotspot
  ```

  > 这个命令还有更多的参数可以创建新的 Wi-Fi 热点， 可以参考 nmcli 的官方文档。 如果不想敲复杂的命令的话， 可以在设置界面先设置好热点的参数。

- 查看热点密码

  ```sh
  nmcli dev wifi show-password
  ```

  这个命令会输出一个二维码， 扫描就应该能获取到密码， 但是我测试失败了。

要了解更多 nmcli 的功能， 请查阅 <https://networkmanager.dev/docs/api/latest/nmcli.html> 。
