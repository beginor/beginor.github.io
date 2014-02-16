---
title: 开始在 GitHub 上写博客
description: 开始在 GitHub 上写博客需要的准备工作， 申请 Github 账户、 准备 Jekyll、 添加讨论 ……
layout: post
tags: [教程, 参考]
---

准备工作如下

### 申请 GitHub 账户并准备代码库

### 安装 Jekyll

#### 安装 Ruby 

* 如果用的是 Windows 系统， 需要先安装 [Ruby](http://rubyinstaller.org/downloads) ， 需要下载 1.9.3 版本的 Ruby ， 并且还要安装 DevKit 。
* 如果是 Linux 或者 MAC 系统的话， 系统一般会自带 Ruby ， 就不需要再安装 Ruby 了。

#### 安装 Jekyll 引擎

打开一个命令行窗口， 输入下面的命令可以安装 Jekyll ：

<pre class="brush:shell">
gem update system
gem install jekyll
</pre>

如果提示有什么不兼容或者提示缺少什么库， 根据提示安装即可。

### 制作 Jekyll 主题模版

[JekBootStrap](http://themes.jekyllbootstrap.com/) 提供了几个主题， 如果你喜欢或者懒得动手， 直接下载一个就可以开始了。

当让， 也可以自己动手做一个。

### 上传文件

上传文件最简单了， 不过我的建议是在本地运行 `jekyll --server` ， 先预览一下， 确认无误之后再上传。 只要用 Git 提交上去即可。 大约过一分钟， 新的 Github 页面就生成了， 输入 http://your-username.github.com 就可以浏览。

**注意问题**

* 如果将运行 `jekyll --server` 之后， _site 目录下没有生成任何文件， 只要将 _config.yml 中的 auto 配置为 false ， 再运行 `jekyll --server` ，看看错误信息， 一般都可以解决的；
* 在 windows 系统平台上， 如果你的博客包含中文字符， 则需要将当前命令行的代码页修改为 65001 （UTF8） 才能正常运行；
* 不要使用 windows 记事本编辑文件， 因为记事本保存的编码是 UTF8 ＋ BOM ， 无法保存为不带 BOM 的 UTF8 。