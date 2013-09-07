---
title: 开源项目
layout: default
---

<div class="page-header">
	<h2>开源项目</h2>
</div>

.Net 开发自然少不了开源项目的支持， 以下是我参与或者编写的部分开源项目， 为我的开发工作提供了不少
帮助， 希望能够对你有所帮助。 

### MonoTouch.ArcGIS

[ESRI ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/en/ios/) 的 MonoTouch 绑定， 
如果是做 iOS 平台开发， 并且采用了 Xamarin.iOS （MonoTouch） 平台， 需要用到高级地图功能的话， 可
以考虑这个类库， 当然， 这个项目还不是很完善， 并且 ESRI 也在不断更新， 因此还需要继续折腾！

项目主页： [https://github.com/beginor/MonoTouch.ArcGIS](https://github.com/beginor/MonoTouch.ArcGIS)

### System.Net.Http for Silverlight 5

微软推出的最新的 HTTP 应用程序的编程接口， 被称之为“现代化的 HTTP 编程接口”， 提供了现代化的 Web Service 的客户端组件， 能够同时在客户端与服务端同时使用的 HTTP 组件（比如处理 HTTP 标头和消息）， 为客户端和服务端提供一致的编程模型， 这个组件在开源之后， 在 Xamarin.iOS 和 Xamarin.Android 中也出现了， 但是唯独没有推出官方的 Silverlight 版本， 我从 mono 的源代码中分离出了这个项目， 针对 Silverlight 平台修改， 保留了绝大部分功能， 这里有[这个项目的介绍](http://beginor.github.io/2013/04/13/system-net-http-for-silverlight.html)。 

项目主页： [https://github.com/beginor/System_Net_Http](https://github.com/beginor/System_Net_Http)

### Assembly Navigation for Silverlight 5

开源的 Silverlight 导航与加载相结合的框架， 我的原创作品， 最大特点是按需从服务端加载所需的 dll 文件， 能够明显减少 Silverlight 程序的初次加载时间， 项目越大、 模块越多， 效果越明显。 这里有一篇[详细的介绍](http://beginor.github.io/2012/10/01/open-source-silverlight-navigation-framework.html)， 推荐所有做 Silverlight 开发的同学采用。

项目主页： [https://github.com/beginor/AssemblyNavigation](https://github.com/beginor/AssemblyNavigation)

### MonoTouch.KKGridView

做 iOS 5.0 开发时， 需要用到一个 GridView ， 最终决定采用 [KKGridView](https://github.com/kolinkrewinkel/KKGridView) ， 因此便有了这个 MonoTouch.KKGridView ， 也就是 KKGridView 的 MonoTouch 绑定， 如果你需要为 iOS 6.0 之前的旧设备开发或者 iOS 自带的 GridView 不能满足需要时， 可以使用这个项目。

项目主页： [https://github.com/beginor/MonoTouch.KKGridView](https://github.com/beginor/MonoTouch.KKGridView)

### iBATIS.NET for .Net 4.0

当初大名鼎鼎的 iBATIS.Net 现在已经改名为 [MyBatis.Net](https://code.google.com/p/mybatisnet/) ， 以灵活的 dynamic sql 著称， 自从 1.6.2 （for .Net 2.0）之后就不再更新了， 曾经在项目中使用过相当长一段时间， 也曾经是 iBATIS 的铁杆粉丝， 由于要在 .Net 4.0 项目中要用到它， 所以有了这个针对 .Net 4.0 的升级版本， 通过了 SQL Server 的全部测试， 可以直接在生产环境使用。

项目主页： [https://github.com/beginor/iBATIS_2010](https://github.com/beginor/iBATIS_2010)

### 更多

当然， 还有一些不值得一提的小项目， 甚至是我平时的一些练习， 就不列出来献丑了， 具体请浏览[我的 GitHub 页面](https://github.com/beginor)。

<p>&nbsp;</p>

{% include comment.md %}