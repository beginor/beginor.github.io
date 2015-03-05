---
layout: post
title: 使用 Castle Windsor 实现 Web API 依赖注入
description: 使用 Castle Windsor 实现 .NET Web API 依赖注入
tags: [ASP.NET, WebAPI]
keywords: WebAPI, IDependencyResolver, IDependencyScope, Castle Windsor, Ioc, Dependency Injection
---

## Web API 的依赖注入

Web API 定义了依赖注入的接口 [IDependencyResolver][1] ， 定义如下：

```c#
public interface IDependencyResolver : IDependencyScope, IDisposable {
    IDependencyScope BeginScope();
}
public interface IDependencyScope : IDisposable {
    object GetService(Type serviceType);
    IEnumerable<object> GetServices(Type serviceType);
}
```

接口 [IDependencyScope][2] 有两个方法：

- GetService 创建指定类型的一个新实例；
- GetServices 创建制定类型的集合；

`IDependencyResolver` 接口继承自 `IDependencyScope` 并添加了一个 BeginScope 方法。 每次请求都会创建新的 Controller ， 为了管理对象的生命周期， IDependencyResolver 使用了作用域 (Scope) 的概念。

HttpConfiguration 对象的 DependencyResolver 拥有全局作用域， 当 Web API 创建 Controller 时， 会调用 BeginScope 方法， 返回一个类型为 IDependencyScope 的子作用域。

Web API 接下来调用子作用域的 GetService 方法来创建 Controller ， 依赖注入容器可以在这里创建 Controller 的实例， 并解决 Controller 的依赖项。 如果 GetService 方法返回 `null` ， 则 Web API 会使用 Controller 默认的构造函数来创建 Controller 实例。

<div class="alert alert-warning">
注意： 如果 GetService 不能创建指定类型的实例， 应当返回 null ； 如果 GetServices 不能创建指定类型的实例， 应当返回空的集合； 遇到未知类型不能抛出异常。
</div>

当请求完成时， 调用的 Dispose 方法来销毁子作用域， 如果 Controller 有资源需要销毁， 请在 Controller 的 Dispose 方法中显式销毁资源。

## 使用 Castle Windsor 实现依赖注入

通过下面的 PowerShell 命令来安装 Windsor： 

```powershell
Install-Package Castle.Windsor
```

知道了 IDependencyScope 和 IDependencyResolver 的定义以及注意问题， 实现起来就很容易了， 首先来实现 IDependencyScope ， 代码如下：

```c#
public class WindsorDependencyScope : IDependencyScope {

    private ILogger logger = NullLogger.Instance;

    public ILogger Logger {
        get { return logger; }
        set { logger = value; }
    }
    
    private IWindsorContainer container;

    protected IWindsorContainer Container {
        get { return container; }
    }

    public WindsorDependencyScope(IWindsorContainer container) {
        this.container = container;
    }

    public void Dispose() {
        // ChildScope 销毁时把 Container 也销毁；
        if (container.Parent != null) {
            container.RemoveChildContainer(container);
        }
        container.Dispose();
    }

    public object GetService(Type serviceType) {
        // 根据 GetService 的约定， 遇到未知类型不能抛出异常
        Logger.DebugFormat("GetService of type {0}", serviceType);
        object service = null;
        try {
            service = container.Resolve(serviceType);
        }
        catch (Exception ex) {
            Logger.Error(string.Format("Can not resolve {0}", serviceType), ex);
        }
        return service;
    }

    public IEnumerable<object> GetServices(Type serviceType) {
        Logger.DebugFormat("Get All Service of type {0}", serviceType);
        // Windsor 的 ResolveAll 方法不会抛出异常， 所以可以直接用；
        return container.ResolveAll(serviceType).Cast<object>();
    }

}
```

有了 WindsorDependencyScope ， 再实现一个 WindsorDependencyResolver 就更容易了， 代码如下：

```c#
public class WindsorDependencyResolver : WindsorDependencyScope, IDependencyResolver {

    public WindsorDependencyResolver(IWindsorContainer container) : base(container) { }

    public IDependencyScope BeginScope() {
        // 创建一个新的 WindsorContainer ， 并添加为 ChildContainer
        var childContainer = new WindsorContainer();
        Container.AddChildContainer(childContainer);
        // 返回新的 DepedencyScope
        return new WindsorDependencyScope(childContainer);
    }

}
```

## 注册 WindsorDependencyResolver

通过下面的代码将 WindsorDependencyResolver 注册到 HttpConfiguration 就可以使用了：

```c#
public void Configuration(IAppBuilder app) {
    var config = new HttpConfiguration();
    // 创建 WindsorContainer 新实例
    var container = new WindsorContainer();
    // 向 Container 注册 WindsorDependencyResolver ， 这样 WindsorDependencyResolver 自己
    // 也可以使用使用依赖项；
    container.Register(
        Component.For<IWindsorContainer>().Instance(container),
        Component.For<IDependencyResolver>().ImplementedBy<WindsorDependencyResolver>()
    );

    // 通过配置文件注册其它类型
    var installer = Castle.Windsor.Installer.Configuration.FromXmlFile("windsor.config");
    container.Install(installer);

    config.DependencyResolver.Resolve<IDependencyResolver>();
    // 向 OWIN 注册 WebAPI
    app.UseWebApi(config);
}
```

## 向 Windsor 注册 Controller

值得注意的是， Windsor 中注册的类型默认全是单例的， 而 WebAPI 对每次请求都需要创建 Controller 的新实例， 在请求完成之后销毁实例， 所以在 Windsor 注册的 Controller 类型必须显示声明生命周期为 transient 才能正常使用。

如果使用配置文件注册， 则需要在 xml 文件中添加生命周期， 示例代码如下：

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>

    <facilities>
        <facility id="logging"
                  type="Castle.Facilities.Logging.LoggingFacility, Castle.Facilities.Logging"
                  loggingApi="log4net" configFile="log.config" />
    </facilities>

    <components>
        <!-- Controller 类型必须显示声明生命周期为 transient  默认为 singleton -->
        <component type="WebApi.Controllers.CategoriesController,WebApi" lifestyle="transient"/>
        <component type="WebApi.Controllers.ProductsController,WebApi" lifestyle="transient"/>
    </components>

</configuration>
```

如果使用代码注册， 同样必须在代码中指定生命周期， 示例代码如下：

```c#
container.Register(
    Component.For<CategoryController>().LifestyleTransient(),
    Component.For<ProductsController>().LifestyleTransient()
);
```

如果 Controller 非常多的话， 可以考虑使用自定义的 Installer 。

参考 [Dependency Injection in ASP.NET Web API 2][3]

[1]: http://msdn.microsoft.com/en-us/library/system.web.http.dependencies.idependencyresolver(v=vs.118).aspx
[2]: http://msdn.microsoft.com/en-us/library/system.web.http.dependencies.idependencyscope(v=vs.118).aspx
[3]: http://www.asp.net/web-api/overview/advanced/dependency-injection