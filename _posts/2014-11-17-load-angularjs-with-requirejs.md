---
layout: post
title: 使用 RequireJS 加载 AngularJS
description: 使用 RequireJS 加载 AngularJS
tags: AngularJS
keywords: AngularJS, RequireJS, AMD
---

[AngularJS][1] 目前的版本没有遵循 Javascript 约定的 [AMD][2] 模块化规范， 因此使用 [RequireJS][3] 加载 AngularJS 时需要一些额外的配置。

通过查阅 RequireJS 的文档， RequireJS 通过配置可以支持支持动态加载没有遵循 AMD 规范的脚本， 接下来就看一下怎么配置：

先在页面引入 RequireJS 脚本， 这个很简单， 只要一个 `script` 标记：

```xml
< script type="text/javascript" src="scripts/lib/require/require.js" data-main="scripts/main"></script>
```

RequireJS 会自动加载脚本 `scripts/main.js` ， 在 `main.js` 文件里面进行配置， 来动态加载 AngularJS ， 文件内容以及说明如下：

```js
requirejs.config({
    // 所有脚本的跟目录， 相对于 html
    baseUrl: 'scripts',
    paths: {
        // angular 脚本的路径， 相对于 baseUrl
        'angular': 'lib/angular/angular',
        'angular-route': 'lib/angular/angular-route'
    },
    shim: {
        // 需要导出一个名称为 angular 的全局变量， 否则无法使用
        'angular' : { exports: 'angular' },
        // 设置 angular 的其它模块依赖 angular 核心模块
        'angular-route': { deps: ['angular'] }
    }
});
```

完整的配置请看这里： [RequireJS Shim for AngularJS 1.3.0](https://gist.github.com/beginor/e57e596be4040c404044)

有了上面的配置之后， 在文件的结尾添加下面的测试：

```js
require(['angular','angular-route'], function(angular){
    console.info(angular.version);
});
```

这样页面加载完之后会在浏览器的 Javascript 的控制台有如下输出：

```js
{full: "1.3.0", major: 1, minor: 3, dot: 0, codeName: "superluminal-nudge"}
```

AngularJS 貌似加载成功了， 写一个简单的 app.js 来验证一下， app.js 自然要遵循 AMD 规范， 和原生的 AngularJS App 稍微有些不同， 文件内容如下：

```js
// 将 app 定义成一个 AMD 模块， 依赖于 angular ， 这样 RequireJS
// 加载 app 时会自动加载 angular 。
define('app', ['angular'], function(angular) {
    // 使用严格模式
    'use strict';
    // 定义 angular 模块
    var app = angular.module('app', []);
    // 定义 DemoController ， 只定义一个属性 greeting 给界面绑定。
    app.controller('DemoController', ['$scope', function($scope) {
        $scope.greeting = 'Hello, world!';
    }]);
    return app;
});
```

将 main.js 文件中的测试代码改成下面这个样子：

```js
require(['app'], function(app){
    // do nothing.
});

```

再写一个简单的 HTML 视图页面， 内容如下：

<script src="https://gist.github.com/beginor/bf9e9e69b6a1f6fe0226.js"></script>

运行如下图所示：

![requirejs-angularjs-hello.png](/assets/post-images/requirejs-angularjs-hello.png)

[1]: https://angularjs.org/
[2]: https://github.com/amdjs/amdjs-api/wiki/AMD
[3]: http://requirejs.org/