---
layout: post
title: iOS 版 PNChart 的 Xamarin.iOS 绑定
description:  iOS 版 PNChart 的 Xamarin.iOS 绑定以及用法
keywords: pnchart, monotouch, xamarin.ios, pnlinechart, pnbarchart, pncirclechart, pnpiechart
tags: [Mono, Xamarin, iOS]
---

iOS 上大名鼎鼎的 [PNChart][1] ， 引用原作者的原话表达一下：

> Piner 在不久前要做 Chart 功能的时候，找了半天各种纠结，竟然没有一个好看又简单易用的。
> So，我写了这个超简约，超易用，带有动画效果的 Chart 库，已支持 Line 和 Bar 两种模式。



刚好需要图表功能， 这个简约漂亮的图表库刚好满足需要， 于是就做了它的 Xamarin.iOS 绑定， 支持下面的四种图表：

### PNLineChart

![PNLineChart](/assets/post-images/pn-line-chart.png)

    // init a new line chart instance
    var lineChart = new PNLineChart(new RectangleF(0, 135, 320, 200));
    lineChart.BackgroundColor = UIColor.Clear;
    // set x labels
    lineChart.XLabels = new [] { @"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7" };
    // init first line data
    var data01Arrr = new [] { 60.1f, 160.1f, 126.4f, 262.2f, 186.2f, 127.2f, 176.2f };
    var data01 = new PNLineChartData();
    data01.Color = PNColor.FreshGreen;
    data01.ItemCount = (uint)lineChart.XLabels.Length;
    data01.GetData = index =>  PNLineChartDataItem.DataItemWithY(data01Arrr[index]);
    // init second line data.
    var data02Arrr = new [] { 20.1f, 180.1f, 26.4f, 202.2f, 126.2f, 167.2f, 276.2f };
    var data02 = new PNLineChartData();
    data02.Color = PNColor.TwitterColor;
    data02.ItemCount = (uint)lineChart.XLabels.Length;
    data02.GetData = index =>  PNLineChartDataItem.DataItemWithY(data02Arrr[index]);
    // set chart data
    lineChart.ChartData = new [] { data01, data02 };
    // stroke chart
    lineChart.StrokeChart();

### PNBarChart

![PNBarChart](/assets/post-images/pn-bar-chart.png)

    // init a new bar chart instance
    var barChart = new PNBarChart(new RectangleF(0, 135, 320, 200));
    barChart.BackgroundColor = UIColor.Clear;
    barChart.YLabelFormatter = yLabelValue => new NSString(string.Format("{0:F0}", yLabelValue));
    barChart.XLabels = new [] { @"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7" };
    barChart.YValues = new NSNumber[] { 1, 24, 12, 18, 30, 10, 21 };
    barChart.StrokeColors = new [] { PNColor.Green, PNColor.Green, PNColor.Red, PNColor.Green, PNColor.Green, PNColor.Yellow, PNColor.Green };
    barChart.StrokeChart();

### PNCircleChart

![PNCircleChart](/assets/post-images/pn-circle-chart.png)

    var circleChart = new PNCircleChart(new RectangleF(0, 60, 320, 200), NSNumber.FromFloat(100f), NSNumber.FromFloat(60f), true, true);
    circleChart.BackgroundColor = UIColor.Clear;
    circleChart.StrokeColor = UIColor.Green;
    circleChart.StrokeChart();
### PNPieChart

![PNPieChart](/assets/post-images/pn-pie-chart.png)

    var items = new [] {
        PNPieChartDataItem.From(10, PNColor.LightGreen),
        PNPieChartDataItem.From(20, PNColor.FreshGreen, "WWDC"),
        PNPieChartDataItem.From(40, PNColor.DeepGreen, "GOOL I/O")
    };

    var pieChart = new PNPieChart(new RectangleF(40, 155, 240, 240), items);
    pieChart.DescriptionTextColor = PNColor.White;
    pieChart.DescriptionTextFont = UIFont.FromName("Avenir-Medium", 14);
    pieChart.DescriptionTextShadowColor = UIColor.Clear;
    pieChart.StrokeChart();


PNChart 本身是开源的， 所以绑定也是开源的， 地址是： [https://github.com/beginor/PNChartTouch][2]

[1]: https://github.com/kevinzhow/PNChart
[2]: https://github.com/beginor/PNChartTouch