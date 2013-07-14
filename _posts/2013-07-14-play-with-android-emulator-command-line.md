---
layout: post
title: 玩转安卓模拟器命令行
description: 讲述安卓模拟器命令行常用参数
tags: [Android]
keywords: 安卓模拟器, 启动模拟器, 屏幕缩放, 模拟网络, 网络速度, 网络延时, 快捷键
---

## 启动模拟器 ##

使用 `emulator -avd <name>` 来启动指定的安卓模拟器， 例如， 我的电脑上配置了下列模拟器：

![安卓模拟器列表](/assets/post-images/android-avd-list.jpg)

要启动名称为 "JB_Pad" 的模拟器， 只要输入下面的命令即可：

    emulator -avd JB_Pad

## 设置屏幕缩放 ##

上面的命令启动的模拟器是按照配置的实际分辨率启动的， 模拟器配置的是 800x400 就启动一个 800x400 的窗口， 如果配置的是 720x1280 就会启动一个 720x1280 的窗口， 这样不仅操作起来麻烦（模拟器只能用鼠标模拟触控）， 而且会占用更多的资源， 最重要的是， 通常手机都没那么大吧， 所以缩放屏幕是必须的， emulator 命令提供了 -scale 参数来设置屏幕缩放：

- 介于 0.1 到 3.0 的数字， 则表示缩放比例， 例如 `-scale 0.5` 表示将窗口缩小一半；
- 以 dpi 结尾的数字， 则表示以指定的 dpi 运行模拟器， 例如： `-scale 110dpi` 表示模拟器运行在 110dpi 的屏幕上；
- 关键字 auto ， 则系统会采用计算机屏幕的 dpi 自动选择合适的窗口大小。

将模拟器 JB_Pad 的屏幕缩小一半启动， 只要输入下面的命令：

    emultor -avd JB_Pad -scale 0.5

要模拟 320dpi 的屏幕， 则需要输入下面的命令：

    emulator -avd JB_Pad -scale 320dpi

当然， 也可以让模拟器自动选择大小启动：

    emulator -avd JB_Pad -scale auto

## 模拟网络 ##

模拟器还可以模拟不同网络状态下的网速和延时， 要模拟不同的网络速度， 使用 `-netspeed` 参数， 要模拟网络延时， 使用 `-netdelay`

可以模拟的网速参数如下：

    -netspeed gsm          GSM/CSD          (up: 14.4, down: 14.4)
    -netspeed hscsd        HSCSD            (up: 14.4, down: 43.2)
    -netspeed gprs         GPRS             (up: 40.0, down: 80.0)
    -netspeed edge         EDGE/EGPRS       (up: 118.4, down: 236.8)
    -netspeed umts         UMTS/3G          (up: 128.0, down: 1920.0)
    -netspeed hsdpa        HSDPA            (up: 348.0, down: 14400.0)
    -netspeed full         no limit         (up: 0.0, down: 0.0)

可以模拟的网络延时参数如下：

    -netdelay gprs         GPRS             (min 150, max 550)
    -netdelay edge         EDGE/EGPRS       (min 80, max 400)
    -netdelay umts         UMTS/3G          (min 35, max 200)
    -netdelay none         no latency       (min 0, max 0)
    -netdelay <num>        select exact latency
    -netdelay <min>:<max>   select min and max latencies

模拟器默认的网络参数是：

    Default network speed   is 'full'
    Default network latency is 'none'

让模拟器模拟运行 edge 网络环境， 启动命令为：

    emulator -avd JB_Pad -netspeed edge -netdelay edge

## 常用快捷键 ##

模拟器运行的快捷键也是必不可少的， 下面是常用的快捷键列表：

    HOME                    Home button
    F2, PAGEUP              Menu (Soft-Left) button
    Shift-F2, PAGEDOWN      Star (Soft-Right) button
    ESCAPE                  Back button
    F3                      Call/Dial button
    F4                      Hangup/EndCall button
    F7                      Power button
    F5                      Search button
    KEYPAD_PLUS, Ctrl-F5    Volume up button
    KEYPAD_MINUS, Ctrl-F6   Volume down button
    Ctrl-KEYPAD_5, Ctrl-F3  Camera button
    KEYPAD_7, Ctrl-F11      Switch to previous layout
    KEYPAD_9, Ctrl-F12      Switch to next layout
    F8                      Toggle cell network on/off
    F9                      Toggle code profiling
    Alt-ENTER               Toggle fullscreen mode
    F6                      Toggle trackball mode
    DELETE                  Show trackball
    KEYPAD_5                DPad center
    KEYPAD_4                DPad left
    KEYPAD_6                DPad right
    KEYPAD_8                DPad up
    KEYPAD_2                DPad down
    KEYPAD_MULTIPLY         Increase onion alpha
    KEYPAD_DIVIDE           Decrease onion alpha

## 总结 ##

安卓模拟器的命令行参数还有很多， 可以将常用的参数做成 BAT 命令或者开发工具的外部命令， 在开发的过程中还是能提高一些效率的， 比如我的 XamarinStudio 就配置了如下的命令：

![Xamarin Studio External Tools](/assets/post-images/emulator-as-external-tools.jpg)