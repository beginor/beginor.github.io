---
layout: post
title: AngularJS 中的 controllerAs
description: post description
keywords: 介绍 controllerAs 的用法及其利弊
tags: [AngularJS]
---

`Controller` 在 AngularJS 应用中可以说是无处不在， 可以在 html 中通过 `ngController` 指令来指定 `Controller` ， 语法为：

```xml
<ANY
    ng-controller="expression">
    ...
</ANY>
```

在 `ngRoute` 模块中使用， 语法为：

```javascript
$routeProvider
    .when('/my-url', {
        controller: 'MyController'
    });
```

在 `ui.route` 模块中使用， 语法为：

```javascript
$stateProvider
    .state('myState', {
        controller: 'MyController'
    })
```

上面用法在 AngularJS 的社区、示例程序中非常普遍。 但是， 有一个细节可能很多人没有注意到， 那就是 `controllerAs` ， 上面的三种用法还可以分别这样使用：

```xml
<ANY
    ng-controller="expression as myExpr">
    ...
</ANY>
```
```javascript
$routeProvider
    .when('/my-url', {
        controller: 'MyController',
        controllerAs: 'ctrl'
    });
```
```javascript
$stateProvider
    .state('myState', {
        controller: 'MyController',
        controllerAs: 'ctrl'
    })
```

那么， 使用了 `controllerAs` 有什么区别呢？ 在 AngularJS 的文档中是这样说的：

> - one binds methods and properties directly onto the controller using this: ng-controller="SettingsController1 as settings"
> - one injects $scope into the controller: ng-controller="SettingsController2"
 
上面的意思是说， 就是使用 `controllerAs` 将直接绑定 `Controller` 的属性和方法， 而不使用 `controllerAs` 将绑定到为 `Controller` 注入的 `$scope` 参数， 下面用一个具体的例子来说明一下：

不使用 `controllerAs` 指令时， 通常我们这样做：

```javascript
angular
    .module('app', []).
    controller('TestController', TestController);

TestController.$inject = ['$scope', '$window'];

function TestController($scope, $window) {
    $scope.name = 'beginor';
    
    $scope.greet = greet;
    
    function greet() {
        $window.alert('Hello, ' + $scope.name);
    }
}
```
```html
<div ng-Controller="TestController">
    <label>Name:
        <input type="text" ng-model="name" />
    </label>
    <button type="button" ng-click="greet()">
</div>
```

在 HTML 视图中， 我们绑定的是 `$scope` 对象的属性和方法， 而不是 `TestController` 的实例。

上面的例子在使用 `controllerAs` 时， 可以修改成这样：

```javascript
angular
    .module('app', []).
    controller('TestController', TestController);

TestController.$inject = ['$window'];

function TestController($window) {
    this.name = 'beginor';
    this.$window = $window;
}

TestController.prototype.greet = function () {
    this.$window.alert('Hello, ' + this.name);
}
```
```html
<div ng-Controller="TestController as vm">
    <label>Name:
        <input type="text" ng-model="vm.name" />
    </label>
    <button type="button" ng-click="vm.greet()">
</div>
```

看到区别了吧， 使用 `controllerAs` 时， 可以将 Controller 定义成 Javascript 的原型类， 在 HTML 视图中直接绑定原型类的属性和方法。

这样做的优点是：

- 可以使用 Javascript 的原型类， 我们可以使用更加高级的 ES6 或者 TypeScript 来编写 Controller ；
- 避开了所谓的 child scope 原型继承带来的一些问题， 具体可以[参考这里](https://github.com/angular/angular.js/wiki/Understanding-Scopes)；