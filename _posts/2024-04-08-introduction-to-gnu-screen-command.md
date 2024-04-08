---
layout: post2
title: GNU Screen 命令简介
description: 简单介绍 GNU Screen 命令常见用法
keywords: linux, shell, gnu screen, background task, split pane, terminal
tags: [参考, Linux]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

![GNU Screen](/assets/post-images/20240408103805.png)

在操作 Linux 服务器时， 经常需要同时使用多个命令， 比如开着 `htop` 查看服务器负载， 同时调整配置等。虽然可以使用高级的客户端终端 (`iTerm2`, `Microsoft Terminal`) 同时建立多个连接到服务器， 但是有些服务器需要二次认证， 甚至不允许一个帐号进行多个连接，同时连接有的时候也会很不方便。 所以在服务器的终端内进行分屏也是有一定需要的。 [GNU Screen](https://www.gnu.org/software/screen/) 可以说是终端分屏/多任务的利器， 而且大多数的 Linux 服务器默认安装， 至少也是在默认的软件源中， 不需要添加第三方源， 安装与使用非常方便。

## 工作模式

`Screen` 的工作模式类似于 `vim/vi` 编辑器， 可分为操作模式和命令模式：

- 操作模式： 在此模式下，可以正常的输入各种指令， 和普通的 Shell 差不多；
- 命令模式： 在操作模式下， 按 `Ctrl + A` 就会进入命令模式， 可以实现终端分屏、断开会话、重连会话以及在多个会话中切换等操作；

## 后台命令

`Screen` 最常用的操作之一是执行后台命令， 常见的数据备份与同步命令， 往往执行的时间会比较长， 就可以使用 `Screen` 来执行， 示例步骤为：

1. 在终端中直接输入 `screen` ， 就会自动创建一个新的会话， 并进入这个会话；
2. 在会话可以执行任意 shell 命令， 比如 `htop` ；
3. 在 Screen 会话中按快捷键 `Ctrl + A` `d` ，即可断开当前会话， 第 2 步输入的命令会继续在后台执行， 当前窗口恢复到输入 screen 命令之前的状态；
4. 输入 `screen -ls` 可以查看所有的会话， 输出如下：

   ![screen list](/assets/post-images/20240116175423.png)

5. 再次输入 `screen -r [session name]` 即可恢复对应的会话状态；

利用 screen 来执行后台命令非常的方便，而且可以随时恢复会话状态， 查看执行状况。

> 如果不需要查看执行状态， 单纯的是后台命令则可以使用 Sub Shell 来执行。

## 终端分区

终端分区才是 screen 的强大之处， 可以将一个终端分成多个区域。 现代化的软件 (iTerm2, Microsoft Terminal, VSCode, Sublime 等) 都提供了分屏的功能, 让用户可以同时处理多个文档或多个任务。 screen 则可以在同一个终端内实现屏幕分区， 且各个分区相互独立， 互不干扰。

要使用屏幕分区， 就要掌握 screen 的命令模式， 这个与 vi/vim 的工作模式很类似， 如果熟悉 vi/vim 的话， 将会有非常熟悉的感觉。

1. 准备工作

   打开命令终端， 输入 `screen` 命令， 得到如下提示，

   ![screen greeting](/assets/post-images/20240408100712.png)

   然后按空格键或者回车键即可。

2. 水平分区

   在 screen 创建的终端中， 按 `Ctrl+A` ， 再按 `Shift+S` ， 即可水平分区， 如下图所示：

   ![horizontal split](/assets/post-images/20240408101635.png)

3. 垂直分区

   在 screen 终端中， 按 `Ctrl+A` ， 再按 `Shift+\` ， 即可垂直分区， 如下图所示：

   ![vertical split](/assets/post-images/20240408101927.png)

4. 切换活动分区

   现在创建了多个分区， 但是光标还在第一个分区内， 要切换分区， 则需要快捷键 `Ctrl+A` ， 再按 `Tab` ， 就会切换到下一个分区， 如果要继续切换， 则需要再次按 `Ctrl+A` 和 `Tab` 。

   ![switch active pane](/assets/post-images/20240408102440.png)

   如果切换到的分区还没有创建会话， 则需要按快捷键 `Ctrl+A` ， 再按 `c` 即可创建会话。

   ![create new session in pane](/assets/post-images/20240408102533.png)

5. 关闭分区

   推出会话之后， 分区还在， 如果要关闭分区， 则需要按快捷键 `Ctrl+A` ， 再按 `Shift+X` 即可。

## 配置文件

可以使用 `$HOME/.screenrc` 文件对 screen 命令进行自定义配置， 而且网上已经有很多网友分享的配置文件。

GNU Sceren 是一个在终端内分屏的软件， Win/Lin/Mac 都可以运行， 熟练了之后，感觉可以把 iTerm2 给删掉了。
