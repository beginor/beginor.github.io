---
layout: post2
title: 使用 mono 编译 .NET Standard 应用
description: 介绍使用 mono 编译 .NET Standard 应用的正确姿势
keywords: .net standard, xamarin, mono, .net core
tags: [.NET Standard, Xamarin, Mono, .Net]
---

微软发布 .NET Standard 2.0 已经有一段时间了， 根据 [.NET Standard 2.0](https://github.com/dotnet/standard/blob/master/docs/versions.md) 支持版本的文档， Mono 5.4 是支持 .NET Standard 2.0 的， 对于 .NET Standard 2.0 应用的开发的介绍， 几乎全部都是在 Windows 系统下使用 Visual Studio 2017 进行的， 而在 Linux 或 macOS 系统下使用 Mono 的介绍缺却少之又少， 本文就一一个简单的控制台应用为例， 介绍一下如何在 Mono 下如何开发 .NET Standard 2.0 应用。

由于 Mono 下没有内置 .NET Standard 2.0 应用的模板， 所以需要先借用一下 .NET Core 的应用模板。

打开终端， 输入下面的命令， 来创建一个控制台应用：

```sh
dotnet new console -o ConsoleApp
```

这个命令会生成一个 ConsoleApp 目录， 里面有两个文件 `ConsoleApp.csproj` 和 `Program.cs` 两个文件， 先来看一下 `ConsoleApp.csproj` 文件， 内容如下：

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.0</TargetFramework>
  </PropertyGroup>

</Project>
```

将 `TargetFramework` 由 `netcoreapp2.0` 修改为 `net461` ， 如下所示：


```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net461</TargetFramework>
  </PropertyGroup>

</Project>
```

而 `Program.cs` 则不用做任何修改， 内容如下：

```cs
using System;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

要编译这个项目， 需要先恢复项目的依赖项， 在控制台继续输入下面的命令：

```sh
msbuild /t:Restore
```

然后就可以编译这个项目了， 继续输入下面的命令：

```sh
msbuild /t:Build
```

最终会在控制台看到 `Build succeeded.` 的输出。 最后， 用 Mono 来运行一下编译好的应用， 如下图所示：

```sh
$ mono bin/Debug/net461/ConsoleApp.exe
Hello World!
```
