---
layout: post
title: 使用 OWIN 作为 ASP.NET Web API 的宿主
description: 使用 OWIN 作为 ASP.NET Web API 的宿主
tags: [OWIN]
keywords: OWIN, ASP.NET, Web API, Katana, Nowin
---

[ASP.NET Web API][1] 是一种框架，用于轻松构建可以访问多种客户端（包括浏览器和移动
设备）的 HTTP 服务。 ASP.NET Web API 是一种用于在 .NET Framework 上构建 RESTful
应用程序的理想平台。

ASP.NET Web API 是 OWIN 兼容的， 因此可以在 OWIN 服务器上运行。 

接下来使用 Xamarin Studio 创建一个 OWIN 兼容的 C# 类库， 也就是 OWIN 中定义的“应
用 (Application)” ， 然后在不同的 OWIN 服务器/宿主上运行。

## 创建 OWIN 兼容的 Web API 类库

打开 Xamarin Studio， 新建一个 C# 类库项目， 如下图：

![OWIN WebApi](/assets/post-images/owin-webapi-01.png)

然后向项目中添加 `Microsoft.AspNet.WebApi.Owin` 包， 相关依赖的包会自动添加，

![OWIN WebApi](/assets/post-images/owin-webapi-02.png)

最终项目依赖的包如下表， 如果没有在 packages.config 文件中列出， 可以再次手工添
加上去。

- Microsoft.AspNet.WebApi.Client
- Microsoft.AspNet.WebApi.Core
- Microsoft.AspNet.WebApi.Owin
- Microsoft.Owin
- Newtonsoft.Json
- Owin

我们的目的是创建 OWIN 兼容的 Web API 应用， 自然要先添加一个 OWIN 约定的 Startup
类， 来配置我们的 OWIN 应用。

向项目中添加一个 Startup 类 ， 代码如下:

```c#
public class Startup {

    public void Configuration(IAppBuilder appBuilder) {
        // 创建 Web API 的配置
        var config = new HttpConfiguration();
        // 启用标记路由
        config.MapHttpAttributeRoutes();
        // 默认的 Web API 路由
        config.Routes.MapHttpRoute(
            name: "DefaultApi",
            routeTemplate: "api/{controller}/{id}",
            defaults: new { id = RouteParameter.Optional }
        );
        // 将路由配置附加到 appBuilder
        appBuilder.UseWebApi(config);
    }
}
```

按照 Web API 项目的约定， 在项目中添加一个名称为 Controllers 的文件夹， 然后新建
一个 ValuesController 类， 设置其基类为 System.Web.Http.ApiController ， 作为示
例， 其内容与 Visual Studio 自带的 Web API Controller 模板一致， 如下所示：


```c#
public class ValuesController : ApiController {

    // GET api/values
    public IEnumerable<string> Get() {
        return new string[] { "value1", "value2" }; 
    }

    // GET api/values/5
    public string Get(int id) {
        return "value"; 
    }

    // POST api/values
    public void Post([FromBody]string value) {
    }

    // PUT api/values/5
    public void Put(int id, [FromBody]string value) {
    }

    // DELETE api/values/5
    public void Delete(int id) {
    }
}
```

## 在 OWIN 环境下运行 Web API

OWIN 目前有兩個比较成熟的服务器：

- [Katana][2] 微软的 OWIN 服务器， 如果没有指定 OWIN 服务器， 则作为默认的 OWIN 
  服务器。
- [Nowin][3] 社区版 OWIN 服务器， 纯 C# 实现， 可以运行在 .NET 和 Mono 运行。

### 使用 Katana 服务器运行

在 Katana 下运行 OWIN 应用是很容易的， 新建一个命令行程序项目， 项目名称为： 
Owin02_WebApi_Katana ， 然后向项目中添加下面的 NuGet 包：

- Microsoft.AspNet.WebApi.Client
- Microsoft.AspNet.WebApi.Core
- Microsoft.AspNet.WebApi.Owin
- Microsoft.AspNet.WebApi.OwinSelfHost
- Microsoft.Owin
- Microsoft.Owin.Host.HttpListener
- Microsoft.Owin.Hosting
- Newtonsoft.Json
- Owin

