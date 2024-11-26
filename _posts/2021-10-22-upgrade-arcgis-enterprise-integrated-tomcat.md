---
layout: post2
title: 升级 ArcGIS 企业版内置的 Tomcat
description: 本文介绍如何手动升级 ArcGIS Enterprise 内置的 Tomcat
keywords: arcgis, arcgis enterprise, apache tomcat, upgrade, security issues
tags: [GIS, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## ArcGIS Enterprise 发现安全漏洞

ArcGIS Enterprise 使用 Apache Tomcat 作为 HTTP 服务器， 在最近的服务器安全漏洞扫描中被发现存在大量的安全漏洞， 如下图所示：

![image-20211021154753142](/assets/post-images/image-20211021154753142.png)

在 [ArcGIS 知乎](http://zhihu.geoscene.cn) 上也有一些关于安全漏动的讨论， [Apache-tomcat远程代码执行漏洞(CVE-2016-8735)漏洞是否会对ArcGIS for Server产生影响？](http://zhihu.geoscene.cn/question/13914) ， 结局似乎不了了之。

查询 Apache Tomcat 的 [安全报告](https://tomcat.apache.org/security.html) 得知， 针对这些安全问题， Apache Tomcat 已经发布一系列的安全更新来解决这些安全问题。 但是 ArcGIS 并没有什么官方的文档说明怎么升级内部的 Tomcat 服务器， 因此只能自己动手升级。

## 查询 ArcGIS Enterprise 内置 Tomcat 的版本

服务器环境是 Ubuntu Linux 20.04 ， ArcGIS Enterprise 包括 Portal , Server 和 DataStore 三个典型的组件， 以 Portal 为例， 安装目录为 `/opt/arcgis/portal` `/opt/arcgis/server` 和 `/opt/arcgis/datastore` ， 以下内容以 Portal 为例。

Tomcat 的安装目录为 `/opt/arcgis/portal/framework/runtime/tomcat` ， tomcat 提供了 `version.sh` 命令可以查询版本信息， 在终端中执行命令：

```shell
/opt/arcgis/portal/framework/runtime/tomcat/bin/version.sh
```

得到的输出为：

```shell
Using CATALINA_BASE:   /opt/arcgis/portal/framework/runtime/tomcat
Using CATALINA_HOME:   /opt/arcgis/portal/framework/runtime/tomcat
Using CATALINA_TMPDIR: /opt/arcgis/portal/framework/runtime/tomcat/temp
Using ARCGIS_JAVA_HOME:        /opt/arcgis/portal/framework/runtime/jre
Using CLASSPATH:       /opt/arcgis/portal/framework/runtime/tomcat/bin/tomcat-juli.jar:/opt/arcgis/portal/framework/runtime/tomcat/bin/bootstrap.jar
Server version: Apache Tomcat/9.0.8
Server built:   Apr 27 2018 19:32:00 UTC
Server number:  9.0.8.0
OS Name:        Linux
OS Version:     5.4.0-89-generic
Architecture:   amd64
JVM Version:    11+28
JVM Vendor:     Oracle Corporation
```

从输出信息可以知道， Tomcat 的版本为 9.0.8 , 发布于 2018 年 5 月 4 日， 查询 Tomcat 的[版本信息](https://tomcat.apache.org/whichversion.htmlhttps://tomcat.apache.org/whichversion.html) 发现 Tomcat 9.x 最新的版本是 9.0.54 发布于 2021 年 10 月 1 日 ， 这期间确实经历了太多的版本迭代， 上面列出的安全问题也都在 9.0.54 版本进行了修复。

## 下载 Tomcat 对应版本的最新版

Tomcat 采用[语义化版本](https://semver.org/lang/zh-CN/)进行发布， 简单说 9.0.54 相对于 9.0.8 功能一致， 只进行 bug 修复， 安全问题也算是 bug 。 因此理论上说 9.0.54 可以无缝替代 9.0.8 。

下载 [Tomcat 9.x](https://tomcat.apache.org/download-90.cgi) 目前最新的 9.0.54 版本， 并解压到 `/opt/arcgis/apache-tomcat-9.0.54` 目录， 目录结构如下图所示：

![Tomcat 9.0.54](/assets/post-images/20211022151250.png)

在 `/opt/arcgis/portal/framework/runtime/tomcat` 目录下， 也有这样的目录， 因此要替换原有的 Tomcat ， 主要就是替换 `bin` 和 `lib` 两个目录的内容。

## 停止 ArcGIS Enterprise

要升级 ArcGIS Enterprise 中内置的 Tomcat ， 必须先停止 ArcGIS Enterprise 服务， 打开终端， 切换到 Portal 的安装目录， 并执行命令 stopportal.sh ：

```sh
cd /opt/arcgis/portal
./stopportal.sh
```

## 替换 Tomcat 的文件

等待 Portal 服务停止之后， 再切换到内置的 Tomcat 安装目录， 先备份一下 `bin` 和 `lib` 目录， 如果有任何问题， 可以恢复原样：

```sh
cd framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak
```

接下来复制新下载的 Tomcat 9.0.54 中 `bin` 和 `lib` 目录中的 jar 文件到对应的 `bin` 和 `lib` 目录， 这是最关键的一步， 一定不能出错：

```sh
cp -fv /opt/arcgis/apache-tomcat-9.0.54/bin/*.jar /opt/arcgis/portal/framework/runtime/tomcat/bin/

cp -fv /opt/arcgis/apache-tomcat-9.0.54/lib/*.jar /opt/arcgis/portal/framework/runtime/tomcat/lib/
```

> 注意： ArcGIS Enterprise 应该修改了一些脚本文件， 因此不能直接将 `bin` 和 `lib` 目录替换， 否则 tomcat 将无法启动 ！！！

现在再执行以下上面获取 Tomcat 版本信息的命令：

```shell
/opt/arcgis/portal/framework/runtime/tomcat/bin/version.sh
```

输出结果如下：

```shell
Using CATALINA_BASE:   /opt/arcgis/portal/framework/runtime/tomcat
Using CATALINA_HOME:   /opt/arcgis/portal/framework/runtime/tomcat
Using CATALINA_TMPDIR: /opt/arcgis/portal/framework/runtime/tomcat/temp
Using ARCGIS_JAVA_HOME:        /opt/arcgis/portal/framework/runtime/jre
Using CLASSPATH:       /opt/arcgis/portal/framework/runtime/tomcat/bin/tomcat-juli.jar:/opt/arcgis/portal/framework/runtime/tomcat/bin/bootstrap.jar
Server version: Apache Tomcat/9.0.54
Server built:   Sep 28 2021 13:51:49 UTC
Server number:  9.0.54.0
OS Name:        Linux
OS Version:     5.4.0-89-generic
Architecture:   amd64
JVM Version:    11+28
JVM Vendor:     Oracle Corporation
```

从输出可以看到， Tomcat 版本为 9.0.54， 说明替换成功， 否则请检查上面的步骤。 并且， 没有替换成功之前， 千万不要进行后面的操作。

## 重新启动 ArcGIS Enterprise

在终端中执行命令启动 ArcGIS Enterprise ：

```sh
/opt/arcgis/portal/startportal.sh
```

启动成功之后， 打开浏览器登录 Portal ， 检查全部功能是否正常。 由于没有修改配置， 只要 Portal 能够启动， 一般不会有什么功能问题。

接下来用同样类似的办法， 依次更新 ArcGIS Enterprise 其它的组件。

## 重新进行安全漏洞扫描

更新 ArcGIS Enterprise 内置的全部 Tomcat 之后， 请安全组的同事再次进行扫描， 不出所料， 所有的高/中危安全漏洞均已经修复， 如下图所示：

![image-20211021154839577](/assets/post-images/image-20211021154839577.png)
