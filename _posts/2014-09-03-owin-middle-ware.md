---
layout: post
title: OWIN 请求处理与中间件
description: 介绍 OWIN 请求处理与中间件及其实现方式
tags: [OWIN]
keywords: OWIN, AppFunc, Middleware
---

## OWIN 请求处理函数

在 OWIN 的最底层， 处理请求的函数定义的委托签名如下：

```c#
Func<IDictionary<string, object>, Task>
```

这个函数接受类型为 `IDictionary<string, object>` 的 OWIN 环境， 返回一个 `Task`
对象。

通常可以为这个函数起这样的别名：

```c#
using AppFunc = Func<
    IDictionary<string, object>, // OWIN 环境
    Task>; // 任务
```

于是，请求处理函数可以这样表示：

```c#
Func<AppFunc, Task>
```

## OWIN 中间件 (Middleware)

中间件是 OWIN 中很重要的概念， 中间件介于 OWIN 服务器 与 OWIN 应用之间， 通过职责链模式处
理请求。 

OWIN 为 Middleware 的注册提供了三个版本的重载函数， 可以分别适用于不同的场景：

```c#
public interface IAppBuilder {
    IAppBuilder Use(object middleware, params object[] args);
}

public static class AppBuilderUseExtensions {
    public static IAppBuilder Use<T>(
        this IAppBuilder app,
        params object[] args
    );
    public static IAppBuilder Use(
        this IAppBuilder app,
        Func<IOwinContext, Func<Task>, Task> handler
    );
}
```

根据这三个方法， 添加 Middleware 有如下几种方式：

### Lambda 表达式

使用 Lambda 表达式可以创建简单的或者用于诊断的中间件， 比如：

```c#
app.Use(async (context, next) => {
    Console.WriteLine("Middleware with Lambda begin.");
    await next();
    Console.WriteLine("Middleware with Lambda end.");
});
```

当然， Middleware 执行时可以不必等待下一个处理程序结束而直接返回， 比如：

```c#
app.Use(async (context, next) => {
    Console.WriteLine("Middleware with Lambda begin.");
    return Task.FromResult(0);
});
```

### Middleware 类型

创建自定义 Middleware 类型是最通用的方式， 只要遵守 OWIN 的约定即可：

- 构造函数的第一个参数必须是处理管线中的下一个处理函数；
- 必须有一个 Invoke 函数， 接受 OWIN 环境参数， 返回 Task；

示例代码如下：

```c#
using AppFunc = Func<IDictionary<string, object>, Task>;

public class LogMiddleware  {

    private readonly AppFunc next;

    public LogMiddleware(AppFunc next) {
        this.next = next;
    }

    public async Task Invoke(IDictionary<string, object> env) {
        Console.WriteLine("LogMiddleware Start.");
        await next(env);
        Console.WriteLine("LogMiddleware End.");
    }
}
```

使用上面的中间件的代码如下：

```c#
app.Use<LogMiddleware>(/* 构造函数其它参数 */);
```

在运行时， OWIN 通过反射调用 LogMiddleware 的构造函数创建实例并调用 Invoke 方法。

### Middleware 实例

当然，还可以直接使用 Middleware 的实例， 这样很适用于有 IoC 容器的场景， 同样， 只要符合
OWIN 的约定即可：

- 必须有一个 Initialize 实例方法， 该方法接受的第一个参数必须是上面的 `AppFunc` ;
- 必须有一个 Invoke 实例方法， 该方法接受 OWIN 环境参数， 返回 `Task` ；

示例代码如下：

```c#
using AppFunc = Func<IDictionary<string, object>, Task>;

public class InstanceMiddleware {

    private AppFunc next;

    public void Initialize(AppFunc next) {
        this.next = next;
    }

    public async Task Invoke(IDictionary<string, object> env) {
        Console.WriteLine("InstanceMiddleware Start.");
        await next(env);
        Console.WriteLine("InstanceMiddleware End.");
    }
}
```

Middleware 实例可以这样使用：

```c#
var instance = new InstanceMiddleware();
/*
   instance 后面可以添加 Initialize 方法的其它参数， 如果有 IoC 容器的话， 似乎就没什么
   必要了
*/
app.Use(instance);
```

### OwinMiddleware 子类

如果对上面的反射以及约定不感兴趣的话， 还可以使用 [`OwinMiddleware`][1] 基类， 该类型定义
如下：

```c#
public abstract class OwinMiddleware {

    protected OwinMiddleware Next { get; set; }

    protected OwinMiddleware(OwinMiddleware next) {
        this.Next = next;
    }

    public abstract Task Invoke(IOwinContext context);

}
```

使用基类的话， 上面的 LogMiddleware 就要这样写了：

```c#
public class LogOwinMiddleware : OwinMiddleware {

    public LogOwinMiddleware(OwinMiddleware next)
        : base(next) {
    }

    public async override Task Invoke(IOwinContext context) {
        Console.WriteLine("LogOwinMiddleware Start.");
        await Next.Invoke(context);
        Console.WriteLine("LogOwinMiddleware End.");
    }

}
```

上面对 Middleware 的介绍比较全了， 如果要做 OWIN Middleware 开发的话， 可以从这几种方式
入手。

> PS:  还有一种使用[內联函数][2]的方式， 也提一下， 但是个人不怎么推荐， 比如 Middleware
可以表示成：

```c#
Func<AppFunc // next process delegate, 
     AppFunc // this process delegate
    >
```

使用起来是这样自的：

```c#
app.Use(new Func<AppFunc, AppFunc>(next => (async env => {
    Console.WriteLine("Middleware with AppFunc begin.");
    await next.Invoke(env);
    Console.WriteLine("Middleware with AppFunc end.");
})));
```

[1]: https://msdn.microsoft.com/en-us/library/microsoft.owin.owinmiddleware(v=vs.113).aspx
[2]: https://benfoster.io/blog/how-to-write-owin-middleware-in-5-different-steps
