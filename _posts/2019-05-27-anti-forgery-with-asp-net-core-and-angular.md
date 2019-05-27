---
layout: post2
title: 在 Asp.Net Core WebAPI 中防御跨站请求伪造攻击
description: 介绍在 Asp.Net Core WebAPI 中防御跨站请求伪造攻击
keywords: csrf, xsrf, anti forgery, asp.net core webapi, angular
tags: [.NET Core, Angular]
---
## 什么是跨站请求伪造

**跨站请求伪造**（英语：Cross-site request forgery），也被称为 **one-click attack** 或者 **session riding**，通常缩写为 **CSRF** 或者 **XSRF**， 是一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法。[【1】](https://zh.wikipedia.org/wiki/跨站请求伪造#cite_note-Ristic-1) 跟[跨网站脚本](https://zh.wikipedia.org/wiki/跨網站指令碼)（XSS）相比，**XSS** 利用的是用户对指定网站的信任，CSRF 利用的是网站对用户网页浏览器的信任。

想了解更多，请查看维基百科上的[详细介绍](https://zh.wikipedia.org/wiki/跨站请求伪造)。

##使用 Asp.Net Core 内置的 Antiforgery

Asp.Net Core 应用中内置了 `Microsoft.AspNetCore.Antiforgery` 包来支持跨站请求伪造。 如果你的应用引用了 `Microsoft.AspNetCore.App` 包， 则就已经包含了 `Microsoft.AspNetCore.Antiforgery` 。 如果没有， 则可以使用下面的命令来添加这个包：

```shell
dotnet add package Microsoft.AspNetCore.Antiforgery
```

添加了这个包之后， 需要先修改 `Startup.cs` 文件中的 `ConfigureServices` 方法， 添加下面的配置：

```c#
public class Startup {

  public void ConfigureServices(IServiceCollection services) {
    services.AddAntiforgery(options => {
      options.Cookie.SameSite = SameSiteMode.Lax;
      // 客户端要向服务端发送的 Header 的名称， 用于 XSRF 验证；
      options.HeaderName = "X-XSRF-TOKEN";
    });
  }

}
```

在 `SecurityController.cs` 文件中添加一个 Api ， 来颁发凭据：

```c#
[Route("api/[controller]")]
[ApiController]
public class SecurityController : Controller {

  private IAntiforgery antiforgery;

  public SecurityController(
    IAntiforgery antiforgery
  ) {
    this.antiforgery = antiforgery;
  }

  [HttpGet("xsrf-token")]
  public ActionResult GetXsrfToken() {
    var tokens = antiforgery.GetAndStoreTokens(HttpContext);
    // 向客户端发送名称为 XSRF-TOKEN 的 Cookie ， 客户端必须将这个 Cookie 的值
    // 以 X-XSRF-TOKEN 为名称的 Header 再发送回服务端， 才能完成 XSRF 认证。
    Response.Cookies.Append(
      "XSRF-TOKEN",
      tokens.RequestToken,
      new CookieOptions {
        HttpOnly = false,
        Path = "/",
        IsEssential = true,
        SameSite = SameSiteMode.Lax
      }
    );
    return Ok();
  }

}
```

当客户端请求 `~/api/security/xsrf-token` 时， 服务端发送两个 Cookie ：

- **.AspNetCore.Antiforgery.xxxxxx** 一个 HTTP Only 的 Cookie ， 用于服务端验证；
- **XSRF-TOKEN** 客户端需要将这个 Cookie 的值用 X-XSRF-TOKEN 的 Header 发送回服务端， 进行验证；

> 注意： 这两个 Cookie 不支持跨域请求， 只能在相同的站点内请求， 也是出于安全性方面的考虑。

可以为某一个 ApiController 或者 Action 方法单独添加 `ValidateAntiForgeryTokenAttribute` 标记来验证 `XSRF-TOKEN`， 也可以全局注册一个 `AutoValidateAntiforgeryTokenAttribute` 过滤器来进行自动验证， 代码如下：

```c#
public class Startup {

  public void ConfigureServices(
    IServiceCollection services,
    IHostingEnvironment env
  ) {
    services.AddMvc(options => {
      // 在生产环境中添加自动 XSRF 验证
      if (env.IsProduction()) {
        options.Filters.Add(
          new AutoValidateAntiforgeryTokenAttribute()
        );
      }
    });
  }

}
```

> 注意问题： 不是所有的方法都需要进行 XSRF 认证，除了 GET， HEAD， OPTIONS 和 TRACE 之外的方法才支持 XSRF 认证。 

## Angular 内置支持

Angular 的 Http 模块内置支持 XSRF ， 前提条件如下：

- 存在客户端可以操作的名称为 **XSRF-TOKEN** 的 Cookie ；
- 该 Cookie 不能是 HttpOnly 的， 否则客户端脚本无法读取；
- 该 Cookie 的 Path 必须为 `/` ；

这三个条件都满足， 则在向服务端请求时自动发送名称为 `X-XSRF-TOKEN` 的 Header ， 值则为 **XSRF-TOKEN** 的 Cookie 的值， 这样就回自动满足上面的服务端的设置， 实现自动防御跨站请求伪造。
