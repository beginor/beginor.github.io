---
layout: post
title: Xcode 5 中 xib 文件格式的调整
description: 描述 Xcode 5 中 xib 文件的变化以及处理
keywords: xamarin, iOS, xib, MvvmCross, ViewsContainer
tags: [Xamarin, iOS, MvvmCross]
---

Xcode 升级到 5 之后， iOS 的 xib 文件发生了变化， 导致 Xamarin Studio 中自带的 iOS ViewController 模板出错了， 本文分析发生的错误， 并给出对应的解决方法。 

旧的 xib 文件的代码是这样子的：

    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="4469" systemVersion="13A476u" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES">
        <dependencies>
            <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="3694" />
        </dependencies>
        <objects>
            <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner" />
            <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder" />
            <view contentMode="scaleToFill" id="1">
                <rect key="frame" x="0.0" y="0.0" width="320" height="568" />
                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES" />
                <color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="calibratedWhite" />
                <simulatedStatusBarMetrics key="simulatedStatusBarMetrics" />
                <simulatedScreenMetrics key="simulatedDestinationMetrics" type="retina4" />
            </view>
        </objects>
    </document>

`objects` 数组下面的第一个对象是 `View` ， 在 Xcode 的界面设计器中看起来是这样子的：

![Old xib in xcode](/assets/post-images/old-view-controller.png)

在界面设计器中， 看到第第一个对象是 `View` 。 上面的 xib 文件在 MonoTouch 下运行没有任何问题。


在 Xcode 更新到 5.x 之后， 默认的 xib 文件如下：

    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="4510" systemVersion="13B42" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES">
        <dependencies>
            <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="3742" />
        </dependencies>
        <objects>
            <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner" />
            <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder" />
            <viewController customClass="NewViewController" id="e7e-KY-v2N">
                <simulatedStatusBarMetrics key="simulatedStatusBarMetrics" />
                <nil key="simulatedTopBarMetrics" />
                <nil key="simulatedBottomBarMetrics" />
                <simulatedOrientationMetrics key="simulatedOrientationMetrics" />
                <simulatedScreenMetrics key="simulatedDestinationMetrics" type="retina4" />
            </viewController>
        </objects>
    </document>

第一个对象由原来的 `View` 变成了 `ViewController` ， 在 Xcode 的界面设计器中看起来是这样子的：

![View Controller](/assets/post-images/new-view-controller-1.png)

当编译目标为 iOS7 是还能显示额外的布局指南 (Layout Guide) ：

![Layout Guide](/assets/post-images/new-view-controller-2.png)

还有一些 ViewController 额外的属性：

![View Controller Properties](/assets/post-images/new-view-controller-3.png)

不过， xib 格式升级之后问题来了， Xamarin Studio 相应生成的代码文件没变， 如下所示：

    public partial class NewViewController : UIViewController {

        public NewViewController() : base("NewViewController", null) {
        }

        public override void DidReceiveMemoryWarning() {
            // Releases the view if it doesn't have a superview.
            base.DidReceiveMemoryWarning();
            
            // Release any cached data, images, etc that aren't in use.
        }

        public override void ViewDidLoad() {
            base.ViewDidLoad();
            
            // Perform any additional setup after loading the view, typically from a nib.
        }
    }

上面的代码在运行时会抛出下面的异常：

![MissingCtorResolution](/assets/post-images/new-view-controller-error-1.png)

上面的异常时说找不到参数类型为 `IntPtr` 的构造函数， 我们添加一个接受 `IntPtr` 类型的构造函数， 如下所示：

    public NewViewController(IntPtr handle) : base(handle) {
    }

再次运行， 却发现又出现了下面的异常：

![view outlet is not set](/assets/post-images/new-view-controller-error-2.png)

最后， 只好用最古老的方法， 直接手工初始化 xib 文件， 然后返回 xib 对象数组里面的 ViewController ：

    public static NewViewController Create() {
        var objects = UINib.FromName("NewViewController", null).Instantiate(null, null);
        return (NewViewController)objects[0];
    }

通过这个静态的 Create 方法创建的 ViewController 终于可以使用了。

> 注意： 使用 MvvmCross 的也可能会遇到同样的问题， 这就需要重写 mvx 默认的 MvxTouchViewsContainer 的 CreateViewOfType 方法 （默认只简单的通过反射创建 ViewController）， 通过手工初始化 xib 文件的方法返回对应的 ViewController 。