---
title: Android 动画系统
description: 介绍 Android 动画系统简介，以及在如何在 Mono for Android 下使用。
keywords: view, property, layout animation, transit, scale
layout: post
tags: [Mono, Android]
---

Android 系统支持三种动画， 它们分别是视图动画 (View Animation) ， 属性动画 (Property Animation) 和布局动画 (Layout Animation)， 接下来分别介绍这三种形式的动画以及在 Mono for Android 下的用法。

### 视图动画

View Animation 在 Android 系统中出现的最早， 可以在 3.1 之前的系统中使用， 可以对视图进行透明度、 缩放、 旋转和平移， 各种动画可以通过 AnimationSet 任意组合， 实现更多的效果。 视图动画的继承关系如下图所示：

![View Animation](/assets/post-images/android.views.animations.png)

视图动画只能针对已经渲染的视图，

###  属性动画

![View Animation](/assets/post-images/android.animation.png)

### 布局动画