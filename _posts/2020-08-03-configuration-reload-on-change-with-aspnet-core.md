---
layout: post2
title: 在 ASP.NET Core 中实现修改配置的重新加载
description: 在 ASP.NET Core 应用中实现配置文件改变时自动重新加载新的配置到应用
keywords: asp.net core, configuration, reload on change, ioptionssnapshot, ioptionsmonitor
tags: [.NET Core]
---

在 ASP.NET Core 默认的应用程序模板中， 配置文件的处理如下面的代码所示：

```cs
config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
      .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true);
```

`appsettings.json` 和 `appsettings.{env.EnvironmentName}.json` 两个配置文件都是可选的， 并且支持当文件被修改时能够重新加载。

可以在 ASP.NET Core 应用中利用这个特性， 实现修改配置文件之后， 不需要重启应用， 自动加载修改过的配置文件， 从而减少系统停机的时间。 实现的步骤如下：

## 使用配置 API 进行注入

假设要在程序中注入这样一个配置类型：

```cs
public class WeatherOption {
    public string City { get; set; }
    public int RefreshInterval { get; set; }
}
```

在 `appsettings.json` 中添加的配置如下：

```cs
{
  "weather": {
    "city": "GuangZhou",
    "refreshInterval": 120
  }
}
```

在 `Startup.cs` 的 `ConfigureServices` 方法中使用配置 API 进行注入， 代码如下：

```cs
public void ConfigureServices(IServiceCollection services) {
    services.Configure<WeatherOption>(Configuration.GetSection("weather"));
    services.AddControllers();
}
```

> 这个步骤很关键， 通过这个配置 API 可以把注入内容和配置所在的节点关联起来。 如果有兴趣了解底层实现的话， 可以继续查看这个 [OptionsConfigurationServiceCollectionExtensions.cs](https://github.com/dotnet/runtime/blob/master/src/libraries/Microsoft.Extensions.Options.ConfigurationExtensions/src/OptionsConfigurationServiceCollectionExtensions.cs) 。

通过这种方式注册的内容， 都是支持当配置文件被修改时， 自动重新加载的。

## 在控制器 (Controller) 中加载修改过后的配置

控制器 (Controller) 在 ASP.NET Core 应用的依赖注入容器中注册的生命周期是 `Scoped` ， 即每次请求都会创建新的控制器实例。 这样只需要在控制器的构造函数中注入 `IOptionsSnapshot<TOption>` 参数即可， 代码如下：

```cs
[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase {

    private WeatherOption option;

    public WeatherForecastController(
        IOptionsSnapshot<WeatherOption> options
    ) {
        this.option = options.Value;
    }

    // GET /weatherforcase/options
    [HttpGet("options")]
    public ActionResult<WeatherOption> GetOption() {
        return options;
    }
}
```

当然， 如果不希望在控制器中使用这个 `IOptionsSnapshot` 接口类型（可能会带来一些现有代码重构和修改， 还是有一定的风险的）， 可以在 `ConfigureServices` 中添加对 `WeatherOption` 的注入， 代码如下：

```cs
public void ConfigureServices(IServiceCollection services) {
    services.Configure<WeatherOption>(Configuration.GetSection("weather"));
    // 添加对 WeatherOption 的注入， 生命周期为 Scoped ， 这样每次请求都可以获取新的配置值。
    services.AddScoped(serviceProvider => {
        var snapshot = serviceProvider.GetService<IOptionsSnapshot<WeatherOption>>();
        return snapshot.Value;
    });
    services.AddControllers();
}
```

这样在控制器中就不需要注入 `IOptionsSnapshot<T>` 类型了， 最终控制器的代码如下：

```cs
[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase {

    private WeatherOption option;

    public WeatherForecastController(
        WeatherOption option
    ) {
        this.option = option;
    }

    // GET /weatherforcase/options
    [HttpGet("options")]
    public ActionResult<WeatherOption> GetOption() {
        return options;
    }
}
```

这样控制器就无需修改任何代码即可加载修改过后的新配置。

## 在中间件 (Middleware) 或者中加载修改过后的配置

中间件 (Middleware) 在 ASP.NET Core 应用的依赖注入容器中注册的生命周期是 `Singleton` ， 即单例的， 只有在当应用启动时， 根据中间件创建处理连时创建一次全局实例， 所以只能通过注入 `IOptionsMonitor<T>` 来监听配置文件的修改情况， 示例代码如下：

```cs
public class TestMiddleware {

    private RequestDelegate next;
    private WeatherOption option;

    public TestMiddleware(
        RequestDelegate next,
        IOptionsMonitor<WeatherOption> monitor
    ) {
        this.next = next;
        option = monitor.CurrentValue;
        // moni config change
        monitor.OnChange(newValue => {
            option = newValue;
        });
    }

    public async Task Invoke(HttpContext context) {
        await context.Response.WriteAsync(JsonSerializer.Serialize(option));
    }

}
```

当然， 在中间件的 `Task Invoke(HttpContext context)` 方法中， 直接获取 `IOptionsSnapshot<T>` 也是可以的， 代码如下：

```cs
public async Task Invoke(HttpContext context) {
    var snapshot = context.RequestServices.GetService<IOptionsSnapshot<WeatherOption>>();
    await context.Response.WriteAsync(JsonSerializer.Serialize(snapshot.Value));
}
```

但是这么做的话， 似乎就偏离了依赖注入的原则了， 所以不推荐这种做法。
