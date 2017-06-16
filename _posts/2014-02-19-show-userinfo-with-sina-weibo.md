---
layout: post
title: 调用新浪微博显示用户信息
description: 在Android上调用新浪微博显示用户信息
tags: [Android]
keywords: android, sinaweibo, userinfo, uid, 一键关注, 新浪微博
---
最近需要在开发的安卓项目中添加新浪微博一件关注的功能， 本来是一个很简单的功能， 就是调用新浪微博客户端显示用户信息的 `Activity` ， 然后用户就点击关注按钮就可以了。 本来是很简单的功能， 可以网上找到的几乎都是 JS 的代码， 或者是要注册新浪微博 SDK 的代码， 这么简单的功能应该不用注册什么 SDK 的， 也不想参合什么 JS ， 只要研究一下新浪微博客户端的 `Activity` 就可以了。

首先我们需要使用 [AXMLPrinter2.jar][1] 反编译新浪微博的 `AndroidManifest.xml` ， 从中查找显示用户信息的页面， 反编译代码如下：

    java -jar AXMLPrinter2.jar AndroidManifest.xml > a.xml

打开反编译出来的 `a.xml` ， 搜索 `userinfo` ， 很幸运的找到了 `UserInfoActivity` ，如下所示：

    <activity android:theme="@7F0B0029" android:name="UserInfoActivity"
        android:configChanges="0x000000A0">
        <intent-filter>
            <action android:name="android.intent.action.VIEW">
            </action>
            <category android:name="android.intent.category.DEFAULT">
            </category>
            <categoryandroid:name="android.intent.category.BROWSABLE">
            </category>
            <data android:scheme="sinaweibo" android:host="userinfo">
            </data>
        </intent-filter>
        <intent-filter>
            <action android:name="android.intent.action.VIEW">
            </action>
            <category android:name="android.intent.category.DEFAULT">
            </category>
            <category android:name="android.intent.category.BROWSABLE">
            </category>
            <data android:scheme="http" android:host="weibo.cn"
                android:path="/qr/userinfo">
            </data>
        </intent-filter>
    </activity>

UserInfoActivity 注册了两个 `intent-filter` ， 第一个注册的 url 是 `sinaweibo://userinfo?uid=3444956000` ， 有了这个信息， 通过如下的代码调用新浪微博客户端显示用户信息了：

    var intent = new Intent(Intent.ActionView);
    var uri = Android.Net.Uri.Parse("sinaweibo://userinfo?uid=3444956000");
    intent.SetData(uri);
    var chooseIntent = Intent.CreateChooser(intent, "Weibo");
    StartActivity(chooseIntent);

不过， 上面代码的前提是用户已经安装了新浪微博客户端，否则运行会报错， 幸好还有第二个， 我们可以使用下面的代码进行调用：

    var intent = new Intent(Intent.ActionView);
    var uri = Android.Net.Uri.Parse("https://weibo.cn/qr/userinfo?uid=3444956000");
    intent.SetData(uri);
    var chooseIntent = Intent.CreateChooser(intent, "Weibo");
    StartActivity(chooseIntent);

上面代码的效果是：

1. 如果用户没有安装新浪微博， 则直接调用浏览器打开那个地址；
2. 如果用户安装了新浪微博， 则会显示下面的对话框让用户选择：

![选择对话框](/assets/post-images/weibo-userinfo-chooser.png)

再次鄙视一下新浪微博的开放程度， 居然有这个功能都不开放。

本来打算用相同的方法在腾讯微信上做相同的功能，  却发现腾讯已经将显示微信号的 Activity 设置为私有的 `android:exported="false"` ， 居然比新浪还要封闭， 真是无语了！

[1]: https://code.google.com/p/android4me/downloads/detail?name=AXMLPrinter2.jar&can=2&q=
