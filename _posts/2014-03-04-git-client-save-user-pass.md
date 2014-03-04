---
layout: post
title: Git 客户端保存用户名和密码
description: 让 git 客户端记住密码的方法
keywords: git, netrc, windows, linux, osx
tags: [Git]
---

Git 每次进行 `Pull` 和 `Push` 操作时都要输入用户名和密码， 非常不便。 虽然有客户端 [SmartGit/HG][1] 以及 [TortiseGig][2] 可以帮你记一下客户端， 但是每个代码库都要记录一次， 如果项目包含很多个 submodule 的话， 用起来也有些不方便。 经过一番搜索， 最终找到了让 git 客户端记住密码的方法， 现总结如下：

### Linux/Unix/Mac 系统

新建一个 `~/.netrc` 文件， 将 git 服务器， 用户名以及密码记录在这个文件， 如下所示：

    machine your-git-server
    login your-username
    password your-password

如果有多个 server 就重复上面的三行， 分别输入对应的服务器、 用户名和密码即可；

> `~` 表示用户主目录， 如果你的用户名是 `zhang` ， 那么 `~` 对应的目录是 `/Users/zhang` 。

### Windows 系统

在 Windows 平台上， 稍微麻烦一些， 但是也能实现, 需要先添加一个用户变量 `%HOME%` ， 如下所示：

![Home User Variable](/assets/post-images/user-var-home.png)

接下来在 `%HOME%` 变量指向的目录下新建一个名称为 `_netrc` 的文件， 内容与上面的一样， 将 git 服务器， 用户名以及密码记录在这个文件， 如下所示：

    machine your-git-server
    login your-username
    password your-password

有了 netrc 文件， 使用 git 时就不用再输入用户名和密码了。

[1]: http://www.syntevo.com/smartgithg/
[2]: https://code.google.com/p/tortoisegit/
