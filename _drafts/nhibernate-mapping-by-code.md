---
title: NHibernate 代码映射实体类
layout: post
description: 本文简单表述如何使用 NHibernate 自带的代码映射
keywords: nhibernate, mapping by code, one to one, many to one, many to many
tags: [NHibernate]
---

## 关于代码映射



## 实体关系

要映射的类

![实体关系](http://beginor.github.io/assets/post-images/entity-relation.png)

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

```c#
Table("product");

```

### 标识映射

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

```c#
var schemaExport = new SchemaExport(config);
schemaExport.SetDelimiter(";");
schemaExport.Execute(true, true, false);
```

![导出的数据库结构](http://beginor.github.io/assets/post-images/schema-export.png)