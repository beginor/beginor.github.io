---
layout: post
title: Silverlight 中的 UIElement 与 FrameworkElement
description: Silverlight 中的 UIElement 与 FrameworkElement 的研究，讨论了 UIElement 与 FrameworkElement 的适用场景。
tags: [Silverlight]

---
在 Silverlight 中， 有两个比较重要的基础控件 [UIElement](http://msdn.microsoft.com/zh-cn/library/system.windows.uielement(v=vs.95).aspx) 和 [FrameworkElement](http://msdn.microsoft.com/zh-cn/library/system.windows.frameworkelement(v=vs.95).aspx)， 如果你要开发自定义控件或者模版控件， 那么就可能要经常使用这两个基础控件， MSDN 中对这两个控件的描述如下： 

> **UIElement**  is a base class for most of the objects that have visual appearance and can process basic input in Silverlight. (UIElement  是 Silverlight 中具有可视外观并可以处理基本输入的大多数对象的基类。)

> **FrameworkElement** Provides a framework of common APIs for objects that participate in Silverlight layout. FrameworkElement also defines APIs related to data binding, object tree, and object lifetime feature areas in Silverlight. (FrameworkElement 为 Silverlight 布局中涉及的对象提供公共 API 的框架。 FrameworkElement  还定义在 Silverlight 中与数据绑定、对象树和对象生存期功能区域相关的 API。)

这两个控件的的继承关系如下：

![Inheritance](/assets/post-images/UIElement-LayoutElement-Simple.png)

从文档以及类图可以看出， UIElement 是一个比较低级的控件， 仅仅具有可视化外观和处理基本的输入事件， 例如控件大小、 透明度、 鼠标键盘事件以及特效等， 如果需要开发的控件仅仅需要这些基本的属性以及事件， 那么继承自 UIElement 是最佳选择。

FrameworkElement 继承自 UIElement ， 并添加了下面的功能：

1、 **布局 (Layout) ：**

与 WPF 相似， 为了区别对待继承自 FrameworkElement 的类型， Silverlight 实现了一个布局系统， 这个布局系统读取许多在 FrameworkElement 级别定义的属性（MinWidth、MaxWidth等）， 并为特殊的布局行为提供了可扩展的方法， 而这些方法可以在其子类的实现中进行重写。

2、 **对象生命周期事件：**  

很多情况下， 知道控件什么时候被首次加载（控件被添加到当前Silverlight应用程序的对象树）是非常有用的。 FrameworkElement 定义了生命周期事件 (Loaded/Unloaded) ， 这些事件对后台代码来说是非常有用的。

3、 **数据绑定上下文 (DataContext) ：**  

支持数据绑定的属性由依赖属性 (DependencyProperty） 实现， 依赖对象 (DependencyObject) 可以拥有依赖属性， 但是， 设置数据绑定以及潜在继承的数据上下文的功能却是由 FrameworkElement 实现的。

4、 **对象树**  

FrameworkElement 提供了 Parent 属性和 FindName 方法可以在对象树中分别向上和向下查找。

在 Silverlight 中， 绝大多数控件都继承自 FrameworkElement ， 因为绝大多数控件都需要 Framework Element 提供的功能， 直接继承自 UIElement 的控件几乎没有， 但是所有的控件都保留了操作 UIElement 的能力。 最后在附加上一个完整的类图， 方便大家参考。

![Inheritance](/assets/post-images/UIElement-LayoutElement-full.png)