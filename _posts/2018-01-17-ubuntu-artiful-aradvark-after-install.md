---
layout: post2
title: Ubuntu 17.10 安装折腾记录
description: 介绍如何在 Ubuntu 17.10 中安装原生的 GNOME 环境
keywords: ubuntu, artiful aradvark, stock gnome, gnome
tags: [Linux]
---

Ubuntu 17.10 发布已经有一段时间了， 终于下定决心全新安装， 安装系统容易， 下载 iso 直接安装即可， 安装之后要配置自己习惯的桌面环境确需要不少的时间。 下面是安装后基本的折腾记录。

![Ubuntu 17.10](/assets/post-images/ubuntu-17-10.png)

> 如果电脑是 EFI 启动的， 只需要把 iso 的内容复制到 U 盘根目录即可启动， 不需要在费心的去格式化做什么启动盘了， 真是省心！

### 清理不用的软件

删除 firefox ， 因为我用 Chrome ：

```sh
sudo apt remove --purge firefox
```

删除亚马逊链接， 不知道为什么， Ubuntu 的所有版本中都有这个， 还不如给老马家带个链接有用：

```
sudo apt remove --purge ubuntu-web-launchers
```

删除内置的 libreoffice ， 随后装个 wps 或者 wine 一个 office ， 都比这个要好：

```
sudo apt remove --purge libreoffice-common
```

删除 thunderbird ， 从来都不用这个邮件客户端：

```
sudo apt remove --purge thunderbird
```

删除 transmission ，随后安装 aria2 ， 比这个好用多了：

```
sudo apt remove --purge transmission
```

删除内置的 rhythmbox 和 totem ， 从来没用过这两个东西：

```
sudo apt remove --purge rhythmbox totem
```

删除内置的游戏， 简单而且无聊，就别浪费空间了， ssd 很贵的：

```
sudo apt remove --purge gnome-mines gnome-mahjongg gnome-sudoku
``` 

删除内置的 imagemagick ， 随后安装 gimp ：

```
sudo apt remove --purge imagemagick 
```

## 安装原生 GNOME 环境

个人比较喜欢 GNOME ， 所以之前一直使用 Ubuntu GNOME ， 虽然 Ubuntu 17.10 采用了 GNOME ， 但是经过一番魔改之后， 默认居然和 unity 一模一样了， 所以还是得装回原生的 GNOME 环境。

动手安装之前， 先更新一下：

```
sudo apt update
```

安装原生的 gnome session ， 装完之后， 会在登录界面的选项中多一个 GNOME 选项：

```
sudo apt install gnome-session
```

安装 GNOME 的常用软件 map 、 weather 、 music 、 photos、 web 等：

```
sudo apt install gnome-maps gnome-weather gnome-music gnome-photos epiphany-browser 
```

原生 GNOME 桌面背景， 这个可是必不可少的：

```
sudo apt install gnome-backgrounds
```

恢复原生 gdm 登录界面：

```
sudo update-alternatives --config gdm3.css
```

然后选择第二个 `gnome-shell.css` ， 输入 `1`

## 中文输入法

不知为什么， Ubuntu 17.10 居然内置了一个傻乎乎的 [ibus-sunpinyin](https://github.com/sunpinyin/sunpinyin) ， 好久没有更新， 设置界面出错， 果断删除， 换上常用的 ibus-pinyin ：

```
sudo apt remove --purge ibus-sunpinyin
sudo apt install ibus-pinyin
```
完成之后， 重启 ibus 输入法：

```
sudo ibus-daemon -d -x -r
```

现在可以在 `Settings` > `Region & Language` > `Input sources` 中添加 pinyin 输入法， 个人觉得， 这个用起来比较顺手。

最后， 可能会有一残留文件需要清理一下：

```
sudo apt autoremove
```

现在， 重新启动， 在登录窗口的选项中， 选择 `GNOME` ，输入密码登录， 就可以使用非常接近原生的 GNOME 环境了 ！

