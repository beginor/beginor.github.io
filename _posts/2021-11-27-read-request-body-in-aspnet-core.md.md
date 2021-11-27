---
layout: post2
title: 在 AspNetCore 中读取当前请求的请求体 (Request.Body)
description: post description
keywords: asp.net, asp.net core, controller, middleware, request.body, enablerequestbuffering
tags: [.NET, ASP.NET, .NET Core]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

最近有需要在 AspNet Core 应用中读取当前请求的请求体 (Request.Body) ， 本来以为是很简单的事情， 没想到居然有坑， 因此记录如下。

动作方法 (Action Method) 没有参数的情况下， 可以用正常读取请求体的， 代码如下：

```c#
[HttpPost("")]
public async Task<ActionResult> Post() {
    var result = await Request.BodyReader.ReadAsync();
    var message = string.Empty;
    if (result.IsCompleted) {
        message = Encoding.UTF8.GetString(result.Buffer);
    }
    return Ok(message);
}
```

动作方法 (Action Method) 如果有任何参数的情况下，即使参数不是来自请求体 (`FromRoute`, `FromQuery`) 等， 都无法再读取 `Request.Body` ， 比如将上面的代码修改一下， 添加一个路由参数， 如下所示：

```c#
[HttpPost("{id}")]
public async Task<ActionResult> Post([FromRoute]string id) {
    var result = await Request.BodyReader.ReadAsync();
    var message = string.Empty;
    if (result.IsCompleted) {
        message = Encoding.UTF8.GetString(result.Buffer);
    }
    return Ok(message);
}
```

将会产生类似这样的的异常信息：

```text
System.ArgumentOutOfRangeException: Specified argument was out of the range of valid values.
   at System.Text.EncodingExtensions.GetString(Encoding encoding, ReadOnlySequence`1& bytes)
   at WebTest.Controllers.TestController.Post(String id) in /Users/zhang/Desktop/WebTest/Controllers/TestController.cs:line 21
   at lambda_method5(Closure , Object )
   at Microsoft.AspNetCore.Mvc.Infrastructure.ActionMethodExecutor.TaskOfActionResultExecutor.Execute(IActionResultTypeMapper mapper, ObjectMethodExecutor executor, Object controller, Object[] arguments)
   at Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker.<InvokeActionMethodAsync>g__Awaited|12_0(ControllerActionInvoker invoker, ValueTask`1 actionResultValueTask)
   at Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker.<InvokeNextActionFilterAsync>g__Awaited|10_0(ControllerActionInvoker invoker, Task lastTask, State next, Scope scope, Object state, Boolean isCompleted)
   at Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker.Rethrow(ActionExecutedContextSealed context)
   at Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker.Next(State& next, Scope& scope, Object& state, Boolean& isCompleted)
   at Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker.InvokeInnerFilterAsync()

```

因为默认设置下， `Request.Body` 只能被读取一次， 而当动作方法有参数时， ASP.NET Core 框架将会处理当前请求， 执行到动作方法内部时， `Request.Body` 已经被读取过一次了。

![image-20211127160034130](/assets/post-images/image-20211127160034130.png)

要解决这个问题， 可以调用 [Request.EnableBuffering()](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.http.httprequestrewindextensions.enablebuffering) 方法来确保请求体能够被多次读取， 比如可以添加一个中间件， 在中间件中调用这个方法：

```diff
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment()) {
    app.UseSwagger();
    app.UseSwaggerUI();
}

+ app.Use((context, next) => {
+     context.Request.EnableBuffering();
+     return next(context);
+ });

app.UseAuthorization();
app.MapControllers();

app.Run();
```

这样，将会对所有的请求的请求体启用缓存， 可能会对性能造成一些影响，请求体小于 30k 时， 在内存中进行缓存， 当请求体大于 30k 时， 将会写入临时文件， 临时文件的目录可以由环境变量 `ASPNETCORE_TEMP` 定义或者写入当前用户的临时目录。

![image-20211127165058103](/assets/post-images/image-20211127165058103.png)

如果只是在控制器中读取请求体，还可以定义一个过滤器， 在过滤器中调用 `Request.EnableBuffering()` 方法， 代码如下：

```c#
public class EnableRequestBufferingAttribute : ActionFilterAttribute {

    public override void OnActionExecuting(ActionExecutingContext context) {
        context.HttpContext.Request.EnableBuffering();
    }

}
```

这样只要在相应的动作方法上添加这个过滤器标记，就可以读取请求体了

```c#
[HttpPost("{id}")]
[EnableRequestBuffering]
public async Task<ActionResult> Post([FromRoute]string id) {
    var result = await Request.BodyReader.ReadAsync();
    var message = string.Empty;
    if (result.IsCompleted) {
        message = Encoding.UTF8.GetString(result.Buffer);
    }
    return Ok(message);
}
```

