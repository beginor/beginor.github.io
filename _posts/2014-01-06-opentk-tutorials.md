---
layout: post
title: OpenTK 入门系列
description: 网络上 OpenGL 的资源可以说是非常多， 但是针对 OpenTK 的资源就很少， 因此特将自己写的一些入门的代码共享给出来， 这些代码只涉及 OpenGL ，OpenAl 和OpenCL 未涉及，  如果你已经具有一些 OpenGL 或者 DirectX 的基础的话，阅读这些代码并不难
tags: [教程]
keywords: OpenTK, Tutorials, OpenGL, C#, .Net
---
本来是很久以前的帖子了， 居然还有人需要， 所以又翻了出来， 重新整理并发布到 [github][1] 。

The Open Took Kit (OpenTK), 是对 OpenGL、OpanAL、OpenCL 的跨平台的封装，使用 C# 编写，可以运行在 Windows、 Linux 以及 MacOSX 平台上， 任何 .Net 语言都可以使用它做开发。 主要特点如下：

**快速开发**

  使用 .Net 的强类型和内嵌的注释文档， 提高代码流程，并且有助于快速发现错误。 

**集成**

  可以单独使用，也可以无缝集成到 Windows Forms、 WPF 或 GTK# 等其它应用程序中。

**完全免费** 

  MIT/X11 协议发行，完全免费。
  
网络上 OpenGL 的资源可以说是非常多， 但是针对 OpenTK 的资源就很少， 因此特将自己写的一些入门的代码共享给出来， 这些代码只涉及 OpenGL ，OpenAl 和OpenCL 未涉及，  如果你已经具有一些 OpenGL 或者 DirectX 的基础的话，阅读这些代码并不难。

1 从0开始，设置一个可用的 OpenGL 窗口。

![从0开始，设置一个可用的 OpenGL 窗口。](/assets/post-images/image_33.png)

2 进行最简单的贴图

![进行最简单的贴图](/assets/post-images/image_8.png)

3 在OpenGl中简单旋转一个物体

![在OpenGl中简单旋转一个物体](/assets/post-images/image_10.png)

4 在 OpenGL 窗口中同时分别旋转两个不同的物体

![在 OpenGL 窗口中同时分别旋转两个不同的物体](/assets/post-images/image_12.png)

5 在 OpenGL 窗口中使用倒影

![在 OpenGL 窗口中使用倒影](/assets/post-images/image_14.png)
   
6 在 OpenGL 窗口中使用倒影反射

![在 OpenGL 窗口中使用倒影反射](/assets/post-images/image_16.png)
 
7 使用 OpenGL 光照效果

![使用 OpenGL 光照效果](/assets/post-images/image_24.png)

8 在 OpenGL 窗口中进行简单的碰撞检测

![在 OpenGL 窗口中进行简单的碰撞检测](/assets/post-images/image_20.png)

9 使用 OpenGL 进行简单的地形渲染

![使用 OpenGL 进行简单的地形渲染](/assets/post-images/image_32.png)

10 使用 OpenGL 创建球体，并进行贴图

![使用 OpenGL 创建球体，并进行贴图](/assets/post-images/image_31.png)

11 创建一个简单的粒子系统

![创建一个简单的粒子系统](/assets/post-images/image_30.png)

下载以[上例子的源代码][1]， 至于OpenTK的源代码就自己下载吧， 这里不提供了， 如果你的机子不是太旧的话， 应该都可以运行的， 我用的机器较旧， ATI Radeon 9500的显卡， 支持 OpenGL 2.0 ， 这些粒子都可以运行， 如果你的机子的显卡比这个还旧的话， 可能会无法运行。

[1]: https://github.com/beginor/LearningOpenTK