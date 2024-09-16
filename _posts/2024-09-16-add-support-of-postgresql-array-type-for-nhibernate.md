---
layout: post2
title: 扩展 NHibernate 支持 PostgreSQL 的数组类型
description: 本文说明如何扩展 NHibernate 以支持 PostgreSQL 数据库的数组类型。
keywords: postgresql, array type, nhibernate, iusertype, dotnet, c#
tags: [NHibernate, .NET]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

PostgreSQL 数据库的一大特征就是数组类型， 使用起来非常的方便， 但是 NHibernate 却一直没有添加对数组类型的支持，因此有必要扩展 NHibernate 以添加对数组类型的支持。

## 定义数据库方言 (Dialect)

NHibernate 对不同提供了相应的数据库方言 (Dialect) ，要添加数组类型支持，自然要从数据库方言(Dialect)开始：

```c#
public class NpgSqlDialect : NHibernate.Dialect.PostgreSQLDialect {
  
  public NpgSqlDialect() {}

}
```

在 NHibernate 配置文件中添加下面的配置使用这个方言：

```xml
<property name="dialect">NHibernate.Extensions.NpgSql.NpgSqlDialect,NHibernate.Extensions.NpgSql</property>
```

## 定义用户数据类型 (UserType)

在 NHibernate 中扩展自定义数据类型， 需要实现 `NHibernate.UserTypes.IUserType` 接口, 因此需要定义一个 `ArrayType` 并实现 `IUserType` 接口， 部分代码如下:

```c#
public class ArrayType<T> : IUserType {

  public SqlType[] SqlTypes => [GetNpgSqlType()];

  public System.Type ReturnedType => typeof(T[]);
  
  public bool IsMutable => false;
  
  public object Assemble(object cached, object owner) { }
  
  public object Disassemble(object value) { }
  
  public object? DeepCopy(object value) { }
  
  public new bool Equals(object? x, object? y) { }
  
  public int GetHashCode(object? x) { }
  
  public object? NullSafeGet(DbDataReader rs, string[] names, ISessionImplementor session, object owner) { }
  
  public object Replace(object original, object target, object owner) { }
  
}
```

