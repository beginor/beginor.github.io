---
layout: post
title: 【翻译】MVP(SC),MVP(PV),PM,MVVM 和 MVC 表现模式架构对比
description: MVP(SC),MVP(PV),PM,MVVM 和 MVC 表现模式架构对比
tags: [转载]

---

翻译 CodeProject 上的一篇文章，对常见的几种表现模式 (Presentation patterns) 进行了说明，并进行对比。原文地址是 [https://www.codeproject.com/KB/aspnet/ArchitectureComparison.aspx](https://www.codeproject.com/KB/aspnet/ArchitectureComparison.aspx)。

### 表现模式 (Presentation patterns) 背景

与用户界面 (UI) 相关的最大的问题就是大量的凌乱的代码，主要是由这两个因素造成的，首先是用户界面包含负责的逻辑用于维护界面相关对象，其次也包含了应用程序状态的维护。表现模式 (Presentation patterns) 就是围绕如何移除用户界面的复杂性，让界面更加简洁和可管理而产生的，下图就是常见表现模式的种类与分类：

![常见表现模式的种类与分类](/assets/post-images/Heirarchy_3.jpg)

### 用户界面的3大问题：状态 (State) ， 逻辑 (Logic) ，同步 (Synchronization)

* 状态 (State) ： 状态是用户界面最关心的问题之一。状态是用户界面数据的当前快照，在 Web 应用中，可能是 Session 级别的一个变量，在 Windows 应用中， 则可能只是界面级别的数据。 用户界面包含的状态越多， 则用户界面越复杂。
* 逻辑 (Logic) ： 用户界面往往包含界面逻辑，例如维护文本框、组合框或者其它任何界面元素，用户界面中这种逻辑越多，则用户界面越复杂。 
* 同步 (Synchronization) ： 用户界面通常需要和业务组件协作，因此用户界面需要在界面元素与业务对象之间同步数据，如果用户界面包含的同步任务越多，则用户界面越复杂。

这三大问题与用户界面的关系如下图：

![三大问题与用户界面的关系](/assets/post-images/3Bigproblems_1.jpg)

### 表现设计模式 (Presentation Design Pattern)

表现设计模式有助于解决上面列出的问题， 它的的基本逻辑就是创建一个额外的表现类 (Presenter) ，用来消化用户界面中复杂的逻辑，数据和同步的问题，从而使得用户界面变得简单明了。根据这个类承担责任的多少，决定了表现设计模式的类型，可能是 SC , PV , PM 等，也就是说，这个类型的成熟度决定了它将是那种设计模式。

![类型的成熟度决定了它将是那种设计模式](/assets/post-images/PresenterHowMuch_1.jpg)

#### 有用的缩写

* V 视图 (View) 或者用户界面 (UI)
* P 包含界面逻辑的表现类 (Presenter class which has the UI logic.)
* L 用户界面逻辑
* S 用户界面的状态
* M 业务组件或业务对象
* SC 监视控制器 (Supervising controller)
* PV 被动视图 (Passive view)
* PM 表现模型 (Passive view)

#### 监视控制器模式 (SC)

* 状态在视图中保存
* 表现类拥有复杂的表现逻辑，只关注简单的界面绑定逻辑，例如 WPF 或 Silverlight 等提供的绑定机制 (Presenter owns the complex presentation logic. Simple UI binding logic is taken care by using binding technologies like WPF binding and Silverlight binding. Anything complex is taken care presenter class. )
* 表现类关注视图
* 视图不关注表现类
* 视图通过数据绑定和业务模型进行关联

![监视控制器模式](/assets/post-images/SC_1.jpg)

#### 被动视图模式 (PV)

* 状态在视图中保存 
* 所有的界面逻辑都被包含在表现类中 
* 视图和业务模型完全独立，这种情况下需要一些在业务模型和视图之间进行同步数据的工作 
* 表现类关注视图 
* 视图不关注表现类

![被动视图模式](/assets/post-images/PV_1.jpg)

#### 表现模型 (PM)

* 表现类包含逻辑 
* 表现类包含状态 
* 表现类代表抽象的用户界面 
* 表现类不关注用户界面 
* 视图关注表现类 
* 视图与业务模型完全隔离

![表现模型](/assets/post-images/PM_1.jpg)

#### MVVM

* 继承自表现模型 
* 使用 WPF 以及 Silverlight 的绑定机制

![MVVM](/assets/post-images/MVVM_thumb.jpg)

#### MVC

* 没有表现类，有控制器 (Controller) 
* 请求首先到达控制器 
* 控制器负责绑定视图与业务模型 
* 逻辑存在于控制器中

![MVC](/assets/post-images/MVC_1.jpg)

### 总结与对比

下表是这几种表现模式从状态，逻辑与同步的角度进行的对比

<table border="1">
  <tbody>
    <tr>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top">状态</td>
      <td valign="top">逻辑</td>
      <td valign="top">同步</td>
    </tr>
    <tr>
      <td valign="top">Supervising controller</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">表现类</td>
      <td valign="top"> </td>
      <td valign="top">
        <strong>X</strong>
      </td>
      <td valign="top">
        <strong>X</strong>
      </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">视图</td>
      <td valign="top">X</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">业务模型</td>
      <td valign="top" colspan="3">视图和业务模型之间通过绑定进行连接。</td>
    </tr>
    <tr>
      <td valign="top">Passive View</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">表现类</td>
      <td valign="top"> </td>
      <td valign="top">X</td>
      <td valign="top">X</td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">视图</td>
      <td valign="top">X</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top">Presenter model</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">表现类</td>
      <td valign="top">X</td>
      <td valign="top">X</td>
      <td valign="top"></td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">视图</td>
      <td valign="top"></td>
      <td valign="top"> </td>
      <td valign="top">X</td>
    </tr>
    <tr>
      <td valign="top">MVVM</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">表现类</td>
      <td valign="top">X</td>
      <td valign="top">X</td>
      <td valign="top"></td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">视图</td>
      <td valign="top"></td>
      <td valign="top"></td>
      <td valign="top">X</td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top" colspan="4">使用 WPF 、Silverlight 的数据绑定机制</td>
    </tr>
    <tr>
      <td valign="top">MVC</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">控制器</td>
      <td valign="top"> </td>
      <td valign="top">X</td>
      <td valign="top">X</td>
    </tr>
    <tr>
      <td valign="top"> </td>
      <td valign="top">视图</td>
      <td valign="top">X</td>
      <td valign="top"> </td>
      <td valign="top"> </td>
    </tr>
  </tbody>
</table>

再来一个图的对比

![theBiggerPicture_1.jpg](/assets/post-images/theBiggerPicture_1.jpg)
