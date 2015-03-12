---
layout: post
title: AngularJS 中的 factory、 service 和 provider
description: 详细介绍 AngularJS 的 factory、 service 和 provider 的区别
tags: [AngularJS]
keywords: angularjs, factory, service, provider
---

初学 AngularJS 时， 肯定会对其提供 factory 、 service 和 provider 感到疑惑， 这三种都是提供服务的方式， 他们到底有什么区别呢？

## factory

factory 可以认为是设计模式中的工厂方法， 就是你提供一个方法， 该方法返回一个对象的实例， 对于 AngularJS 的 factory 来说， 就是先定义一个对象， 给这个对象添加属性和方法， 然后返回这个对象， 例如：

```javascript
var app = angular.module('MyApp', []);

app.factory('MyFactory', function() {
    // define result object of factory.
    var result = {};
    // add some property and method to the object
    result.greeting = 'Hello from factory.';
    // return the object;
    return result;
});
```

最后 controller 拿到的就是 `result` 对象， 相当于下面的代码：

```javascript
var factoryResult = MyFactory();
```

所谓的 factory 就是这么简单。

## service

service 通过 `new` 运算符进行实例化， 可以认为是一个类型， 只要把属性和方法添加到 `this` 对象上即可， 不用显式返回什么对象， 比如下面的代码：

```javascript
app.service('MyService', function() {
    this.greeting = 'Hello from service';
});
```

controller 拿到的对象就是上面代码中 `this` 指向的对象， 相当于下面的代码：

```javascript
var serviceObj = new MyService();
```

## provider

与 factory 和 service 稍有不同的是， provider 必须提供一个 `$get` 方法， `$get` 方法和 factory 要求是一致的， 即： 先定义一个对象， 给这个对象添加属性和方法， 然后返回这个对象， 例如：  

```javascript
app.provider('MyProvider', function() {
    
    this.$get = function() {
        var result = {};
        result.greeting = 'Hello from provider';
        return result;
    }
})
```

最后 controller 拿到的对象就是 provider 的 `$get` 方法返回的对象， 相当于下面的代码：

```javascript
var instance = new MyProvider();
var provider = instance.$get();
```

## 使用 factory、 service 与 provider

factory、 service 与 provider 使用起来是一样的， 都是通过 AngularJS 的依赖注入使用， 比如：

```javascript
// inject factory, service and provider to a controller
app.controller('TestController', ['$scope', 'MyFactory', 'MyService', 'MyProvider', function($scope, myFactory, myService, myProvider) {
    $scope.greetingFromFactory = myFactory.greeting;
    $scope.greetingFromService = myService.greeting;
    $scope.greetingFromProvider = myProvider.greeting;
}]);
```

对应的 HTML 视图为：

```html
<body ng-controller="TestController">
    <p>greeting from factory:  {{greetingFromFactory}}</p>
    <p>greeting from service:  {{greetingFromService}}</p>
    <p>greeting from provider: {{greetingFromProvider}}</p>
</body>
```

## provider 可以在应用启动时进行配置

provider 的特殊之处就是可以在 module 启动时进行配置， 从而达到特殊的用途， 比如在上面的 provider 中可以添加一个 `setName` 方法， 可以在启动时调用这个方法， 进行一些额外的初始化工作：

```javascript
app.provider('MyProvider', function() {
    // default name is 'anonymous';
    var defaultName = 'anonymous';
    var name = defaultName;
    // setName can be called duaring module init
    this.setName = function(newName) {
        name = newName;
    }
    
    this.$get = function() {
        var result = {};
        result.greeting = 'Hello from provider';

        result.name = name;
        result.defaultName = defaultName;
        return result;
    }
})
```

添加了 `setName` 方法之后， 可以 module 启动时来调用这个方法， 实现对 provider 的配置

```javascript
app.config(function(MyProviderProvider) {
    MyProviderProvider.setName('Angularjs Provider');
});
```

在 controller 中添加显示 provider 的这些信息：

```javascript
app.controller('TestController', ['$scope', 'MyFactory', 'MyService', 'MyProvider', function($scope, myFactory, myService, myProvider) {
    $scope.greetingFromFactory = myFactory.greeting;
    $scope.greetingFromService = myService.greeting;
    $scope.greetingFromProvider = myProvider.greeting;
    
    $scope.defaultName = myProvider.defaultName;
    $scope.name = myProvider.name
}]);
```

对应的 HTML 视图也调整一下

```html
<body ng-controller="TestController">
    <p>greeting from factory:  {{greetingFromFactory}}</p>
    <p>greeting from service:  {{greetingFromService}}</p>
    <p>greeting from provider: {{greetingFromProvider}}</p>
    <p>defaultName: {{defaultName}}, config to: {{name}}</p>
</body>
```

最后程序运行截图如下：

![factory service provider](/assets/post-images/angularjs-factory-service-provider.png)