---
layout: post2
title: 在 .NET Core 应用中使用 NHibernate 
description: 介绍如何在 .NET Core 应用中使用 NHibernate
keywords: .net core, nhibernate, webapp
tags: [.NET Core, NHibernate]
---

[NHibernate](http://nhibernate.info/) 最近发布了 [5.1.3](https://www.nuget.org/packages/NHibernate/) 版本，  支持 .NET Standard 2.0 ， 这意味着可以在 .NET Core 2.0 应用中使用， 本文就已 WebAPI 应用为例， 介绍一下如何在 .NET Core 应用中如何使用 NHibernate 。

1、 新建一个基于 .NET Core 的 Web API应用， 命令如下：

```sh
mkir WebApiTest
cd WebApiTest/
dotnet new webapi
```

2、 添加 NHibernate 包以及对应的数据库驱动程序（以 Npgsql 为例）：

```sh
dotnet add pakcage NHibernate
dotnet add package NHibernate.NetCore
dotnet add package Npgsql
```

现在打开项目文件 WebApiTest.csproj ， 可以看到已经添加了这些包：

```xml
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.App" />
    <PackageReference Include="NHibernate" Version="5.1.3" />
    <PackageReference Include="NHibernate.NetCore" Version="1.0.1" />
    <PackageReference Include="NpgSql" Version="4.0.2" />
  </ItemGroup>
```

3、 在项目中新建一个 Models 目录， 并创建实体类以及对应的 xml 映射文件， 代码如下：

```csharp
namespace WebApiTest.Models {

    public class GpsPosition {
        public virtual long Id { get; set; }
        public virtual string UserAgent { get; set;}
        public virtual long? Timestamp { get; set; }
        public virtual float? Latitude { get; set; }
        public virtual float? Longitude { get; set; }
        public virtual float? Accuracy { get; set; }
        public virtual float? Altitude { get; set; }
        public virtual float? AltitudeAccuracy { get; set; }
        public virtual float? Heading { get; set; }
        public virtual float? Speed { get; set; }
        public virtual string Tag { get; set; }
    }
}
```

对应的 xml 映射文件如下：

```xml
<?xml version="1.0" encoding="utf-8"?>
<hibernate-mapping
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns="urn:nhibernate-mapping-2.2"
  namespace="WebApiTest.Models"
  assembly="WebApiTest">
  <class name="GpsPosition" schema="public" table="gps_position">
    <id name="Id" column="id" type="long">
      <generator class="sequence">
        <param name="sequence">public.gps_position_id_seq</param>
      </generator>
    </id>
    <property name="UserAgent" column="user_agent" type="string" />
    <property name="Timestamp" column="timestamp" type="long" />
    <property name="Latitude" column="latitude" type="float" />
    <property name="Longitude" column="longitude" type="float" />
    <property name="Accuracy" column="accuracy" type="float" />
    <property name="Altitude" column="altitude" type="float" />
    <property name="AltitudeAccuracy" column="altitude_accuracy" type="float" />
    <property name="Heading" column="heading" type="float" />
    <property name="Speed" column="speed" type="float" />
    <property name="Tag" column="tag" type="string" />
  </class>
</hibernate-mapping>
```

这些都是 NHibernate 的常规做法， 因此不做过多介绍， 不熟悉的可以查阅 NHIbernate 的相关文档。

4、 将 xml 文件编译为嵌入的资源， 打开项目文件 WebApiTest.csproj ， 添加一个 ItemGroup 节点：

```xml
<ItemGroup>
  <None Remove="Models/*.hbm.xml" />
  <EmbeddedResource Include="Models/*.hbm.xml" />
</ItemGroup>
```

5、 创建 NHibernate 的配置文件， 并设置为复制到输出目录：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<hibernate-configuration xmlns="urn:nhibernate-configuration-2.2">
    <session-factory>
        <property name="connection.connection_string">server=localhost;database=test_db;user id=postgres;password=postgres;</property>
        <property name="dialect">NHibernate.Dialect.PostgreSQL83Dialect</property>
        <property name="connection.driver_class">NHibernate.Driver.NpgsqlDriver</property>
        <property name="show_sql">true</property>
        <property name="format_sql">true</property>
        <property name="adonet.batch_size">10</property>
        <mapping assembly="NaturalReserveApi" />
    </session-factory>
</hibernate-configuration>
```

打开项目文件， 添加 ItemGroup 节点， 内容如下：

```xml
<ItemGroup>
  <Content Update="hibernate.config">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </Content>
</ItemGroup>
```

6、 修改 Startup.cs 文件， 将 NHibernate 集成到 .NET Core 内置的依赖注入框架中：

6.1、 修改 Startup.cs 的 using 部分， 添加下面的语句：

```csharp
using Microsoft.Extensions.Logging;
using NHibernate.NetCore;
```

6.2、 修改 Startup.cs 的构造函数， 代码如下：

```csharp
public Startup(
    IConfiguration configuration,
    ILoggerFactory factory
) {
    Configuration = configuration;
    // 将内置的日志组件设置为 NHibernate 的日志组件
    factory.UseAsHibernateLoggerFactory();
}
```

6.3、 修改 ConfigureServices 方法， 添加 NHibernate 相关的服务：

```csharp
public void ConfigureServices(IServiceCollection services) {
    // nhibernate 配置文件的路径
    var path = System.IO.Path.Combine(
        AppDomain.CurrentDomain.BaseDirectory,
        "hibernate.config"
    );
    // 添加 NHibernate 相关的服务
    services.AddHibernate(path);
    services.AddMvc()
        .SetCompatibilityVersion(CompatibilityVersion.Version_2_1);
}
```

7、 修改默认的 ValuesController.cs ， 注入并使用 NHibernate：

7.1、 修改构造函数， 注入 ISessionFactory ：

```csharp
public ValuesController(ISessionFactory factory) {
    this.factory = factory;
}
```

7.2、 修改 Get 方法， 使用 NHibernate 进行查询：

```csharp
// GET api/values
[HttpGet]
public ActionResult<IEnumerable<GpsPosition>> Get() {
    using (var session = factory.OpenSession()) {
        var query = session.Query<GpsPosition>();
        return query.ToList();
    }
}
```

8、 编译并运行：

```sh
dotnet run
```

之后可以看到类似这样的 NHibernate 初始化信息：

```
Using launch settings from ~/Projects/WebApiTest/Properties/launchSettings.json...
info: NHibernate.Cfg.Environment[0]
      NHibernate 5.1.3 (assembly 5.1.0.0)
info: NHibernate.Cfg.Environment[0]
      hibernate-configuration section not found in application configuration file
info: NHibernate.Cfg.Environment[0]
      Bytecode provider name : lcg
info: NHibernate.Cfg.Environment[0]
      Using reflection optimizer
dbug: NHibernate.Cfg.Configuration[0]
......
Hosting environment: Development
Content root path: ~/Projects/WebApiTest
Now listening on: https://localhost:5001
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
```

看到这些信息， 就表示已经可以正常的使用 NHibernate 了。