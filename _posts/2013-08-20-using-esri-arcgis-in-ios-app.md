---
layout: post
title: 在 iOS 项目中使用 ESRI ArcGIS SDK
description: 介绍如何在 Xcode 项目以及 Xamarin.iOS (MonoTouch) 项目中使用 ESRI ArcGIS SDK
tags: [iOS, Xamarin, GIS]
keywords: ArcGIS, MonoTouch, Xamarin, iOS, XCode
---

## ArcGIS SDK for iOS 简介 ##

[ArcGIS SDK for iOS][1] 是 ESRI 公司针对 iOS 平台的 GIS 解决方案， 以 iOS Framework 的形式提供， 与 iOS 自带的 MapKit 相比， 提供了很多强大的地图以及分析功能， 如果你要想要在 iOS 平台上实现类似下图的应用， [ArcGIS SDK for iOS][1] 是不错的选择。

![arcgis-org](/assets/post-images/arcgis-org.jpg)

![comm-at-large](/assets/post-images/comm-at-large.jpg)

![arcgis-tech2](/assets/post-images/arcgis-tech2.jpg)

[点击这里了解更多功能。][2]

## 在 Xcode 项目中使用 ArcGIS SDK ##

### 下载并安装 ArcGIS SDK for iOS ###

在 iOS 项目中使用[ArcGIS SDK for iOS][1]， 需要有一个 [ESRI 账户][3]， 登录之后， 可以转到 [ESRI ArcGIS Runtime SDK for iOS][4] 的下载页面， 下载到的是一个 pkg 文件， OSX 系统下的一种安装格式， 类似于 Windows 系统下的 exe/msi ， 双击即可安装。

### Xcode 项目设置 ###

ESRI 提供的 [ArcGIS SDK for iOS][1] 是 Framework 形式， 但是与 iOS 提供的 Framework 有些不同， 在 Xcode 项目中使用有些麻烦， 设置步骤如下：

#### 1. 将 ArcGIS 添加到框架搜索路径 ####

要将 ArcGIS Framework 添加到项目， 选择左边导航窗口的项目节点， 选择一个目标节点， 再选择编译设置标签， 如下图所示：

![add-arcgis-to-framework-search-path](/assets/post-images/add-arcgis-to-framework-search-path.png)

在编译设置标签的搜索框输入 `Framework Search Paths` 可以快速找到框架搜索路径设置， 双击右边的空白处， 点击 `+` 按钮并输入下面的路径：

`$(HOME)/Library/SDKs/ArcGIS/iOS/**`

> 注意： 如果在项目的 `Valid Architectures setting` 中有 `armv7s` 选项的话， 请删除这个选项， 这个选项是有 Xcode 针对 iPhone5 自动添加的， 但是 ArcGIS 库目前不包含 `armv7s` 。

#### 2. 添加依赖项 ####

ArcGIS 依赖于下面的框架和类库， 因此需要把它们添加到项目中：

- CoreGraphics.framework
- CoreLocation.framework
- CoreText.framework
- Foundation.framework
- libc++.dylib
- libz.dylib
- QuartzCore.framework
- MediaPlayer.framework
- MobileCoreServices.framework
- OpenGLES.framework
- Security.framework
- UIKit.framework

选择项目目标的 `Build Phases` 标签， 在 `Link Binary with Libraries` 节点， 点击 `+` 按钮， 添加上面列出的依赖项， 如下图所示：

![add-dependet-library](/assets/post-images/add-dependet-library.png)

#### 3. 修改编译选项 ####

为了确认能够正确的加载 ArcGIS framework ， 需要在项目中添加一些编译标志 (build flags) 。

> 注意： 如果没有这些标志， 程序在使用 ArcGIS API 提供的类时可能会崩溃！

选择 `Build Settings` 标签， 在搜索框内输入 `Other Linker Flags` 可快速找到 `Other Linker Flags` 设置， 双击空白处， 会弹出一个文本框， 在文本框内输入 `-all_load -ObjC -framework ArcGIS` ， 点击文本框外任意位置， 保存输入选项， 如下图所示：

![modity-build-flags](/assets/post-images/modity-build-flags.png)

#### 4. 添加资源包 ####

