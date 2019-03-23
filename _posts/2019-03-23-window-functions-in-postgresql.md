---
layout: post2
title: PostgreSQL 数据库中的窗口函数
description: 简单介绍 PostgreSQL 数据库中的窗口函数
keywords: postgresql, window function, over, partition by, order by
tags: [参考]
---

## 什么是窗口函数？

一个窗口函数在一系列与当前行有某种关联的表行上执行一种计算。这与一个聚集函数所完成的计算有可比之处。但是窗口函数并不会使多行被聚集成一个单独的输出行，这与通常的非窗口聚集函数不同。取而代之，行保留它们独立的标识。在这些现象背后，窗口函数可以访问的不仅仅是查询结果的当前行。

1. 可以访问与当前记录相关的多行记录；
2. 不会使多行聚集成一行， 与聚集函数的区别；

## 窗口函数语法

窗口函数跟随一个 OVER 子句， OVER 子句决定究竟查询中的哪些行被分离出来由窗口函数处理。

可以包含分区 (PARTITION BY) 和排序 (ORDER BY) 指令， 这二者都是可选的。

window_func() OVER([PARTITION BY field] [ORDER BY field]) 

如果没有指定 PARTITION BY 和 ORDER BY 指令， 则等同于聚合函数， 对全部数据进行计算。

PARTITION BY 子句将查询的行分组成为分区， 窗口函数会独立地处理它们。PARTITION BY 工作起来类似于一个查询级别的 GROUP BY 子句， 不过它的表达式总是只是表达式并且不能是输出列的名称或编号。 如果没有 PARTITION BY， 该查询产生的所有行被当作一个单一分区来处理。

ORDER BY 子句决定被窗口函数处理的一个分区中的行的顺序。 它工作起来类似于一个查询级别的 ORDER BY 子句， 但是同样不能使用输出列的名称或编号。 如果没有 ORDER BY， 行将被以未指定的顺序被处理。

## PostgreSQL 中的聚合函数也可以作为窗口函数来使用

除了这些内置的[窗口函数](http://www.postgres.cn/docs/10/functions-window.html)外，任何内建的或用户定义的通用或统计聚集（也就是有序集或假想集聚集除外）都可以作为窗口函数。仅当调用跟着OVER子句时，聚集函数才会作为窗口函数；否则它们作为非窗口的聚集并为剩余的集合返回单行。

## 窗口函数示例

员工工资 (emp_salary) 表结构如下：

```sql
SELECT emp_no, dep_name, salary
FROM public.emp_salary
order by dep_name, emp_no;
```

|   emp_id   |   dep_name   |   salary   |
| ---------- | ------------ | ---------- |
| 7          | develop      | 4200       |
| 8          | develop      | 6000       |
| 9          | develop      | 4500       |
| 10         | develop      | 5200       |
| 11         | develop      | 5200       |
| 2          | personnel    | 3900       |
| 5          | personnel    | 3500       |
| 1          | sales        | 5000       |
| 3          | sales        | 4800       |
| 4          | sales        | 4800       |

如果要将每位员工与其部门的平均工资进行对比， 需要这样的结果：

| emp_id | dep_name  | salary | avg              |
| ------ | --------- | ------ | ---------------- |
| 7      | develop   | 4200   | 5020             |
| 8      | develop   | 6000   | 5020             |
| 9      | develop   | 4500   | 5020             |
| 10     | develop   | 5200   | 5020             |
| 11     | develop   | 5200   | 5020             |
| 2      | personnel | 3900   | 3700             |
| 5      | personnel | 3500   | 3700             |
| 1      | sales     | 5000   | 4866.66666666667 |
| 3      | sales     | 4800   | 4866.66666666667 |
| 4      | sales     | 4800   | 4866.66666666667 |

如果不用窗口函数来查询， 则比较复杂， 当然也能做到， 语句如下：

```sql
SELECT e0.emp_no, e0.dep_name, e0.salary, e2.avg_salary
FROM public.emp_salary e0
join (
  select e1.dep_name, avg(e1.salary) as avg_salary
  from public.emp_salary e1
  group by e1.dep_name
) e2 on e2.dep_name = e0.dep_name
order by e0.dep_name, e0.emp_no;
```

如果使用窗口函数进行查询， 则很容易做到， sql 语句如下：

```sql
SELECT emp_no, dep_name, salary,
       avg(salary) over(partition by dep_name)
FROM public.emp_salary
order by dep_name, emp_no;
```

但是如果要查询随着员工的增加， 各部门平均工资的变化， 如下表所示的结果， 不用窗口函数查询的话就很难做到了。

| emp_id | dep_name  | salary | avg              |
| ------ | --------- | ------ | ---------------- |
| 7      | develop   | 4200   | 4200             |
| 8      | develop   | 6000   | 5100             |
| 9      | develop   | 4500   | 4900             |
| 10     | develop   | 5200   | 4975             |
| 11     | develop   | 5200   | 5020             |
| 2      | personnel | 3900   | 3900             |
| 5      | personnel | 3500   | 3700             |
| 1      | sales     | 5000   | 5000             |
| 3      | sales     | 4800   | 4900             |
| 4      | sales     | 4800   | 4866.66666666667 |

如果使用窗口函数， 依然可以轻松完成， 语句如下：

```sql
SELECT emp_no, dep_name, salary,
       avg(salary) over(partition by dep_name order by emp_no)
FROM public.emp_salary
order by dep_name, emp_no;
```

可见， 窗口函数在需要对查询结果中的相关行进行计算时有很大的优势。
