---
layout: post
title: 从 SVN 迁移到 Git
description: 本文介绍从 SVN 迁移到 Git ， 并保留历史记录。
tags: [Git]
---

### 准备工作 ###

确认所有用户的本地修改都签入到服务器， 将 SVN 源代码的分支尽可能的合并到主干， 已经发布的做好归档信息， 并备份 SVN 库。 虽然迁移到 Git 的风险不大， 但是备份一下总是好的。

安装 Git ， 这看起来是废话， 不装 Git 怎么迁移？

### 将用户映射到 Git ###

创建一个用户映射文件， 将 SVN 用户映射到 Git 用户， 这样可以保留用户的签入历史信息， 比如用户输入的修改记录等， 这个文件看起来是这样子的：

    svnuser1 = gituser1 <gituser1@yourcompany.com>
    svnuser2 = gituser2 <gituser2@yourcompany.com>

这样， 用户 svnuser1 签入的历史信息在迁移之后就会映射成 gituser1 ， svnuser2 映射程 gituser2 。

编辑好用户映射文件之后， 保存为 users.txt 。

### 克隆 SVN 库 ###

假设 svn 库的布局是标准的 trunk 、 branches 以及 tags ， 运行下面的命令开始克隆 svn 库：

    git svn clone <svn repo url> --no-metadata -A users.txt -t tags -b branches -T trunk <destination dir name>

Git 会克隆 svn 完整的历史记录， 可能会需要很长的时间， 视 svn 库的历史而定。

### 转换分支及归档 ###

克隆完成之后， 所有的 svn 归档在 git 看来都是远程分支 (remote tags) ， 不是真正的 git 归档， 需要将他们手工转换为 git 归档， 然后再删除远程分支， 对于每一个分支或归档， 做如下操作（以 v1.0.1 归档为例）：

    git tag v1.0.1 tags/v1.0.1
    git branch -r -d tags/v1.0.1

所有的归档信息处理完成之后， git 本地库就有了完整的历史记录。

### 提交到 Git 库 ###

现在可以放心的将代码提交到自己的 git 服务器了， 命令如下：

    git remote add origin git@github.com:userid/project.git
    git push origin master --tags

总的来说， 从 svn 迁移到 git 还是很容易的。