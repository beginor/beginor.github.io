---
layout: post
title: 在 ASP.NET WebAPI 中使用 DataAnnotations 验证数据
description: 在 ASP.NET WebAPI 中使用 DataAnnotations 简化数据验证
keywords: asp.net, webapi, data validation, 
tags: [ASP.NET, WebAPI]
---

数据验证在开发工作中是十分重要的，不过数据验证的代码确实

```c#
public class RegisterModel {

    public string Username { get; set; }

    public string Password { get; set; }

    public string Confirm { get; set; }

}
```

```c#
[RoutePrefix("api/account")]
public class AccountController : ApiController {

    [HttpPost]
    public IHttpActionResult Register(RegisterModel model) {
        var errors = new Dictionary<string, string>();
        if (string.IsNullOrEmpty(model.Username)) {
            errors.Add("Username", "Username is required.");
        }
        if (string.IsNullOrEmpty(model.Password)) {
            errors.Add("Password", "Password is required.");
        }
        if (string.IsNullOrEmpty(model.Confirm)) {
            errors.Add("Confirm", "Confirm is required.");
        }
        if (model.Confirm != model.Password) {
            errors.Add("Confirm", "Password != Confirm");
        }
        if (errors.Count == 0) {
            // register new user;
            return Ok(model.Username);
        }
        else {
            return BadRequest(errors);
        }
    }

}
```

```c#
public class RegisterModel {

    [Required]
    public string Username { get; set; }

    [Required]
    public string Password { get; set; }

    [Required, Compare("Password")]
    public string Confirm { get; set; }

}
```

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