在默认的 Program.cs 文件的 Main 方法中， 添加下面的代码：

```c#
public static void Main(string[] args) {

    var baseAddress = "https://localhost:9000/";

    var startOpts = new StartOptions(baseAddress) {
        // katana http listener
        ServerFactory = "Microsoft.Owin.Host.HttpListener"
    };

    using (WebApp.Start<Owin02_WebApi.Startup>(startOpts)) {
        var client = new HttpClient {
            BaseAddress = new Uri(baseAddress, UriKind.Absolute)
        }; 

        var requestTask = client.GetAsync("api/values");
        requestTask.Wait();
        var response = requestTask.Result; 
        Console.WriteLine(response);

        var readTask = response.Content.ReadAsStringAsync();
        readTask.Wait();
        Console.WriteLine(readTask.Result);

        Console.ReadLine();
    }
}
```

现在运行 Owin02_WebApi_Katana 项目， 命令行显示如下：

![OWIN WebApi](/assets/post-images/owin-webapi-03.png)

也可以通过浏览器来访问 `https://localhost:9000/api/values` ， 得到的结果如下：

![OWIN WebApi](/assets/post-images/owin-webapi-04.png)

### 使用 Nowin 服务器运行

OWIN 兼容的应用可以在任何 OWIN 服务器上运行， 下面就看看如何在 Nowin 上运行。

最简单的方法是将上面代码中 StartOptions 的 ServerFactory 属性设置为 Nowin ， 然
后在添加 Nowin 包就可以运行了：

```c#
var baseAddress = "https://localhost:9000/";

var startOpts = new StartOptions(baseAddress) {
    // Nowin
    ServerFactory = "Nowin"
};
```

不过这样会依赖包 `Microsoft.Owin.Hosting` ， 其实 Nowin 自身也提供了 Hosting 的
功能， 下面就看如何直接从 Nowin 启动。

新建一个 C# 命令行程序， 项目名称为 Owin02_WebApi_Nowin ， 添加下面的 NuGet 包：

- Microsoft.Owin
- Nowin
- Owin

向 Program.cs 文件中的 Main 方法添加下面的代码：

```c#
public static void Main(string[] args) {
    var appBuilder = new AppBuilder();
    Nowin.OwinServerFactory.Initialize(appBuilder.Properties);

    var startup = new Owin02_WebApi.Startup();
    startup.Configuration(appBuilder);

    var builder = new ServerBuilder();
    var ip = "127.0.0.1";
    var port = 8888;
    builder.SetAddress(System.Net.IPAddress.Parse(ip)).SetPort(port)
        .SetOwinApp(appBuilder.Build())
        .SetOwinCapabilities((IDictionary<string, object>)appBuilder.Properties[OwinKeys.ServerCapabilitiesKey]);

    using (var server = builder.Build()) {

        Task.Run(() => server.Start());

        var baseAddress = "https://" + ip + ":" + port + "/";
        Console.WriteLine("Nowin server listening " + baseAddress);

        var client = new HttpClient {
            BaseAddress = new Uri(baseAddress, UriKind.Absolute)
        }; 

        var requestTask = client.GetAsync("api/values");
        requestTask.Wait();
        var response = requestTask.Result; 
        Console.WriteLine(response);

        var readTask = response.Content.ReadAsStringAsync();
        readTask.Wait();
        Console.WriteLine(readTask.Result);

        Console.ReadLine();
    }
}
```

如果没错的话就可以看到和 Owin02_WebApi_Katans 一致的效果了， 而且 Nowin 是开源的
纯 .NET 实现， 在 Mono 的环境下也可以运行， 下面是 Mac 系统下的运行截图：

![OWIN WebApi](/assets/post-images/owin-webapi-05.png)

[1]: https://www.asp.net/web-api
[2]: https://katanaproject.codeplex.com/
[3]: https://github.com/Bobris/Nowin
