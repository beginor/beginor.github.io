---
layout: post
title: iOS 系统中的视图动画
description: 扁平化设计原则
tags: [iOS, Xamarin]
keywords: xamarin, mono, c#, ios, uiview, animation
---

动画为用户界面的状态转换提供了流畅的可视化效果， 在 iOS 中大量使用了动画效果， 包括改变视图位置、 大小、 从可视化树中删除视图， 隐藏视图等。 你可以考虑用动画效果给用户提供反馈或者用来实现有趣的特效。

在 iOS 系统中， [Core Animation][1] 提供了内置的动画支持， 创建动画不需要任何绘图的代码， 你要做的只是激发指定的动画， 接下来就交给 Core Animation 来渲染， 总之， 复杂的动画只需要几行代码就可以了。

## 哪些属性可以添加动画效果

根据 [iOS 视图编程指南][2]中说明， UIView 内置支持为下列属性添加动画效果：

- **Frame** 可以改变视图相对于上一级视图的位置和大小。 （如果视图已经经过了缩放、 旋转、平移之类的变换， 则需要修改 Center 和 Bounds 属性）
- **Bounds** 改变视图大小。
- **Center** 改变视图相对于上级视图的位置。
- **Transform** 相对于中心点进行视图缩放、旋转和平移， 这个属性只能进行二维转换。 （如果要进行三位转换， 则必须用 CoreAnimation 操作视图的 Layer 属性。）
- **Alpha** 改变视图的透明度。
- **BackgroundColor** 修改视图的背景色。
- **ContentStretch** 改变视图内容在视图的可用空间内的拉伸方式。

## 为视图的属性变化添加动画

为了给属性的变化添加动画效果， 需要把修改这些属性的代码放到指定的动画代码段 (**animation block**) 中。 只有在动画代码段中修改支持动画的属性， 才能添加动画效果。

### 使用 Begin/Commit 方法做动画

在 iOS 3.0 以及之前的系统中， 必须使用 `UIView` 的类方法 [`beginAnimations:context:`][9] 和 [`commitAnimations`][10] 来定义动画代码段， 在 begin 和 commit 之间的代码会在特殊的动画线程中运行， 因此不会阻塞主线程， 比如说要切换两个视图， 代码应该是这样子的：

    [UIView beginAnimations:@"ToggleViews" context:nil];
    [UIView setAnimationDuration:1.0];
 
    // Make the animatable changes.
    firstView.alpha = 0.0;
    secondView.alpha = 1.0;
 
    // Commit the changes and perform the animation.
    [UIView commitAnimations];

在 Xamarin.iOS (MonoTouch) 平台下， begin/end 方法对应的绑定为：

- [`public static void BeginAnimations (string animation)`][11]
- [`public static void BeginAnimations (string animationID, IntPtr context)`][12]
- [`public static void CommitAnimations ()`](13)

上面的切换视图的 C# 版本代码为：

    UIView.BeginAnimations("ToggleViews");
    UIView.SetAnimationDuration(1.0)
    this.FirstView.Alpha = 0.0;
    this.SecondView.Alpha = 1.0;
    UIView.CommitAnidations();

> **注意：** 如果不是为了支持很旧的设备， 则推荐使用下面的 lambda (block based method) 来实现动画效果， 虽然 begin/commit 还能够使用， 按照官方的说法， 对新系统来说是不推荐的了。

### 使用 lambda (block based method) 做动画

在 iOS 4.0 以后， 引入了代码块 (code block) 的概念， 可以使用代码块来初始化动画， 这也是在 iOS 4.0 之后苹果推荐的做法， iOS SDK 提供的 API 如下：

- [`animateWithDuration:animations:`][3]
- [`animateWithDuration:animations:completion:`][4]
- [`animateWithDuration:delay:options:animations:completion:`][5]

而在 Xamarin.iOS (MonoTouch) 平台下， 这些方法被绑定为下列方法：

