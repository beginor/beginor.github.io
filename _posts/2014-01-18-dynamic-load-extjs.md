---
layout: post
title: 动态加载 ExtJS 类库
description: 本文介绍如何动态加载 ExtJS 框架
tags: [ExtJS]
keywords: ExtJS, 动态加载, loader, 
---

[ExtJS][1] 是一个非常优秀的 JS 框架， 由于 ExtJS 自身非常庞大， 用于开发测试的 `ext-all-debug.js` 文件达到了 3.24M ， 如果是再加载带注释的 `ext-all-debug-w-comments.js` 则更是达到了 6M ， 可以说是非常庞大了， 因此动态加载 ExtJS 是很有必要的， 接下来就介绍如何对 ExtJS 做动态加载。

## 创建一个基本的模板

首先需要先创建一个基本可用的 ExtJS 模板， 这个很简单， 如下所示：

    <!DOCTYPE html>
    <html>
    <head>
        <title></title>
        <link rel="stylesheet" type="text/css" href="https://localhost/ext-4/resources/css/ext-all.css" />
        <script type="text/javascript" src="https://localhost/ext-4/ext-debug.js"></script>
    </head>
    <body>
        
    </body>
    </html>

我们需要引用的脚本是 ExtJS 根目录下的 `ext-debug.js` ， 不是 `ext-all-debug.js`， 这个文件非常小， 只有几百K ， 当让这个只是最基本的 ExtJS 组件， 不包括任何的界面功能。

## 配置 Ext.Loader 启用动态加载

ExtJS 中的动态加载是由 `Ext.Loader` 来完成的， 默认不启用动态加载， 所以接下来需要做的事配置 `Ext.Loader` 启用动态加载， 在上面模板的 `body` 标签内添加如下代码：

    <script type="text/javascript">
    Ext.onReady(function() {
        Ext.Loader.setConfig({
            enabled    : true,
            disableCaching: false,
            paths    : {
                Ext : '/ext-4/src'
            }
        });
    });
    </script>

上面的代码启用了动态加载， 禁用了浏览器缓存， 以及指定了 ExtJS 的所部署的路径。

现在用浏览器测试一下， 同时打开开发人员工具， 切换到网络标签， 跟踪浏览器的 http 请求， 如下图所示：

![ExtJS 动态加载模板](/assets/post-images/dynamic-load-extjs-template.png)

从图中可以看出， 现在只加载了css和少量的脚本， 并没有加载 ExtJS 额外的组件。

## 测试动态加载

新建一个测试 Javascript 文件， 输入如下代码， 并保存为 `testWindow.js` 。

    Ext.define('App.testWindow', {
        extend: 'Ext.window.Window',
        title: 'My Window',
        width: 300,
        height: 200,
        html: '<h1>Hello,world!</h1>',
        initComponent: function() {
            this.callParent();
        }
    });

然后再 `Ext.Loader` 的配置中添加一条路径： `App : '.'` ， 再添加一个测试按钮， 以及测试按钮的点击处理函数， 如所示：

    <button onclick="createWindow()">Create Window</button>
    <script type="text/javascript">
    function createWindow() {
        var win = Ext.create('App.testWindow');
        win.show();
    }
    </script>

现在， 刷新一下浏览器， 能看到 `Create Window` 测试按钮， 在浏览器看到的情形如下图所示：

![动态加载 ExtJS 组件](/assets/post-images/dynamic-load-extjs-test.png)

从图中可以看到， 浏览器依次加载了 `testWindow.js` 、 `/ext-4/src/window/Window.js` 、 `/ext-4/src/panel/Panel.js` 等相关文件。

## 结论

从上面的测试可以看出， 动态加载 ExtJS 是可以的， 但是文件有点儿多， 仅仅创建一个简单的窗口就需要加载 100 多个文件， 所以最终的建议是将所需要的 ExtJS 组件单独编译成一个文件或者直接使用 `ext-all.js` ， 自己写的 js 文件倒是可以考虑进行动态加载。

[1]: https://www.sencha.com/store/extjs/
