---
layout: post
title: NHibernate 使用 SqlQuery
description: 在一些情况下， 需要使用 SqlQuery， 使用 SqlQuery 可以查询标量（简单类型）， 查询单表实体类， 关联表查询。
tags: [NHibernate]
---

多数情况下， NHibernate 提供的 HQL、 Linq 以及条件查询足够用了， 但是在某些情况下， 需要使用 SqlQuery， 使用 SqlQuery 可以查询标量（简单类型）， 查询单表实体类， 关联表查询。 

### 查询标量（简单类型）

	var db = this.ObjectContainer.Resolve<NorthwindContext>();

	var sqlQuery = db.Session.CreateSQLQuery("select count(0) as c from categories");
	sqlQuery.AddScalar("c", NHibernateUtil.Int32);
	var count = sqlQuery.UniqueResult<int>();

### 查询单表实体类

	var db = this.ObjectContainer.Resolve<NorthwindContext>();
	var sqlQuery = db.Session.CreateSQLQuery("select {c.*} from categories {c}")
	    .AddEntity("c", typeof(Category));
	var result = sqlQuery.List<Category>();

### 关联表查询

	var db = this.ObjectContainer.Resolve<NorthwindContext>();
	var sql = "select {p.*}, {c.*} from products {p} join categories {c} on p.CategoryID = c.CategoryID";
	var sqlQuery = db.Session.CreateSQLQuery(sql)
   		.AddEntity("p", typeof(Product))
   		.AddJoin("c", "p.Category");
	var result = sqlQuery.List<Product>();
