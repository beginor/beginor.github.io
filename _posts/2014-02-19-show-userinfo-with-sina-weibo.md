---
layout: post
title: 调用新浪微博显示用户信息
description: 在Android上调用新浪微博显示用户信息
tags: [Android]
keywords: android, sinaweibo, userinfo, uid
---

使用 [AXMLPrinter2.jar][1] 反编译新浪微博的 `AndroidManifest.xml` ，

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

UserInfoActivity 注册了两个 `intent-filter`

    var intent = new Intent(Intent.ActionView);
    var uri = Android.Net.Uri.Parse("sinaweibo://userinfo?uid=3444956000");
    intent.SetData(uri);
    var chooseIntent = Intent.CreateChooser(intent, "Weibo");
    StartActivity(chooseIntent);

前提是用户已经安装了新浪微博，否则会报错

    var intent = new Intent(Intent.ActionView);
    var uri = Android.Net.Uri.Parse("http://weibo.cn/qr/userinfo?uid=3444956000");
    intent.SetData(uri);
    var chooseIntent = Intent.CreateChooser(intent, "Weibo");
    StartActivity(chooseIntent);

如果用户没有安装新浪微博， 则直接调用浏览器打开那个地址， 如果用户安装了新浪微博， 则会显示下面的对话框让用户选择：

![选择对话框](/assets/post-images/weibo-userinfo-chooser.png)

[1]: https://code.google.com/p/android4me/downloads/detail?name=AXMLPrinter2.jar&can=2&q=
