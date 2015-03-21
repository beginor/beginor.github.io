---
layout: post
title: 在 ASP.NET WebAPI 中使用 DataAnnotations 验证数据
description: 在 ASP.NET WebAPI 中使用 DataAnnotations 简化数据验证
keywords: asp.net, webapi, data validation, 
tags: [ASP.NET, WebAPI]
---

为了 Web 服务的安全， 通常在服务端也会做数据验证， 不过数据验证的代码确实是优点枯燥， 以简单的用户注册来说， 需要的注册信息如下：

```c#
public class RegisterModel {

    public string Username { get; set; }

    public string Password { get; set; }

    public string Confirm { get; set; }

}
```

作为最简单的示例， 只需要提供用户名、 密码、 以及确认密码即可， 验证的要求如下：

- 用户名必填；
- 密码必填；
- 确认密码必填；
- 确认密码必须和密码一致；

虽然示例是简单的， 但是验证的规则并不简单， 如果手写验证代码的话， 则对应的服务端验证代码如下：

```c#
[RoutePrefix("api/account")]
public class AccountController : ApiController {

    [HttpPost]
    public IHttpActionResult Register(RegisterModel model) {
        // 开始检查用户输入
        var errors = new Dictionary<string, string>();
        // 用户名必填
        if (string.IsNullOrEmpty(model.Username)) {
            errors.Add("Username", "Username is required.");
        }
        // 密码必填
        if (string.IsNullOrEmpty(model.Password)) {
            errors.Add("Password", "Password is required.");
        }
        // 确认密码必填
        if (string.IsNullOrEmpty(model.Confirm)) {
            errors.Add("Confirm", "Confirm is required.");
        }
        // 确认密码必须和密码一致
        if (model.Confirm != model.Password) {
            errors.Add("Confirm", "Password != Confirm");
        }
        // 没有错误
        if (errors.Count == 0) {
            // 注册新用户， 其它的数据检查忽略。
            return Ok(model.Username);
        }
        else {
            return BadRequest(errors);
        }
    }

}
```

上面的验证代码确实有点儿多， 而且很枯燥， 不过在 ASP.NET WebAPI 中， 可以使用 [DataAnnotations][1] 来简化数据验证， 稍微修改一下上面的 RegisterModel ， 为要验证的字段添加验证标记， 代码如下： 

```c#
public class RegisterModel {

    // username is required
    [Required]
    public string Username { get; set; }

    // Password is required
    [Required]
    public string Password { get; set; }

    // Confirm is required, and compare to Password.
    [Required, Compare("Password")]
    public string Confirm { get; set; }

}
```

添加了对应的验证标记之后， ASP.NET WebAPI 在参数绑定时会根据验证标记做相应的检查， 并将检查结果放在 ApiController 的 ModelState 属性中， 这样 ApiController 的代码就简化为：


```c#
[RoutePrefix("api/account")]
public class AccountController : ApiController {

    [HttpPost]
    public IHttpActionResult Register(RegisterModel model) {
        if (ModelState.IsValid) {
            // register user.
            return Ok(model.Username);
        }
        return BadRequest(ModelState);
    }

}
```

如果我们只输入用户名， 没有输入密码和确认密码， 则服务器会返回 `400 BadRequest` 错误信息， 内容如下：

```json
{
    "Message": "The request is invalid.",
    "ModelState": {
        "model.Password": ["The Password field is required."],
        "model.Confirm": ["The Confirm field is required."]
    }
}
```

值得注意的是， DataAnnotations 标记可以嵌套使用， 比如上面的 RegisterModel 有一个属性 `Other` 是复杂类型：

```c#
public class RegisterModel {

    // Other is required
    [Required]
    public OtherModel Other { get; set; }

}

public class OtherModel {
    
    [Required]
    public string OtherProperty { get; set; }

}
```

在检查 `RegisterModel` 时， 也会检查 `OtherModel` 的 `OtherProperty` 。

除了上面的 Required 和 Compare 标记， [DataAnnotations][1] 中关于数据验证的标记如下：

- CompareAttribute
- CustomValidationAttribute
- DataTypeAttribute
  - CreditCardAttribute
  - EmailAddressAttribute
  - EnumDataTypeAttribute
  - FileExtensionsAttribute
  - PhoneAttribute
  - UrlAttribute
- MaxLengthAttribute
- MinLengthAttribute
- RangeAttribute
- RegularExpressionAttribute
- RequiredAttribute
- StringLengthAttribute

每个标记的具体用法， 请分别参考其对应的 [MSDN][1] 文档。

[1]: https://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations(v=vs.110).aspx