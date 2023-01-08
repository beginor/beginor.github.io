---
layout: post2
title: Switch 模拟器 Ryujinx 在 Mac M1 上的体验
description: 如何在 Mac M1 上安装 Ryujinx 模拟器以及使用 Ryujinx 玩 Swtich 上的游戏
keywords: macos, macbook pro, m1 max, apple silicon, ryujinx, switch emulator
tags: [参考, macOS]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## Ryujinx 模拟器安装与初始化

[Ryujinx](https://ryujinx.org/) 是一个开源的任天堂 Switch 模拟器，由 [gdkchan](https://github.com/gdkchan) 创建， 用 C# 编写。 这个模拟器的目标是提供出色的准确性和性能， 一个用户友好的界面， 以及一致的构建。

为什么要装这个 Ryuginx 模拟器呢， 原因如下：

1. 上面说了， Ryujinx 是用 C# 编写的， 作为一个多年使用 C# 程序的程序员， 倍感亲切， 肯定要支持一下；
2. Ryujinx 适配了 Mac M1 芯片， 这更要体验一下了；
3. 任天堂的游戏评价很高， 一直想体验一下， 至于为什么不买个 Switch 则不在本文讨论范围内。

Ryujinx 的安装还是挺简单的， 直接从 [Mac Release Channel](https://github.com/Ryujinx/release-channel-macos/releases) 下载最新版， 解压到 `/Applications` 目录或者 `~/Applications` 目录即可。

主要是初始化设置， 根据官方的设置指南，需要下载 Switch 的密钥 (`prod.keys` 和 `title.keys`) 以及系统固件 (Firmware) ， 由于版权的原因， Ryujinx 并没有提供下载链接。

不过好在有完成的搜索， 在这个网站 <https://prodkeys.net> 上可以找到 Switch 最新的密钥和系统固件， 建议下载中文的固件， 这样打开支持中文的游戏， 默认的界面就会是中文了。

- 密钥有两个文件， `prod.keys` 和 `title.keys`， 退出 Ryujinx ， 将这两个文件放到 `~/.config/Ryujinx/system` 目录。

- 系统固件下载下来一般会是个 Firmware.zip 文件， 这个文件不用解压， 启动 Ryujinx ， 在工具菜单 (Tools)  下选择安装固件 (Install Firmware)， 然后选择从 XCI 或者 ZIP 安装固件 (Install Firmware from XCI or Zip) ， 选择下载好的系统固件文件安装即可。

调整 Ryujinx 默认的选项与设置：

- 选项 > 更改语言， 这里的设置模拟器自身的显示语言， 不是 Switch 系统的；
- 选项 > 设置 > 输入， 可以设置输入方式， 可以选择键盘或者手柄， macOS 支持很多种手柄， 比如 Xbox 手柄、 PS 手柄， Switch 手柄以及 iOS 的 MFi 手柄；
- 选项 > 设置 > 系统， 将系统区域设置为 `中国` ， 系统语言设置为 `中文(简体)` , 系统时区设置为 `Asia/Shanghai` ， 系统时钟设置为当前时间， 注意 `启用 VSync` 一定要勾选， 否则稳定性会变差， 闪退机率会高很多；
- 选项 > 设置 > CPU , `Use Hypervisor` 不要勾选， 否则稳定性也会降低， 增加闪退机率；
- 选项 > 设置 > 日志， 可以全部取消勾选；
- 其它的选项可以保持默认；

Ryujinx 支持多用户， 点击 `选项` > `管理用户账户` 菜单， 可以管理多个用户账户， 每个用户都有自己的档案， 保存自己的游戏记录等。

- 建议不要使用也不要删除默认的用户 `RyuPlayer`；
- 新建一个自己的用户， 并激活；

完成上面的设置之后， 再下载到你喜欢的 Switch 游戏， 就可以玩了。

至于 Switch 游戏哪里来， 如果你有卡带的话， 可以用特殊的工具导出来， 网上也有不少教程， 可以自己动手试一下。 当然也可以下载别人共享的， 比如 [xxxxx 520](https://xxxxx520.com/) 就有很多网友共享的 Switch 游戏， 下载自己喜欢的即可。

对于 Ryujinx 模拟器来说， 尽量下载 XCI 格式的游戏文件， 兼容性好一些。

## 游戏体验

![塞尔达传说-旷野之息](/assets/post-images/ryujinx_capture.jpg)

以 Switch 上著名的游戏 `塞尔达传说-旷野之息` 为例（没错， 就是传说中被 `原神` 致敬 (chaoxi) 的游戏）， 游戏体验大概是这样这样：

- 游戏画面： 主机模式（ Docked 相当于 Switch 连接到电视机） 下输出的分辨率为全高清 1920x1080 ,  便携模式下输出模式为 1280x720 ， 也就是 Switch 的原生分辨率， 如果有高性能独立显卡的话， 模拟器可以设置更高的输出分辨率；
- 游戏刷新率： `塞尔达传说-旷野之息` 是 Switch 平台的大型游戏， 游戏刷新率平均是每秒 20 帧左右， 简单场景可以到 30 帧 (Switch 满帧就是30 帧)， 在电脑的屏幕上， 还是能感觉到较明显的卡顿， 属于基本能玩的水平。 如果是玩一些小型的游戏， 则全部可以以 30 帧来运行。

  > 模拟器可以通过有金手指来调整刷新率，强制 60 帧来运行， 我就没有尝试了。

- 资源占用： Ryujinx 在 MacBook 14 M1 Max 上运行 `塞尔达传说-旷野之息` 这样的大型游戏时， 资源占用情况为：

  - CPU 差不多占满 2 个效能核 + 2 个性能核， 外加两个性能核的一半， 从活动监视器里面看到 CPU 占用为 310% 上下浮动；
  - 显卡占用在活动监视器中看到的数值在 60% 上下波动， GPU 历史窗口几乎占满了；
  - 内存占用 8.5G 左右；

  ![GPU History](/assets/post-images/ryujinx-gpu-history.png)

  ![CPU History](/assets/post-images/ryujinx-cpu-history.png)

  ![CPU](/assets/post-images/ryujinx-cpu.png)

  ![Memory](/assets/post-images/ryujinx-mem.png)

- 功耗与散热： 使用 Ryujinx 运行游戏时虽然占用大量的 CPU 和 GPU 资源， 但是整体功耗也不大， 散热压力不大， 只需用 `Mac Fans Control` 软件将风扇固定在 3000 转， 即可轻松压制， 噪声也几乎可以忽略了；

- 电池续航： 这个是最拉的， 满电估计只能运行 2 小时左右。

- 手柄支持： macOS 支持 Xbox/PS 手柄， 但是键位不够用， 比如 Switch 有特殊的 `+` 和 `-` 键， macOS 还支持 MFi 认证的手柄， 我刚好有一个 MFi 手柄， 在 iPad 上游戏或者使用 PlayCover 玩 iOS 游戏都能完美的识别， 但是 Ryujinx 却不能正确识别， 已经按照 Ryujinx 官方的提示， 向 SDL 项目提交了问题以及对应的手柄配置， 希望在将来的版本中能够支持。

## 总结

Ryujinx 是为数不多， 或者是仅有的适配苹果原生 M1 芯片的模拟器， 在 Mac M1 上算是基本能用的状态， 而且标记为[可以玩](https://github.com/Ryujinx/Ryujinx-Games-List/issues?q=is%3Aissue+is%3Aopen+label%3Astatus-playable)的游戏也很多， 如果你想尝试， 也未尝不可。

我觉得 Ryujinx 目前模拟的效率比较低， 貌似没有发挥 M1 芯片的全部能力， 比如不能使用 Hypervisor ， 显卡的能力也没有完全发挥出来， Ryujinx 官方也发布了 [MacOS upstreaming roadmap](https://github.com/Ryujinx/Ryujinx/issues/4062) ， 看来官方还是比较重视 MacOS 的， 一起期待未来的版本吧。

最后， 希望 Ryujinx 能够像 [PlayCover](https://playcover.io) 和 [PPSSPP](https://ppsspp.org) 那样完美！