为了减少冗余的代码， 将 `ArrayType` 定义成范型类型。 如果想了解全部实现代码，请查看 [ArrayType.cs](https://github.com/beginor/nhibernate-extensions/blob/master/src/NHibernate.Extensions.NpgSql/UserTypes/ArrayType.cs) 的源代码。

接下来在上面定义的 `NpgSqlDialect` 中，注册常用的数组类型（以 `int[]` 和 `string[]` 为例）：

```c#
public class NpgSqlDialect : NHibernate.Dialect.PostgreSQLDialect {
  
  public NpgSqlDialect() {
    RegisterUserTypes();
  }
  
  private void RegisterUserTypes() {
    TypeFactory.RegisterType(
      typeof(int[]),
      NHibernateUtil.Custom(typeof(ArrayType<int>)),
      ["int[]"]
    );
    TypeFactory.RegisterType(
      typeof(string[]),
      NHibernateUtil.Custom(typeof(ArrayType<string>)),
      ["string[]"]
    );
  }

}
```

现在，就可以在配置和sql查询中使用数组类型了，在实体映射中这样使用：

```c#
[Class(Schema = "public", Table = "arr_test")]
public class ArrTestEntity {
    [Id(Name = nameof(Id), Column = "id", Type = "long", Generator = "trigger-identity")]
    public virtual long Id { get; set; }
    [Property(Column = "int_arr", Type = "int[]")]
    public virtual int[] IntArr { get; set; }
    [Property(Column = "str_arr", Type = "string[]")]
    public virtual string[] StrArr { get; set; }
}
```

或者使用 xml 映射：

```xml
<class table="arr_test" schema="public" name="UnitTest.ArrTestEntity,UnitTest">
  <id name="Id" type="long" column="id" generator="trigger-identity" />
  <property name="IntArr" type="int[]" column="int_arr" />
  <property name="StrArr" type="string[]" column="str_arr" />
</class>
```

使用 SQL 进行查询过滤：

```c#
string[] strArr = ["a", "c"];
var sqlQuery = session.CreateSQLQuery(
  $"select * from public.arr_test where strArr = any(:{nameof(strArr)})"
);
sqlQuery.SetParameter(
  nameof(strArr),
  strArr,
  NHibernateUtil.Custom(typeof(ArrayType<string>))
);
var data = sqlQuery.List<ArrTestEntity>();
Assert.That(data, Is.Not.Empty);
```

当然，仅支持属性类型映射和 SQL 查询过滤是不够的， 因为最常用的是 Linq 查询， 接下来继续让 Linq 查询也支持数组类型过滤。

## 定义 HQL 数组过滤函数

数组条件过滤函数最常用的有两个：

1. 数组是否包含某一个元素，SQL 查询表达式为： `element = ANY(array)` ;
2. 两个数组是否有共同的元素， SQL 查询表达式为： `array1 && array2` ；

NHibernate Linq 是基于 HQL 的， 因此需要先让 HQL 能够支持数组过滤， HQL 支持比较容易实现， 只需要在上面定义的 `NpgSqlDialect` 中添加对应的 SQL 函数模板：

```c#
public class NpgSqlDialect : NHibernate.Dialect.PostgreSQLDialect {
  
  public NpgSqlDialect() {
    RegisterFunctions()
  }
  
  private void RegisterFunctions() {
    // array_contains(arr, 3) => :num = any(arr)
    RegisterFunction(
      "array_contains",
      new SQLFunctionTemplate(NHibernateUtil.Boolean, "?2 = any(?1)")
    );
    // array_intersects => ?1 && ?2
    RegisterFunction(
      "array_intersects",
      new SQLFunctionTemplate(NHibernateUtil.Boolean, "?1 && ?2")
    );
  }

}
```

注册了 SQL 函数模板之后，就可以在 HQL 查询中使用数组类型进行过滤：

```c#
string[] strArr = ["a", "c"];
var query1 = session.CreateQuery(
  $"from ArrTestEntity e where array_intersects(e.StrArr, :{nameof(strArr)})"
);
query1.SetParameter(nameof(strArr), strArr, NHibernateUtil.Custom(typeof(StringArrayType)));
var data1 = query1.List<ArrTestEntity>();
Assert.That(data1, Is.Not.Empty);
```

对应生成的的 SQL 语句为：

```sql
select
  arrtestent0_.id as id1_2_,
  arrtestent0_.int_arr as int2_2_,
  arrtestent0_.str_arr as str3_2_ 
from
  public.arr_test arrtestent0_ 
where
  arrtestent0_.str_arr && :p0;
```

## 定义 Linq 扩展查询

终于来到了最关键的一步，有点儿复杂， 但是也不难。 先定义两个针对数据类型的扩展函数， 分别对应上面定义的 `array_contains` 和 `array_intersects` HQL 扩展函数，代码如下：

```c#
public static class ArrayExtensions {

  public static bool ArrayContains<T>(this T[] array, T element) {
    return array.Contains(element);
  }

  public static bool ArrayIntersects<T>(this T[] array, T[] other) {
    return array.Intersect(other).Any();
  }

}
```

> 这里只需要函数定义即可，与如何实现没有关系，因为会被转换成对应的 HQL 查询， 不会真正执行这两个表达式。

定义数据类型生成器 (Generator)，也就是将 Linq 表达式转换成对应的 HQL 表达式：

```c#
public class ArrayHqlGenerator : BaseHqlGeneratorForMethod {

  public ArrayHqlGenerator() {
    SupportedMethods = [
      ReflectHelper.GetMethodDefinition<int[]>(
        x => x.ArrayContains(0)
      ),
      ReflectHelper.GetMethodDefinition<int[]>(
        x => x.ArrayIntersects(Array.Empty<int>())
      ),
    ];
  }

  public override HqlTreeNode BuildHql(
    MethodInfo method,
    Expression targetObject,
    ReadOnlyCollection<Expression> arguments,
    HqlTreeBuilder treeBuilder,
    IHqlExpressionVisitor visitor
  ) {
    var hqlMethod = "";
    var linqMethod = method.Name;

    hqlMethod = linqMethod switch {
      "ArrayContains" => "array_contains",
      "ArrayIntersects" => "array_intersects",
      _ => hqlMethod
    };
    if (string.IsNullOrEmpty(hqlMethod)) {
      throw new HibernateException($"Method {method.Name} not found");
    }
    return treeBuilder.BooleanMethodCall(
      hqlMethod,
      arguments.Select(visitor.Visit).Cast<HqlExpression>()
    );
  }

}
```

最后，定一个 `LinqToHqlGeneratorsRegistry` 将上面定义的 `ArrayHqlGenerator` 合并进默认的 `DefaultLinqToHqlGeneratorsRegistry` ， 代码如下：

```c#
public class LinqToHqlGeneratorsRegistry : DefaultLinqToHqlGeneratorsRegistry {

    public LinqToHqlGeneratorsRegistry() {
        this.Merge(new ArrayHqlGenerator());
    }

}
```

修改 nhibernate.config 配置文件， 使用新定义的 `LinqToHqlGeneratorsRegistry` ：

```xml
<property name="linqtohql.generatorsregistry">NHibernate.Extensions.NpgSql.LinqToHqlGeneratorsRegistry,NHibernate.Extensions.NpgSql</property>
```

就可以在 Linq 查询中使用数组过滤表达式了:

```c#
string[] strArr = ["a", "c"];
var query1 = session.Query<ArrTestEntity>().Where(
    x => x.StrArr.ArrayIntersects(strArr)
);
var data1 = await query1.ToListAsync();
Assert.That(data1, Is.Not.Empty);

int[] intArr = [1, 3];
var query2 = session.Query<ArrTestEntity>().Where(
    x => x.IntArr.ArrayIntersects(intArr)
);
var data2 = await query2.ToListAsync();
Assert.That(data2, Is.Not.Empty);

var query3 = session.Query<ArrTestEntity>().Where(
    x => x.StrArr.ArrayIntersects(strArr) && x.IntArr.ArrayIntersects(intArr)
);
var data3 = await query3.ToListAsync();
Assert.That(data3, Is.Not.Empty);
```

而且， 还可以反向使用 `ArrayContains` ：

```c#
var idArr = idList.ToArray();
var query2 = session.Query<ArrTestEntity>().Where(
    x => idArr.ArrayContains(x.Id)
);
var data2 = query2.ToList();
Assert.That(data2, Is.Not.Empty);
```

最后要特别感谢 NHibernate 核心成员 [@fredericDelaporte](https://github.com/fredericDelaporte) 和 [hazzik](https://github.com/hazzik) ，在实现的过程中提供了不少帮助。
