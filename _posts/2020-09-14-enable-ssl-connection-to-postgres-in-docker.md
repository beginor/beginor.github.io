---
layout: post2
title: 为容器化的 Postgres 数据库启用 ssl 连接
description: 为容器化的 Postgres 数据库启用 ssl 连接
keywords: postgres, openssl, ssl connection
tags: [PostgreSQL]
---

由于项目安全评测的原因， 需要为 Postgres 数据库启用 ssl 连接， 特记录如下。

## 使用 openssl 生成 ssl 证书

生成证书需要 openssl 工具， 如果没有安装的话， 可以直接登录进去 Postgres 数据库的容器， 已经内置了 openssl ， 而且兼容性也比较好。

生成证书的命令如下：

```bash
openssl req -new -text -passout pass:abcd -subj /CN=localhost -out server.req -keyout privkey.pem
openssl rsa -in privkey.pem -passin pass:abcd -out server.key
openssl req -x509 -in server.req -text -key server.key -out server.crt
chmod 600 server.key
```

上面的命令会生成 `privkey.pem` 、 `server.key` 和 `server.crt` 三个文件， 这三个文件要妥善保管， 接下来就要用到这些文件。

## 配置 Postgres 启用 ssl 连接

需要修改 `/var/lib/postgresql/data/postgresql.conf` 以启用 ssl 连接， 打开这个文件， 搜索 `# - SSL -` ， 找到 ssl 相关的配置， 需要修改的内容如下所示：

```diff
  # - SSL -
- # ssl = off
+ ssl = on
- # ssl_cert_file = ''
+ ssl_cert_file = '/var/lib/postgresql/data/server.crt'
- # ssl_key_file = ''
+ ssl_key_file = '/var/lib/postgresql/data/server.key'
```

修改配置文件， 需要重启数据库容器实例， 让这些修改的配置生效。

> 如果需要强制客户端只能使用 ssl 连接的话， 可以修改配置文件 `/var/lib/postgresql/data/pg_hba.conf` ， 这个配置文件很简单， 也有详细的说明， 就不在多说了。 修改这个文件也是需要重启数据库实例的。

## 配置客户端使用 ssl 连接数据库

### .NET 应用

.NET 应用一般会使用 `Npgsql` 来连接 Postgres 数据库， 需要修改连接字符串

```c#
var builder = new NpgsqlConnectionStringBuilder {
  Host = "localhost",
  Port = 2009,
  Database = "ssl_test",
  Username = "postgres",
  Password = "password",
  SslMode = SslMode.Require,
  TrustServerCertificate = true,
  ApplicationName = "PgSslTest"
};
var connStr = builder.ToString();
Console.WriteLine(connStr);
```

这样， 就可以得到标准的连接字符串， 如下所示：

```
Host=localhost;Port=2009;Database=ssl_test;Username=postgres;Password=password;SSL Mode=Require;Trust Server Certificate=True;Application Name=PgSslTest
```

> 由于使用的是自签名证书， 所以 TrustServerCertificate 必须为设置为 true ， 否则在使用 ssl 连接数据库时会出现证书错误。

### Java 应用

Java 应用使用 JDBC 连接， 似乎必须提供证书， 可以使用上面生成的 `server.crt` 。
