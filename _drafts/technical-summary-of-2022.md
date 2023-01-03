---
layout: post2
title: 2022年技术总结
description: 总结2022年我接触到的关键技术
keywords: .net7, ruby, angular, react, rollup, esbuild, es6, typescript, es-lint, gdal, mapbox-gl
tags: [参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## 后端技术

后端技术主要还是 .NET 为主， 估计我也很难全面转向其它的技术方向， 毕竟接触 .NET 20 年了， 太熟悉了， 很难舍弃。

我维护的 .NET 项目均升级到了最新的 .NET 7 ， 本来以为是常规升级， 但是由于 .NET 7 默认启用了 `nullable` 检查， 为了适应这个新特性， 许多代码都需要进行相应的修改， 程序的健壮性会增加不少， 随后会专门针对这个特性再写一篇。

## 前端技术

### 前端框架

前端一直用的是 [Angular](https://angular.io) ， 可以说是很棒的框架， 但是由于目前国内的现状， Angular 可以说是后继无人， 因此不得不寻找替代的前端技术框架， 基本上就只有 [Vue](https://vuejs.org) 和 [React](https://reactjs.org) 选择了， 经过一段时间的尝试， 决定开始转向生态更好也更开放的 React ， 如果有时间， 会写几篇入门教程或者心得什么的。

### 前端工具

学习并掌握了前端的转译/打包工具 [rollup](https://rollupjs.org) 和 [esbuild](http://esbuild.github.io) ， 不仅可以自己控制如何转译、 分包、 模块转换等常规操作， 甚至还尝试过自己写一些插件， 掌握了这些之后， 可以完全按照自己的想法来掌控前端的项目， 也算是有不小的收获。

### 前端模块化

前端模块化正在尝试全面转向浏览器原生支持的 ES6 模块化， 放弃传统的 umd 模块， 也是大势所趋了。 不过有两个痛点， Safari 和 移动端浏览器， 目前支持比较差。

### WebGIS

WebGIS 之前这一块一直使用 ESRI 的 [ArcGIS API for JavaScript](https://js.arcgis.com) (简称 ArcGIS JS API)， 现在已经改名为 ArcGIS Maps SDK for JavaScript （简称可能 ArcGIS JS SDK）， 反正就是同一个东西了。 不过 ArcGIS JS SDK 虽然功能全面， 也非常专业， 但是也非常的笨重， 很难在移动端使用， 而且很多功能必须和 ArcGIS 的服务端绑定才能使用， 没有对应的服务端的话， 很多功能都不可用， 或者很难使用。

所以现在更加倾向于使用开源的 [Mapbox GL JS](https://www.mapbox.com/mapbox-gljs)， 和 ArcGIS 的策略不同， Mapbox 的规范和工具都是开放的， 你可以自己做需要的服务， 也可以付费使用他们提供服务， 为对开发者提供了极大的开放性和灵活性。

## GDAL/Python

由于工作中要用到大量的 [GDAL](https://gdal.org/) 操作， 单纯依靠 Shell 脚本很难满足需要了， GDAL 提供两种 SDK ， C++ 和 Python， 因此学习了 Python 这个胶水语言， 却意外的开辟了另一个技术方向。 掌握了 Python 之后， 不仅 GDAL 使用更加灵活， 而且还可以在 Linux 系统上和 Shell 无缝衔接， 真不愧为胶水语言。

2022 年的技术总结大概就这么多了， 希望接下来的 2023 年能有新的收获。
