---
layout: post
title: 按需加载 AngularJS 的 Controller
description: 本文提供 AngularJS 多视图应用的按需加载解决方案
tags: AngularJS
keywords: AngularJS, controller, load on demand, async loader , requirejs 
---

## 多视图应用

AngularJS 通过路由支持多视图应用， 可以根据路由动态加载所需的视图， 在 AngularJS 的文档中有[详细的介绍][1]，  网上也有不少教程， 就不用介绍了！

随着视图的不断增加， js文件 会越来越多， 而 AngularJS 默认需要把全部的 js 都一次性加载， 使用起来非常不便， 因此按需加载模块的需求会越来越强， 不过， AngularJS 并没有实现按需加载。

## 异步加载

关于异步加载， AngularJS 的[开发指南中有这样一段话][2]：

> Modules are a way of managing $injector configuration, and have nothing to do with loading of scripts into a VM. There are existing projects which deal with script loading, which may be used with Angular. Because modules do nothing at load time they can be loaded into the VM in any order and thus script loaders can take advantage of this property and parallelize the loading process.

这段话的大意是说 AngularJS 的模块只关注依赖注入，不关注脚本是怎么加载的。 目前已经有项目来处理脚本加载， 可以和 AngularJS 一起使用。  模块在加载的过程中什么都没做， 可以按照任意顺序加载， 因此脚本加载器可以使用这个特性进行并发加载。

AngularJS 在 `$routeProvider` 的[文档][3]中， `when` 方法的 `route` 参数有这样一个属性：

- resolve - `{Object.<string, function>=}` - An optional map of dependencies which should be injected into the controller. **If any of these dependencies are promises, the router will wait for them all to be resolved** or one to be rejected before the controller is instantiated. 

`route` 的 `resolve` 参数是一个可选依赖的 map 对象， 如果这个对象有成员是 promise 对象， 路由就会等待 promise 对象完成再初始化 controller 。

可以通过这一点， 来刻意创建一个 promise 对象加载需要的模块，  比如下面的代码：

```js
$routeProvider.when('/myView', {
    controller: 'MyController',
    templateUrl: '/views/myView.html',
    resolve: {
        deps: function($q, $rootScope) {
            var defered = $q.defer();
            require(dependencies, function() {
                $rootScope.$apply(function() {
                    defered.resolve();
                });
            });
            return defered.promise;
        }
    }
});
```

为此， 可以单独写一个 `loader.js`  来生成 promise 对象， 代码如下：

```js
define([], function() {
    return function(dependencies) {
        // 返回路由的 resolve 定义， 
        var definition = {
            // resolver 是一个函数， 返回一个 promise 对象；
            resolver: ['$q', '$rootScope', function($q, $rootScope) {
                // 创建一个延迟执行的 promise 对象
                var defered = $q.defer();
                // 使用 requirejs 的 require 方法加载的脚本
                require(dependencies, function() {
                    $rootScope.$apply(function() {
                        // 加载完脚本之后， 完成 promise 对象；
                        defered.resolve();
                    });
                });
                返回延迟执行的 promise 对象， route 会等待 promise 对象完成
                return defered.promise;
            }]
        };
        return definition;
    }
});
```

将应用的路由单独放在一个 `route.js` 文件中进行定义：

```js
define([], function () {
    return {
        defaultRoute: '/welcome',
        routes: {
            '/welcome': {
                templateUrl: 'components/welcome/welcomeView.html',
                controller: 'WelcomeController',
                dependencies: ['components/welcome/welcomeController']
            },
            '/dialogs': {
                templateUrl: 'components/dialogs/dialogsView.html',
                controller: 'DialogsController',
                dependencies: ['components/dialogs/dialogsController']
            },
            '/list': {
                templateUrl: 'components/list/listView.html',
                controller: 'ListController',
                dependencies: ['components/list/listController']
            },
            '/user': {
                templateUrl: 'components/user/userView.html',
                controller: 'UserController',
                dependencies: ['components/user/userController']
            },
            '/help': {
                templateUrl: 'components/help/helpView.html',
                controller: 'HelpController',
                dependencies: ['components/help/helpController']
            }
        }
    };
});
```

`$routeProvider` 根据上面的定义进行初始化：

```js
if (routeConfig.routes != undefined) {
    angular.forEach(routeConfig.routes, function(route, path) {
        $routeProvider.when(path, {
            templateUrl: route.templateUrl,
            controller: route.controller,
            // 设置每个路由的 resolve ， 使用 requirejs 加载 controller 脚本
            resolve: loader(route.dependencies)
        });
    });
}

if (routeConfig.defaultRoute != undefined) {
    $routeProvider.otherwise({ redirectTo: routeConfig.defaultRoute });
}
```

## 手工注册 Controller

对于动态加载下来的 Controller 需要手工注册， 这就需要调用 `$controllerProvider` 的 `register` 方法， 为了方便使用， 可以定义一个全局的 `app` 对象， 将 AngularJS 的注册 controller 、 directive 、 filter 、 factory 、 service 方法都暴露出来， 代码如下：

```js
define(['app.routes', 'app.loader', 'angular', 'angular-route'], function (config, loader) {
    'use strict';

    var app = angular.module('app', ['ngRoute', 'ngResource', 'ui.bootstrap']);
    app.config(configure);

    configure.$inject = ['$routeProvider', '$locationProvider', '$controllerProvider', '$compileProvider', '$filterProvider', '$provide'];

    return app;

    function configure($routeProvider, $locationProvider, $controllerProvider, $compileProvider, $filterProvider, $provide) {
        app.registerController = $controllerProvider.register;
        app.registerDirective = $compileProvider.directive;
        app.registerFilter = $filterProvider.register;
        app.registerFactory = $provide.factory;
        app.registerService = $provide.service;
    }
});
```

有了这个 `app` 之后， 要做动态加载的 controller 就可以这样写了：

```js
// 将 controller 定义为一个 AMD 模块， 依赖上面的 app
define(['app'], function(app) {
    'use strict';
    // 调用 app 暴露的 registerController 方法注册 controller
    app.registerController('HelpController', HelpController);
    // 定义 controller 的注入对象；
    HelpController.$inject = ['$scope'];
    // controller 具体实现
    function HelpController($scope) {
        $scope.greeting = 'Help Info';
    }
});
```

点击这里查看完整的例子 [https://github.com/beginor/html-app-demo/tree/master/www][4]

[1]: https://code.angularjs.org/1.3.2/docs/api/ngRoute/service/$route#example
[2]: https://docs.angularjs.org/guide/module
[3]: https://docs.angularjs.org/api/ngRoute/provider/$routeProvider
[4]: https://github.com/beginor/html-app-demo/tree/master/www