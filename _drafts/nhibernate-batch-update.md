---
layout: post
title: NHibernate 批量数据插入测试
description: 在 .net 和 mono 下分别测试 NHibernate 的 批量数据导入 
keywords: NHibernate, .net, mono, batchsize, batchupdate
tags: [Mono, NHibernate]
---

## .Net 开发环境下测试

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

### 测试结果

运行单元测试的结果如下图所示：

![nhibernate-batch-insert-unit-test](/assets/post-images/nhibernate-batch-insert-unit-test.jpg)

从上图单元测试运行时间看， 在同一台机器上， SqlServer 的性能大概是 MariaDB 5~6 倍。

## Mono 开发环境下测试