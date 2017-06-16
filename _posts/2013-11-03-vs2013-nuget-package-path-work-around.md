---
layout: post
title: Visual Studio 2013 下 NuGet 无法识别自定义包路径的解决方法
description: Visual Studio 2013 下 NuGet 无法识别自定义包路径的解决方法
tags: [NuGet]
keywords: VS2013, NuGet, repositorypath
---

升级到 VS2013 之后， 编译时会发现 VS2013 下 NuGet 不能正确识别预先配置好的存放目录， 总是把文件放在解决方案的 packages 目录下， 这个可以说是 NuGet 的 bug ， 也可以说是 VS2013 的 bug ， 原因是：

安装 VS2013 时， 会自动生成文件 `%ProgramData%\NuGet\Config\VisualStudio\12.0\Microsoft.VisualStudio.config` ， 这个文件为 VS2013 配置了一个特殊的源 `Microsoft and .NET` ， 内容如下：

    <?xml version="1.0" encoding="utf-8"?>
    <configuration>
      <packageSources>
        <add key="Microsoft and .NET"
             value="https://www.nuget.org/api/v2/curated-feeds/microsoftdotnet/" />
      </packageSources>
    </configuration>

然而正是这个文件导致了 NuGet 不能正确识别自定义的包路径， 估计 NuGet 会更新并修复这个 bug ， VS2013 估计是不会修改的啦。 暂时的解决方法就是删除这个文件， 如果你需要用到这个特殊的 NuGet 源， 可以把它添加到 NuGet 的选项中。

还有一个小问题就是 Json.Net ， 安装 VS2013 时， 会自动部署一个 .Net 4.0 版本的 Json.Net 到系统的 GAC 中， 很难删除， [需要修改注册表才能删除](https://abhi.dcmembers.com/blog/2009/04/17/forcefully-delete-an-assembly-from-gac/)， 但是为了VS的稳定性， 不建议删除。

如果你有程序是引用了旧版本的 Json.Net ， 比如 .Net Framework 3.5 版本的， 可能也会出现问题。
