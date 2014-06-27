---
layout: post
title: Android 沉浸式全屏
description: 
keywords: Android, Immersive, Sticky Immersive, Fullscreen
tags: [Android, Xamarin]
---

Android 4.4 带来了沉浸式全屏体验， 在沉浸式全屏模式下， 状态栏、 虚拟按键动态隐藏， 应用可
以使用完整的屏幕空间， 按照 Google 的说法， 给用户一种 “身临其境” 的体验。

Android 4.4 中提供了 `IMMERSIVE` 和 `IMMERSIVE_STICKY` 标记， 可以用这两个标记与
`SYSTEM_UI_FLAG_HIDE_NAVIGATION` 和 `SYSTEM_UI_FLAG_FULLSCREEN` 一起使用， 来实现沉
浸模式。

<div class="alert alert-info">
<span class="glyphicon glyphicon-info-sign"> </span><strong>注意：</strong> 这些标
记在Xamarin.Android 中被映射为 <code>Android.Views.SystemUiFlags</code> 枚举。
</div>

## 普通全屏模式 (Fullscreen)

普通全屏模式通过设置下面的标记位实现：

    var uiOpts = SystemUiFlags.LayoutStable
            | SystemUiFlags.LayoutHideNavigation
            | SystemUiFlags.LayoutFullscreen
            | SystemUiFlags.Fullscreen
            | SystemUiFlags.HideNavigation;
    Window.DecorView.SystemUiVisibility = uiOpts;

在普通全屏模式下， 应用可以占据屏幕的全部空间， 当用户触摸屏幕的任何部分时， 会自动退出全屏模
式， 这种模式比较适用于视频播放器类应用。

## 沉浸模式 (Immersive)

沉浸模式通过设置下面的标记位实现：

    var uiOpts = uiOpts = SystemUiFlags.LayoutStable
            | SystemUiFlags.LayoutHideNavigation
            | SystemUiFlags.LayoutFullscreen
            | SystemUiFlags.Fullscreen
            | SystemUiFlags.HideNavigation
            | SystemUiFlags.Immersive;
    Window.DecorView.SystemUiVisibility = uiOpts;

在沉浸模式下， 应用占据屏幕的全部空间， 只有当用户从屏幕的上方边沿处向下划动时， 才会退出沉浸
模式， 用户触摸屏幕其它部分是， 不会退出该模式， 这种模式比较适用于阅读器、 杂志类应用。

## 黏性沉浸模式 (Sticky Immersive)

黏性沉浸模式通过设置下面的标记位来实现：

    uiOpts = SystemUiFlags.LayoutStable
            | SystemUiFlags.LayoutHideNavigation
            | SystemUiFlags.LayoutFullscreen
            | SystemUiFlags.Fullscreen
            | SystemUiFlags.HideNavigation
            | SystemUiFlags.ImmersiveSticky;
    Window.DecorView.SystemUiVisibility = uiOpts;

在黏性沉浸模式下， 应用使用屏幕的全部空间， 当用户从屏幕的上方边沿处向下滑动时， 也不会退出该
模式， 但是系统界面 （状态栏、 导航栏） 将会以半透明的效果浮现在应用视图之上 （如下图所示），
只有当用户点击系统界面上的控件时， 才会退出黏性沉浸模式。 因此， 这种全屏模式使用与游戏、 绘
图类应用。

![黏性沉浸模式](/assets/post-images/android-immersive-sticky.png)

根据 Android 开发文档中提到， 应用在使用沉浸模式时最好将 ActionBar 设置为 Overlay 模式，
具体设置可以参考这里：
<https://developer.android.com/training/basics/actionbar/overlaying.html>