ArcGIS API 用到的资源文件， 比如 ESRI 和 Bind 的 Logo ， GPS 位置图片等， 被整理打包成一个 `ArcGIS.bundle` 文件， 默认安装在 `${HOME}/Library/SDKs/ArcGIS/iOS/ArcGIS.framework/Versions/Current/Resources` 目录， 需要手工将这个文件添加到项目中。

转到 XCode 的 `File` 菜单， 选择 `Add Files to <project>` 菜单项， 导航到 `${HOME}/Library/SDKs/ArcGIS/iOS/ArcGIS.framework/Versions/Current/Resources` 目录， 选择 `ArcGIS.bundle` 文件， 最后点击 `Add` 按钮， 将 bundle 文件添加到项目。

> 注意： 在 OS X 系统下， `${HOME}/Library` 目录默认是隐藏的， 可以通过在终端程序中输入命令 `chflags nohidden ~/Library/` 来显示这个目录。

### 使用 ArcGIS Online 基础图层 ###

项目设置完成之后， 使用 ArcGIS Online 的图层就很简单了， 比如：

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        AGSTiledMapServiceLayer *tiledLayer =
        [AGSTiledMapServiceLayer
         tiledMapServiceLayerWithURL:[NSURL URLWithString:@"https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"]];
        [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
        
        //Set the map view's layerDelegate to self so that our
        //view controller is informed when map is loaded
        self.mapView.layerDelegate = self;
    }


## 在 Xamarin.iOS 项目中使用 ArcGIS SDK ##

要在 Xamarin.iOS 项目中使用 ArcGIS Runtime SDK ， 需要先将 ArcGIS SDK 绑定成 Xamarin.iOS 类库项目， 这个在 Github 上已经有了，地址是： [https://github.com/beginor/MonoTouch.ArcGIS][5] ， 有了这个绑定项目， 在 Xamarin.iOS 中使用 ArcGIS 就容易的多了。

### 下载并编译 ArcGIS iOS 绑定项目 ###

访问 [https://github.com/beginor/MonoTouch.ArcGIS][5] ， 选择右边的 `Download Zip` 链接或者 `Clone in Desktop` 链接， 都可以得到这个绑定项目， 推荐 fork 这个项目， 这样便于根据自己的需要进行更改。

下载之后用 XamarinStudio 打开 `MonoTouch.ArcGIS.sln` 解决方案， 可以看到这个解决方案包括两个项目， Binding 和 AGSTestCS 两个项目， 分别是 ArcGIS for iOS 的绑定项目以及测试项目， 如下图所示：

![MonoTouch.ArcGIS.sln](/assets/post-images/monotouch-arcgis-sln.png)

参照 ReadMe.md 文件的说明， 需要把 ArcGIS 文件从 `~/Library/SDKs/ArcGIS/iOS/ArcGIS.framework/Versions/Current/` 目录复制到 Binding 项目所在的目录， 并重命名为 `libArcGIS.a` ，然后编译这个项目， 如果没有错误的话， 会在 bin 目录内生成一个体积巨大的 dll 文件 `MonoTouch.ArcGIS.dll` ， 这就表示 Binding 项目生成成功了， 虽然这个 dll 文件很大， 但是不用担心， 最终生成 ios 应用时， 编译器会将用不到的部分删除， 最终的应用程序不会很大， 一般会在 10m 以内。

现在可以生成并运行 AGSTestCS 项目， 可以看到一个地图应用在 iOS 模拟器启动， 这就表示一切都成功了！

### 使用 ArcGIS Online 基础图层

Binding项目只是对 ArcGIS API 的绑定， 因此对外暴露的 API 函数几乎不变， 不同的只是换成了 C# 的语法， 上面在 Xcode 中使用 ArcGIS Online 的基础图层的代码对应的 C# 版本如下：

    public override void ViewDidLoad() {
       base.ViewDidLoad();
       // add a basemap tiled layer.
       var url = NSUrl.FromString("https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer");
       var tiledLayer = AGSTiledMapServiceLayer.TiledMapServiceLayerWithURL(url);
       this.MapView.AddMapLayer(tiledLayer, "Basemap Tiled Layer");
    }

[1]: https://developers.arcgis.com/en/ios/
[2]: https://developers.arcgis.com/en/features/
[3]: https://developers.arcgis.com/en/sign-in/
[4]: https://www.esri.com/apps/products/download/index.cfm#ArcGIS_Runtime_SDK_for_iOS
[5]: https://github.com/beginor/MonoTouch.ArcGIS
