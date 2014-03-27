---
layout: post
title: Xcode 5 中 xib 文件格式的调整
description: 描述 Xcode 5 中 xib 文件的变化以及处理
keywords: xamarin, iOS, xib, MvvmCross, ViewsContainer, 
tags: [Xamarin, iOS, MvvmCross]
---

old xib like :

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

![](/assets/post-images/old-view-controller.png)

new xib like :

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


![](/assets/post-images/new-view-controller-1.png)

![](/assets/post-images/new-view-controller-2.png)

![](/assets/post-images/new-view-controller-3.png)

new view controller

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

![](/assets/post-images/new-view-controller-error-1.png)

    public NewViewController(IntPtr handle) : base(handle) {
    }

![](/assets/post-images/new-view-controller-error-2.png)

    public static NewViewController Create() {
        var objects = UINib.FromName("NewViewController", null).Instantiate(null, null);
        return (NewViewController)objects[0];
    }