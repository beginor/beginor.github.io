---
title: Mvvm 框架中 ViewModel  之间的导航以及生命周期
description: 介绍 MvvmCross 框架中的 ViewModel 之间的导航以及 ViewModel 的生命周期
layout: post
tags: [MvvmCross, Xamarin, iOS, Android]
---

介绍 MvvmCross (Mvx) 框架中的 ViewModel 之间的导航以及 ViewModel 的生命周期。

## 在 ViewModel 之间导航

Mvx 框架中， 用一个页面跳转到另一个页面， 对应的也会从一个 ViewModel 跳转到另外的 ViewModel ， 页面间的跳转由 ViewModel 发起， 通常会调用 `ShowViewModel` 方法来完成 ViewModel 之间的导航， 这个方法提供了一下几个重载版本：

    protected bool ShowViewModel<TViewModel>(
        IMvxBundle parameterBundle = null,
        MvxBundle presentationBundle = null,
        MvxRequestedBy requestedBy = null
    ) where TViewModel : IMvxViewModel { ... };

这个重载版本所有的参数的默认值都是 `null` ， 可以不提供任何参数。

    protected bool ShowViewModel<TViewModel>(
        object parameterValuesObject,
        MvxBundle presentationBundle = null,
        MvxRequestedBy requestedBy = null
    ) where TViewModel : IMvxViewModel { ... };

这个重载版本需要提供一个类型为 `object` 的对象， 通常会使用匿名对象或者一个复杂类型对象， 其它参数为可选。

    protected bool ShowViewModel<TViewModel>(
        IDictionary<string, string> parameterValues,
        MvxBundle presentationBundle = null,
        MvxRequestedBy requestedBy = null
    ) where TViewModel : IMvxViewModel { ... };

## ViewModel 的生命周期

### 基于依赖注入的创建

Mvx 提供了一个依赖注入容器， 它在初始化 ViewModel 时就使用了依赖注入， 比如 ViewModel 的构造函数是这样的： 

    public MyViewModel(IEmailService service) { ... }

如果 `IEmailService` 已经在 Mvx 容器中注册过了， `IEmailService` 对应的实例就会自动注入给 `MyViewModel` ， 如果在程序中需要手工初始化一个对象， 也可以通过 `Mvx.IocConstruct<T>()` 方法来初始化指定的 ViewModel 。

### 基于约定的初始化

ViewModel 的构造函数执行完成之后， Mvx 接下来会调用 ViewModel 的 `Init` 方法， `Init` 方法的参数可以有以下几种形式：

**多个简单类型的参数**

使用多个简单类型的参数， 签名如下所示：

    public void Init(int a, string b, float c)

要调用这种签名类型的参数， 需要在 ShowViewModel 方法的参数中使用匿名类 (anonymous class) ， 并且匿名类的属性名称必须和 Init 函数的各个参数名称相同。

**一个复杂类型的参数**

Init 方法还可以使用一个复杂类型的参数， 并且只能有一个参数， 参数的成员只能包含简单类型， 如下所示：

    public void Init(Parameter param)

要调用这种类型的参数， 需要在 ShowViewModel 方法的参数中使用对应类型的实例。

**使用 IMvxBundle 参数**

如果上面的两种形式都不能满足需要， 则还可以使用 IMvxBundle 参数， 如下所示：

    public void init(IMvxBundle)

IMvxBundle 是 Mvx 提供的类型， 类似于字典， 可以自己读写需要的类型， 要调用到这个方法， 需要在 ShowViewModel 方法中提供 IMvxBundle 的实例， 不过很少用到这种类型的 Init 方法。

上面的三种形式的 Init 方法可以同时出现在一个 ViewModel 中， 不过推荐的是在一个应用中只是用一种风格的 Init 方法。

> 简单类型是指是指 int , long , double , string , Guid, enum 。

## ReloadState

## Start
