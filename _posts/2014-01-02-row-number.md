---
title: SQL Server 中的 ROW_NUMBER 函数
description: SQL Server 中的 ROW_NUMBER 函数
layout: post
keywords: sql, row_number, partition, order by
tags: [参考]
---

ROW_NUMBER 是 SQL 2005 中新增的函数， 显示结果的行号， 多用于分页， 基本的语法为

    ROW_NUMBER() OVER({<partition_by_clause>}<order_by_clause>)

其中， 分区语句是可选的， 排序语句是必须的， 比如这样的语句：

    SELECT
      ROW_NUMBER() OVER(ORDER BY ProductID),
      CategoryID,
      ProductName,
      UnitPrice
    FROM
      Products

返回的结果为：

![ROW_NUMBER](/assets/post-images/row-number1.png)

也可以按照 CategoryID 对行号进行分区， 也就是将行号按照 CategoryID 进行分组， 例如：

    SELECT
      ROW_NUMBER() OVER(PARTITION BY CategoryID ORDER BY ProductID),
      CategoryID,
      ProductName,
      UnitPrice
    FROM
      Products

返回结果为：

![ROW_NUMBER](/assets/post-images/row-number2.png)

ROW_NUMBER 通常用于分页， 但是也有一些巧妙地用法， 例如， 要查询每个分类中最便宜的三种产品， 可以使用下面的查询语句：

    SELECT * FROM
    (
      SELECT
        ROW_NUMBER() OVER(PARTITION BY CategoryID ORDER BY UnitPrice) AS 'RowNum',
        CategoryID,
        ProductName,
        UnitPrice
      FROM
        Products
    ) AS p
    WHERE
      RowNum <= 3

返回结果为：

![ROW_NUMBER](/assets/post-images/row-number3.png)
