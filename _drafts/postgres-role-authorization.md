---
layout: post2
title: PostgreSQL 中的角色授权
description: 本文描述如何对 PostgreSQL 的角色进行授权
keywords: postgresql, role privilege, authentication, grant, group role, login role
tags: [PostgreSQL]
---

## PostgreSQL 数据库中的角色

PostgreSQL 使用角色 (role) 来体现用户账户， 和其它数据库系统的用户概念不同：

- 通常， 如果一个角色能够登录到数据库， 则被视为一个登录角色 (Login Role)， 和其它数据库中的用户的等价；
- 当一个角色包含了其它角色时， 则被视为组角色 (Group Role) ；

创建角色的语句为

```sql
create role name [ [ with ] option [ ... ] ];
```

可选的 option 有： `login` `password` `superuser` `createdb` 等

- 要创建一个登录角色 (Login Role):

  ```sql
  create role test_user with
    login
    password 'abcd1234'
  ```

- 创建一个超级用户角色

  ```sql
  create role test_super with
    superuser
    login
    password 'test_super'
  ```

- 创建一个带有过期时间的角色

  ```sql
  create role test_user with
    login
    password '1234abcd'
    valid until '2030-01-01';
  ```

如果想要进一步了解其它的参数， 请参考 [create role](https://www.postgresql.org/docs/current/sql-createrole.html) 的官方文档。

## PostgreSQL 数据库中的角色授权

PostgreSQL 使用 `grant` 语句进行授权， 常用的主要有：

- 对数据表进行授权：

  ```sql
  grant { { select | insert | update | delete | truncate | references | trigger }
      [, ...] | all [ privileges ] }
      on { [ table ] table_name [, ...]
           | all tables in schema schema_name [, ...] }
      to role_specification [, ...] [ with grant option ]
  ```

  授权用户使用特定的数据表：

  ```sql
  grant select on table test.dist to test_user;
  ```

  授权用户使用指定架构下的全部数据表：

  ```sql
  grant select on all tables in schema public to test_user;
  ```

- 将登录角色添加到组角色

  ```sql
  grant { group_role_name } to { login_role_name }
  ```

  这样登录角色就会继承组角色的权限；

如果想要进一步了解授权的其它用法， 请参考 [grant](https://www.postgresql.org/docs/current/sql-grant.html) 的官方网文档。

PostgreSQL 使用 `revoke` 语句进行撤销授权， 语法为：

```sql
revoke [ grant option for ]
    { { select | insert | update | delete | truncate | references | trigger }
    [, ...] | all [ privileges ] }
    on { [ table ] table_name [, ...]
         | all tables in schema schema_name [, ...] }
    from role_specification [, ...]
    [ cascade | restrict ]
```

- 撤销用户对指定数据表的权限

  ```sql
  revoke all on table test.dist from test_user;
  ```

- 撤销用户对指定架构下全部数据表的权限

  ```sql
  revoke all on all tables in schema public from test_user;
  ```

- 将登录角色从组角色中移除

  ```sql
  revoke test_users from test_user;
  ```

如果想要进一步了解撤销授权的其它用法， 请参考 [revoke](https://www.postgresql.org/docs/current/sql-revoke.html) 的官方网文档。

## 角色授权总结

PostgreSQL 虽然能够通过 grant/revoke 对应角色进行授权， 但是似乎并没有那么严格， 经过测试发现， 虽然指定了某个用户只能使用指定的表， 但是该用户依然能够通过 `information_schema`  读取到其它数据表的表结构信息。
