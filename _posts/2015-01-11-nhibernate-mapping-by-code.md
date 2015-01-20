---
title: NHibernate 代码映射实体类
layout: post
description: 本文简单表述如何使用 NHibernate 自带的代码映射
keywords: nhibernate, mapping by code, one to one, many to one, many to many
tags: [NHibernate]
---

## 关于代码映射

NHibernate 3.2 自带了代码映射机制， 作为 xml 映射之外的一种映射方式， 由于推出的时间比较晚， 所以资料相对比较少， 而且与社区版的 [Fluent Mapping](https://github.com/jagregory/fluent-nhibernate) 和 [Attribute Mapping](http://sourceforge.net/projects/nhcontrib/files/NHibernate.Mapping.Attributes/) 不同， 有其独特的设计风格。

下面就通过一个实例来说明怎么使用 NHibernate 自带的代码映射。

## 实体关系

要映射的类关系图如下：

![实体关系](http://beginor.github.io/assets/post-images/entity-relation.png)

上图中有三个实体类， 他们之间的关系说明如下：

- `Product` 与 `Store` 之间是多对多关系；
- `Store` 与 `Employee` 之间是一对多关系；
- `Employee` 与 `Store` 之间是多对一关系；

## 使用代码映射

使用 xml 做实体类映射时， 推荐一个实体类对应一个 xml 文件， 用代码映射时也推荐这样， 一个实体类对应一个映射类， 一个映射类一个文件。

映射类继承自 `ClassMapping<T>` , `T` 标识要映射的实体类， 如下所示：

```c#
public class ProductMapping : ClassMapping<Product> {

    public ProductMapping() {
        // 此处添加映射代码
    }
}
```

### 映射到数据表

使用 `Table` 函数将类映射到制定的数据表：

```c#
Table("product");

```

### 标识映射

使用 `Id` 函数映射标识， NHibernate 提供了内置的工具类来简化代码：

```c#
Id(
    m => m.Id,
    map => {
        map.Column("id");
        map.Type(NHibernateUtil.Int32);
        map.Generator(Generators.Identity);
    }
);

```

### 属性映射

使用 `Property` 函数映射属性， NHibernate 提供了内置的工具类来简化代码：

```c#
Property(
    m => m.Name,
    map => {
        map.Column("name");
        map.Type(NHibernateUtil.String);
        map.Length(20);
    }
);

```

### 多对一映射

使用 `ManyToOne` 函数来映射多对一属性， 比如 `Employee` 的 `Store` 属性：

```c#
ManyToOne(
    m => m.Store,
    map => {
        map.Class(typeof(Store));
        map.Cascade(Cascade.All);
        map.Column("store_id");
        map.ForeignKey("employee_to_store");
    }
);

```

### 一对多映射

使用 `Bag` 方法来映射一对多属性，  比如 `Store` 的 `Staff` 属性：

```c#
Bag(
    m => m.Staff,
    map => {
        map.Table("employee");
        map.Key(k => {
            k.Column("store_id");
            k.ForeignKey("employee_to_store");
        });
    },
    rel => {
        rel.OneToMany(map => map.Class(typeof(Employee)));
    }
);

```

### 多对多映射

`Store` 与 `Product` 两个类之间是多对多映射， 映射代码如下：

`Store` 类的 `Products` 属性：

```c#
Bag(
    m => m.Products,
    map => {
        map.Table("store_product");
        map.Key(k => {
            k.Column("store_id");
            k.ForeignKey("store_product_to_store");
        });
    },
    rel => rel.ManyToMany(map => {
        map.Class(typeof(Product));
        map.Column("product_id");
    })
);

```

`Product` 类的 `StoresStockedIn` 属性：

```c#
Bag(
    m => m.StoresStockedIn,
    map => {
        map.Table("store_product");

        map.Key(k => {
            k.Column("product_id");
            k.ForeignKey("store_product_to_product");
        });
    },
    rel => rel.ManyToMany(map => {
        map.Class(typeof(Store));
        map.Column("store_id");
    })
);
```

## 将映射添加到配置

通过下面的代码将上面的映射添加到配置：

```c#
var config = new Configuration();
config.Configure("MySql.cfg.xml");

var mapper = new ConventionModelMapper();
mapper.AddMapping(new EmployeeMapping());
mapper.AddMapping(new StoreMapping());
mapper.AddMapping(new ProductMapping());

var mapping = mapper.CompileMappingForAllExplicitlyAddedEntities();
config.AddMapping(mapping);
```

## 导出到数据库

也可以向 xml 映射那样， 将映射导出到数据库， 创建对应的数据表以及表关系：

```c#
var schemaExport = new SchemaExport(config);
schemaExport.SetDelimiter(";");
schemaExport.Execute(true, true, false);
```

![导出的数据库结构](http://beginor.github.io/assets/post-images/schema-export.png)

## 总结

与 xml 映射以及其它第三方映射相比， 使用 NHibernate 代码映射有下面几个优点：

- 不需要使用 xml 文件即可完成， 可以充分利用 IDE 智能提示， 重构， 以及编译时检查；
- 与 Attribute Mapping 相比， 对原来的 POCO 实体类没有污染 (Attribute) ；
- NHibernate 自带， 可以说是一等公民， 而 Fluent Mapping 是第三方维护的；