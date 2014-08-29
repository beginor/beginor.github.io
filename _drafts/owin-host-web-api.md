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

## 创建 OWIN 兼容的 Web API 类库

- Microsoft.AspNet.WebApi.Client
- Microsoft.AspNet.WebApi.Core
- Microsoft.AspNet.WebApi.Owin
- Microsoft.Owin
- Newtonsoft.Json
- Owin

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

```c#
public class Startup {

    public void Configuration(IAppBuilder appBuilder) {

        var config = new HttpConfiguration();
        config.MapHttpAttributeRoutes();
        config.Routes.MapHttpRoute(
            name: "DefaultApi",
            routeTemplate: "api/{controller}/{id}",
            defaults: new { id = RouteParameter.Optional }
        );

        appBuilder.UseWebApi(config);
    }
}
```

## 在 OWIN 环境下运行 Web API

### 使用 Katana 服务器运行

- Microsoft.AspNet.WebApi.Client
- Microsoft.AspNet.WebApi.Core
- Microsoft.AspNet.WebApi.Owin
- Microsoft.AspNet.WebApi.OwinSelfHost
- Microsoft.Owin
- Microsoft.Owin.Host.HttpListener
- Microsoft.Owin.Hosting
- Newtonsoft.Json
- Owin

```c#
public static void Main(string[] args) {

    var baseAddress = "http://localhost:9000/";

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

### 使用 Nowin 服务器运行

- Microsoft.Owin
- Nowin
- Owin


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

        var baseAddress = "http://" + ip + ":" + port + "/";
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

[1]: http://www.asp.net/web-api