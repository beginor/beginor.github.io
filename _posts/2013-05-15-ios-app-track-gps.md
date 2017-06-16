---
layout: post
title: iOS 应用使用位置信息
description: 介绍 iOS 应用使用位置信息，以及如何在后台继续获取位置信息
tags: [iOS, Mono, Xamarin]
keywords: ios, track gps background, lock screen, switch app, xamarin.ios, monotouch
---

最近要在 iOS 应用中添加位置信息， 需要满足的需求如下：

1. 应用在前台时能够获取位置信息；
2. 通过切换、 Home 按键将应用切换到后台时，停止获取位置信息；
3. 应用程序在前台运行， 直接锁定屏幕时，能够继续获取位置信息；

接下来逐步实现这三个需求。

## 获取设备位置信息

在 iOS 上获取位置信息是很容易的， 网上的资料也很多， 我的代码如下：

    // make sure location service is enabled.
    if (!CLLocationManager.LocationServicesEnabled) {
       return;
    }
    // create a new location manager
    CLLocationManager locationManager = new CLLocationManager {
       DistanceFilter = CLLocationDistance.FilterNone,
       DesiredAccuracy = 1000
    };
    // check to work with both ios 6 and older.
    if (UIDevice.CurrentDevice.CheckSystemVersion(6, 0)) {
       locationManager.LocationsUpdated += OnLocationsUpdated;
    }
    else {
       locationManager.UpdatedLocation += OnLocationUpdated;
    }
    locationManager.StartUpdatingLocation();

第一次运行时， 系统会弹出应用要使用位置的对话框， 点击确认即可。

## 在锁屏情况下继续更新 GPS 信息

当程序运行时， 用户直接锁定屏幕， 会调用 AppDelegate 的 DidEnterBackground 方法， 但是对于 iOS 应用来说， 用户切换程序或者点击 Home 按钮是， 也会调用这个函数， 这两种操作的区别在当前应用实例([UIApplication](https://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplication_Class/Reference/Reference.html#//apple_ref/doc/c_ref/UIApplication))的状态， 当用户切换程序或者点击 Home 按钮时， 应用的状态是 UIApplicationStateBackground ， 而锁定屏幕时， 应用状态是 UIApplicationStateInactive ， 使用下面的代码可以区分这两种情况：

    public override void DidEnterBackground(UIApplication application) {
       if (application.ApplicationState == UIApplicationState.Background) {
          Log.Debug("App send to background by home button/switching to other app, stop upload location.");
       }
       else if (application.ApplicationState == UIApplicationState.Inactive) {
          Log.Debug("App send to background by locking screen, contine upload location, but change mode to powersave mode");
       }
    }

对于锁屏情况下继续更新位置信息的需求， 就很容易达到了， 只要在 DidEnterBackground 函数中检查应用的状态， 当状态为 UIApplicationBackground 是才停止更新位置， 代码如下：

    public override void DidEnterBackground(UIApplication application) {
       // switch to other app or click home button, stop update location
       if (application.ApplicationState == UIApplicationState.Background) {
          locationManager.StopUpdatingLocation();
       }
    }

**注意：** 根据 Apple 的文档， DidEnterBackground 函数大约有 5 秒钟的执行时间， 如果超过 5 秒钟还没有从这个函数返回， 应用将会异常退出， 因此不要再这个函数中进行耗时的操作。 

当应用切换到前台或者解锁时， 会调用 AppDelegate 的 WillEnterBackground 方法， 只要在这个方法中继续更新位置即可：

    public override void WillEnterForeground(UIApplication application) {
       // app switch to foreground, continue to update location.
       locationManager.StartUpdatingLocation();
    }

**注意：** 同样， WillEnterForeground 大约有 5 秒钟的执行时间， 因此也不要在这个函数中进行耗时的操作。

## 为应用添加后台位置权限

要真正能在锁屏状态下继续更新位置， 需要修改 info.plist ，增加后台位置权限。 找到项目中的 info.plist 文件， 双击打开， 并切换到 Source 标签， 如下图所示：

![info.plist file in project](/assets/post-images/open-info-plist-file.png)

然后添加 Required background modes 属性项， 并将这个属性类型设置为 Array ， 并为这个属性添加一个子项 Location-based information ， 最终如下图所示：

![add location based info](/assets/post-images/add-location-based-info.png)

也可以直接把下面的代码添加到 info.plist 文件中， 效果是一样的。

    <key>UIBackgroundModes</key>
    <array>
       <string>location</string>
    </array>
