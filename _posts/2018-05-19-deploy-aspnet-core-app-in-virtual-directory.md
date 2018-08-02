---
layout: post2
title: 在虚拟目录中部署 ASP.NET Core 应用
description: 介绍如何实现在虚拟目录中部署 ASP.NET Core 应用
keywords: aspnetcore, deploy, virtual directory
tags: [.NET Core]
---

ASP.NET Core 已经发布了 2.0 RC1 (Go Live) 版本， API 已经不在变化， 但是很多人期待的已久的在虚拟目录中部署的功能还是没有出现， 看来只能自己想办法解决这个问题了。

由于 ASP.NET Core 有自己的服务器进程 (kestrel) ， 在部署时通常是采用反向代理转发的形式， 对于应用服务器的集成上， 不如传统的 ASP.NET 应用那么友好， 比如在应用服务器的虚拟目录中部署， 一直没有很好的方案。

ASP.NET Core 有一个 [UsePathBase](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.usepathbaseextensions.usepathbase?view=aspnetcore-2.0) 扩展方法， 使用一个中间件向当前 http 请求中添加或者移除根路径 (Pathbase) ， 利用这个方法， 添加虚拟路径也就不难实现。

首先来定义并导出一个名称为 `ASPNETCORE_PATHBASE` 的环境变量，


```sh
export ASPNETCORE_PATHBASE=/MvcTestApp
```

再在 `Startup.cs` 文件中的 `Configure` 方法的最前面， 添加下面的代码， 读取这个环境变量， 将环境变量的值作为 `PathBase` 中间件， 代码如下所示：

```cs
public void Configure(IApplicationBuilder app, IHostingEnvironment env) {
    // 读取环境变量 ASPNETCORE_PATHBASE
    var pathBase = Environment.GetEnvironmentVariable("ASPNETCORE_PATHBASE");
    // 如果 ASPNETCORE_PATHBASE 的值不为空， 则使用 Pathbase 中间件
    if (!string.IsNullOrEmpty(pathBase)) {
        app.UsePathBase(new PathString(pathBase));
        Console.WriteLine("Hosting pathbase: " + pathBase);
    }
}
```

> 注意， 一定要在 Configure 方法的最前面调用这个方法， 让 Pathbase 中间件成为第一个处理请求的中间件， 才能正确的模拟虚拟路径。

现在输入命令 `dotnet run` ， 开始运行， 输出如下

```
Hosting pathbase: /MvcTestApp
Hosting environment: Development
Content root path: /Projects/MvcTestApp
Now listening on: https://localhost:5001
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
```

现在， 可以通过 `http://localhost:5000/MvcTestApp/` 来访问这个应用了。

如果使用 Visual Studio 或者 VS Code 进行调试， 则需要修改 `Properties ` 目录下的 `launchSettings.json` 文件， 为不同的 profile 均添加一个 ASPNETCORE_PATHBASE 环境变量， 如下所示：

```json
{
    "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_PATHBASE": "/MvcTestApp"
    }
}
```

部署到生产环境下， 如果需要修改虚拟目录的值， 则只要调整环境变量 `ASPNETCORE_PATHBASE` 的值就行了， 不需要修改代码。
