---
layout: post
title: NHibernate 批量数据插入测试
description: 在 .net 和 mono 下分别测试 NHibernate 的 批量数据导入 
keywords: NHibernate, .net, mono, batchsize, batchupdate
tags: [Mono, NHibernate]
---

## .Net 环境下测试

### 数据库环境以及 NHibernate 配置

SQL Server 环境为 VS2013 自带的 localdb v11.0， 对应的 NHibernate 配置为：

    var cfg = new Configuration();
    cfg.SetProperty(Environment.ConnectionString, "Data Source=(localdb)\\Projects;Initial Catalog=TestDB;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False");
    cfg.SetProperty(Environment.ConnectionProvider, "NHibernate.Connection.DriverConnectionProvider");
    cfg.SetProperty(Environment.ConnectionDriver, "NHibernate.Driver.SqlClientDriver");
    cfg.SetProperty(Environment.Dialect, "NHibernate.Dialect.MsSql2008Dialect");
    cfg.SetProperty(Environment.UseSecondLevelCache, "false");
    cfg.SetProperty(Environment.UseQueryCache, "false");
    cfg.SetProperty(Environment.GenerateStatistics, "false");
    cfg.SetProperty(Environment.CommandTimeout, "500");
    cfg.SetProperty(Environment.BatchSize, "10");
    cfg.SetProperty(Environment.BatchStrategy, typeof(SqlClientBatchingBatcherFactory).AssemblyQualifiedName);
    cfg.AddAssembly(typeof(SqlServerBatchTest).Assembly);

MariaDB 环境为官方网站上下载的 10.0.11 稳定版， 对应的 NHibernate 配置为：

    var cfg = new Configuration();
    cfg.SetProperty(Environment.ConnectionString, "Server=127.0.0.1;Database=test_db;Uid=root;Pwd=security;");
    cfg.SetProperty(Environment.ConnectionProvider, "NHibernate.Connection.DriverConnectionProvider");
    cfg.SetProperty(Environment.ConnectionDriver, "NHibernate.Driver.MySqlDataDriver");
    cfg.SetProperty(Environment.Dialect, "NHibernate.Dialect.MySQL5Dialect");
    cfg.SetProperty(Environment.UseSecondLevelCache, "false");
    cfg.SetProperty(Environment.UseQueryCache, "false");
    cfg.SetProperty(Environment.GenerateStatistics, "false");
    cfg.SetProperty(Environment.CommandTimeout, "500");
    cfg.SetProperty(Environment.BatchSize, "10");
    cfg.SetProperty(Environment.BatchStrategy, typeof(MySqlClientBatchingBatcherFactory).AssemblyQualifiedName);
    cfg.AddAssembly(typeof(MySqlBatchTest).Assembly);

<div class="alert alert-warning">
NHibernate 没有提供针对 MySQL 的 BatchingBatcherFactory ， 针对 MySQL 的测试加载了第三方的
<a href="www.nuget.org/packages/NHibernate.MySQLBatcher/" target="_blank" class="alert-link">NHibernate.MySQLBatcher</a>
</div>

### 测试代码

插入数据的测试代码如下， 代码中的 `InsertCount` 为 100000 ：

    using (var session = sessionFactory.OpenSession()) {
        for (int i = 0; i < InsertCount; i++) {
            var data = new TestData {
                Id = Guid.NewGuid().ToString(),
                Name = "Test Data " + i,
                Data1 = random.Next(),
                Data2 = random.Next(),
                Data3 = random.NextDouble(),
                UpdateTime = DateTime.Now
            };
            session.Save(data);
        }
        session.Flush();
        session.Clear();
    }

<div class="alert alert-info">
经过测试发现， NHibernate 的 Session 和 StatelessSession 在纯插入数据时性能相当， 只是 StatelessSession 不会检查
实体类约束关系， 比如有重复 Id 的实体类。
</div>

### 开发环境测试结果

运行单元测试的结果如下图所示：

![nhibernate-batch-insert-unit-test](/assets/post-images/nhibernate-batch-insert-unit-test.jpg)

从上图单元测试运行时间看， 在同一台机器上， SqlServer 的性能大概是 MariaDB 5~6 倍。

### 生产环境测试结果

将测试数据库分别部署在 SQL Server 2012 和 MariaDB 内网的服务器上， 服务器硬件配置几乎一致， 数据库版本也与开发环境
一致， 反复运行测试， 结果大致如下：

![nhibernate-batch-insert-unit-test](/assets/post-images/nhibernate-batch-insert-unit-test-2.jpg)

<div class="alert alert-info">
测试结果说明，在内网环境下， 两者的性能接近， 可以说不相上下。
</div>

## Mono 环境下测试

听到有同事说同样的代码在 mono 上运行会慢很多， 只有五分之一甚至十分之一的性能， 带着这个疑问， 分别在 OS X 和 Ubuntu 
Server 环境下再次运行测试。

<div class="alert alert-warning">
由于 SqlClientBatchingBatcherFactory 在 mono 环境下无法运行， 所以以下两个测试都不使用 batch 。
</div>

在 OS X 开发环境下测试结果如下：

![nhibernate-batch-insert-unit-test](/assets/post-images/nhibernate-batch-insert-unit-test-3.jpg)

在 Ubuntu Server 环境下测试结果如下：

![nhibernate-batch-insert-unit-test](/assets/post-images/nhibernate-batch-insert-unit-test-4.jpg)

## 测试总结

从上面的测试结果可以看出， mono 和 .net 的性能是差不多的， 可以说是不相伯仲， MySQL 的性能也是不错的， 最终的结论是 mono + mysql
是可以值得信赖的。