---
title: 在 Nowin 下运行 ASP.NET 5 Beta 2
layout: post
description: 在 owin 环境下使用 Nowin 创建 ASP.NET 5 服务器， 运行 ASP.NET 5 Beta 2
tags: [Xamarin, Mono, ASP.NET, MVC, OWIN]
keywords: asp.net5, mvc, vnext, owin, nowin, server factory, server information
---

ASP.NET Mvc vNext 改名为 ASP.NET 5 ， 看来距离正式发布已经不远了， 在发布之初就号称可以跨平台运行， 在发布的早期 alpha 版本中， 做个一次[在 mono 下尝试 ASP.NET vNext][1]的试验， 虽然最终以失败告终， 但是在试验的过程中还是还是收获良多， 对 [OWIN][2] 有了更深一步的认识， 也熟悉了 OWIN 的第三方实现 [Nowin][3] 。

现在最新发布的 ASP.NET 5 版本为 Beta 2， 不仅功能更加完善， 第三方资料也多了很多， 不过完全依靠微软提供的资源还不能在非 Windows 平台运行， ASP.NET 5 可以在 OWIN 环境下运行， 而 OWIN 是开源开放的， 也有第三方实现可以在非 Windows 平台下基于 Mono 运行， 因此借助第三方的 OWIN 实现在非 Windows 平台下基于 Mono 运行 ASP.NET 5 也是完全可以的。

## 使用 Nowin 搭建 ASP.NET 5 服务器

要搭建 ASP.NET 5 服务器， 至少需要实现两个接口 `IServerInformation` 和 `IServerFactory` ， 对这两个接口的实现分别如下：

### 实现 IServerInformation

IServerInformation 接口是需要实现者提供服务器的一些信息， 定义如下：

```c#
namespace Microsoft.AspNet.Builder {

    public interface IServerInformation {

        string Name { get; }
    }

}
```

从接口的定义来看， 只需要提供个服务器名称即可， 当然用 Nowin 实现这个接口时， 包含了 `Nowin.ServerBuilder` 实例成员， 可以提供额外的关于 Nowin 的一些信息， 实现代码如下：

```c#
using System;
using Microsoft.AspNet.Builder;
using Nowin;

namespace Nowin.vNext {

    public class NowinServerInformation : IServerInformation {

        public ServerBuilder Builder { get; }

        string IServerInformation.Name => "Nowin";

        public NowinServerInformation(ServerBuilder builder) {
            Builder = builder;
        }

    }

}
```

### 实现 IServerFactory

上面的 `NowinServerInformation` 比较简单， 只是简单的提供服务器信息， 接下来要实现的 `IServerFactory` 就是关键了， `IServerFactory` 的定义如下：

```c#
namespace Microsoft.AspNet.Hosting.Server {

    [AssemblyNeutral]
    public interface IServerFactory {

        IServerInformation Initialize(IConfiguration configuration);
        
        IDisposable Start(
            IServerInformation serverInformation,
            Func<object, Task> application
        );

    }

}
```

ASP.NET 5 既然是基于 OWIN 运行的， 自然少不了 OWIN 的标志性函数 `Func<IDictionary<string, object>, Task>` 了， 在我们的实现中， 自然也必须用到这个函数， 我们先来定义这样一个 HandleRequest 函数， 作为 OWIN 的处理函数：

```c#
private Task HandleRequest(IDictionary<string, object> env) {
}
```

第一步， 将当前 ASP.NET 5 应用适配成一个标准的 OWIN 应用， 代码如下：

```c#
IServerInformation IServerFactory.Initialize(IConfiguration configuration) {
    // adapt aspnet to owin app Func<IDictionary<string, object>, Task>;
    var owinApp = OwinWebSocketAcceptAdapter.AdaptWebSockets(HandleRequest);
}
```

第二步， 从 configuration 参数中提取必要的服务器信息 （服务器名称、要监听的地址）， 并返回 `IServerInformation` 的实例， 在上面的 `Inisitlize` 方法中继续添加下面的代码：

```c#
// Get server info, write to console.
var server = configuration.Get("server");
var serverUrls = configuration.Get("server.urls");
Console.WriteLine("Owin server is: {0}, listening at {1}", server, serverUrls);
// parse ip address and port.
var uri = new Uri(serverUrls, UriKind.Absolute);
IPAddress ip;
if (!IPAddress.TryParse(uri.Host, out ip)) {
    if (uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase)) {
        ip = IPAddress.Parse("127.0.0.1");
    }
    else {
        ip = IPAddress.Any;
    }
}
var port = uri.Port;

// build nowin server;
var builder = ServerBuilder.New()
    .SetAddress(ip)
    .SetPort(port)
    .SetOwinApp(owinApp);

var serverInfo = new NowinServerInformation(builder);
return serverInfo;
```

第三步继续来实现 `IServerFactory.Start` 方法， 这个方法有两个参数：

1. `IServerInformation` 就是在 initialize 方法中返回的 NowinServerInformation 实例；
2. `Func<object, Task>` 是 ASP.NET 5 运行时提供给 OWIN 环境调用的处理函数， 也就是说， 在 OWIN 环境下运行 ASP.NET 5 就是调用这个函数。

实现代码如下：

```c#
IDisposable IServerFactory.Start(
    IServerInformation serverInformation,
    Func<object, Task> application
    ) {
    // get server info,
    var info = (NowinServerInformation)serverInformation;
    // save the application callback
    this.callback = application;
    // build and start nowin server.
    var server = info.Builder.Build();
    server.Start();
    return server;
}

private Func<object, Task> callback;

private Task HandleRequest(IDictionary<string, object> env) {
    // just call the application callback ASP.NET 5 provided.
    return callback(new OwinFeatureCollection(env));
}
```

## 运行测试程序

![在 Windows 下运行 Nowin.vNext](http://beginor.github.io/assets/post-images/run-aspnet-5-beta2-with-nowin-win.png)

![Windows 下浏览器截图](http://beginor.github.io/assets/post-images/run-aspnet-5-beta2-with-nowin-win-ie.png)

![在 Mac 下运行 Nowin.vNext](http://beginor.github.io/assets/post-images/run-aspnet-5-beta2-with-nowin-mac.png)

![Mac 下浏览器截图](http://beginor.github.io/assets/post-images/run-aspnet-5-beta2-with-nowin-mac-safari.png)

本文所有源代码： https://github.com/beginor/mvc-vnext

[1]: http://beginor.github.io/2014/06/08/try-aspnet-vnext-under-mono.html
[2]: http://owin.org/
[3]: https://github.com/beginor/Nowin