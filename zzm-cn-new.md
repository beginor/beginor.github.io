---
layout: zzm
title: 张志敏的简历
show_in_sitemap: false
---


# 架构师简历模板

本简历模板由国内首家互联网人才拍卖网站「 [JobDeer.com](http://www.jobdeer.com) 」提供。

（括号里的是我们的顾问编写的说明，建议在简历书写完成后统一删除）

## 先讲讲怎样才是一份好的技术简历

首先，一份好的简历不光说明事实，更通过FAB模式来增强其说服力。

- Feature：是什么
- Advantage：比别人好在哪些地方
- Benefit：如果雇佣你，招聘方会得到什么好处 

其次，写简历和写议论文不同，过分的论证会显得自夸，反而容易引起反感，所以要点到为止。这里的技巧是，提供论据，把论点留给阅读简历的人自己去得出。放论据要具体，最基本的是要数字化，好的论据要让人印象深刻。

举个例子，下边内容是虚构的：

2006年，我参与了手机XX网发布系统WAPCMS的开发（```这部分是大家都会写的```）。作为核心程序员，我不但完成了网站界面、调度队列的开发工作，更提出了高效的组件级缓存系统，通过碎片化缓冲有效的提升了系统的渲染效率。（```这部分是很多同学忘掉的，要写出你在这个项目中具体负责的部分，以及你贡献出来的价值。```）在该系统上线后，Web前端性能从10QPS提升到200QPS，服务器由10台减少到3台（``` 通过量化的数字来增强可信度 ```）。2008年我升任WAPCMS项目负责人，带领一个3人小组支持着每天超过2亿的PV（``` 这就是Benefit。你能带给前雇主的价值，也就是你能带给新雇主的价值。 ```）。

有同学问，如果我在项目里边没有那么显赫的成绩可以说怎么办？讲不出成绩时，就讲你的成长。因为学习能力也是每家公司都看中的东西。你可以写你在这个项目里边遇到了一个什么样的问题，别人怎么解决的，你怎么解决的，你的方案好在什么地方，最终这个方案的效果如何。

具体、量化、有说服力，是技术简历特别需要注重的地方。

（以上内容在写完简历后，对每一段进行评估，完成后再删除）

---

## 联系方式

- 手机：`134 1805 6213` , `139 2412 5200`(备用)
- Email：beginor@qq.com 
- QQ：18905182

---

# 个人信息

- 张志敏/男/1981 
- 本科/华南师范大学物理系 
- 工作年限：8 年 +
- 技术博客：http://beginor.github.io
- Github: https://github.com/beginor 
- 期望职位：系统架构师，应用架构师
- 期望薪资：税前月薪16k~20k，特别喜欢的公司可例外
- 期望城市：广州

---

# 工作经历

## 广东省环境信息中心（2005年9月至今）

### 环保移动执法

我在此项目负责了哪些工作，分别在哪些地方做得出色/和别人不一样/成长快，这个项目中，我最困难的问题是什么，我采取了什么措施，最后结果如何。这个项目中，我最自豪的技术细节是什么，为什么，实施前和实施后的数据对比如何，同事和领导对此的反应如何。

该项目是环监局现有执法项目的移动端解决方案， 客户端采用 Xamarin 的 MonoTouch 和 Mono for Android 实现， 服务端采用 ASP.NET MVC 实现。

在这个项目中我负责客户端基础框架以及服务端入口网关服务器的设计与实现。

由于要支持 iOS 和 Android 两个平台， 最困难的就是如何不同的平台上共享逻辑代码的问题。 我采取的措施是尽量提取公共的、 平台独立的接口， 然后根据不同的平台进行实现， 应用逻辑代码面向这些中立的接口， 尽可能的保持平台无关性。

最自豪的是实现了跨平台的数据绑定， 将 .NET 的数据绑定的概念以及 MVVM 的模式应用到移动开发中， 将逻辑代码封装到 ViewModel ， 在 iOS 和 Android 两个平台上使用同一份逻辑代码。

### SilverGIS

该项目的主要目的是解决环境信息与 GIS 相结合的数据可视化解决方案， 基于 Silverlight + ArcGIS (SilverGIS) + ASP.NET MVC 技术构建。

在这个项目中我负责客户端基础架构建设， 包括 ArcGIS 客户端 API 的二次开发、 插件式框架的创建以及与服务端 MVC API 的集成。

在这个项目中， 为了解决 Silverlight 应用体积过大的问题， 采用了主程序 + 插件式开发的模式， 最困难的问题是从服务端按需加载客户端 Silverlight 插件模块， 最终采用 Mono.Cecil 绕过 Silverlight 平台的限制， 实现了客户端异步队列加载， 实现按需加载机制。

在这个项目中， 我最自豪的技术是通过动态解析 lambda 表达式的方式向服务端发送请求， 避免了在客户端代码中硬编码 URL 和请求参数， 大量减少由手工输入出错的情况， 即提高了程序员的效率也提高了代码的可靠性。

这个项目最终发展成为一个基础的应用程序框架， 在多个项目中使用， 至今依然在项目中使用。

### 污染源自动监控

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

   优秀的算法胜于卓越的计算机！ 算法在移动端显得更为重要， 在众多的算法书籍中， 我选择了这一本。

- 架构设计师必须知道的97件事

  本书提供了分享软件架构知识的新方式， 拓宽了阐述软件架构艺术的视角， 总结了 50 多位经验丰富的软件架构师的时间经验， 范围覆盖了软件架构师的职业操守、 技术技能、 思维模式、 领导力、 和客户的沟通交流、 权衡利弊的平衡感等主题。

  对我最有影响的观点是 “架构师应该亲力亲为” 和 “架构师当聚焦于边界和接口” 。

- 你必须知道的 .Net

   了解 IL、 GC 性能等；

- 代码整洁之道(英文影印版)
   代码整洁之道

- WPF Essentials （英文版）

    完善介绍 XAML/WPF 的知识

- Learning ExtJS （英文版）

   系统的学习了 ExtJS 的整体架构， 掌握了

- 重构——改善现有代码的质量（英文影印版）；

  了解代码中的坏味道

- 设计模式解析（英文影印版版）；

  设计模式入门经典

# 技能清单

以下均为我熟练使用的技能：

- 开发语言：C#/C/C++/JavaScript
- Web开发：ASP.NET/MVC/WEB-API
- 后端框架：NHibernate/MyBatis.NET(iBatis.NET)/EntityFramework/Unity
- 前端框架：Bootstrap/ExtJS/HTML5/jQuery/SCSS
- 数据库：SQL Server/MySQL/SQLite
- 版本管理：Git/Svn/TFS
- 单元测试：NUnit/MSUnit

## 参考技能关键字

`web` `uml` `html` `css` `soa` `nhibernate` `ios` `android` `mvc` `oop` `json` 

---

# 致谢

感谢您花时间阅读我的简历，期待能有机会和您共事。 