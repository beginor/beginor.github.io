---
title: Mvvm 框架中的数据绑定语法
description: 介绍Mvvm 框架中的绑定语法
layout: post
keywords: mvx, mvvmcross, databinding, swiss, fluent, tilbet, rio
tags: [MvvmCross, Xamarin, iOS, Android]
---

数据绑定一直是 MvvmCross (Mvx) 框架的核心， 随着 Mvx 版本的版本更新， 绑定语法由 Json 变化到了 Swiss 语法， 并逐渐向 Tilbet 过度。 由于基于 Json 的绑定语法在 Mvx 3.0 之后的版本已经标记为过时， 不再支持， 因此不做介绍， 本文详细介绍 Swiss 和 Tilbet 语法。

Mvx 实现了跨平台的数据绑定， 概念与 WPF/Silverlight/WinPhone (Xaml) 的数据绑定一致， 可以在 Android 和 iOS 平台使用， 这也正是 Mvx 框架的魅力所在。

## Swiss 绑定语法

在 Xaml 平台下， 数据绑定技术是非常普遍的， 比如： 

    <TextBlock Text="{Binding Path=TweetText, Converter={StaticResource RemainingLength},
        ConverterParameter=140}" />

与之对应的 Swiss 绑定为：

    Text TweetText, Converter=RemainingLength, ConverterParameter=140

Swiss 绑定语法看起来比 Xaml 平台下的绑定语法要简洁一些， 接下来详细介绍。

先来看一个最基本的绑定， 将视图 ViewModel 的属性 $Target$ 绑定到数据模型 ViewModel 的属性 $SourcePath$ ， 如下所示：

    $Target$ $SourcePath$

通常情况下 `$Target$` 必须是直接是 View 的属性， 例如：

- Text
- IsChecked
- Value
- ...

而 `$SourcePath$` 则可以 ViewModel 的属性， 也可以是 ViewModel上 C# 风格的属性路径 (PropertyPath) ， 例如：

- `UserId`
- `RememberMe`
- `Password`
- `Customer.FirstName`
- `Customer.Address.City`
- `Customer.Orders[0].Date`
- `Customer.Orders[0].Total`
- `Customer.Cards["Primary"].Expiry`
- `Customer.Cards["Primary"].Number`
- … 

在这个最基本的绑定之上， 还可以：

如果 `$SourcePath$` 被忽略， 或者直接是一个 `.` 则将使用整个 ViewModel 作为数据源；

如果需要使用 Converter ， 则直接在后面添加：

    , Converter=$ConverterName$

`$ConverterName$` 标识 ValueConverter 的名称， 通常是将类名去掉 ValueConverter 后缀， 例如： Length 对应的 ValueConverter 的类名是 `LengthValueConverter` 。

如果需要 ConverterParameter ， 则在后面继续添加：

    , ConverterParameter=$ParameterValue$

`$ParameterValue$` 允许的内容如下：

- 单引号或双引号表示字符串；
- 单词 null 表示 C# 的 `null` ；
- true 或 false 标识布尔值；
- 整数数字表示 `long` ；
- 浮点数字标识 `double` 。

如果需要 FallbackValue ， 则继续添加：

    , FallbackValue=$FallbackValue$

`$FallbackValue$` 允许的内容和 `$ParameterValue$` 一致， 再加上 `Enum` 枚举类型的 `ToString()` 的字符串形式， 这个在绑定类似 `Visibility` 之类的属性时非常有用。

如果需要特定的 BindMode ， 则继续添加：

    , Mode=$WhichMode$

`$WhichMode$` 允许的值如下：

- OneWay
- OneWayToSource
- TwoWay
- OneTime
- Default

如果需要 CommandParameter ， 则可以继续添加：

    , CommandParameter=$CPValue$

`$CPValue$` 允许的内容与 `$ParameterValue$` 相同。

如果需要多个绑定， 则用分号 `;` 分割。

下面再看几个具体的例子：

    Text Customer.FirstName

