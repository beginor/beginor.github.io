---
layout: post2
title: 关于 .NET 发布单文件应用
description: .NET Core 3.x 以及 .NET 5 单文件应用
keywords: .net core 3.x, .net 5, single file app, content location
tags: [.NET Core, .NET]
---

## 单文件应用简介

.NET Core 3.x 发布的单文件应用是自解压程序， 解压路径貌似是通过 `System.IO.Path.GetTempPath()` 来确定的：

- Windows 系统 `%TEMP%\.net\`
- macOS 系统 `/var/folders/s8/q4c00lhx3k384hngtv9pmwv40000gn/T/.net/`
- Linux 系统 `/var/tmp/.net/`

> .NET Core 3.x 发布的单文件应用偶尔会出现无法运行的错误， 需要删除上面目录中对应的 app 目录， 再运行就可以了；

.NET 5.0 发布的自单文件应用可以直接运行，不需要再解压；

## 单文件应用相关的几个编译属性

- **PublishSingleFile** 是否发布为单文件应用；
- **SelfContained** 发布的单文件应用是否包含运行时， 不包含运行时会显著减小发布文件的大小， 但是要求目标计算机必须安装 .NET 运行时， 这个属性是 .NET 5.0 新增的；
- **PublishTrimmed** 是否对发布的单文件应用进行裁切， 通过删除依赖项中不使用的部分以达到减小发布文件的大小， 但是可能会出现错误， 这个属性设置为 `true` 时，需要对发布后的文件测试；
- **PublishReadyToRun** 是否对发布后的文件进行 aot 编译， 转换成对应平台本地化的可执行程序， 但是不能跨平台使用， 比如不能在 linux 系统上对目标为 windows 系统的应用进行 aot 编译， 这个属性也是 .NET 5.0 新增的；

## 文件大小

.NET Core 3.x 发布的单文件应用文件最小大概是 30 兆左右， 和 Go 发布的 10 兆左右的单文件应用相比确实大一些， 但是如果在发布之后用 7zip 压缩一下， 也是 10 多兆， 和 Go 发布的单文件应用不相上下。

.NET 5.0 发布的单文件应用大小也差不多是这样子的。

## 发布单文件测试

测试环境的操作系统为 Ubuntu 20.04.1 LTS ， 安装 .NET 5.0.100-preview.8.20417.9 , 以一个控制台程序为例， 发布命令为

```sh
dotnet publish -r osx-x64 -c Release \
  -p:PublishSingleFile=true \
  -p:PublishTrimmed=true \
  -p:SelfContained=true \
  -p:PublishReadyToRun=false \
  -p:DebugType=None -o ./bin/Publish/osx-x64
```

经过测试， 使用 .NET 5.0 Preview 8 发布的单文件应用， 如果应用稍微复杂一些， 只有在目标是 Linux 系统时， 发布结果只有一个可执行文件， Windows 和 macOS 都会额外带上几个小尾巴。

当输出目标为 Linux 系统时， 发布的结果为：

- YourApp

当输出目标为 Windows 系统时， 发布的结果可能为：

- YourApp.exe
- mscordaccore.dll
- coreclr.dll
- clrjit.dll
- clrcompression.dll

而当输出目标为 macOS 系统时， 发布的结果可能为：

- YourApp
- libclrjit.dylib
- libcoreclr.dylib
- libSystem.IO.Compression.Native.dylib
- libSystem.Native.dylib
- libSystem.Net.Security.Native.dylib
- libSystem.Security.Cryptography.Native.Apple.dylib
- libSystem.Security.Cryptography.Native.OpenSsl.dylib