- [`public static void Animate(double duration, NSAction animation)`][6]
- [`public static void Animate (double duration, NSAction animation, NSAction completion)`][7]
- [`public static void Animate (double duration, double delay, UIViewAnimationOptions options, NSAction animation, NSAction completion)`][8]

还是切换视图的动画， 如果用 objective-c 的代码块来实现， 则应该是这样子的： 

    [UIView animateWithDuration:1.0 animations:^{
        self.firstView.alpha = 0.0;
        self.secondView.alpha = 1.0;
    }];

如果用 C# 来实现的话， 应该是这样：

    UIView.Animate(1.0, () => {
        this.FirstView.Alpha = 0.0f;
        this.SecondView.Alpha = 1.0f;
    });

这样就实现了一个简单的渐变动画， 并且只能运行一次， 通常不能满足需求， 再来一个复杂点儿的：

    [UIView animateWithDuration:1.0
            delay:0.0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.firstView.alpha = 0.0;
            }
            completion:^(BOOL finished){
                [UIView animateWithDuration:1.0
                        delay:1.0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            self.firstView.alpha = 1.0;
                        }
                        completion:nil];
    }];

对应的 C# 代码如下：

    UIView.Animate(
        1.0,
        0.0,
        UIViewAnimationOptions.CurveEaseIn,
        () => this.FirstView.Alpha = 0.0f,
        () => {
            UIView.Animate(
                1.0,
                1.0,
                UIViewAnimationOptions.CurveEaseOut,
                () => this.FirstView.Alpha = 1.0f,
                null
            );
        }
    );

### 嵌套动画

iOS 支持嵌套的动画， 也就是说在一个动画代码段中， 可以再开始另外一个动画代码段， 例如：

    [UIView animateWithDuration:1.0
        delay: 1.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            aView.alpha = 0.0;
            // Create a nested animation that has a different
            // duration, timing curve, and configuration.
            [UIView animateWithDuration:0.2
                 delay:0.0
                 options: UIViewAnimationOptionOverrideInheritedCurve |
                          UIViewAnimationOptionCurveLinear |
                          UIViewAnimationOptionOverrideInheritedDuration |
                          UIViewAnimationOptionRepeat |
                          UIViewAnimationOptionAutoreverse
                 animations:^{
                      [UIView setAnimationRepeatCount:2.5];
                      anotherView.alpha = 0.0;
                 }
                 completion:nil];
 
        }
        completion:nil];

### 实现动画的自动翻转

## 创建视图切换动画

### 修改子视图

### 替换视图

## 链接多个动画

## 同时进行视图和图层动画

[1]:https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html "Core Animation"
[2]:http://developer.apple.com/library/ios/#documentation/windowsviews/conceptual/viewpg_iphoneos/animatingviews/animatingviews.html "View Programming Guide for iOS: Animations"
[3]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/animateWithDuration:animations: "animateWithDuration:animations:"
[4]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/animateWithDuration:animations:completion: "animateWithDuration:animations:completion:"
[5]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/animateWithDuration:delay:options:animations:completion: "animateWithDuration:delay:options:animations:completion:"
[6]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.Animate(System.Double%2cMonoTouch.Foundation.NSAction)
[7]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.Animate(System.Double%2cMonoTouch.Foundation.NSAction%2cMonoTouch.Foundation.NSAction)
[8]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.Animate(System.Double%2cSystem.Double%2cMonoTouch.UIKit.UIViewAnimationOptions%2cMonoTouch.Foundation.NSAction%2cMonoTouch.Foundation.NSAction)
[9]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/beginAnimations:context:
[10]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/commitAnimations
[11]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.BeginAnimations(System.String)
[12]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.BeginAnimations(System.String%2cSystem.IntPtr)
[13]:http://iosapi.xamarin.com/?link=M%3aMonoTouch.UIKit.UIView.CommitAnimations