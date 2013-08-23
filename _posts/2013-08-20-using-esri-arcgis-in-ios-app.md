---
layout: post
title: 在 iOS 项目中使用 ESRI ArcGIS SDK
description: 介绍如何在 Xcode 项目以及 Xamarin.iOS (MonoTouch) 项目中使用 ESRI ArcGIS SDK
tags: [iOS, Xamarin]
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

![add-arcgis-to-framework-search-path](/assets/post-images/add-arcgis-to-framework-search-path.png)

#### 2. 添加依赖项 ####

![add-dependet-library](/assets/post-images/add-dependet-library.png)

#### 3. 修改编译选项 ####

![modity-build-flags](/assets/post-images/modity-build-flags.png)

#### 4. 添加资源包 ####

### 使用 ArcGIS Online 基础图层 ###

## 在 Xamarin.iOS 项目中使用 ArcGIS SDK ##

### 下载并编译 ArcGIS iOS 绑定项目 ###

### 使用 ArcGIS Online 基础图层

[1]: https://developers.arcgis.com/en/ios/
[2]: https://developers.arcgis.com/en/features/
[3]: https://developers.arcgis.com/en/sign-in/
[4]: http://www.esri.com/apps/products/download/index.cfm#ArcGIS_Runtime_SDK_for_iOS