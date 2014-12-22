---
title: NHibernate 代码映射实体类
layout: post
description: 本文简单表述如何使用 NHibernate 自带的代码映射
keywords: nhibernate, mapping by code, one to one, many to one, many to many
tags: [NHibernate]
---

## 关于代码映射

## 实体关系

![实体关系](/assets/post-images/entity-relation.png)

## 使用代码映射

```c#
public class ProductMapping : ClassMapping<Product> {

    public ProductMapping() {
        // 
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

## 将映射添加到数据库

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

![导出的数据库结构](/assets/post-images/schema-export.png)