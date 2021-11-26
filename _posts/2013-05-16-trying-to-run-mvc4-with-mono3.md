---
layout: post
title: 尝试在 Mono 3.0 下运行 ASP.NET MVC 4
description: 关于在 Mono 3.0 下运行 ASP.NET MVC 4 的一些尝试
tags: [.NET, Mono, ASP.NET, MVC]
keywords: net mvc4, mono 3.0, xamarin studio, visual studio, nhibernate, entity framework, nuget packages.
---

在这之前， 我并不知道结果， 虽然网上有介绍说可以运行， 但是一直没有亲自尝试过， 所有， 本文的测试是真实的， 做一步就记录一步。

## 测试环境介绍

### .Net 环境

.Net 测试环境为 Windows 8 ， Visual Studio 2012.2 ， .Net 4.5 ， 可以说是码农必备， 如下图所示：

![Visual studio & .Net information](/assets/post-images/vs-net-info.jpg)

### Mono 测试环境

Mono 的测试环境为 Mac OS X 10.8 ， XamarinStudio 4.1.2 ， Mono 3.0.10 ， 如果是用 Xamarin.iOS 做 iOS 开发的话， 也可以说是码农必备， 如下图所示：

![Xamarin Studio & Mono information](/assets/post-images/mono-env-info.jpg)

## 尝试运行默认项目模板

由于 XamarinStudio 没有 MVC4 的项目模板， 因此我们选择用 VS2012 的默认项目模板建立一个默认的 MVC4 项目， .Net 运行时选择 4.5 ， 项目模板选择 ASP.NET MVC 4 Web Application ， 如下图所示：

![New mvc4 project under .net 4.5](/assets/post-images/new-mvc4-project-under-net45.jpg)

项目类型选择为 Internet Application ， 视图引擎选择 Razor ， 如下图所示：

![mvc4 project with razor view engine](/assets/post-images/internet-app-with-razor-view-engine.jpg)

MVC 4 项目有很多 NuGet 包的引用， 不管三七二十一， 全部更新到最新， 不做任何修改， 然后直接编译运行， 将自动打开 IE 浏览器， 一切正常， 能看到下图的结果：

![First look of default mvc4 app](/assets/post-images/first-look-of-mvc4-app.jpg)

现在， 将这个项目原封不动的复制到 Mac OS X + Mono 环境下， 用 XamarinStudio 打开， 可以正常打开项目， 如下图所示：

![Open Mvc4 project under mono](/assets/post-images/open-mvc4-under-mono.jpg) 

同样，不做任何修改，直接运行， 自动启动 Safari 浏览器， 得到如下结果：

![First look under mono](/assets/post-images/first-look-under-mono.jpg)

最终结果是 Mono 还不能运行由 VS2012 默认的 MVC4 项目， 这也不奇怪， 因为 VS 2012 的项目模板中附带了很多微软特有的技术， 比如 WCF 、 EntityFramework 等。

## 尝试运行手工创建 MVC4 项目运行

现在尝试从零创建一个 MVC4 项目， 再看看结果如何。 现在在 .Net 4.5 环境下新建一个空的 Web 项目， 如下图所示：

![New empty web application](/assets/post-images/create-new-empty-web-app.jpg)

创建好之后， 在删除不必要的引用， 项目结构最终如下所示：

![empty web application](/assets/post-images/empty-web-app.jpg)

现在我们通过 NuGet 来添加 MVC4 包， NuGet 会自动添加 MVC4 的依赖项， 最终如下图所示：

![Add mvc4 to empty web application](/assets/post-images/add-mvc4-package-to-empty-web-app.jpg)

通过对比可以看出， 项目中添加了下列引用：

- Microsoft.Web.Infrastructure
- System.Web.Helpers
- System.Web.Mvc
- System.Web.Razor
- System.Web.WebPages
- System.Web.WebPages.Deployment
- System.Web.WebPages.Razor

