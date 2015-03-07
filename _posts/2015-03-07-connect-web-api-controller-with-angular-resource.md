---
layout: post
title: 使用 AngularJS 的 $resource 连接 WebAPI Controller
description: 使用 AngularJS 的 $resource 连接 WebAPI Controller , 实现 REST 客户端
tags: [AngularJS, ASP.NET, WebAPI]
keywords: rest, web api controller, angular
---

ASP.NET Web API 是 .NET 平台创建 [REST][1] 风格的 HTTP 服务的理想框架， REST 风格的 HTTP 服务可以被多种客户端使用， 包括浏览器和移动设备， 使用 REST 风格的 HTTP 服务也越来越多。

由于 REST 服务的逐渐流行， 越来越多的客户端类库都提供了 REST 服务的专用类库， AngularJS 也不例外， 提供了 `$resource` 来实现 REST 服务的支持。

在 AngularJS 的文档中， 对 `$resource` 的描述如下：

> A factory which creates a resource object that lets you interact with [RESTful][1] server-side data sources.

接下来就介绍如何使用 AngularJS 的 `$resource` 对接 ASP.NET Web API 创建的 REST 服务。

假设我们有下面一个 `Category` 实体类：

```c#
public class Category {

    public int CategoryId { get; set; }

    public string CategoryName { get; set; }

    public string Description { get; set; }

}
```

`CategoriesController` 类实现了基本的 CURD 操作， 代码如下：

```c#
public class CategoriesController : ApiController {

    private static readonly IList<Category> Data;

    // GET ~/api/categories
    public IHttpActionResult GetAll() {
        return Ok(Data);
    }

    // GET ~/api/categories/{id:int}
    public IHttpActionResult Get(int id) {
        var c = Data.FirstOrDefault(cat => cat.CategoryId == id);
        if (c == null) {
            return NotFound();
        }
        return Ok(c);
    }

    // POST ~/api/categories
    public IHttpActionResult Post(Category category) {
        category.CategoryId = Data.Count + 1;
        Data.Add(category);
        var response = Request.CreateResponse(category);
        var url = Url.Link("DefaultApi", new { id = category.CategoryId });
        response.Headers.Location = new Uri(url);
        return ResponseMessage(response);
    }

    // PUT ~/api/categories/{id:int}
    public IHttpActionResult Put([FromUri]int id, [FromBody]Category category) {
        var cat = Data.FirstOrDefault(c => c.CategoryId == id);
        if (cat == null) {
            return NotFound();
        }
        cat.CategoryName = category.CategoryName;
        cat.Description = category.Description;
        return Ok(cat);
    }

    // DELETE ~/api/categories/{id:int}
    public IHttpActionResult Delete(int id) {
        var cat = Data.FirstOrDefault(c => c.CategoryId == id);
        if (cat != null) {
            Data.Remove(cat);
        }
        return StatusCode(System.Net.HttpStatusCode.NoContent);
    }
}
```

实现的 REST 服务描述如下：

<table class="table">
<thead>
<tr>
<th><div class="text-left">方法</div></th>
<th><div class="text-left">地址</div></th>
<th><div class="text-left">描述</div></th>
</tr>
</thead>
<tbody>
<tr>
    <td><div class="text-left">GET</div></td>
    <td><div class="text-left">~/api/categories</div></td>
    <td><div class="text-left">Get all categories</div></td>
</tr>
<tr>
    <td><div class="text-left">GET</div></td>
    <td><div class="text-left">~/api/categories/{id:int}</div></td>
    <td><div class="text-left">Get category by id</div></td>
</tr>
<tr>
    <td><div class="text-left">POST</div></td>
    <td><div class="text-left">~/api/categories/</div></td>
    <td><div class="text-left">Create a new category</div></td>
</tr>
<tr>
    <td><div class="text-left">PUT</div></td>
    <td><div class="text-left">~/api/categories/{id:int}</div></td>
    <td><div class="text-left">Update an exist category</div></td>
</tr>
<tr>
    <td><div class="text-left">DELETE</div></td>
    <td><div class="text-left">~/api/categories/{id:int}</div></td>
    <td><div class="text-left">Delete category by id</div></td>
</tr>
</tbody>
</table>

AngularJS 提供了 `$resource` 服务来创建具有高级行为的对象和 REST 服务交互， 从而不需要在使用底层的 `$http` 服务。

`$resource` 的基本用法如下：

```js
$resource(url, [paramDefaults], [actions], options);
```

参数说明如下：

- url REST 服务的地址， 如果URL有参数， 则在参数名之前添加 `:`， 比如： `/user/:username` ；
- paramDefaults ， 用 json 形式表示的 url 参数的默认值， 比如上面的  `/user/:username` ， 可以设置默认值为： `{ username: 'anonymous' }` ， 则默认会生成下面的 URL： `/user/anonymous`； 如果参数的默认值是函数， 在请求时会执行函数以求得默认值；如果参数值是以 `@` 开头的， 则表示要从请求发送的 json 对象中提取对应的属性值， 比如参数默认值为 `{ username: '@username' }`， 则会讲发送对象的 `username` 属性填充到 URL 中；
- actions 额外的 HTTP 动作， 具体请参考 [$http.config][2];
- options 可选项， 只支持 `stripTrailingSlashes` ， 配置是否将 URL 结尾的 `/` 移除；

$resource 返回的对象默认支持下列动作：

```json
{
  'get':    {method:'GET'},
  'save':   {method:'POST'},
  'query':  {method:'GET', isArray:true},
  'remove': {method:'DELETE'},
  'delete': {method:'DELETE'}
};
```

因此， 针对前面创建的 REST 服务， 还需要一个使用 `PUT` 的 `update` 动作， 客户端代码如下：

```js
var categories = $resource('/api/categories/:id', { id: '@id' }, {
    update: {
        method: 'PUT'
    }
});
```

使用起来也是非常方便的， 比如： 

```js
// get all categories from server
categories.query(function(data) {
    // play with data in the call back;
});

// get one category
var cat = categories.get({id: 1}, function() {
    cat.Description = 'a nice description';
    cat.$update();
});
```

当然， 也可以使用 `promise` 风格的回调函数， 比如：

```js
// get all categories with promise
categories.query().promise.then(function(data) {
    // play with data in promise.then
})
.fail(function(http) {
    // show http error here.
});
```

[1]: http://zh.wikipedia.org/wiki/REST
[2]: https://docs.angularjs.org/api/ng/service/$http#usage