---
layout: post
title: Android 沉浸式全屏
description: 
keywords: Android, Immersive, Sticky Immersive, Fullscreen
tags: [Android, Xamarin]
---

Android 4.4 带来了沉浸式全屏体验， 在沉浸式全屏模式下， 状态栏、 虚拟按键动态隐藏， 应用可以使用
完整的屏幕空间， 按照 Google 的说法， 给用户一种 “身临其境” 的体验。

Android 4.4 中提供了 `IMMERSIVE` 和 `IMMERSIVE_STICKY` 标记， 可以用这两个标记与
`SYSTEM_UI_FLAG_HIDE_NAVIGATION` 和 `SYSTEM_UI_FLAG_FULLSCREEN` 一起使用， 来实现沉浸模。

<div class="alert alert-info">
<strong>注意：</strong> 这些标记在 Xamarin.Android 中被映射为 <code>Android.Views.SystemUiFlags</code> 枚举。
</div>

## 普通全屏模式 (Fullscreen)

    var uiOpts = SystemUiFlags.Fullscreen | SystemUiFlags.HideNavigation;
    Window.DecorView.SystemUiVisibility = uiOpts;

## 沉浸模式 (Immersive)

    uiOpts = SystemUiFlags.Fullscreen | SystemUiFlags.HideNavigation | SystemUiFlags.Immersive;
    Window.DecorView.SystemUiVisibility = uiOpts;

## 黏性沉浸模式 (Sticky Immersive)

    uiOpts = SystemUiFlags.Fullscreen | SystemUiFlags.HideNavigation | SystemUiFlags.ImmersiveSticky;
    Window.DecorView.SystemUiVisibility = uiOpts;

<https://developer.android.com/training/basics/actionbar/overlaying.html#EnableOverlay>