打开 web.config 文件， 添加下面的 MVC4 需要用到的 AppSetting 项：

    <appSettings>
       <add key="webpages:Version" value="2.0.0.0"/>
       <add key="webpages:Enabled" value="false"/>
       <add key="PreserveLoginUrl" value="true"/>
       <add key="ClientValidationEnabled" value="true"/>
       <add key="UnobtrusiveJavaScriptEnabled" value="true"/>
    </appSettings>

新建 Global.asax ， 并在 Application_Start 方法中添加下面的 MVC4 初始化配置代码：

    AreaRegistration.RegisterAllAreas();
    GlobalFilters.Filters.Add(new HandleErrorAttribute());
    RouteTable.Routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
    
    RouteTable.Routes.MapRoute(
       name: "Default",
       url: "{controller}/{action}/{id}",
       defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
    );

然后在添加 HomeController 和 Index 动作方法， 以及相应的 Index 视图、 布局， 并终编译运行， 如下图所示：

![Hello, mvc4 world!](/assets/post-images/mvc4-hello-world.jpg)

到现在为止， 我们从零创建了一个 MVC4 的 HelloWorld 程序， 接下来拿到 Mono 环境中运行， 满怀欣喜，踌躇满志， 结果如下图所示：

![Hello, mvc4 world](/assets/post-images/hello-world-mvc4-with-mono.jpg)

不过，在 XamarinStudio 的输出窗口， 看到了下面的错误提示：

    System.Web.HttpException: Initial exception ---> System.Configuration.ConfigurationErrorsException: Error deserializing configuration section httpRuntime: Unrecognized attribute 'targetFramework'. (/Volumes/Temp/MvcApp/EmptyWebApp/Web.config line 1)
      at System.Configuration.ConfigurationSection.DeserializeSection (System.Xml.XmlReader reader) [0x00018] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Configuration/System.Configuration/ConfigurationSection.cs:198 
      at System.Configuration.Configuration.GetSectionInstance (System.Configuration.SectionInfo config, Boolean createDefaultInstance) [0x000db] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Configuration/System.Configuration/Configuration.cs:305 
      at System.Configuration.ConfigurationSectionCollection.get_Item (System.String name) [0x00032] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Configuration/System.Configuration/ConfigurationSectionCollection.cs:68 
      at System.Configuration.Configuration.GetSection (System.String path) [0x00077] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Configuration/System.Configuration/Configuration.cs:261 
      at System.Web.Configuration.WebConfigurationManager.GetSection (System.String sectionName, System.String path, System.Web.HttpContext context) [0x001d4] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Web/System.Web.Configuration_2.0/WebConfigurationManager.cs:504 
      at System.Web.Configuration.WebConfigurationManager.GetSection (System.String sectionName) [0x00006] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Web/System.Web.Configuration_2.0/WebConfigurationManager.cs:414 
      at System.Web.HttpRuntime..cctor () [0x00051] in /private/tmp/source/bockbuild-crypto-mono/profiles/mono-mac-xamarin/build-root/mono-3.0.10/mcs/class/System.Web/System.Web/HttpRuntime.cs:142 
      --- End of inner exception stack trace ---

看样子是 httpRuntime 不支持 targetFramework 属性， 去掉 targetFramework 属性， 再试一下， 惊艳的一幕出现了：

![hello world mvc4 with mono sucess](/assets/post-images/hello-world-mvc4-with-mono-sucess.jpg)

## 小结一下

如果你是十足的微软技术爱好者， 并且项目中使用了大量的微软特有的技术（EntityFramework、 WCF等）， 那么将产品移植到 Mono 下将会是非常痛苦的， 我的建议还是远离 Mono ，珍惜生命；

但是如果你只是 C# 爱好者，在项目中使用了大量开源的技术（NHibernate、 MVC、 NJson等） ， 那么完全可以开始尝试将现有的产品移植到 Mono 。

本文中所做的尝试仅仅是一个开始！
