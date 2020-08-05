---
layout: post2
title: 指定 ASP.NET Core 应用监听的端口
description: 本文介绍如何指定ASP.NET Core 应用监听的端口
keywords: asp.net core, listening port, urls, aspnetcore_urls, useurls, kestrelserveroptions
tags: [.NET Core]
---

ASP.NET Core 应用默认监听的端口是 5000 ， 在调试或者部署的过程中经常需要指定监听的端口来来运行， 本文就这个问题， 进行一个总结， 可以通过下面的方法来指定运行端口。

## 使用命令行参数

使用命令行参数 `--urls` 是最常用的方法了， 测试或者开发环境下用的最多。 只需要在运行命令中添加这个参数即可， 如下所示：

```sh
dotnet run --urls=http://localhost:5001/
```

## 在 `appsettings.json` 中添加配置

如果倾向于使用配置文件， 可以在 `appsettings.json` 文件中添加 `urls` 节点， 如下所示：

```json
{
  "urls": "http://localhost:5001"
}
```

这样， 执行 `dotnet run` 时， 会自动读取这个配置。

## 环境变量

ASP.NET Core 应用在启动时会自动读取名称以 `ASPNETCORE` 开头的环境变量， 所以也可以通过环境变量来指定监听的端口。

```sh
export ASPNETCORE_URLS=http://localhost:5001/
dotnet run
```

> 在微软提供的 `mcr.microsoft.com/dotnet/core/aspnet` Docker 镜像中， 就是用这个环境变量来指定监听端口的。

## 使用 `UseUrls()` 函数

如果倾向于使用代码， 则可以在 `Program.cs` 文件中的 `ConfigureWebHostDefaults` 方法中使用 `UseUrls()` 函数， 在代码中指定要监听的端口：

```cs
public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .ConfigureWebHostDefaults(builder => {
            builder.UseStartup<Startup>();
            builder.UseUrls("http://localhost:5001/");
        });
```

> 在实际的项目中， 可以将要监听的端口配置到其它地方， 而不必硬编码在代码中过。

## 使用 Kestrel 服务器选项

ASP.NET Core 内置的 kestrel 服务器， 也提供了许多选项， 当然也包括了要监听的端口， 要在应用中使用 Kestrel 服务器选项， 需要在 `Program.cs` 文件中的 `CreateHostBuilder` 方法中添加 `ConfigureServices` 方法， 对 `KestrelServerOptions` 进行配置， 代码如下：

```cs
public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .ConfigureServices((context, services) => {
            services.Configure<KestrelServerOptions>(
                context.Configuration.GetSection("kestrel")
            );
        })
        .ConfigureWebHostDefaults(builder =>{
            builder.UseStartup<Startup>();
        });
```

> 也可以在 `Startup.cs` 文件中的 `ConfigureServices` 方法中进行配置。

然后在 `appsettings.json` 中添加 `kestrel` 节点， 内容如下所示：

```json
{
  "kestrel": {
    "endPoints": {
      "http": {
        "url": "http://localhost:5001/"
      }
    }
  }
}
```

`KestrelServerOptions` 还提供了许多额外的配置选项， 比如最大并发连接数、是否返回服务器名称标头等， 具体可以参考 [kestrel-aspnetcore-3.1](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-3.1) ， 如果需要同时调整额外的服务器配置， 则推荐使用这种方式。
