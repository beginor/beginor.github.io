---
layout: post
title: 使用自签名证书内部分发 iOS7 应用
description: 使用自签名证书分发iOS应用，兼容 iOS7
keywords: iOS
tags: [iOS]
---

iOS 升级到 7.1 之后， 原来通过[网页分发应用的方法][1]出现错误， 提示 “无法安装应用， 服务器证书无效”， 原来 iOS 要求必需将 plist 文件放到 https 服务器上 （对 ipa 文件无要求）， 在 StackOverFlow 上有网友[将 plist 文件放到 dropbox 或者 skydrive 上的方法][2]， 国内也可以将 plist 文件放到 SAE (Sina App Engine) 上面经测试是可行的。 不过如果是通过内网分发 iOS 应用的话， 修改起来还是挺麻烦的， 最好还是使用自签名的证书实现 https 链接， 这样对内网分发应用方式的修改最小。

## 使用 OpenSSL 创建自签名的CA根证书

使用 OpenSSL 创建 CA 根证书是很方便的， 只需要输入下面的几个命令即可：

    # 创建 CA 私钥
    openssl genrsa -out ca.key 1024

    # 创建 CA 根证书， 30 年比较省心
    openssl req -x509 -new -key ca.key -out ca.cer -days 10950

## 安装 CA 根证书

由于上面创建的 CA 根证书是自签名的， 需要手工在 iOS 设备以及分发服务器上安装。

### iOS 安装 CA 证书

在 iOS 上安装 CA 证书很很容易的， 如果在 iOS 设备上配置了邮件， 只要把证书作为附件发送过去， 在 iOS 设备上收到邮件后点击下载附件， 按照提示进行安装就可以了。 

当然， 也可以在服务器上向证书的链接上添加 Http 头 `Content-Composition` ， 对应的值为 `attachment: filename=ca.cer` ， 强制浏览器下载 cer 文件 （在 IIS服务器下浏览器会直接以文本的形式打开证书）， 下载完成之后按照提示进行安装就可以了。 

证书安装之后可以在 “设置” -> “通用” -> “描述文件” 下看到， 不用的话可以从这里删除。

### 服务器上安装 CA 证书

在服务器上双击证书文件， 选择 “安装证书” 按钮， “存储位置” 设置为 “本地计算机” ， 然后选择将证书存储为 “受信任的根证书办法机构” ， 确定即可。

## 服务器上安装 HTTPS 证书

### 用 IIS 管理器创建证书申请

打开 IIS 管理器， 选择要添加 HTTPS 的证书的服务器， 在功能视图的 “IIS” 分组找到并打开 “服务器证书” ， 在右边的 “操作” 窗格点击 “创建证书申请” ， 证书的 “通用名称” 必需与服务器的完整域名一致， 否则签发的证书无效， 然后点击下一步， 加密方式选择 RSA ， 长度选择 1024 ， 最后将 “证书申请” 信息保存为 iis.txt 。

### 使用 OpenSSL 签发 https 证书

输入下面的命令签发服务器证书：

    openssl ca -in iis.txt -cert ca.cer -keyfile ca.key -out iis.cer

### 使用 IIS 管理器导入 https 证书

打开 IIS 管理器， 选择要添加 HTTPS 的证书的服务器， 在功能视图的 “IIS” 分组找到并打开 “服务器证书” ， 在右边的 “操作” 窗格点击 “完成证书申请” ,  选择证书文件 iis.cer ， “好记名称” 可以设置为服务器的完整域名， 证书存储设置为 “个人”， 点击确定按钮完成。

现在在 iOS 设备上通过 https 访问原来的分发应用的网页， 就应该可以下载了。

参考资料：

- [在iOS上使用自签名的SSL证书][3]
- [IIS8中使用OpenSSL来创建CA并且签发SSL证书][4]

[1]: https://beginor.github.io/2013/01/25/ios-app-enterprise-adhoc-distribution.html
[2]: https://stackoverflow.com/questions/20276907/enterprise-app-deployment-doesnt-work-on-ios-7-1/22325916#22325916
[3]: https://beyondvincent.com/blog/2014/03/17/five-tips-for-using-self-signed-ssl-certificates-with-ios/
[4]: https://www.cnblogs.com/mosquitos/p/3147539.html

