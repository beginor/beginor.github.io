---
layout: post2
title: 在 PostgreSQL 数据库中使用 crosstab 进行行列转置
description: 在 PostgreSQL 数据库中使用 crosstab 进行行列转置
keywords: PostgreSQL
tags: [PostgreSQL]
---

查询语句为

```sql
select ps_name, first_day, item_name,  result, unit
from public.om3_ps_month_discharge
where ps_id = 268
order by first_day desc
```

结果为

| ps_name | stat_time | item_name | value | unit |
| ---- | ---- | ---- | ---- | ---- |
| 江门市皮革总厂 | 2019-04-01 | COD | 15.484 | 吨 |
| 江门市皮革总厂 | 2019-04-01 | 氨氮 | 0.0637 | 吨 |
| 江门市皮革总厂 | 2019-04-01 | 总氮 | 7.6164 | 吨 |
| 江门市皮革总厂 | 2019-03-01 | COD | 11.9028 | 吨 |
| 江门市皮革总厂 | 2019-03-01 | 氨氮 | 0.0454 | 吨 |
| 江门市皮革总厂 | 2019-03-01 | 总氮 | 5.8278 | 吨 |
| 江门市皮革总厂 | 2019-02-01 | 总氮 | 0.0 | 吨 |
| 江门市皮革总厂 | 2019-02-01 | COD | 0.0 | 吨 |
| 江门市皮革总厂 | 2019-02-01 | 氨氮 | 0.0 | 吨 |
| 江门市皮革总厂 | 2019-01-01 | COD | 0.0 | 吨 |
| 江门市皮革总厂 | 2019-01-01 | 氨氮 | 0.0 | 吨 |
| 江门市皮革总厂 | 2019-01-01 | 总氮 | 0.0 | 吨 |

行列转置查询语句为

```sql
select * from crosstab(
   'select first_day, ps_name, item_name, result 
    from public.om3_ps_month_discharge
    where ps_id = 268
    order by first_day desc, ps_name',
   'select distinct item_name
    from public.om3_ps_month_discharge
    where ps_id = 268'
) as (
    first_day timestamp without time zone,
    ps_name text,
    COD numeric, 氨氮 numeric, 总磷 numeric
);
```

查询结果为

|  first_day |    ps_name   |  COD  |   氨氮   |  总磷   |
| ---------- | ------------ | ----- | -------- | ------ |
| 2019-04-01 | 江门市皮革总厂 | 7.6164 | 15.484  | 0.0637 |
| 2019-03-01 | 江门市皮革总厂 | 5.8278 | 11.9028 | 0.0454 |
| 2019-02-01 | 江门市皮革总厂 | 0.0    | 0.0     | 0.0    |
| 2019-01-01 | 江门市皮革总厂 | 0.0    | 0.0     | 0.0    |
