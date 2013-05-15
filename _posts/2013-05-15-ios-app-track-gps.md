---
layout: post
title: iOS 应用使用位置信息
description: 介绍 iOS 应用使用位置信息，以及如何在后台继续获取位置信息
tags: [iOS, Mono]
keywords: ios, track gps background, lock screen, switch app
---

最近要在 iOS 应用中添加位置信息， 需要满足的需求如下： 

1. 应用在前台时能够获取位置信息；
2. 通过切换、 Home 按键将应用切换到后台时，停止获取位置信息；
3. 应用程序在前台运行， 直接锁定屏幕时，能够继续获取位置信息；

接下来逐步实现这三个需求。

## 获取设备位置信息

在 iOS 上获取位置信息是很容易的， 网上的资料也很多， 我的代码如下：



## 在锁屏情况下继续更新 GPS 信息

## 为应用添加后台位置权限