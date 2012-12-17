---
layout: post
title: 使用代码配置 NHibernate
description: 多数情况下 NHibernate 使用配置文件进行配置， 但是我们也可以使用代码进行配置， 步骤如下：
tags: [NHibernate]
---

## 使用代码配置 NHibernate

多数情况下 NHibernate 使用配置文件进行配置， 但是我们也可以使用代码进行配置， 步骤如下：

### 1、 创建一个 Configuration 

	using Nhibernate.cfg;

	var config = new Configuration()
		.SetProperty("connection.provider", "NHibernate.Connection.DriverConnectionProvider")
		.SetProperty("connection.driver_class", "NHibernate.Driver.SqlClientDriver")
		.SetProperty("dialect", "NHibernate.Dialect.MsSql2005Dialect")
		.SetProperty("proxyfactory.factory_class", "NHibernate.Bytecode.DefaultProxyFactoryFactory, NHibernate")
		.SetProperty("format_sql", "true")
		.SetProperty("show_sql", "true")
		.SetProperty("connection.connection_string", connectionString);

### 2、 添加映射

	using NHibernate.Mapping.ByCode;

	var mapper = new ModelMapper();
	mapper.Class<Category>(cm => {
	   cm.Schema("dbo");
	   cm.Table("Categories");
	   cm.Id(cat => cat.CategoryID, map => {
	      map.Column("CategoryID");
	      map.Generator(Generators.Native);
	   });
	   cm.Property(cat => cat.CategoryName, map => {
	      map.Column("CategoryName");
	      map.Length(100);
	   });
	   cm.Property(cat => cat.Description, map => {
	      map.Column("Description");
	      map.Length(200);
	   });
	});

### 3、 添加映射至 Configuration 

	var mappingDocument = mapper.CompileMappingForAllExplicitlyAddedEntities();
	config.AddMapping(mappingDocument);
