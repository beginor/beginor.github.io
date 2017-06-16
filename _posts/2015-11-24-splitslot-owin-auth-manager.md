---
layout: post
title: 吐槽 Micorsoft.Owin 的设计
description: 吐槽 Micorsoft.Owin.Security.IAuthenticationManager 的设计， 并提供一个不算完美的解决方案
keywords: OWIN, IAuthenticationManager, OwinContext, Windsor, IoC
tags: [OWIN, Windsor]
---

在 OWIN 的设计当中， 一切都是松散耦合的， 基于职责链的中间件处理模式给开发者提供了很大的自由， 基于 OWIN 的应用甚至可以脱离 Windows/IIS ， 运行在 Linux/Mono 之上。

## Microsoft.Owin 中奇葩的设计

不过今天要吐槽的是 `Microsoft.Owin` 的设计， 在传统的 `System.Web` 命名空间下， 有一个很庞大的 `HttpContext` 对象， 让开发者又爱又恨， 它位于 `System.Web.dll` 之中， 紧密依赖与 Windows/IIS ， 而且无所不包， 在 Windows/IIS 上完美运行， 然而也正是因为它紧密依赖 Windows/IIS ， 导致它无法跨平台运行， 在 Linux/Mono 上简直就是噩梦。

微软在 `Microsoft.Owin` 命名空间下设计了 `IOwinContext` 接口， 毫无疑问受到了 `HttpContext` 的影响， 这个接口的定义如下：

```csharp
public interface IOwinContext {

    IAuthenticationManager Authentication { get; }

    IDictionary<string, object> Environment { get; }

    IOwinRequest Request { get; }

    IOwinResponse Response { get; }

    TextWriter TraceOutput { get; set; }

    T Get<T>(string key);

    IOwinContext Set<T>(string key, T value);
}
```

这个接口简直是 `HttpContext` 的 OWIN 版， 包含 `Request` 和 `Response` 也就算了， 居然连 `IAuthenticationManager` 也包含了进去， 而且更为奇葩的事情是 `IAuthenticationManager` 的实例只能从 `IOwinContext` 获取， 没有其它任何实例化的方法。 以 WebApi 项目为例， 如果要使用 `IAuthenticationManager` 只能通过 OwinContext 来获取：

```csharp
// get AuthenticationManager from current owin context
var authMgr = Request.GetOwinContext().Authentication;
```
上面的代码只能在 `ApiController` 的子类的方法中使用， 但是会让 `ApiController` 隐式依赖于 `AuthenticationManager` 。

如果想在 `ApiController` 之外使用， 则只能这样：

```csharp
// or get from current http context;
HttpContext.Current.GetOwinContext()
```

但是这样又增加了对 `System.Web` 的依赖， 而且在 OWIN 应用中是不可用的。

## 使用依赖注入来分离这种奇葩的设计

在稍微大型的项目中， 为了隔离各个组件的依赖项， 便于模块化开发和测试， 一般都会使用依赖注入， 各个组件的依赖项都是注入的， 不是自己实例化的， 使用 `IAuthenticationManager` 的示例代码如下：

```csharp
public class TestController {

	public TestController(IAuthenticationManager authMgr) {}

}
```

项目中使用了 `Windsor` 作为 IoC 容器， 那么该怎么配置 `IAuthenticationManager` 呢？ `IAuthenticationManager` 只能通过 `IOwinContext` 实例属性获取， 就必须得先得到 `IOwinContext` 实例， 而 `IOwinContext` 的实例只有在 OWIN 中间件的 `Invoke` 方法才能获取到， 所以只能先做一个 OWIN 中间件：

```csharp
public class WindsorMiddleware : OwinMiddleware {

    public WindsorMiddleware(OwinMiddleware next) : base(next) {
    }

    public async override Task Invoke(IOwinContext context) {
        CallContext.LogicalSetData("owinContext", context);
        await Next.Invoke(context);
        CallContext.FreeNamedDataSlot("owinContext");
    }
}
```

然后扩展对 `ComponentRegistration<TService>` 做一个扩展方法 `FromOwinContext` ， 代码如下：

```csharp
public static class ComponentRegistrationExtensions {
    
    public static ComponentRegistration<TService> FromOwinContext<TService>(this ComponentRegistration<TService> registration)
        where TService : class {
        return registration.UsingFactoryMethod(
            factoryMethod: (kernel, model, creationContext) => {
                IOwinContext owinContext = (IOwinContext) CallContext.LogicalGetData("owinContext");
                if (owinContext == null) {
                    throw new InvalidOperationException("OwinContext is null!");
                }
                if (creationContext.RequestedType == typeof(IAuthenticationManager)) {
                    return (TService)owinContext.Authentication;
                }
                throw new NotSupportedException();
            },
            managedExternally: true
        );
    }
}
```

最终使用可以使用下面的代码来配置 `IAuthenticationManager` ：

```csharp
container.Register(
    Component.For<IAuthenticationManager>()
             .FromOwinContext()
             .LifestyleTransient()
);
```

虽然最终的目的达到了， 但是这代码的味道 ......

最后有图为证：

![Resolve IAuthenticationManager](/assets/post-images/resolve-authentication-manager.png)

本文参考： [Registering OWIN IAuthenticationManager using Castle Windsor](https://stackoverflow.com/questions/31807415/registering-owin-iauthenticationmanager-using-castle-windsor)

