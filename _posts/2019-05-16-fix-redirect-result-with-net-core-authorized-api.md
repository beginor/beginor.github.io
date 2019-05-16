---
layout: post2
title: Asp.Net Core API 需要认证时发生重定向的解决方法
description: 介绍在 Asp.Net Core API 需要认证时发生重定向的解决方法
keywords: angular, asp.net core, identity, webapi, authorize, redirect
tags: [Angular, .NET Core, 参考]
---

使用 .Net Core 开发 API 时， 有些 API 是需要认证， 添加了 `[Authorize]` 标记， 代码如下所示：

```C#
[Route("api/[controller]")]
[ApiController]
public class AccountController : Controller {

    [HttpGet("info")]
    [Authorize]
    public async Task<ActionResult<AccountInfoModel>> GetInfo() { }

}
```

客户端在没有认证之前， 应该返回 401 （未认证）的 HTTP 状态码， 但是在添加了 Identity 认证之后， 返回结果变成了 302 （重定向）。 

对于浏览器来说， 重定向是正确的， 而 Ajax 请求则会自动继续请求重定向之后的地址， 因此必须解决掉返回重定向的问题。

既然是通过添加 Identity 认证造成， 肯定要从 Identity 来找问题， 经过一番搜索， 终于在 [CookieAuthenticationEvents](https://github.com/aspnet/AspNetCore/blob/8fcadf72cd4ab783bc5d3cb4121fd2f4ec88f961/src/Security/Authentication/Cookies/src/CookieAuthenticationEvents.cs#L91) 中找到了原因， 代码中有关于是否是 Ajax 请求的判断

```c#
public Func<RedirectContext<CookieAuthenticationOptions>, Task> OnRedirectToReturnUrl { get; set; } = context =>
{
    if (IsAjaxRequest(context.Request))
    {
        context.Response.Headers[HeaderNames.Location] = context.RedirectUri;
    }
    else
    {
        context.Response.Redirect(context.RedirectUri);
    }
    return Task.CompletedTask;
};

private static bool IsAjaxRequest(HttpRequest request)
{
    return string.Equals(request.Query["X-Requested-With"], "XMLHttpRequest", StringComparison.Ordinal) ||
        string.Equals(request.Headers["X-Requested-With"], "XMLHttpRequest", StringComparison.Ordinal);
}
```

从上面的代码可以看出， 如果请求的 QueryString 或者 Header 中包含 `X-Requested-With` 并且值为 `XMLHttpRequest` 的话， 则会被判断为 AjaxRequest ， 将不会返回重定向结果， 问题原因找到了， 解决方法也就有了。

对于 Angular 来说， 可以实现一个全局的 `HttpInterceptor` ， 来添加这个 Header ， 代码如下：

```ts
export class AuthInterceptor implements HttpInterceptor {

    public intercept(
        req: HttpRequest<any>,
        next: HttpHandler
    ): Observable<HttpEvent<any>> {
        if (req.url.startsWith(environment.apiUrl)) {
            const request = req.clone({
                withCredentials: true,
                setHeaders: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });
            return next.handle(request);
        }
        return next.handle(req);
    }
}
```

最后， 在 app.module.ts 中注册这个拦截器， 代码为：

```ts
import { AuthInterceptor } from './services/auth.interceptor';

@NgModule({
    declarations: [
        AppComponent,
    ],
    providers: [
        {
            provide: HTTP_INTERCEPTORS,
            useClass: AuthInterceptor,
            multi: true
        }
    ],
    bootstrap: [AppComponent]
})
export class AppModule {}
```

现在再次访问需要认证的 API 就不会有重定向结果返回了。
