---
layout: post
title: 开源一个 Sliverlight 导航框架
description: 开源一个 Sliverlight 可以动态从服务端加载 silverlight dll的导航框架 。
tags: [Silverlight]

---

开源项目中的一个 Silverlight 导航框架， 源代码已经发布到 GitHub， 地址为 [https://github.com/beginor/AssemblyNavigation](https://github.com/beginor/AssemblyNavigation)

## 特点

### 按需加载 Silverlight 组件

与 SL 内置实现了真正意义的按需加载， 主程序可以非常小， 最小不超过 200 KB， 只有当点击链接之后， 才会去服务端下载 对应的组件， 每个组件文件只会下载一次。 如果要下载的组件引用了其它第三方的组件， 也会自动下载第三方组件， 下载第这些 时会自动过滤掉重复的组件。

### 几乎零配置

使用这个导航框架几乎不需要在客户端或服务端做任何配置， 整个加载过程是自动完成的， 你需要写的只是导航的菜单项。

## 使用方法

### 主程序

1、 添加对 AssemblyNavigation、 System.Windows.Controls.Navigation 的引用至项目；

2、 在主页面的 xaml 代码添加下面的 xmlns 引用：

	xmlns:sdk="http://schemas.microsoft.com/winfx/2006/xaml/presentation/sdk"
	xmlns:asmNav="clr-namespace:Beginor.AssemblyNavigation;assembly=Beginor.AssemblyNavigation"

3、 添加 Frame 控件并设置 ContentLoader， 代码如下：

	<sdk:Frame Name="MainFrame" Grid.Row="1" Source="MainApp.WelcomePage,MainApp">
		<sdk:Frame.ContentLoader>
			<asmNav:AssemblyNavigationContentLoader />
		</sdk:Frame.ContentLoader>
	</sdk:Frame>

### 模块

每个模块需要添加对 System.Windows.Controls.Navigation 的引用， 至少要有一个页面（否则就不是模块了）， 这个 页面需要继承自 System.Windows.Controls.Page 类。

### 导航链接地址格式

导航地址的链接地址格式为要显示的模块的完整的类型名称， 例如：

	<StackPanel Orientation="Horizontal">
		<HyperlinkButton Content="Welcome Page" NavigateUri="MainApp.WelcomePage,MainApp"/>
		<HyperlinkButton Content="Chart Page" NavigateUri="ChartModule.ChartPage,ChartModule"/>
		<HyperlinkButton Content="Map Page" NavigateUri="MapModule.MapPage,MapModule"/>
		<HyperlinkButton Content="Grid Page" NavigateUri="GridModule.GridPage,GridModule"/>
	</StackPanel>

如果还不够清楚， 可以从 GitHub 网站项目下载这个[项目](https://github.com/beginor/AssemblyNavigation)， 有一个完整的测试程序。

**注意问题**

* 如果模块引用的第三方组件只在 xaml 中使用， 则必须添加 x:Name 属性， 否则可能会出现找不到这个第三方组件的问题；
* 如果模块的 xaml 中引用了 clrnamespace ， 则必须指定 assembly 值， 否则也可能会出现问题。
