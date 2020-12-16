---
layout: post2
title: Docker 中的 PostgreSQL 崩溃恢复记录
description: Docker 中的 PostgreSQL 崩溃恢复记录
keywords: postgres, panic, checkpoint, pg_resetxlog, pg_resetwal
tags: [Docker, PostgreSQL]
---

在 Docker 中运行的 PostgreSQL 数据库突然无法启动， 错误日志类似这样：

```csv
PANIC,XX000,"could not locate a valid checkpoint record",,,,,,,,,""
LOG,00000,"startup process (PID 24) was terminated by signal 6: Aborted",,,,,,,,,""
LOG,00000,"aborting startup due to startup process failure",,,,,,,,,""
```

这种情况多数情况下是在执行事务时， 数据库被强行关闭导致的， 修复的方法是：

- 如果使用的 PostgreSQL 是 10.x 或更高的的版本， 使用 `pg_resetwal DATADIR` 来解决；
- 否则使用 `pg_resetxlog DATADIR` 来解决；

由于数据库是在 Docker 中运行的， 因此需要按照 Docker 的方式来修复：

1. 停止正在运行的容器实例

   使用命令 `docker-compose down` 来停止正在运行的数据库容器实例， 也可以使用 `docker stop` 和 `docker rm` 命令。

2. 覆盖 entrypoint 来的形式启动一个临时的容器

   这一步很重要， 需要使用原来的镜像， 覆盖默认的 entrypoint 启动， 进入可交互的命令行窗口：

   ```bash
   docker run -it --rm --entrypoint /bin/bash \
     -v ${pwd}/data:/var/lib/postgresql/data \
     postgres:9.3
   ```

   > 注意镜像的版本必须和原来的一致

3. 根据数据库的版本选择 `pg_resetwal` 或者 `pg_resetxlog` 进行修复

   以 PostgreSQL 9.3 为例， 在上面的步骤中打开的命令行窗口中输入 `pg_resetxlog` 命令

   ```bash
   pg_resetxlog /var/lib/postgresql/data
   ```

   通常会返回这样的提示

   ```
   The database server was not shut down cleanly. Resetting the transaction log might cause data to be lost. If you want to proceed anyway, use -f to force reset.
   ```

   根据提示， 使用 `-f` 强制重置事务日志

   ```bash
   pg_resetxlog -f /var/lib/postgresql/data
   ```

4. 重新启动数据库实例

   ```bash
    docker-compose up -d
   ```

使用 `pg_resetxlog` 或者 `pgresetwal` 有可能会丢失数据， 启动之后， 需要仔细检查数据库的健康情况。 如果有数据库备份的话， 请尽快进行数还原。

更多请参考 PostgreSQL 的文档 <https://www.postgresql.org/docs/current/app-pgresetwal.html> 
