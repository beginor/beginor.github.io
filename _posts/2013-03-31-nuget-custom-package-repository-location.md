---
layout: post
title: NuGet 使用自定义本地类库目录
keywords: nuget, repository, path, package
description: 本文介绍 NuGet 使用自定义本地类库目录。
tags: [NuGet]
---

在项目中使用 [NuGet](http://www.nuget.org/) 作为第三方类库管理器是非常方便的， NuGet 默认会在解决方案的目录下建立一个名为 packages 的目录， 把解决方案所需的第三方类库都放到 packages 目录下， 解决方案下所有的项目都引用 packages 目录内的类库， 对于单个解决方案来说， 非常不错。

如果要在多个解决方案之间共享类库的话， NuGet 默认的设置明显就不能满足需要了， 解决方案可能位于不同的目录， 如果每个解决方案目录内都再都有一个 packages 目录的话， 就会重复下载很多类库， 大家自然会想到将所有的第三方资源都放到一个统一的目录内， 这个特性在早期的 NuGet 版本下是不支持的， 随着 NuGet 2.x 系列版本的发布， 这个功能可以通过 NuGet 配置文件来实现。

我计算机上的项目目录如下， 所有的解决方案都位于 ~/MyProjects 目录内， 每个解决方案一个目录， 将所有的 nuget 包都放到一个 packages 目录， 而不是在每个解决方案目录内都建一个这样的目录。

    ~/MyProjects
     |-- SoluationA
     |-- SoluationA
     |-- SoluationA
     |-- (Other soluations)... 
     |-- packages

为了达到这样的效果， 需要现在 MyProjects 目录下新建一个 NuGet.config 文件， 文件的内容如下：

    <?xml version="1.0" encoding="utf-8"?>
    <configuration>
      <solution>
        <!-- 默认不将 packages 提交到源代码管理 -->
        <add key="disableSourceControlIntegration" value="true" />
      </solution>
      <config>
        <!-- 指定这个目录下默认的 packages 目录 -->
  	    <add key="repositorypath" value="~/MyProjects/packages/" />
      </config>
      <packageRestore>
        <!-- 默认启用 packages 还原 -->
        <add key="enabled" value="True" />
      </packageRestore>
    </configuration>

这样， 在这个目录内的项目中使用 nuget 时， nuget 会检测的这个配置文件， 并读取里面的配置信息， 如果子目录内也有 NuGet.config  文件， 那么 NuGet 会自动将子目录内的配置与上级目录的配置合并， 存在相同的配置时， 以子目录内的配置优先。

还需要修改一下 VS 的配置， 允许 NuGet 自动下载 package ， 如下图所示：

![Allow NuGet download missing packages during builds](/assets/post-images/allow-nuget-download-missing-packages-during-build.png)

最终的目录结构看起来是这样子的：

    ~/MyProjects
     |-- SoluationA
     |-- SoluationA
     |-- SoluationA
     |-- (Other soluations)... 
     |-- NuGet.config
     |-- packages

有了这样的 NuGet 一个配置文件， 在 MyProjects 目录下所有的解决方案将会公用一个 packages 目录， 并且自动下载缺失的 package 。

当然， NuGet 的配置远不止这些， 像深入挖掘的话， 需要好好看看[NuGet 提供的文档](http://docs.nuget.org/)。