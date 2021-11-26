---
layout: post2
title: ASP.NET WebAPI 中的参数绑定
description: ASP.NET WebAPI 中的参数绑定
keywords: asp.net, webapi, parameter, binding, fromuri, frombody, type converter, model binder, value providers, httpparameterbinding, iactionvaluebinder
tags: [.NET, ASP.NET, WebAPI]
---

当 WebAPI 调用 Controller 上的方法时， 必须为其参数赋值， 这个过程就是参数绑定。 本文介绍 WebAPI 如何绑定参数， 以及如何进行自定义。

WebAPI 默认使用下面的规则进行参数绑定：

- 简单类型， WebAPI 尝试从 URL 中获取它的值。 简单类型包括：
  - .NET [原始类型](https://msdn.microsoft.com/en-us/library/system.type.isprimitive.aspx)（`int`、 `bool`、 `float`、 `double` 等）；
  - 以及 `TimeSpan` 、 `DateTime` 、 `Guid`、 `decimal` 和 `string`；
  - 提供了类型转换器 (Type Converter)， 能够从字符串转换的类型。
- 复杂类型则使用 [`media-type formatter`](https://docs.microsoft.com/en-us/aspnet/web-api/overview/formats-and-model-binding/media-formatters) 从 HTTP 请求的正文 (body) 中读取。

比如一个典型的 WebAPI 方法：

```cs
IHttpActionResult Put(int id, Product item) { ... }
```

参数 `id` 是一个简单类型， 所以从 request URI 中取值， 而参数 `item` 是复杂类型， 则从 request 正文 (body) 中取值。

## 使用 [FromUri]

要强制 WebAPI 从 URL 读取一个复杂类型的参数， 则需要在该参数上添加 [FromUri](https://msdn.microsoft.com/en-us/library/system.web.http.fromuriattribute.aspx) 标记。 下面的例子定义了一个 `GeoPoint` 类型， 以及如何从 URI 中获取 `GeoPoint` 实例。

```cs
public class GeoPoint {
    public double Latitude { get; set; }
    public double Longitude { get; set; }
}

public class TestController : ApiController {
    public IHttpActionResult Get([FromUri]GeoPoint location) { ... }
}
```

客户端可以在 QueryString 中传递 Latitude 和 Longitude 来构造 GeoPoint 实例， 示例请求如下：

```
http://127.0.0.1/api/test?latitude=22.3&longitude=113.2
```

> 注： QueryString 中的参数名称是不区分大小写的。

对于数组类型， 也可以使用 `[FromUri]` 标记， 比如：

```cs
public IHttpActionResult Get([FromUri]int[] items) { ... }
```

客户端这样发送请求：

```
http://127.0.0.1/api/test?items=1&items=2&items=3
```

服务端就可以接收到数组参数了。

## 使用 [FromBody]

要强制 WebAPI 从 request正文 (body) 中读取一个简单类型的参数， 需要在该参数上添加 [`FromBody`](https://msdn.microsoft.com/en-us/library/system.web.http.frombodyattribute.aspx) 标记:

```cs
public HttpResponseMessage Post([FromBody] string name) { ... }
```

在这个例子中， WebAPI 需要使用 `media-type formatter` 从 request正文 (body) 中读取 `name` 的值， 示例请求如下：

```console
POST http://localhost:5076/api/values HTTP/1.1
User-Agent: Fiddler
Host: localhost:5076
Content-Type: application/json
Content-Length: 7
"Alice"
```

当一个参数有 `[FromBody]` 标记时， WebAPI 使用 `Content-Type` 标头来选择正确的格式， 在上面的例子中， `Content-Type` 是 `application/json` ， request正文 (body) 的内容是原始的 JSON 字符串， 而不是一个 JSON 对象。

> 一个函数中， 最多只能有一个 `[FromBody]` 标记， 因为客户端的请求有可能没有缓冲， 只能被读取一次。

## 使用 Type Converter

通过创建 **Type Converter** ， 实现从字符串转换的方法， 可以让 WebAPI 将复杂类型参数视为简单类型参数。

以上面的 `GeoPoint` 为例， 再提供一个 `GeoPointConverter` 实现从字符串到 `GeoPoint` 的转换：

```cs
[TypeConverter(typeof(GeoPointConverter))]
public class GeoPoint {

    public double Latitude { get; set; }
    public double Longitude { get; set; }

    public bool TryParse(string s, out GeoPoint result) {
        result = null;
        var parts = s.Split(',');
        if (parts.Length != 2) {
            return false;
        }
        double latitude, longitude;
        if (double.TryParse(parts[0], out latitude) &&
            double.TryParse(parts[1], out longitude)) {
            result = new GeoPoint() { Longitude = longitude, Latitude = latitude };
            return true;
        }
        return false;
    }
}

public class GeoPointConverter : TypeConverter {

    public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType){
        if (sourceType == typeof(string)) {
            return true;
        }
        return base.CanConvertFrom(context, sourceType);
    }

    public override object ConvertFrom(ITypeDescriptorContext context, 
        CultureInfo culture, object value) {
        if (value is string) {
            GeoPoint point;
            if (GeoPoint.TryParse((string)value, out point)) {
                return point;
            }
        }
        return base.ConvertFrom(context, culture, value);
    }
}
```

现在， WebAPI 会将 `GeoPoint` 当作简单类型， 意味着将尝试从 URI 中绑定 GeoPoint 参数的值， 也不再需要 `[FromUri]` 标记：

```cs
public HttpResponseMessage Get(GeoPoint location) { ... }
```

客户端这样发送 HTTP 请求：

```
https://127.0.0.1/api/test?location=22.3,113.2
```

## 使用 Model Binder

另一个比 **type converter** 更加灵活的是创建自定义 **Model Binder** 。 通过 **Model Binder** ， 可以直接访问 http 请求、 action 描述以及路由的原始值。

要创建 **Model Binder** ， 需要实现接口 `IModelBinder` ， 它只定义了一个方法 `BindModel` :

```cs
public interface IModelBinder {
    bool BindModel(
        HttpActionContext actionContext,
        ModelBindingContext bindingContext
    );
}
```

下面是针对 `GeoPoint` 的实现：

```cs
public class GeoPointModelBinder : IModelBinder {
    // List of known locations.
    private static ConcurrentDictionary<string, GeoPoint> _locations
        = new ConcurrentDictionary<string, GeoPoint>(StringComparer.OrdinalIgnoreCase);

    static GeoPointModelBinder() {
        _locations["redmond"] = new GeoPoint() { Latitude = 47.67856, Longitude = -122.131 };
        _locations["paris"] = new GeoPoint() { Latitude = 48.856930, Longitude = 2.3412 };
        _locations["tokyo"] = new GeoPoint() { Latitude = 35.683208, Longitude = 139.80894 };
    }

    public bool BindModel(
        HttpActionContext actionContext,
        ModelBindingContext bindingContext
    ) {
        if (bindingContext.ModelType != typeof(GeoPoint)) {
            return false;
        }
        // exit if no value from value provider
        var val = bindingContext.ValueProvider.GetValue(
            bindingContext.ModelName
        );
        if (val == null) {
            return false;
        }
        // exit if row value is not a string.
        string key = val.RawValue as string;
        if (key == null) {
            bindingContext.ModelState.AddModelError(
                bindingContext.ModelName,
                "Wrong value type"
            );
            return false;
        }
        //
        GeoPoint result;
        if (_locations.TryGetValue(key, out result)
            || GeoPoint.TryParse(key, out result)) {
            bindingContext.Model = result;
            return true;
        }
        //
        bindingContext.ModelState.AddModelError(
            bindingContext.ModelName,
            "Cannot convert value to Location"
        );
        return false;
    }
}
```

代码很简单， 不必做太多的说明， Model Binder 不止局限于简单类型， 也支持复杂类型。 上面的 MobelBinder 支持两种格式的查询：

- 使用已知的地名： `http://127.0.0.1:/rest/api/test?location=redmond` ；
- 使用经纬度： `http://127.0.0.1:/rest/api/test?location=47.67856,-122.131` ；

### 设置 Model Binder

首先， 可以在 action 方法的参数上添加 [`[ModelBinder]`](https://msdn.microsoft.com/en-us/library/system.web.http.modelbinding.modelbinderattribute.aspx) 标记， 例如：

```cs
public HttpResponseMessage Get(
    [ModelBinder(typeof(GeoPointModelBinder))] GeoPoint location
)
```

其次， 可以在 `GeoPoint` 类型上添加 [ModelBinder] 标记， 例如：

```cs
[ModelBinder(typeof(GeoPointModelBinder))]
public class GeoPoint {
    // ....
}
```

最后， 还可以在 `HttpConfiguration` 类中添加一个 **model-binder provider** 来使用， 代码如下：

```cs
public static class WebApiConfig {

    public static void Register(HttpConfiguration config) {
        var provider = new SimpleModelBinderProvider(
            typeof(GeoPoint),
            new GeoPointModelBinder()
        );
        config.Services.Insert(
            typeof(ModelBinderProvider),
            0,
            provider
        );
        // ...
    }

}
```

在 action 方法中仍然需要为参数添加 `[ModelBinder]` 标记， 来说明该参数需要使用 **model-binder** 来而不是 **media formatter** 来进行参数绑定， 不过此时就不需要再指定 ModelBinder 的类型了：

```cs
public HttpResponseMessage Get(
    [ModelBinder] GeoPoint location
) { ... }
```

## 使用 ValueProvider 

**Model Binder** 需要从 **Value Provider** 中取值， 因此也可以创建自定义的 **Value Provider** 实现获取特殊的值。 要实现自定义的 `ValueProvider` ， 需要实现接口 `IValueProvider` ， 下面是一个从 Cookie 中获取值的 `CookieValueProvider` ：

```cs
public class CookieValueProvider : IValueProvider {

    private Dictionary<string, string> values;

    public CookieValueProvider(HttpActionContext actionContext) {
        if (actionContext == null) {
            throw new ArgumentNullException("actionContext");
        }
        values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var cookie in actionContext.Request.Headers.GetCookies()) {
            foreach (CookieState state in cookie.Cookies) {
                values[state.Name] = state.Value;
            }
        }
    }

    public bool ContainsPrefix(string prefix) {
        return values.Keys.Contains(prefix);
    }

    public ValueProviderResult GetValue(string key) {
        string value;
        if (values.TryGetValue(key, out value)) {
            return new ValueProviderResult(value, value, CultureInfo.InvariantCulture);
        }
        return null;
    }

}
```

同时还需要定义一个继承自 `ValueProviderFactory` 的 `CookieValueProviderFactory` ， 代码如下：

```cs
public class CookieValueProviderFactory : ValueProviderFactory {

    public override IValueProvider GetValueProvider(HttpActionContext actionContext) {
        return new CookieValueProvider(actionContext);
    }

}
```

然后将 `CookieValueProviderFactory` 注册到 `HttpConfiguration` 实例：

```cs
public static void Register(HttpConfiguration config) {
    config.Services.Add(
        typeof(ValueProviderFactory),
        new CookieValueProviderFactory()
    );
    // ...
}
```

Web API 将组合所有的 **ValueProviderFactory** ， 当一个 model binder 调用 `ValueProvider.GetValue` 方法时， 将会收到第一个能够提供对应值的 **ValueProviderFactory** 提供的值。

或者， 也可以直接在在参数上使用 `ValueProviderAttribute` 标记：

```cs
public HttpResponseMessage Get(
    [ValueProvider(typeof(CookieValueProviderFactory))] GeoPoint location
) { ... }
```

这样， Web API 在处理这个参数时， 就会直接使用 `CookieValueProviderFactory` ， 不再使用其它的 CookieValueProviderFactory 。

## HttpParameterBinding

**Model binder** 只是参数绑定中的一个特定的实例， 如果查看 `ModelBinderAttribute` 类的定义， 会发现它继承自抽象类 `ParameterBindingAttribute` ， 这个类只定义了一个方法 `GetBinding` ， 返回一个 `HttpParameterBinding` 实例。

```cs
public abstract class ParameterBindingAttribute : Attribute {

    public abstract HttpParameterBinding GetBinding(
        HttpParameterDescriptor parameter
    );

}
```

`HttpParameterBinding` 负责将参数绑定到值， 以 `[ModelBinder]` 为例， 这个标记返回一个 `HttpParameterBinding` 实现， 使用 `IModelBinder` 进行具体的绑定。 当然， 也可以实现自定义的 `HttpParameterBinding` 。

假设要获取 HTTP 请求 Header 中的 `if-match` 和 `if-none-match` 标签 (ETag) ， 先定义一个类来表示 ETag ：

```cs
public class ETag {
    public string Tag { get; set; }
}
```

同时再定义一个枚举来指定是从 `if-match` 还是 `if-none-match` 标头中获取 ETag：

```cs
public enum ETagMatch {
    IfMatch,
    IfNoneMatch
}
```

接下来是从 HTTP 请求头中获取 `ETag` 的 `ETagParameterBinding` ， 

```cs
public class ETagParameterBinding : HttpParameterBinding {

    ETagMatch match;

    public ETagParameterBinding(
        HttpParameterDescriptor parameter,
        ETagMatch match
    ) : base(parameter) {
        match = match;
    }

    public override Task ExecuteBindingAsync(
        ModelMetadataProvider metadataProvider, 
        HttpActionContext actionContext,
        CancellationToken cancellationToken
    ) {
        EntityTagHeaderValue etagHeader = null;
        switch (match) {
            case ETagMatch.IfNoneMatch:
                etagHeader = actionContext.Request.Headers.IfNoneMatch.FirstOrDefault();
                break;
            case ETagMatch.IfMatch:
                etagHeader = actionContext.Request.Headers.IfMatch.FirstOrDefault();
                break;
        }
        ETag etag = null;
        if (etagHeader != null) {
            etag = new ETag { Tag = etagHeader.Tag };
        }
        actionContext.ActionArguments[Descriptor.ParameterName] = etag;
        var tsc = new TaskCompletionSource<object>();
        tsc.SetResult(null);
        return tsc.Task;
    }
}
```

在 `ExecuteBindingAsync` 方法中实现具体的绑定， 在这个方法中， 将取得的参数的值存放到 `HttpActionContext` 的 `ActionArgument` 字典中。

> 注意， 如果自定义的 `HttpParameterBinding` 需要从 HTTP 请求的正文 (body) 中读取信息， 则需要重写 `WillReadBody` 并返回 `true` 。 由于 HTTP 请求正文可能是个没有缓冲的流， 只能读取一次， 所以 Web API 加强了一个规则， 那就是每个方法只有一个绑定能够从 HTTP 请求正文读取数据。

要使用自定义的 `HttpParameterBinding` ， 则需要创建一个自定义的标记， 继承自 `ParameterBindingAttribute` 。 针对上面的 `ETagParameterBinding` ， 我们来定义两个自定义标记， 分别表示从 `if-match` 和 `if-none-match` 标头中获取， 代码如下：

```csharp
public abstract class ETagMatchAttribute : ParameterBindingAttribute {

    private ETagMatch match;

    public ETagMatchAttribute(ETagMatch match) {
        match = match;
    }

    public override HttpParameterBinding GetBinding(
        HttpParameterDescriptor parameter
    ) {
        if (parameter.ParameterType == typeof(ETag)) {
            return new ETagParameterBinding(parameter, match);
        }
        return parameter.BindAsError("Wrong parameter type");
    }
}

public class IfMatchAttribute : ETagMatchAttribute {

    public IfMatchAttribute() : base(ETagMatch.IfMatch) { }

}

public class IfNoneMatchAttribute : ETagMatchAttribute {

    public IfNoneMatchAttribute() : base(ETagMatch.IfNoneMatch) { }

}
```

下面是一个使用 `IfNoneMatch` 的例子：

```csharp
public HttpResponseMessage Get([IfNoneMatch] ETag etag) { ... }
```

除了直接使用这个标记， 也可以在 `HttpConfiguration` 中进行配置， 代码如下：

```csharp
config.ParameterBindingRules.Add(p => {
    if (p.ParameterType == typeof(ETag)
        && p.ActionDescriptor.SupportedHttpMethods.Contains(HttpMethod.Get)
    ) {
        return new ETagParameterBinding(p, ETagMatch.IfNoneMatch);
    }
    else {
        return null;
    }
});
```

> 注意， 无法绑定时， 一定要返回 `null` 。

## IActionValueBinder

整个参数绑定的过程由一个叫做 `IActionValueBinder` 的可插拔的服务控制，默认的按照下面的规则进行参数绑定：

1. 在参数上查找 ` ParameterBindingAttribute` ， 包括 `[FromBody]` 、 `[FromUri]` 、 `[ModelBinder]` 或者其它自定义标记；
2. 然后在 `HttpConfiguration.ParameterBindingRules` 中查找一个返回 `HttpParameterBinding` 实例的函数；
3. 最后， 使用上面提到的默认规则：
   - 如果参数是一个简单类型或者指定了类型转换器， 从 URI 绑定， 相当于在参数上添加 `[FromUri]` 标记；
   - 否则， 尝试从 HTTP 请求正文中读取， 相当于在参数上添加 `[FromBody]` 标记。

如果默认的绑定不能满足需求， 也可以实现自定义的 `IActionValueBinder` 来替换掉 Web API 默认的实现。
