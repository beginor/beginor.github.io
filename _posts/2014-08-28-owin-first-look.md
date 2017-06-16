---
layout: post
title: OWIN 初探
description: 什么是 OWIN, 为什么使用 OWIN, 怎么使用 OWIN
tags: [OWIN]
keywords: OWIN, .NET
---

## 什么是 OWIN ？

[OWIN][1] 的全称是 "Open Web Interface for .NET"， OWIN 在 .NET Web 服务器和 .NET
Web 应用之间定义了一套标准的接口， 其目的是为了实现服务器与应用之间的解耦， 鼓励为 .NET Web
应用开发简单模块。

OWIN 是一个开源开放的标准， 有助于建设 .NET 开发的开源生态环境, OWIN 定义了如下几个概念：

- **服务器 (Server)**

  HTTP 服务器直接与客户端交互， 并用 OWIN 语义处理请求, 服务器需要一个适配层将客户请求转换
  成 OWIN 语义。 支持 OWIN 的服务器有 [Katana][2] 和 [Nowin][3] 。

- **Web 框架 (Web Framework)**

  构建在 OWIN 之上的自包含的独立组件， 向 Web 应用提供可用的对象模型或者接口。 Web 框架可
  能需要一个适配层来转换 OWIN 语义。 支持 OWIN 的 Web 框架有：

  - [Nancy][4]
  - [SignalR][5]
  - [WebApi][6]
  - [FubuMVC][7]
  - [Simple.Web][8]
  - [DuoVia.Http][9]

- **Web 应用 (Web Application)**

  一个特定的 Web 应用， 通常构建在 Web 框架之上， 使用 OWIN 兼容的服务器运行。

- **中间件 (Middleware)**

  特定的目的的服务器和应用之间的可插拔组件， 可以监视、 路由、 修改请求与响应。

- **宿主 (Host)**

  应用与服务器所在的进程， 主要负责应用的启动， 有些服务器自身也是宿主， 比如 Nowin 。

## 为什么使用 OWIN

正如上面所说， OWIN 定义了 .NET Web 服务器与 .NET Web 应用之间的标准接口， 将应用与服务器
解耦， 使得便携式 .NET Web 应用以及跨平台的愿望成为现实， 标准的 OWIN 应用可以在任何 OWIN
兼容的服务器上运行， 不再依赖与 Windows 和 IIS 。

## 怎么使用 OWIN

OWIN 通过 NuGet 包的形式发布， 获取和使用都非常方便。 下面就先建立一个最简单的 OWIN 应用：

1. 打开 Xamarin Studio， 新建一个 C# 命令行程序， 如下图所示：

   ![OWIN Hello](/assets/post-images/owin-hello-01.png)

2. 然后打开项目属性， 确认目标框架设置为 `Mono / .NET 4.5` ， 如下图所示：

   ![OWIN Hello](/assets/post-images/owin-hello-02.png)

3. 向项目中添加如下几个 NuGet 包：

   - Owin
   - Microsoft.Owin
   - Microsoft.Owin.Hosting
   - Microsoft.Owin.Host.HttpListener

4. 添加一个 OWIN Startup 类， 代码如下：

   ```c#
   public class Startup {

       public void Configuration(IAppBuilder appBuilder) {
           appBuilder.Run(HandleRequest);
       }

       static Task HandleRequest(IOwinContext context) {
           context.Response.ContentType = "text/plain";
           return context.Response.WriteAsync("Hello, world!");
       }
   }
   ```

   OWIN 约定的处理请求的代理类型是：

   ```c#
   Func<IOWinContext, Task> handler
   ```

   对应上面 Startup 类的 HandleRequest 方法， 所以上面的 Startup 类就定义了一个最简单的
   OWIN 应用， 向客户端输出 `Hello， World！`

5. 在自动生成的 Program.cs 文件中的 Main 方法中添加如下代码， 来启动 OWIN 应用：

   ```c#
   class MainClass {
   
       public static void Main(string[] args) {
           var url = "https://localhost:8080/";
           var startOpts = new StartOptions(url) {
   
           };
           using (WebApp.Start<Startup>(startOpts)) {
               Console.WriteLine("Server run at " + url + " , press Enter to exit.");
               Console.ReadLine();
           }
       }
   }
   ```

6. 现在开始运行程序， 命令行显示如下：

   ![OWIN Hello](/assets/post-images/owin-hello-03.png)

   打开浏览器， 访问 https://localhost:8080/ ， 得到的响应如下：

   ![OWIN Hello](/assets/post-images/owin-hello-04.png)

到目前为止， 没有 Windows ， 更没有 IIS ， OWIN 应用就能正常运行了。

[1]: https://owin.org/
[2]: https://katanaproject.codeplex.com/
[3]: https://github.com/Bobris/Nowin/
[4]: https://nancyfx.org/
[5]: https://signalr.net/
[6]: https://aspnetwebstack.codeplex.com/
[7]: https://mvc.fubu-project.org/
[8]: https://github.com/markrendle/Simple.Web
[9]: https://github.com/duovia/duovia-http
