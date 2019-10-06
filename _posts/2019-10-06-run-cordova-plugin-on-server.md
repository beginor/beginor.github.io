---
layout: post2
title: Cordova 运行 Web 应用
description: post description
keywords: cordova, plugin, web, http server
tags: [参考]
---

## Cordova 简介

Cordova 非常的流行，因为它可以让 Web 开发人员来创建移动应用， 而且还可以通过 JavaScript 来调用设备硬件 API （GPS、蓝牙等）。 

通常 Cordova 的做法是把应用的 Web 内容 (HTML, JavaScript, CSS) 打包到移动应用中， 这样看起来更像是一个本地应用， 即使在离线的情况下也可以使用。 

其实还可以使用 Cordova 为现有的 Web 应用提供设备 API ， 增强现有 Web 应用的功能。 这样做不仅可以使用服务端技术（aspx， cshtml， php等）， 还可以随时更新 Web 应用， 只有在需要新的设备功能（Cordova 插件）时才更新客户端。

这样的应用架构看起来是这样子的：

![Archtect](/assets/post-images/cordova-with-web.png)

个人认为， 这才是**真**混合开发！

## 新建一个 Cordova 应用

按照 Cordova 的文档说明， 创建一个测试应用， 并添加 Android 平台， 指令如下：

```sh
cordova create myApp org.apache.cordova.myApp myApp
cordova platform add android
```

然后先编译一次，确认可以生成 Android 应用：

```sh
cordova build android
```

第一次编译时， 会下载特定版本的 gradle ， 需要一些时间。 一切顺利的话， 最终可以看到如下输出：

```
BUILD SUCCESSFUL in 19s
44 actionable tasks: 44 executed
Built the following apk(s): 
  ~/platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

看到最后生成了 app-debug.apk ，就算是编译成功了。

## 添加并使用 Cordova 原生插件

以 `cordova-plugin-app-version` 为例， 通过这个插件可以获取到客户端 app 的包名称以及版本等扩展：

```sh
cordova plugin add cordova-plugin-app-version
```

修改 `index.js` 文件中的 `onDeviceReady` 方法， 代码如下所示：

```js
// deviceready Event Handler
//
// Bind any cordova events here. Common events are:
// 'pause', 'resume', etc.
onDeviceReady: function() {
    this.receivedEvent('deviceready');
    // 启动时访问服务器上的文件
    if (location.href.startsWith('file://')) {
        var url = 'http://10.0.2.2/cdvtest/index.html?_t=';
        var date = new Date();
        url += date.toISOString();
        // 注意， 一定要用 replace 方法， 否则会打开新浏览器窗口， 而不是在 Cordova 应用的 WebView 中打开。
        location.replace(url);
    }
    else {
        // 这段代码在 web 服务器上才能执行。
        cordova.getAppVersion.getAppName().then(
            name => {
                document.getElementById('version').innerHTML = name;
            },
            err => {
                console.error(err);
            }
        )
    }
}
```

修改 `config.xml` ， 允许访问服务器地址：

```xml
<allow-navigation href="http://10.0.2.2" />
```

对于比较新的 Android 版本 (据说是 7.0 以上)， 默认是不允许访问 HTTP 服务器的， 需要再修改一个配置， 允许 HTTP 访问：

```xml
<edit-config file="app/src/main/AndroidManifest.xml" mode="merge" target="/manifest/application">
    <application android:usesCleartextTraffic="true" />
</edit-config>
```

修改 `index.html` ， 将服务器的URL添加至 CSP (Content-Security-Policy) 元数据：

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data: gap: http://10.0.2.2 https://ssl.gstatic.com 'unsafe-eval'; style-src 'self' 'unsafe-inline'; media-src *; img-src 'self' data: content:;">
```

最后， 再运行一次 `cordova build android` ， 确认重新生成了对应的 apk 文件。

> 安卓模拟器访问本机时的地址是 `10.0.2.2` ， 可以根据实际的服务器地址进行修改。

## 部署 Web 内容至服务器

本文的目的是在 Web 服务器上的脚本中使用 Cordova 的插件功能， 因此需要把 Cordova 的插件脚本也部署到服务器上：

```sh
cordova build android
cp -r platforms/android/app/src/main/assets/www/* /usr/share/nginx/html/cdvtest/
```

## 运行测试程序

最后， 运行一下生成的应用， 确认可以在服务器上的脚本中使用 Cordova 插件!
