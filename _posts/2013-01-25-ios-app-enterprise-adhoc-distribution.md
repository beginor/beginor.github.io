---
layout: post
title: 通过网页进行 iOS 应用内部分发
description: 介绍如何通过网页内部分发 iOS 应用， 包括 In-House 企业应用和 ad-hoc 测试应用。 
tags: [iOS]
---

## 通过网页进行 iOS 应用内部分发 ##

介绍如何通过网页内部分发 iOS 应用， 包括 In-House 企业应用和 ad-hoc 测试应用。

### 原生 XCode 应用 ###

**1. 归档编译**

用 XCode 打开要分发的项目， 依次选择 `"Product" -> "Build for" -> "Archiving"`， 如下图：

![Build for Archiving](/assets/post-images/product-build-for-archiving.png)

编译完成之后，就会生成 XCode 的项目归档， 接下来使用 Organizer 设置分发信息。

**2. 使用 Organizer 设置分发信息**

打开 Orangizer ， 选择 Archives 标签， 可以看到现有的 XCode 项目归档， 选择要分发的项目， 然后点击右边的 `Distribute...` 按钮， 如下图所示：

![选择分发项目](/assets/post-images/select-archive-project.png)

接下来回弹出分发向导， 第一步分发方式， 选择 `Save for Enterprise  or Ad-Hoc Development`， 如下图所示：

![选择分发方式](/assets/post-images/select-distribution-method.png)

点击 `Next` 按钮， 第二步选择代码签名， 选择 `Enterprise` 或者 `Ad-Hoc` 签名， 如下图所示：

![选择代码签名](/assets/post-images/select-code-sign-identity.png)

点击 `Next` 按钮， 第三步填写分发信息， 选择应用保存位置以及名称， 同时要勾选 `Save for Enterprise Distribution`， 输入分发信息， 然后保存， 这样将会生成两个文件， 一个是后缀为 ipa 文件， 就是 iOS 程序本身了， 另一个是后缀为 plist 文件， 包含 ipa 文件的描述信息。

![填写分发信息](/assets/post-images/select-ipa-location.png)

**3. 部署到内部 Web 服务器**

将上一部最终生成的 ipa 以及 plist 文件复制到内部的 Web 服务器，  在网页上添加类似这样的链接：

    <a href="itms-services://?action=download-manifest&url=http://url-to-your-app.plist">安装移动办公iOS版</a>

Web 服务器上可能需要添加 .plist 和 .ipa 的 Mime 类型， 它们的 Mime 类型分别为：

*   `.plist : text/xml`;
*   `.ipa : application/octet-stream`

**4. iOS 设备下载安装**

用 iOS 设备访问网页， 点击链接就可以直接安装了。 如果是未越狱的设备， 需要确认签名许可包含了设备的 UDID ， 否则无法安装。

### MonoTouch 应用 ###

对于 MonoTouch 编写的应用， 需要将 MonoDevelop 升级到最新版的 3.1.1 ， 在 `Build` 菜单下也添加了 `Achive` 选项， 选择 `Arcive` 菜单进行编译， 就会在 XCode 的 Organizer 的 Archives 标签下能看到对应的项目， 接下来就和上面的步骤一致了。