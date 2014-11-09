---
layout: zzm
title: 张志敏的简历
show_in_sitemap: false
---

# 基本信息

张志敏 | 男 | 本科 | 9年工作经验
134-1805-6213 | 139-2412-5200 (备用)
beginor@qq.com | http://beginor.github.io

---

# 期望工作

广州，全职，月薪16k-20k，软件架构师、技术经理、高级软件工程师

---

# 工作经历

## 广东省环境信息中心（2005年9月至今）

### 环保移动执法  (2012.3至今)

该项目是环监局现有执法项目的移动端解决方案， 客户端采用 Xamarin 的 MonoTouch 和 Mono for Android 实现， 服务端采用 ASP.NET MVC 实现。

在这个项目中我负责客户端基础框架以及服务端入口网关服务器的设计与实现。

由于要支持 iOS 和 Android 两个平台， 最困难的就是如何不同的平台上共享逻辑代码的问题。 我采取的措施是尽量提取公共的、 平台独立的接口， 然后根据不同的平台进行实现， 应用逻辑代码面向这些中立的接口， 尽可能的保持平台无关性。

最自豪的是实现了跨平台的数据绑定， 将 .NET 的数据绑定的概念以及 MVVM 的模式应用到移动开发中， 将逻辑代码封装到 ViewModel ， 在 iOS 和 Android 两个平台上使用同一份逻辑代码。

### SilverGIS  （2010.03-至今）

该项目的主要目的是解决环境信息与 GIS 相结合的数据可视化解决方案， 基于 Silverlight + ArcGIS (SilverGIS) + ASP.NET MVC 技术构建。

在这个项目中我负责客户端基础架构建设， 包括 ArcGIS 客户端 API 的二次开发、 插件式框架的创建以及与服务端 MVC API 的集成。

在这个项目中， 为了解决 Silverlight 应用体积过大的问题， 采用了主程序 + 插件式开发的模式， 最困难的问题是从服务端按需加载客户端 Silverlight 插件模块， 最终采用 Mono.Cecil 绕过 Silverlight 平台的限制， 实现了客户端异步队列加载， 实现按需加载机制。

在这个项目中， 我最自豪的技术是通过动态解析 lambda 表达式的方式向服务端发送请求， 避免了在客户端代码中硬编码 URL 和请求参数， 大量减少由手工输入出错的情况， 即提高了程序员的效率也提高了代码的可靠性。

这个项目最终发展成为一个基础的应用程序框架， 在多个项目中使用， 至今依然在项目中使用。

### 污染源自动监控 （2007.10-2013.10）

该项目的主要目的是解决企业排污数据向环保部门的采集、传输、分析与展示的问题， 基于 ExtJS + ASP.NET 创建。

在项目中我负责客户端界面实现、 监控视频集成以及权限模块的设计与实现。

在项目中最初采用的是微软 Ajax 解决方案， 缺点是客户端 Javascript 代码和服务端 C# 混合在一起， 导致逻辑混乱， 很难进行重构。 此外， 由于微软的 Ajax 库当时存在严重的性能问题， 在对比了当时的主流客户端解决方案之后， 决定采用 ExtJS 做为客户端解决方案， Ajax Handler 作为服务端提供数据， 类似于后来微软推出的 ASP.NET MVC 架构， 将客户端代码完全与服务端代码分离， 不仅解决了客户端服务端代码混合的问题， 也解决了客户端性能以及浏览器兼容性等的问题。

在项目中最自豪的技术细节是：

1. 创建了 AjaxHandler 框架， 将客户端与服务端松散耦合， 与后来微软推出的  ASP.NET MVC 框架不谋而合；
2. 在数据访问层使用 Castle.DynamicProxy 特有的拦截技术将数据访问层接口巧妙的映射到对应的 SQL 语句或存储过程， 从而减少了大量的冗余代码。

# 开源项目和作品

## 开源项目

