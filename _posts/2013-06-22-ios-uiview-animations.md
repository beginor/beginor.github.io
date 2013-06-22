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

- **frame** 可以改变视图相对于上一级视图的位置和大小。 （如果视图已经经过了缩放、 旋转、平移之类的变换， 则需要修改 Center 和 Bounds 属性）
- **bounds** 改变视图大小。
- **center** 改变视图相对于上级视图的位置。
- **transform** 相对于中心点进行视图缩放、旋转和平移， 这个属性只能进行二维转换。 （如果要进行三位转换， 则必须用 CoreAnimation 操作视图的 Layer 属性。）
- **alpha** 改变视图的透明度。
- **backgroundColor** 修改视图的背景色。
- **contentStretch** 改变视图内容在视图的可用空间内的拉伸方式。

## 为视图的属性变化添加动画

### Starting Animations Using the Begin/Commit Methods 

### Starting Animations Using the Block-Based Methods

### Nesting Animation Blocks

### Implementing Animations That Reverse Themselves

## Creating Animated Transitions Between Views

### Changing the Subviews of a View

### Replacing a View with a Different View

## Linking Multiple Animations Together

## Animating View and Layer Changes Together

[1]:https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html "Core Animation"
[2]:http://developer.apple.com/library/ios/#documentation/windowsviews/conceptual/viewpg_iphoneos/animatingviews/animatingviews.html "View Programming Guide for iOS: Animations"