将 `Text` 绑定到 ViewModel 的 `Customer.FirstName` 属性；

    Text Title, Converter=Length

将 `Text` 绑定到 ViewModel 的 `Title` 属性， 并使用名称为 Length 的 ValueConverter ， 而这个 ValueConverter 是 LengthValueConverter 的默认实例；

    Text Order.Amount, Converter=Trim, ConverterParameter='£'

将 `Text` 属性绑定到 ViewModel 的 `Order.Amount` ， 并应用 `Trim` ValueConverter , Converter 的参数是字符串 `'£'` ；

    Text Order.Amount, Converter=Trim, ConverterParameter='£', FallbackValue='N/A'

Bind the Text property to Order.Amount on the ViewModel, but apply the Trim value converter, passing it the string "£". If no Order is available, or if the Order object doesn't have an Amount value, then display "N/A"

将 `Text` 属性绑定到 ViewModel 的 `Order.Amount` ， 并应用 `Trim` ValueConverter , Converter 的参数是字符串 `'£'` ， 如果不能成功获取 `Order.Amount` 的值， 则显示 `"N/A"` 。

    Value Count, BindingMode=TwoWay

将 `Value` 属性绑定到 ViewModel 的 `Count` 属性， 并指明是双向绑定；

    Click DayCommand, CommandParameter='Thursday'

Bind the Click event to the DayCommand property on the ViewModel (which should implement ICommand). When invoked, ensure that Execute is passeda parameter value of "Thursday"
将 `Click` 事件绑定到 ViewModel 的 `DayCommand` 属性 ( `ICommand` 的实现)， 当事件被激发时， 传递 `"Thursday"` 参数。

## Fluent 绑定 API

Mvx 还为数据绑定提供了 Fluent API ， 可以很方便的使用 C# 代码进行绑定， 通常使用 `CreateBindingSet<TView, TViewModel>` 扩展方法来完成， 包括：

    Bind($ViewObject$) 

其中 `$ViewObject$` 是要进行绑定的视图对象；

    For(v => v.$ViewProperty$) 

`$ViewProperty$` 是视图上的属性， 如果没有提供 `For`， 将使用默认的属性， 例如： 对于 `UILabel` 默认的属性是 `Text` ；

    To(vm => vm.$ViewModelPath$)

`$ViewModelPath$` 是 ViewModel 上的属性路径， 数据源；

    OneWay()
    TwoWay()
    OneWayToSource()
    OneTime()

指定绑定模式， OneWay， TwoWay， OneWayToSource 还是 OneTime ；

    WithConversion($name$, $parameter$)

`$name$` 是 ValueConverter 的名称, `$parameter$` 是参数；

一些具体的绑定示例如下所示：

    var set = this.CreateBindingSet<MyView, MyViewModel>();
    set.Bind(nameLabel)
       .For(v => v.Text)
       .To(vm => vm.Customer.FirstName);
    set.Bind(creditLabel)
       .For(v => v.Text)
       .To(vm => vm.Customer.Total)
       .WithConversion("CurrencyFormat", "$");
    set.Bind(cardLabel)
       .For(v => v.Text)
       .To(vm => vm.Customer.Cards["Primary"].Number)
       .WithConversion("LastFour")
       .OneWay()
       .FallbackValue("N/A");
    set.Bind(warningView)
       .For(v => v.Hidden)
       .To(vm => vm.Customer.Alert)
       .WithConversion("Not")
       .FallbackValue(true);
    set.Apply(); 

除了上面的基于 lambda 表达式的 Fluent 绑定， 还可以使用基于字符串的 fluent 绑定， 在绑定视图的事件或者视图的属性没有被暴露成 c# 属性时非常有用。 比如， UIButton 并没有暴露 C# 的 Title 属性， 但是依然可以这样进行绑定：

    set.Bind(okButton)
       .For("Title")
       .To(vm => vm.Caption);

> 注意： 当使用 fluent 进行绑定时， 别忘记在最后加上 `.Apply()` ， 否则整个绑定不会起作用。

## Tilbet 绑定语法




