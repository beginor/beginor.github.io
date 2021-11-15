---
layout: post2
title: 在 GeoServer 中使用 JNDI 连接数据库
description: 本文介绍如何在 GeoServer 通过 JNDI 连接数据库
keywords: geoserver, jndi, database, jetty, jetty-jndi, jetty-plus
tags: [GeoServer, 教程]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

GeoServer 使用 [Jetty](https://www.eclipse.org/jetty/) 作为服务容器， 但是默认的下载的 GeoServer 并没有包含 JNDI 相关的 Jetty 模块， 而在 GeoServer 的配置界面是支持使用 JNDI 连接数据库的，这就前后矛盾了。 不过最坑的是 GeoServer [关于 JNDI 关文档](https://docs.geoserver.org/stable/en/user/tutorials/tomcat-jndi/tomcat-jndi.html) 只有那么一小段， 居然还是基于 Tomcat 服务容器的， 真是太过分了。

## 添加 JNDI 支持

下载与 GeoServer 中的 Jetty 版本一致的完整包， 以最近发布的 GeoServer 2.20.0 为例， 内置的 Jetty 为 `9.4.36.v20210114` 。 添加 JNDI 支持需要 `jndi` 和 `plus` 两个模块， 添加步骤为：

1. 复制 `~/jetty/modules/jndi.mod` 文件到 `~/geoserver/modules` 目录， 并将 `depend` 节点中的 `mail` 注释掉， 因为不需要 `mail` 模块， 当然如果需要 `mail` 模块， 也可以将 `mail` 相关的模块也添加进来；
2. 复制 `~/jetty/modules/plus.mod` 文件到 `~/geoserver/modules` 目录， 并将 `depend` 节点中的 `transactions` 注释掉， 因为不需要 `transactions` 模块， 如果需要 `transactions` 模块， 也可以将 `transactions` 相关模块也添加进来；
3. 复制 `~/jetty/lib/jetty-jndi-9.4.36.v20210114.jar` 、 `~/geoserver/lib/jetty-plus-9.4.36.v20210114.jar` 到 `~/geoserver/lib/` 目录；
4. 修改 `~/geoserver/start.ini` 文件，在文件末尾添加 `--module=jndi` 和 `--module=plus` 两行， 表示启用这两个模块；
5. 运行 `~/geoserver/bin/startup.sh` ， 启动 GeoServer ， 观察控制台是否有错误信息输出：

   1. 如果有任何错误输出， 则检查前面的步骤是否有遗漏；
   2. 如果能够正常启动， 则可以进行下一步设置；

## 配置 JNDI 数据源

1. 新建 `~/geoserver/webapps/geoserver/WEB-INF/jetty-env.xml` 文件， 配置一个 JNDI 资源， 名称为 `jdbc/geo_test` , 文件内容如下：

   ```xml
   <Configure id="wac" class="org.eclipse.jetty.webapp.WebAppContext">
       <New id="jdbc/geo_test" class="org.eclipse.jetty.plus.jndi.Resource">
           <Arg></Arg>
           <Arg>jdbc/geo_test</Arg>
           <Arg>
               <New class="org.postgresql.ds.PGSimpleDataSource">
                   <Set name="url">jdbc:postgresql://127.0.0.1:54321/geo_test?ApplicationName=geoserver&amp;useSSL=true</Set>
                   <Set name="user">postgres</Set>
                   <Set name="password">YOUR_PASSWORD</Set>
               </New>
           </Arg>
       </New>
   </Configure>
   ```

2. 重启 GeoServer 之后， 登录到 GeoServer ， 选择新建矢量数据源 PostGIS (JNDI) ， 在新建页面的 `jndiReferenceName *` 中输入上面 `jetty-env.xml` 文件中的定义的 JNDI 资源名称 `jdbc/geo_test` 即可；
3. 保存之后， 发布图层就是常规操作了。

## 为什么要使用 JNDI ？

原因很简单， 使用 GeoServer 提供的数据库连接界面只提供了数据连接常用属性的设置， 而 JNDI 可以配置数据源的全部属性， 比如设置应用程序名称 (ApplicationName) ， 可以对数据源进行进行更加精确的设置。
