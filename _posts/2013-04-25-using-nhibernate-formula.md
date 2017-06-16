---
layout: post
title: NHibernate 配置使用 Formula
description: 简要介绍 NHibernate 配置中的 Formula 以及其使用场景
tags: [NHibernate]
keywords: nhibernate, formula, configuration
---

在 Nhibernate 的实体类映射中， 如果实体类的属性需要通过 SQL 计算才能得到， 则可以使用 Formula 选项解决。 

Nhibernate 对 Formula 的要求如下： 

> formula (optional): an SQL expression that defines the value for a computed property. Computed properties do not have a column mapping of their own. 

### 场景1: 映射需要计算的属性

以下面的 Category 映射为例：

    <?xml version="1.0" encoding="utf-8" ?>
    <hibernate-mapping xmlns="urn:nhibernate-mapping-2.2" assembly="Northwind" namespace="Northwind">
       <class name="Category" table="[Categories]" schema="[dbo]">
          <id name="CategoryID" column="[CategoryID]" type="int" />
          <property name="CategoryName" column="[CategoryName]" type="string"/>
          <property name="Description" column="[Description]" type="string"/>
          <property name="Picture" column="[Picture]" type="binary"/>
    
          <set name="Products" lazy="true">
             <key column="CategoryID" />
             <one-to-many class="Product" not-found="ignore"/>
          </set>
    
       </class>
    </hibernate-mapping>

如果要增加一个属性 NameAndDesc ， 把 CategoryName 和 Description 两个字段连接起来， 用 Formula 可以这样做：

    <property name="NameAndDesc" formula="[CategoryName] + ' ' + [Description]" type="string" />

### 场景2: 映射复杂的 SQL 类型

SQL 2008 支持空间数据类型 [geography](https://msdn.microsoft.com/zh-cn/library/cc280766) 和 [geometry](https://msdn.microsoft.com/zh-cn/library/cc280487) ， 映射空间数据类型可以通过 Nhibernate 的空间扩展解决， 操作起来比较麻烦， 在客户端不需要空间数据类型或者不能处理空间数据类型的情况下， 可以用 Formula 处理。 示例表结构定义如下：

    CREATE TABLE SpatialTable (
       id int IDENTITY (1,1),
       GeogCol1 geography,
    );

使用 Formula 的映射文件如下：

    <?xml version="1.0" encoding="utf-8" ?>
    <hibernate-mapping xmlns="urn:nhibernate-mapping-2.2" assembly="Northwind" namespace="Northwind">
       <class name="Category" table="[Categories]" schema="[dbo]">
          <id name="Id" column="[id]" type="int" />
          <property name="GeoCol1" formula="[GeogCol1].STAsText()" type="string" />
       </class>
    </hibernate-mapping>

