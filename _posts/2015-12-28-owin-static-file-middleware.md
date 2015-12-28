---
layout: post
title: 分享 OWIN 静态文件处理中间件
description: 分享一个 OWIN 文件处理中间件， 支持 ETag ， Html5 路径模式
keywords: owin, middleware, static file, etag, html 5 location mode
tags: [OWIN, .Net, Mono]
---

分享一个自己写的 OWIN 静态文件处理中间件， 功能如下：

- 支持标准的 OWIN 环境， 跨平台运行 (.Net, Mono) 

  为 OWIN 环境开发， 只依赖 `Owin.dll` ， 和具体的 OWIN 宿主无关， 可以在 .Net 和 Mono 环境下运行；

- 支持实体标签 (HTTP ETag)

  [实体标签](https://zh.wikipedia.org/wiki/HTTP_ETag) 是HTTP协议提供的若干机制中的一种Web缓存验证机制，并且允许客户端进行缓存协商。这就使得缓存变得更加高效，而且节省带宽。(参考维基百科)

- 支持 Html5 路径模式

  支持 [AngularJS](https://angularjs.org/) 的 [html5Mode](https://docs.angularjs.org/guide/$location) 路径（其它前端框架应该也有类似的）， 相信熟悉前端的同学对这个不陌生， Html5 路径模式的优点很多， 对搜索引擎友好， 对浏览器友好， 对用户也又好， 但是需要服务端配合。

- 支持扩展， 可以自定义 MimeTypeProvider 和 ETagProvider

  默认的 `MimeTypeProvider` 可以识别绝大多数静态文件的 mimetype ， 如果不够用或者觉得默认的不爽， 可以使用自定义的 MimeTypeProvider ， 只要实现接口 `IMimeTypeProvider` 即可。

  默认的 `ETagProvider` 使用文件的 `LastWriteTimeUtc.Ticks` 做为 `ETag` 信息返回， 如果觉得不合适， 也可以使用自定义的 ETagProvider ， 只要实现接口 `IETagProvider` 即可。

这个中间件通过 `StaticFileMiddlewareOptions` 类进行配置， 各个属性说明如下：

```csharp
public class StaticFileMiddlewareOptions {
    // 默认的根目录
    public string RootDirectory { get; set; } = "wwwroot";
    // 默认文件名
    public string DefaultFile { get; set; } = "index.html";
    // 是否适用 ETag ， 默认值为 true 
    public bool EnableETag { get; set; } = true;
    // 是否适用 Html5 路径模式， 默认值为 false
    public bool EnableHtml5LocationMode { get; set; } = false;
    // 自定义的 MimeTypeProvider ， 如果没有赋值， 则使用默认的
    public IMimeTypeProvider MimeTypeProvider { get; set; }
    // 自定义 ETagProvider ， 当 EnableETag 为 true 时， 会检查这个
    // 属性， 如果没有赋值， 则使用默认的
    public IETagProvider ETagProvider { get; set; }
}
```

通过扩展方法

```csharp
public static void UseStaticFile(this IAppBuilder app, StaticFileMiddlewareOptions options)
```

进行配置和使用， 示例如下：

```csharp
app. UseStaticFile(new StaticFileMiddlewareOptions {
    RootDirectory = "../wwwroot",
    DefaultFile = "index.html",
    EnableETag = true,
    EnableHtml5LocationMode = true
});
```

获取方式当然是通过 NuGet 了， 输入下面的命令就可以了：

```
Install-Package Beginor.Owin.StaticFile
```

NuGet 包的地址是 [https://www.nuget.org/packages/Beginor.Owin.StaticFile](https://www.nuget.org/packages/Beginor.Owin.StaticFile)

示例程序源码： [https://github.com/beginor/static-file-middleware-demo](https://github.com/beginor/static-file-middleware-demo)

