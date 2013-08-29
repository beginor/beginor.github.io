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

当用户点击按钮时， 会调用 View Controller 的 `ShowCountryPicker` 方法， 在这个方法中， 我们初始化一个 `UIPickerView` 并把它显示在屏幕上， 要显示国家列表， 则需要指定数据源并实现 `UIPickerViewDataSource` 协议中定义的方法， 为了能收到用户选择的选项， 还需要实现 `UIPickerViewDelegate` 协议中定义的 `pickerView:didSelectRow:inComponent:` 方法。

    partial void ShowCountryPicker(UIButton sender) {
        if (this.Countries == null) {
            this.Countries = new string[] { @"None",@"US",@"Canada",@"France",@"Australia",@"Brazil" };
        }

        var pickerSheet = new UIActionSheet(new RectangleF(0, 0, 320, 410));
        pickerSheet.ShowInView(this.View);
        pickerSheet.Bounds = new RectangleF(0, 0, 320, 410);

        var countryPicker = new UIPickerView(pickerSheet.Bounds);
        countryPicker.WeakDelegate = this;
        countryPicker.DataSource = this;
        countryPicker.ShowSelectionIndicator = true;

        pickerSheet.AddSubview(countryPicker);
    }

    #region "UIPickerview DataSource Part"
    [Export("numberOfComponentsInPickerView:")]
    public int GetComponentCount(UIPickerView picker) {
        return 1;
    }

    [Export("pickerView:numberOfRowsInComponent:")]
    public virtual int GetRowsInComponent(UIPickerView picker, int component) {
        return this.Countries.Length;
    }

    [Export("pickerView:titleForRow:forComponent:")]
    public virtual string GetTitle(UIPickerView picker, int row, int component) {
        return this.Countries[row];
    }
    #endregion
    
    #region "UIPickerview Delegate Part"
    [Export("pickerView:didSelectRow:inComponent:")]
    public virtual void Selected(UIPickerView picker, int row, int component) {

        // Dismiss action sheet
        var pickerSheet = (UIActionSheet)picker.Superview;
        pickerSheet.DismissWithClickedButtonIndex(0, true);
    }
    #endregion

## 3. 显示选中的专题数据

我们现在来完成高亮显示属于用户选择的国家的数据。

首先得到的是用户选择的国家， 如果用户选择了 `None` 的话， 清空专题图层选中的数据； 否则， 使用类似于 SQL 的语法 `COUNTRY = <selected_country>` 来选中专题图层的数据。 不过在进行选中操作之前， 需要设置专题图层选中数据的符号， 比如设置选中的数据在地图上显示为红色的原点； 同时还需要设置图层的 `queryDelegate` ， 实现 `AGSFeatureLayerQueryDelegate` 协议定义的方法， 这样当选择操作完成时，才能收到通知。  

    #region "UIPickerview Delegate Part"
    [Export("pickerView:didSelectRow:inComponent:")]
    public virtual void Selected(UIPickerView picker, int row, int component) {
        var countryName = this.Countries[row];
        var featureLayer = (AGSFeatureLayer)this.MapView.MapLayerForName("CloudData");

        if (featureLayer.SelectionSymbol == null) {
            // SYMBOLOGY FOR WHERE CLAUSE SELECTION
            var selectedFeatureSymbol = AGSSimpleMarkerSymbol.SimpleMarkerSymbolWithColor(UIColor.FromRGBA(0.78f, 0.3f, 0.19f, 1f));
            selectedFeatureSymbol.Style = AGSSimpleMarkerSymbolStyle.Circle;
            selectedFeatureSymbol.Size = new SizeF(10, 10);
            featureLayer.SelectionSymbol = selectedFeatureSymbol;
        }

        if (featureLayer.WeakQueryDelegate == null) {
            featureLayer.WeakQueryDelegate = this;
        }

        if (countryName == "None") {
            // CLEAR SELECTION
            featureLayer.ClearSelection();
        }
        else {
            var selectQuery = AGSQuery.Query();
            selectQuery.Where = string.Format("COUNTRY = '{0}'", countryName);
            featureLayer.SelectFeaturesWithQuery(selectQuery, AGSFeatureLayerSelectionMethod.New);
        }

        // Dismiss action sheet
        var pickerSheet = (UIActionSheet)picker.Superview;
        pickerSheet.DismissWithClickedButtonIndex(0, true);
    }
    #endregion

    #region "AGSFeature Query Delegate part"
    [Export("featureLayer:operation:didSelectFeaturesWithFeatureSet:")]
    public virtual void DidSelectFeaturesWithFeatureSet(AGSFeatureLayer featureLayer, NSOperation op, AGSFeatureSet featureSet) {
        AGSMutableEnvelope env = null;
        foreach (var selectedFature in featureSet.Features) {
            if (env != null) {
                env.UnionWithEnvelope(selectedFature.Geometry.Envelope);
            }
            else {
                env = (AGSMutableEnvelope)selectedFature.Geometry.Envelope.MutableCopy();
            }
        }
        this.MapView.ZoomToGeometry(env, 20, true);
    }
    #endregion

## 4. 运行示例程序

好了， 现在可以运行一下这个测试程序， 如果没有错误的话， 看到下面的程序截图：

![cloud-data-tutorial](/assets/post-images/cloud-data-tutorial-1.png)

点击按钮时， 屏幕截图如下：

![cloud-data-tutorial](/assets/post-images/cloud-data-tutorial-2.png)

选择 US 时， 截图如下：

![cloud-data-tutorial](/assets/post-images/cloud-data-tutorial-3.png)

[1]: https://developers.arcgis.com/en/ios/
[2]: https://github.com/beginor/MonoTouch.ArcGIS
[3]: https://developers.arcgis.com/en/ios/api-reference/interface_a_g_s_feature_layer.html