---
layout: post2
title: 备份和恢复 timescaledb 的超级表 (hypertables)
description: 使用 PostgreSQL 内置的工具 `pg_dump` 和 `psql` 对超级表 `conditions` 进行备份和恢复
keywords: PostgreSQL, timescaledb, hypertables, backup, restore, pg_dump, psql, copy
tags: [PostgreSQL]
---

下面是使用 PostgreSQL 内置的工具 `pg_dump` 和 `psql` 对超级表 `conditions` 进行备份和恢复的步骤。

## 备份

备份超级表架构：

```bash
pg_dump -s -d old_db --table conditions -N _timescaledb_internal | \
  grep -v _timescaledb_internal > schema.sql
```

将备份超级表的数据备份到 CSV 文件：

```bash
psql -d old_db \
-c "\COPY (SELECT * FROM conditions) TO data.csv DELIMITER ',' CSV"
```

## 恢复

恢复表的架构：

```bash
psql -d new_db < schema.sql
```

重新构建超级表：

```bash
psql -d new_db -c "SELECT create_hypertable('conditions', 'time')"
```

> 提示： 传递给 `create_hypertable` 的参数不必和旧数据库保持一致， 所以这也是重新组织超级表（比如：修改分区键、 分区数量、 等）的好方法。

恢复数据：

```bash
psql -d new_db -c "\COPY conditions FROM data.csv CSV"
```

> 提示： PostgreSQL 内置的 `COPY` 命令是单线程的， 如果想要快速导入大量的数据， 建议使用 timescaledb 提供的并行导入工具 [parallel importer](https://github.com/timescale/timescaledb-parallel-copy) 。

其它备份方法可以参考 Timescaledb 的官方文档中的[备份与恢复](https://docs.timescale.com/latest/using-timescaledb/backup)。
