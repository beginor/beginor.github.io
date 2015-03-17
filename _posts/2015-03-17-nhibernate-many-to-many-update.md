---
layout: post
title: NHibernate 多对多映射的数据更新
description: NHibernate 多对多映射数据更新
keywords: nhibernate, many-to-many, many to many, update, bag, set
tags: [NHibernate]
---

最近在用 NHibernate 做多对多更新时突然发现 NHibernate 更新的策略很差， 对多对多关系的更新居然是先全部删除再插入全部数据， 感觉非常奇怪， 现在还原如下：

原来的实体类关系如下：

```c#
public class User {

    public virtual int Id { get; set; }

    public virtual string Name { get; set; }

    public virtual ICollection<Role> Roles { get; set; }

    public User() {
        Roles = new HashSet<Role>();
    }
}

public class Role {

    public virtual int Id { get; set; }

    public virtual string Name { get; set; }

    public virtual ICollection<User> Users { get; set; }

    public Role() {
        Users = new HashSet<User>();
    }

}
```

即一个用户可以有多个角色， 一个角色也可以有多个人， 典型的多对多关系， 对应的映射代码如下：

```c#
public class UserMapping : ClassMapping<User> {

    public UserMapping() {
        Table("[User]");

        Id(m => m.Id, map => {
            map.Column("[Id]");
            map.Type(NHibernateUtil.Int32);
            map.Generator(Generators.Identity);
        });

        Property(m => m.Name, map => {
            map.Column("[Name]");
            map.Type(NHibernateUtil.String);
        });

        Bag(
            m => m.Roles,
            map => {
                map.Table("[User_Role]");
                map.Key(k => { k.Column("[UserId]"); });
            },
            rel => {
                rel.ManyToMany(map => {
                    map.Class(typeof(Role));
                    map.Column("[RoleId]");
                });
            }
        );
    }
}

public class RoleMapping : ClassMapping<Role> {

    public RoleMapping() {
        Table("[Role]");

        Id(m => m.Id, map => {
            map.Column("[Id]");
            map.Type(NHibernateUtil.Int32);
            map.Generator(Generators.Identity);
        });

        Property(m => m.Name, map => {
            map.Column("[Name]");
            map.Type(NHibernateUtil.String);
        });


        Bag(
            m => m.Users,
            map => {
                map.Table("[User_Role]");
                map.Key(k => { k.Column("[RoleId]"); });
                map.Inverse(true);
            },
            rel => {
                rel.ManyToMany(map => {
                    map.Class(typeof(User));
                    map.Column("[UserId]");
                });
            }
        );

    }
}
```

数据库关系图如下：

![数据库关系图](/assets/post-images/user-role-many-to-many.png)

当向用户添加或删除角色是， 发现更新的效率特别低， 代码如下：

```c#
using (var session = sessionFactory.OpenSession()) {
    var user = session.Query<User>().First();

    var firstRole = user.Roles.First();
    user.Roles.Remove(firstRole);
    session.Update(user);

    var roleCount = session.Query<Role>().Count();
    var role = new Role { Name = "Role " + (roleCount + 1) };
    session.Save(role);

    user.Roles.Add(role);
    session.Update(user);

    session.Update(user);
    session.Flush();
}
```

上面的代码是将用户的第一个角色删除， 再添加一个新的角色， NHibernate 生成的 SQL 语句如下（仅包含对关系表 `User_Role` 的操作）：

```sql
DELETE FROM [User_Role] WHERE [UserId] = @p0;@p0 = 1 [Type: Int32 (0)]
INSERT INTO [User_Role]  ([UserId], [RoleId]) VALUES (@p0, @p1);@p0 = 1 [Type: Int32 (0)], @p1 = 2 [Type: Int32 (0)]
INSERT INTO [User_Role]  ([UserId], [RoleId]) VALUES (@p0, @p1);@p0 = 1 [Type: Int32 (0)], @p1 = 7 [Type: Int32 (0)]
INSERT INTO [User_Role]  ([UserId], [RoleId]) VALUES (@p0, @p1);@p0 = 1 [Type: Int32 (0)], @p1 = 6 [Type: Int32 (0)]
INSERT INTO [User_Role]  ([UserId], [RoleId]) VALUES (@p0, @p1);@p0 = 1 [Type: Int32 (0)], @p1 = 10 [Type: Int32 (0)]
```

居然是先将属于该用户的全部角色删除， 再添加一份新的进来， 完全无法接受， 反过来思考觉得肯定是自己的问题， 经过一番搜索， 发现 StackOverflow 上也有人问类似的问题， 并且最终在 [NHibernate Tip: Use set for many-to-many associations][1] 发现了解决方案， 将多对多的映射的 `bag` 改为用 `set` ， 问题终于得到了解决， 改过后的映射如下：

```c#
Set(
    m => m.Roles,
    map => {
        map.Table("[User_Role]");
        map.Key(k => { k.Column("[UserId]"); });
    },
    rel => {
        rel.ManyToMany(map => {
            map.Class(typeof(Role));
            map.Column("[RoleId]");
        });
    }
);
```

将 `UserMapping` 和 `RoleMapping` 中多对多映射全部改为 `Set` 之后， 上面的测试代码生成的 SQL 如下：

```sql
DELETE FROM [User_Role] WHERE [UserId] = @p0 AND [RoleId] = @p1;@p0 = 1 [Type: Int32 (0)], @p1 = 8 [Type: Int32 (0)]
INSERT INTO [User_Role]  ([UserId], [RoleId]) VALUES (@p0, @p1);@p0 = 1 [Type: Int32 (0)], @p1 = 9 [Type: Int32 (0)]
```

由此可见， `bag` 在多对多映射更新是性能较差， 而 `set` 在多对多映射是更好的选择。 

[1]: http://www.codinginstinct.com/2010/03/nhibernate-tip-use-set-for-many-to-many.html