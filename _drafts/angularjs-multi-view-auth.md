---
layout: post
title: AngularJS 多视图应用中的登录认证
description: 介绍在 AngularJS 多视图应用中实现登录认证
keywords: angularjs, authentication, $rootScope, $routeChangeStart
tags: [AngularJS]
---

在 AngularJS 的多视图应用中， 一般都有实现登录认证的需求， 最简单的解决方法是结合服务端认证， 做一个单独的登录页面， 登录完成之后再跳转回来， 这种方法当然可取， 不过就破坏了单页面应用 (SPA) 的体验， 追求完美的开发者肯定不会采用这种方法。

在 AngularJS 应用中， 都有一个唯一的变量 `$rootScope` 当切换视图时， `$rootScope` 会广播事件 `$routeChangeStart` ， 只要在这个事件的处理函数中检查下一个路由是否允许匿名访问， 如果不允许匿名访问并且没有用户信息的话， 则重定向到登录页面， 思路很简单， 具体实现代码如下：

```javascript
angular
// 声明应用程序模块
.module('app', ['ngRoute'])
// 注册 Controller 
.controller('HomeController', function ($scope) {})
.controller('LoginController', function ($scope) {})
/* 注册其它模块省略 */
// 配置路由
.config(function ($routeProvider) {
    $routeProvider
        .when('/home', {
            controller: 'HomeController',
            templateUrl: 'homeView.html',
            allowAnonymous: false
        })
        /* 其它路由配置省略 */
        .when('/login', {
            controller: 'LoginController',
            templateUrl: 'loginView.html',
            allowAnonymous: true
        })
        .otherwise({ redirectTo: '/home' });
})
// 应用启动时运行
.run(function ($location, $rootScope, $log, $route) {
    // $rootScope 的 $routeChangeStart 事件
    function onRouteChangeStart(event, next, current) {
        // 如果下一个路由不允许匿名， 并且没有认证， 则重定向到 login 页面
        if (!next.allowAnonymous && !$rootScope.currentUser) {
            $log.log('Authentication required, redirect to login.');
            var returnUrl = $location.url();
            $log.log('return url is ' + returnUrl);
            //
            event.preventDefault();
            $location.path('/login').search({ returnUrl: returnUrl });
        }
    }
    // 监听 $rootScope 的 $routeChangeStart 事件
    $rootScope.$on('$routeChangeStart', onRouteChangeStart);
});
```

这样， AngularJS 在开始切换视图时 (`$routeChangeStart`) 会调用 (`onRouteChangeStart`) 函数进行检查， 如果要切换的路由不允许匿名访问， 则会重定向到路由中定义的 `/login` 对应的视图。