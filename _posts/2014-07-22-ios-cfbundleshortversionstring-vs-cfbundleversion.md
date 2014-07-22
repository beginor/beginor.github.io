---
title: iOS 中的 CFBundleShortVersionString 与 CFBundleVersion
description: iOS 开发中经常看到 CFBundleShortVersionString 和 CFBundleVersion 两个都可以用来标识应用版本号的变量， 究竟应该用哪个呢？ 下面就一探究竟
layout: post
tags: [iOS]
keywords: CFBundleShortVersionString, CFBundleVersion, iOS, OS X, InfoPlist.strings
---

iOS 开发中经常看到 CFBundleShortVersionString 和 CFBundleVersion 两个都可以用来标识应
用版本号的变量， 究竟应该用哪个呢？ 下面就一探究竟。

## CFBundleShortVersionString

`CFBundleShortVersionString` (`String` - iOS, OS X) 表示 bundle 发布版本号， 标识应
用的一个发布迭代。 发布版本号是由三个用句点 `.` 分割的整数组成的字符串， 第一个数字是主版本
号，表示重要的功能或重大的更新， 第二个数字表示次要功能的更新，第三个数字表示维护更新， 
具体规则也可以参考[语义化版本][3]。

这个值与表示应用构建迭代（包括发布与未发布）的 `CFBundleVersion` 的值不同， 并且这个值可以
被包含在 `InfoPlist.strings`  文件中进行本地化。

查看 [CFBundleShortVersionString][1] 的苹果开发者文档。

## CFBundleVersion

`CFBundleVersion` (`String` - iOS, OS X) 表示 bundle 构建迭代的版本号(发布与未发布)，
命名规则与 `CFBundleShortVersionString` 相同， 并且只能包含数字 (`0-9`) 和 句点 (`.`) ，
整数开头部分的 `0` 会被忽略，比如： `1.02.3` 与 `1.2.3` 相同。 这个值不能被本地化。

查看 [CFBundleVersion][2] 的苹果开发者文档。

这两个值的对比如下：

<table class="table table-bordered">
<tr>
<th> Key </th>
<th> Xcode name </th>
<th>  Summary </th>
</tr>
<tr>
<td>CFBundleShortVersionString</td>
<td>Bundle versions string, short</td>
<td>(Localizable) The release-version-number string for the bundle</td>
</tr>
<tr>
<td>CFBundleVersion</td>
<td>Bundle version </td>
<td>(Recommended) The build-version-number string for the bundle </td>
</tr>
</table>

简单来说， CFBundleShortVersionString 标识 bundle 的版本号字符串， 并且可以被本地化， 而
CFBundleVersion 表示构建版本号， 因此推荐使用 `CFBundleVersion` 作为应用程序的版本号标识。

[1]: https://developer.apple.com/library/ios/documentation/general/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-111349
[2]: https://developer.apple.com/library/ios/documentation/general/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102364
[3]: http://semver.org/lang/zh-CN/