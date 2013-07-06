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
- **Transform** 相对于中心点进行视图缩放、旋转和平移， 这个属性只能进行二维转换。 （如果要进行三维转换， 则必须用 CoreAnimation 操作视图的 Layer 属性。）
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

在 Begin/Commit 函数之间， 可以通过下面的方法设置动画的参数和选项：

- [`setAnimationStartDate:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationStartDate:)
- [`setAnimationDelay:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationDelay:)
- [`setAnimationDuration:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationDuration:)
- [`setAnimationCurve:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationCurve:)
- [`setAnimationRepeatCount:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationRepeatCount:)
- [`setAnimationRepeatAutoreverses:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationRepeatAutoreverses:)
- [`setAnimationDelegate:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationDelegate:)
- [`setAnimationWillStartSelector:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationWillStartSelector:)
- [`setAnimationDidStopSelector:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationDidStopSelector:)
- [`setAnimationBeginsFromCurrentState:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationBeginsFromCurrentState:)

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

iOS 支持嵌套的动画， 也就是说在一个动画代码段中， 可以再开始另外一个动画代码段， 而不必等当前动画完成， 嵌套的动画会同时开始运行， 默认继承原来动画的延时、 时间长度、 加速曲线等， 不过这些选项也能被覆盖。 例如：

    [UIView animateWithDuration:1.0
        delay:1.0
        options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.firstView.alpha = 0.0f;
            // 这里开始一个新的动画
            [UIView animateWithDuration:1.0
                delay:0.0
                options:UIViewAnimationOptionOverrideInheritedCurve |
                    UIViewAnimationOptionCurveLinear |
                    UIViewAnimationOptionOverrideInheritedDuration |
                    UIViewAnimationOptionRepeat |
                    UIViewAnimationOptionAutoreverse
                animations:^{
                    [UIView setAnimationRepeatCount:2.5];
                    self.secondView.alpha = 0.0f;
                }
                completion:nil];
        }
        completion:nil
    ];

对应的 C# 代码如下：

    UIView.Animate(
        1.0,
        1.0,
        UIViewAnimationOptions.CurveEaseIn,
        () => {
            this.FirstView.Alpha = 0.0;
            UIView.Animate(
                1.0,
                1.0,
                UIViewAnimationOptions.OverrideInheritedCurve |
                UIViewAnimationOptions.CurveLinear |
                UIViewAnimationOptions.OverrideInheritedDuration |
                UIViewAnimationOptions.Repeat |
                UIViewAnimationOptions.Autoreverse,
                () => {
                    UIView.SetAnimationRepeatCount(2.f);
                    this.SecondView.Alpha = 0.0;
                },
                null
            );
        },
        null
    );

对于使用 Begin/Commit 方法的动画， 也可以嵌套调用 Begin/Commit 方法来实现嵌套的动画， 例如：

    UIView.BeginAnimations("Animation1");
    // Animation code goes here
        // Start another animation
        UIView.BeginAnimations("Nested animation");
        // nested animations code goes here.
        UIView.CommitAnimations();
    // other code
    UIView.CommitAnimations();

这段 C# 代码对应的 ObjC 代码很简单， 就不写出来了。

### 实现动画的自动翻转

当创建自动翻转指定次数的动画时， 考虑将重复次数设置为非整数值。 因为对于自动翻转的动画来说， 每次循环都是从原始值变化到目标值再变化回原始值， 如果希望动画结束之后停留在目标值， 需要将重复次数设置加上 0.5 ， 否则， 动画回慢慢变回原始值， 再迅速变化到目标值， 这可能不是原来期望的动画效果。

## 创建视图切换动画

视图切换动画可以减少修改可视化树时引起的界面上的突变， iOS 系统中大量使用了视图切换动画， 视图切换动画主要有下面两种场景：

- **修改子视图**
- **替换子视图**

> 注意： 不要把视图切换和视图控制器的切换混淆（显示一个模式对话框、将视图控制器推入导航堆栈等）， 视图切换改变的仅仅是视图的可视化树， 视图控制器是不变的, 更多信息可以参考[iOS视图控制器编程指南][14]。

### 修改子视图

可以修改子视图的可见性用来表示当前视图的不同的状态， 看下面的两个视图切换的例子，在 iOS 4.0 之前， 需要将视图切换动画添加到 Begin/Commit 动画之间， 代码如下：

在 iOS 4.0 之后， 可以使用 [transitionWithView:duration:options:animations:completion:][15]

    [UIView transitionWithView:self.view
        duration:1.0
        options:UIViewAnimationOptionTransitionCurlUp
        animations:^{
            self.currentView.hidden = YES;
            self.swapView.hidden = NO;
        }
        completion:^(BOOL finished) {
            UIView *tmp = self.currentView;
            self.currentView = self.swapView;
            self.swapView = tmp;
        }
    ];

在 iOS 4.0 之前需要用到的函数是 [`setAnimationTransition:forView:cache:`][16] 对应的代码如下：

    [UIView beginAnimations:@"toggleView" context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [UIView setAnimationDuration:1.0];
    // animation goes here
    self.currentView.hidden = YES;
    self.swapView.hidden = NO;
    [UIView commitAnimations];

这里只有动画部分的代码， 动画完成之后请参考 [`setAnimationDelegate:`][17] 方法设置并实现 UIAnimationDelegate 。

### 替换子视图

要进行子视图的替换， 需要用到 [`transitionFromView:toView:duration:options:completion:`][18] 方法， 示例代码如下：

    UIView *fromView = (self.displayPrimary ? self.view : self.secondView);
    UIView *toView = (self.displayPrimary ? self.secondView : self.view);
    UIViewAnimationOptions option = (self.displayPrimary ? UIViewAnimationOptionTransitionFlipFromRight
                                    : UIViewAnimationOptionTransitionFlipFromLeft);
    [UIView transitionFromView:fromView toView:toView duration:1.0 options:option
        completion:^(BOOL finished) {
            if (finished) {
            self.displayPrimary = !self.displayPrimary;
            }
        }
    ];

## 链接多个动画

有了上面的知识， 链接多个动画就非常简单了：

- 对于 lambda 或 block-based 方法的动画， 使用 complete 回调函数即可；
- 对于 Begin/Commit 方法的动画， 需要实现一个 UIAnimationDelegate ， 然后调用 setAnimationDelegate 方法设置 Delegate 即可。


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
[14]:http://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007457
[15]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/transitionWithView:duration:options:animations:completion:
[16]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationTransition:forView:cache:
[17]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/setAnimationDelegate:
[18]:http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/clm/UIView/transitionFromView:toView:duration:options:completion: