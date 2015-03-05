---
layout: post
title: 使用 AngularJS 的 $resource 连接 WebAPI Controller
description: 使用 AngularJS 的 $resource 连接 WebAPI Controller , 实现 REST 客户端
tags: [AngularJS, ASP.NET, WebAPI]
keywords: rest, web api controller, angular
---

ASP.NET Web API is a framework that makes it easy to build HTTP services that reach a broad range of clients, including browsers and mobile devices. ASP.NET Web API is an ideal platform for building [RESTful][1] applications on the .NET Framework.

A factory which creates a resource object that lets you interact with [RESTful][1] server-side data sources.

```c#
public class Category {

    public int CategoryId { get; set; }

    public string CategoryName { get; set; }

    public string Description { get; set; }

}
```

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

```js
var categories = $resource('/api/categories/:id', null, {
    update: {
        method: 'PUT'
    }
});
```

[1]: http://zh.wikipedia.org/wiki/REST