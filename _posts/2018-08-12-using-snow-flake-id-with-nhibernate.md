---
layout: post2
title: 在 NHibernate 中使用 Snow Flake ID
description: 介绍如何在数据库中生成 Snow Flake ID， 以及如何在 NHibernate 中使用
keywords: snow flake id, postgresql, nhibernate
tags: [NHibernate, PostgreSQL]
---

## Snow Flake ID 算法简介

Snow Flake 是 Twitter 开源的分布式 ID 生成算法，结果是一个 long 型的 ID。其核心思想是：

  - 使用 41bit 作为毫秒时间戳；
  - 10bit 作为机器的 ID （ 5 个 bit 是数据中心，5 个 bit 的机器 ID ）；
  - 12bit 作为毫秒内的流水号（意味着每个节点在每毫秒可以产生 4096 个 ID ）；
  - 最后还有一个符号位，永远是 0 。

如下图所示：

![Snow Flake Id](/assets/post-images/snow-flake-id.png)

Snow Flake ID 算法的优点是：

  - 所有生成的 id 按时间趋势递增（时间戳）， 方便排序；
  - 整个系统内不会产生重复 id （因为有 datacenterId 和 workerId 来做区分）。
  - 结果是一个长整型数字 (int64) ， 索引性能也比较好。

关于 Snow Flake ID 算法， 网上已经有太多的介绍， 因此不再做过多的描述。

## 数据库实现

关于  Snow Flake ID 算法的实现， 已经有多种语言版本的实现， 这里以 PostgreSQL 为例， 使用 sql 实现个简化版。

先创建一个序列， 生成毫秒内的流水号， sql 语句如下：

```sql
CREATE SEQUENCE public.snow_flake_id_seq;

ALTER SEQUENCE public.snow_flake_id_seq
    OWNER TO postgres;
```

再创建一个函数， 实现 Snow Flake ID 算法， sql 语句如下：

```sql
CREATE OR REPLACE FUNCTION public.snow_flake_id()
    RETURNS bigint
    LANGUAGE 'sql'
    COST 100
    VOLATILE
AS $BODY$

SELECT (EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000)::bigint * 1000000 -- 将时间戳（精确到毫秒）放在最高位， 便于排序
  + 5 * 10000 -- 数据库实例 id ， 可以根据数据库进行修改
  + nextval('public.snow_flake_id_seq') % 1000 -- 毫秒内的序列号， 求 1000 的余数， 保证在 0 ～ 999 的范围内
  as snow_flake_id
$BODY$;

ALTER FUNCTION public.snow_flake_id()
    OWNER TO postgres;

COMMENT ON FUNCTION public.snow_flake_id()
    IS 'snow flake id ';
```

测试生成的 ID ， 执行 sql 语句 `select public.snow_flake_id()` 可以得到下面的结果：

```
1534042025838050074
```

说明如下：

- 1534042025838 为 Unix 时间戳， 精确到毫秒
- 050 为数据库实例
- 074 为毫秒内的流水号

因此， 这个结果基本上符合 Snow Flake ID 算法。

在数据库使用这个 ID 也很容容易， 只要设置数据表的对应的列的默认值即可， 示例如下：

```sql
CREATE TABLE public.snow_flake_test
(
    id bigint NOT NULL DEFAULT public.snow_flake_id(), -- 设置 ID 列的默认值， 自动生成 Snow Flake ID
    name character varying(32) COLLATE pg_catalog."default",
    CONSTRAINT snow_flake_test_pkey PRIMARY KEY (id)
)
```

现在执行插入语句

```sql
insert into public.snow_flake_test (name)
values ('snow flake id test')
```

数据库的到的结果为

<table class="table table-bordered" style="width: 80%;">
  <thead>
    <tr>
      <th>
        <div>id</div>
        <div>bigint</div>
      </th>
      <th>
        <div>name</div>
        <div>character varying(32)</div>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1534042851390050075</td>
      <td>snow flake id test</td>
    </tr>
  </tbody>
</table>

## NHibernate 配置

为了能够在 NHibernate 中使用， 需要根据上面的 `snow_flake_test` 表创建一个实体类， 代码如下：

```csharp
public class SnowFlakeTestEntity {

    public virtual long Id { get; set; }

    public virtual string Name { get; set; }

}
```

Id 是在数据库生成的， 所以应该使用的生成器为 `trigger-identity` , 对应的 xml 映射文件为如下：

```xml
<class name="SnowFlakeTestEntity" table="snow_flake_test" schema="public">
  <id name="Id" column="id" type="long">
    <generator class="trigger-identity">
    </generator>
  </id>
  <property name="Name" column="name" type="string" length="32" />
</class>
```

最后， 写一个单元测试来验证一下配置， 代码如下：

```csharp
[Fact]
public void _02_CanInsertSnowFlakeId() {
    using (var session = factory.OpenSession()) {
        var entity = new SnowFlakeTestEntity {
            Name = "snow flake id test"
        };
        session.Save(entity);
        Assert.True(entity.Id > 0);
        Console.WriteLine($"Id: {entity.Id}");
    }
}
```

运行测试代码， 可以得到如下的输出：

```
Starting test execution, please wait...[xUnit.net 00:00:01.19]
NHibernate:
    INSERT
    INTO
        public.snow_flake_test
        (name)
    VALUES
        (:p0) returning id;
    :p0 = 'd0f7198ea8ab4faa982a16df7cc8e96b' [Type: String (0:0:0)], :nhIdOutParam = NULL [Type: Int64 (0:0:0)]

Id: 1534043843651050079

Total tests: 1. Passed: 1. Failed: 0. Skipped: 0.
Test Run Successful.
Test execution time: 4.5339 Seconds
```

毫无悬念， 单元测试通过， 可以在 NHibernate 中愉快的使用 Snow Flake ID 了。
