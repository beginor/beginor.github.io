---
layout: post2
title: .NET Core 3.x 单文件应用
description: .NET Core 3.x 单文件应用的内容路径
keywords: .net core 3.x, single file app, content location
tags: [.NET Core]
---

## 单文件应用简介

.NET Core 3.x 发布的单文件应用是自解压程序。

## 自解压路径

貌似是通过 `System.IO.Path.GetTempPath()` 来确定的

Windows 系统 `%TEMP%\.net\`

macOS 系统 `/var/folders/s8/q4c00lhx3k384hngtv9pmwv40000gn/T/.net/`

Linux 系统 `/var/tmp/.net/`

## 文件大小

.NET Core 3.x 发布的单文件应用文件最小大概是 30 兆左右， 和 Go 发布的 10 兆左右的单文件应用相比确实大一些， 但是如果在发布之后用 7zip 压缩一下， 也是 10 多兆， 和 Go 发布的单文件应用不相上下。
