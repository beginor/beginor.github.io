---
layout: post
title: 在 mono 下使用微软的 OWIN 认证中间件
description: 在 mono 下使用微软的 OWIN 认证中间件时遇到的问题以及解决方法
keywords: owin, security, DataProtectionProvider, AesDataProtector, aes
tags: [OWIN, WebAPI, ASP.NET]
---

使用 [Microsoft.Owin.Security][1] 中间件作为 OWIN 应用的标准验证在 IIS 下面工作良好， 不过最近在将 WebAPI 应用迁移到 Linux + Mono 的环境时， 发现这个中间件不能运行， 在启动时会抛出下面的异常：

![can-not-load-dpapi-data-protector](/assets/post-images/can-not-load-dpapi-data-protector.png)

这个异常是说无法加载类型 `Microsoft.Owin.Security.DataProtection.DpapiDataProtector` ， 通过 ILSpy 分析 Microsoft.Owin.Security.dll 发现， `Microsoft.Owin.Security.DataProtection.DpapiDataProtector` 使用 `System.Security.Cryptography.DpapiDataProtector` 实现， 而 `System.Security.Cryptography.DpapiDataProtector` 使用了 win32 函数实现， 因此，不能直接在非 windows 环境下运行。

不过， Microsoft.Owin.Security 中预留了扩展接口 [`IDataProtectionProvider`][2] ， 可以实现自定义的 [`IDataProtector`][3]， Mono 内置了 `AesManaged` 类， 可以用来实现自定义的 `IDataProtector` ， 示例代码如下：

```c#
public class AesDataProtector : IDataProtector {

    private readonly byte[] key;

    public AesDataProtector(string key) {
        using (var sha1 = new SHA256Managed()) {
            this.key = sha1.ComputeHash(Encoding.UTF8.GetBytes(key));
        }
    }

    public byte[] Protect(byte[] userData) {
        byte[] dataHash;
        using (var sha = new SHA256Managed()) {
            dataHash = sha.ComputeHash(userData);
        }

        using (AesManaged aesAlg = new AesManaged()) {
            aesAlg.Key = key;
            aesAlg.GenerateIV();

            using (var encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV))
            using (var msEncrypt = new MemoryStream()) {
                msEncrypt.Write(aesAlg.IV, 0, 16);

                using (var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                using (var bwEncrypt = new BinaryWriter(csEncrypt)) {
                    bwEncrypt.Write(dataHash);
                    bwEncrypt.Write(userData.Length);
                    bwEncrypt.Write(userData);
                }
                var protectedData = msEncrypt.ToArray();
                return protectedData;
            }
        }
    }

    public byte[] Unprotect(byte[] protectedData) {
        using (AesManaged aesAlg = new AesManaged()) {
            aesAlg.Key = key;

            using (var msDecrypt = new MemoryStream(protectedData)) {
                byte[] iv = new byte[16];
                msDecrypt.Read(iv, 0, 16);

                aesAlg.IV = iv;

                using (var decryptor = aesAlg.CreateDecryptor(aesAlg.Key, aesAlg.IV))
                using (var csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                using (var brDecrypt = new BinaryReader(csDecrypt)) {
                    var signature = brDecrypt.ReadBytes(32);
                    var len = brDecrypt.ReadInt32();
                    var data = brDecrypt.ReadBytes(len);

                    byte[] dataHash;
                    using (var sha = new SHA256Managed()) {
                        dataHash = sha.ComputeHash(data);
                    }

                    if (!dataHash.SequenceEqual(signature)) {
                        throw new SecurityException("Signature does not match the computed hash");
                    }

                    return data;
                }
            }
        }
    }
}
```

再来实现一个 `IDataProtectionProvider` ， 提供 `AesDataProtector` 实例， 代码如下：

```c#
public class AesDataProtectionProvider : IDataProtectionProvider {

    private string appName;

    public AesDataProtectionProvider() : this(Guid.NewGuid().ToString()) {
    }

    public AesDataProtectionProvider(string appName) {
        if (appName == null) {
            throw new ArgumentNullException("appName");
        }
        this.appName = appName;
    }

    public IDataProtector Create(params string[] purposes) {
        return new AesDataProtector(appName + ":" + string.Join(",", purposes));
    }
}
```

为了方便使用， 对 `Owin.IAppBuilder` 做一个扩展方法 `UseAesDataProtectionProvider` ， 代码如下：

```c#
public static void UseAesDataProtectionProvider(this IAppBuilder app) {
    const string hostAppNameKey = "host.AppName";
    if (app.Properties.ContainsKey(hostAppNameKey)) {
        var appName = app.Properties[hostAppNameKey].ToString();
        app.SetDataProtectionProvider(new AesDataProtectionProvider(appName));
    }
    else {
        app.SetDataProtectionProvider(new AesDataProtectionProvider());
    }
}
```

有了上面的扩展方法， 使用自己实现的 `AesDataProtectionProvider` 就非常简单了， 只要在 `UseCookieAuthentication` 之前加上一句 `UseAesDataProtectionProvider` 即可， 下面是示例代码：

```c#
void Configure(IAppBuilder app) {
    // handle static file
    app.UseStaticFile(new StaticFileMiddlewareOptions {
        RootDirectory = @"../Website",
        DefaultFile = "index.html",
        MimeTypeProvider = new MimeTypeProvider(),
        EnableETag = true,
        ETagProvider = new LastWriteTimeETagProvider()
    });
    // use aes data protection provider;
    app.UseAesDataProtectionProvider();
    // cookie auth;
    app.UseCookieAuthentication(new CookieAuthenticationOptions{
        AuthenticationType = CookieAuthenticationDefaults.AuthenticationType
    });
    // web-api
    var config = new HttpConfiguration();
    config.MapHttpAttributeRoutes();
    app.UseWebApi(config);
}
```

本文的全部源代码已经上传到至 [github][4] ， 也做了一个 [nuget][5] 包方便大家使用。

[1]: https://www.nuget.org/packages/Microsoft.Owin.Security/
[2]: https://msdn.microsoft.com/en-us/library/microsoft.owin.security.dataprotection.idataprotectionprovider(v=vs.113).aspx
[3]: https://msdn.microsoft.com/en-us/library/microsoft.owin.security.dataprotection.idataprotector(v=vs.113).aspx
[4]: https://github.com/beginor/Beginor.Owin.Security.Aes
[5]: https://www.nuget.org/packages/Beginor.Owin.Security.Aes/