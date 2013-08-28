---
layout: post
title: 在 Xamarin.iOS 项目中访问 ArcGIS 云端专题数据图层
description: 介绍如何在 Xamarin.iOS 项目中使用 MonoTouch.ArcGIS 使用云端专题数据
tags: [iOS, Xamarin, ArcGIS]
keywords: ArcGIS, MonoTouch, Xamarin, iOS, FeatureLayer
---

本文介绍如何在 Xamarin.iOS 项目中使用使用 ArcGIS Server 云端专题数据， 假设你已经准备好了 [ArcGIS Client Runtime SDK for iOS][1] 和 [MonoTouch.ArcGIS][2] 绑定项目。

ArcGIS API 提供的专题图层 ([AGSFeatureLayer][3]) 可以用来访问并编辑矢量地图数据， 它依赖于 ArcGIS 服务器专题服务 (Feature Service) ， 专题服务不仅可以浏览和编辑数据， 还可以使用类似 SQL 的语法对数据进行过滤， 专题服务可以托管在 ESRI 的 ArcGIS Online 云中， 也可以部署在自己的服务器上。 本文中使用的是 ArcGIS Online 的专题服务。

## 1. 添加专题服务数据

添加专题服务图层是非常简单的， 只要初始化一个 [AGSFeatureLayer][3] 图层实例并把它添加到地图上就可以了， 要初始化一个图层 ， 你需要知道专题服务的 URL 和访问服务所需的用户凭据， 而本文中使用专题服务是公开的， 因此不需要任何凭据。 将图层添加到地图上之后， 你需要使用自定义符号将图层的数据在地图上显示成蓝色的小圆点。

    public override void ViewDidLoad() {
        base.ViewDidLoad();
        // 添加地图底图
        var url = NSUrl.FromString("http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer");
        var tiledLayer = AGSTiledMapServiceLayer.TiledMapServiceLayerWithURL(url);
        this.MapView.AddMapLayer(tiledLayer, "Basemap Tiled Layer");
    
        // 专题图层
        var featureLayerUrl = NSUrl.FromString("http://services.arcgis.com/oKgs2tbjK6zwTdvi/arcgis/rest/services/Major_World_Cities/FeatureServer/0");
        var featureLayer = AGSFeatureLayer.FeatureServiceLayerWithURL(featureLayerUrl, AGSFeatureLayerMode.OnDemand);
        featureLayer.OutFields = new string[] { "*" };
        this.MapView.AddMapLayer(featureLayer, "CloudData");
    
        // 自定义符号
        AGSSimpleMarkerSymbol featureSymbol = AGSSimpleMarkerSymbol.SimpleMarkerSymbolWithColor(UIColor.FromRGBA(0f, 0.46f, 0.68f, 1f));
        featureSymbol.Size = new SizeF(7, 7);
        featureSymbol.Style = AGSSimpleMarkerSymbolStyle.Circle;
        //featureSymbol.Outline
        featureLayer.Renderer = AGSSimpleRenderer.SimpleRendererWithSymbol(featureSymbol);
    }

## 2. 允许用户选择专题

在这一节中， 允许用户从列表中选择一个国家。 要完成这个功能， 需要在界面上添加一个按钮， 并将按钮的 `Touch Up Inside` 事件连接到方法 `ShowCountryPicker` :

![Show Country picker button](/assets/post-images/show-country-picker.png)

When a user taps the button, the view controller's method `showCountryPicker:` will be invoked. In this method, you'll instantiate `UIPickerView` and display it on screen. To add a list of countries to the picker, you'll set the view controller as the picker's data source and implement the methods defined in the `UIPickerViewDataSource` protocol. Finally, you'll also set the view controller as the picker's delegate and implement the `pickerView:didSelectRow:inComponent:` method defined in the `UIPickerViewDelegate` protocol to allow the picker to inform you when a user selects a country.

## 3. 显示选中的专题数据

## 4. 运行示例程序

[1]: https://developers.arcgis.com/en/ios/
[2]: https://github.com/beginor/MonoTouch.ArcGIS
[3]: https://developers.arcgis.com/en/ios/api-reference/interface_a_g_s_feature_layer.html