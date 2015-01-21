---
layout: post
title: 使用 OWIN 搭建 OAuth2 服务器
description: 本文介绍如何使用微软提供的 OWIN 中间件一步一步搭建自己的 OAuth2 服务器
tags: OWIN，OAuth2
keywords: OWIN, OAuth2, ASP.NET MVC, WebAPI, resource owner, token, resource server, authorization server
---

## 关于 OAuth

维基百科中对 OAuth 的描述如下：

> OAuth（开放授权）是一个开放标准，允许用户让第三方应用访问该用户在某一网站上存储的私密的资源（如照片，视频，联系人列表），而无需将用户名和密码提供给第三方应用。

> OAuth允许用户提供一个令牌，而不是用户名和密码来访问他们存放在特定服务提供者的数据。每一个令牌授权一个特定的网站（例如，视频编辑网站)在特定的时段（例如，接下来的2小时内）内访问特定的资源（例如仅仅是某一相册中的视频）。这样，OAuth让用户可以授权第三方网站访问他们存储在另外服务提供者的某些特定信息，而非所有内容。

很多知名网站都采用支持[OAuth2][1]认证， 允许第三方应用接入， 客户端接入 OAuth2 服务器这方面的资料已经很多了， 但是关于怎么搭建自己的 OAuth 服务器这方面的资料则比较少， 接下来就介绍一下怎么用微软的 OWIN 中间件搭建自己的 OAuth 服务， 实现 OAuth2 框架中的认证服务器和资源服务器 。

## 使用 OWIN 搭建 OAuth2 认证服务器

认证服务器指 [authorization server][2] ， 负责在资源所有者 （最终用户） 通过认证之后， 向客户端应用颁发凭据 (code) 和对客户端授权 (access_token) 。

### 新建空的 Web 项目

这一步很容易， 只要用 Visual Studio 新建一个空的 Web 项目， 并用 nuget 管理器添加下面几个 package：

- Owin
- Microsoft.Owin
- Microsoft.Owin.Host.SystemWeb
- Microsoft.Owin.Security
- Microsoft.Owin.Security.Cookies
- Microsoft.Owin.Security.OAuth
- Microsoft.AspNet.Mvc

打开项目属性， 设置项目使用 `IIS Express` ， 虚拟目录为 `/OWin04_OAuthServer` , 如下图所示：

![认证服务器项目属性](/assets/post-images/oauth-server-web-info.png)

<div class="alert alert-info">
<span class="glyphicon glyphicon-info-sign"></span> 这个配置是可选的， 也可以设置成你自己喜欢的值。
</div>

### 配置 OWIN OAuth 中间件

添加一个 `OWIN Startup Class` ， 名称为 `Startup.cs` ， 如下所示：

```c#
using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(Owin04_OAuthServer.Startup))]

namespace Owin04_OAuthServer {

    public partial class Startup {

        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }

    }
}
```

在项目中添加 `App_Start` 目录， 并在这个目录添加一个部分类文件 `Startup.Auth.cs` ， 在这个文件中来实现上面的 `ConfigureAuth` 方法：

```c#
using Owin04_Consts;
using Microsoft.Owin.Security.OAuth;
using System.Threading.Tasks;
using Microsoft.Owin.Security.Infrastructure;

namespace Owin04_OAuthServer {

    partial class Startup {

        public const string AuthenticationType = "OAuth2";

        private void ConfigureAuth(IAppBuilder app) {
        }
    }
}
```

既然要认证用户， 首先启用 Cookie 认证， 在 `ConfigureAuth` 方法中添加下面的代码：

```c#
app.UseCookieAuthentication(new CookieAuthenticationOptions {
    AuthenticationType = AuthenticationType,
    AuthenticationMode = AuthenticationMode.Passive,
    LoginPath = new PathString(Paths.LoginPath),
    LogoutPath = new PathString(Paths.LogoutPath)
});
```

### 用户登录与授权

## 创建受保护资源服务

作为例子， 本文创建一个简单的 WebAPI 项目，向通过 OAuth 授权认证的第三方应用返回用户信息。

注： 本文搭建 OAuth2 服务器部分参考 [OWIN OAuth 2.0 Authorization Server][2] 实现。

[1]: http://tools.ietf.org/html/rfc6749
[2]: http://tools.ietf.org/html/rfc6749#section-1.1
[2]: http://www.asp.net/aspnet/overview/owin-and-katana/owin-oauth-20-authorization-server