- [ PNChart for iOS 的 Xamarin.iOS 绑定](https://github.com/beginor/PNChartTouch) : 

  iOS 上大名鼎鼎的 [PNChart](https://github.com/kevinzhow/PNChart) ， 超简约，超易用，带有动画效果的 Chart 库， 为了能够在 Xamarin 平台上使用， 我做了这个绑定项目。

- [ArcGIS for Android 的 Xamarin.Android 绑定](https://github.com/beginor/MonoDroid.ArcGIS) : 

  [ArcGIS](http://www.arcgis.com/) for Android 的 Xamarin.Android 绑定， 绝大多数功能都已经可以使用， 包括 GraphicsLayer, FeatureLayer, Symbol, DynamicLayer等。

- [Assembly Navigation for Silverlight 5](https://github.com/beginor/AssemblyNavigation) :

  开源的 Silverlight 导航与加载相结合的框架， 我的原创作品， 最大特点是按需从服务端加载所需的 dll 文件， 能够明显减少 Silverlight 程序的初次加载时间， 项目越大、 模块越多， 效果越明显。

## 技术文章

- [Silverlight 异步任务队列实现](http://www.cnblogs.com/beginor/archive/2010/12/24/1915910.html)
- [MonoTouch 的限制](http://www.cnblogs.com/beginor/archive/2011/09/24/2189767.html)
- [ExtJS 开发总结](http://www.cnblogs.com/beginor/archive/2008/12/14/1354922.html)
- [优秀程序员无他-善假于物也(翻译文章)](http://beginor.github.io/2013/04/08/senior-programer-good-habits.html)
- [给 c# 程序员的十个重要提示(翻译文章)](http://beginor.github.io/2014/08/01/top-10-tips-for-c-programmers.html) 
- [MVP(SC),MVP(PV),PM,MVVM 和 MVC 表现模式架构对比(翻译文章)](http://beginor.github.io/2012/10/17/Comparison-of-Architecture-presentation-patterns.html)

# 阅读清单

- Algorithms 4th edition

  工作中涉及到移动应用开发， 和 PC 以及服务器相比， 移动设备性能较弱， 算法显得更加重要， 于是我选择这本书重温算法。

  这本书给我最大的感觉就是算法的可视化做的非常好， 对于每一个算法都以图形化的形式逐步演示， 非常有助于算法的理解。 通过阅读这本书， 我加深了对常用的排序、 搜索算法理解。

- 架构设计师必须知道的97件事

  本书提供了分享软件架构知识的新方式， 拓宽了阐述软件架构艺术的视角， 总结了 50 多位经验丰富的软件架构师的时间经验， 范围覆盖了软件架构师的职业操守、 技术技能、 思维模式、 领导力、 和客户的沟通交流、 权衡利弊的平衡感等主题。

  对我最有影响的观点是 “架构师应该亲力亲为” 和 “架构师当聚焦于边界和接口” ， 在工作中我更加注重如何使用要设计的 API ， 更加注重模块与模块之间的交互。

- 你必须知道的 .Net

  这本书书主要包括了.NET基础知识及其深度分析，以 .NET Framework 和 CLR 研究为核心展开 .NET 本质论述，涵盖了 .NET 基本知识几乎所有的重点内容。

  通过阅读这本书， 主要巩固了.NET 的 IL 以及 GC 两方面的知识。

- 代码整洁之道(英文影印版)

  这本书通过大量的示例代码参数了如何让代码保持整洁， 通过这本书我学到了：

  - 好代码和糟糕的代码之间的区别；
  - 如何编写好代码， 如何将糟糕的代码转化为好代码；
  - 如何创建好名称、好函数、好对象和好类；
  - 如何格式化代码以实现其可读性的最大化；
  - 如何在不妨碍代码逻辑的前提下充分实现错误处理；
  - 如何进行单元测试和测试驱动开发。

  我这本书中的知识点归结为重构、 测试和代码规范三个方面， 我在开发中制订了代码规范， 加强了测试， 并在团队中推广， 同时也更加注重对代码的重构。

- Programming WPF (英文版)

  这本书详细完善介绍 XAML/WPF 开发的方方面边， 包括依赖属性、 数据绑定、 样式、 模板、 导航、 资源、 动画、 图形、 以及多媒体等。

  这本书中的知识对工作中的 Silverlight 开发起了很大的帮助。

- Learning ExtJS （英文版）

   这本书详细介绍了 ExtJS 的核心理念、 组件与布局、 托管渲染模型、 数据绑定、 常用控件和图表， 通过阅读这本书， 系统的学习了 ExtJS ， 对在项目中使用 ExtJS 有很大的帮助。

- 重构——改善现有代码的质量（英文影印版）；

   这本书用通俗易懂的语言， 大量的代码重构示例， 阐述了代码中常见的坏味道， 以及对应的修正方法， 对于提高代码水平有很大的帮助。

- 设计模式解析（英文影印版版）

   这本书首先概述了模式的基础知识，以及面向对象分析和设计在当代软件开发中的重要性，随后使用易懂的示例代码阐明了12个最常用的模式，包括它们的基础概念、优点、权衡取舍、实现技术以及需要避免的缺陷，使读者能够理解模式背后的基本原则和动机，理解为什么它们会这样运作。

  这本书是我对设计模式理解的入门书籍， 堪称入门经典。 通过阅读这本书， 我了解了设计模式的概念， 开始注重面向接口编程。

# 技能清单

以下均为我熟练使用的技能：

- 开发语言：C#/C/C++/JavaScript
- Web开发：ASP.NET/MVC/WEB-API
- 后端框架：NHibernate/MyBatis.NET(iBatis.NET)/EntityFramework/Unity
- 前端框架：AngularJS/Bootstrap/ExtJS/HTML5/jQuery/SCSS
- 数据库：SQL Server/MySQL/SQLite
- 版本管理：Git/Svn/TFS

## 参考技能关键字

`web` `uml` `html` `css` `soa` `nhibernate` `ios` `android` `mvc` `oop` `json` 

---

# 致谢

感谢您花时间阅读我的简历，期待能有机会和您共事。