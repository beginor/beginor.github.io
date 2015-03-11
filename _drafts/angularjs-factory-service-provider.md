---
layout: post
title: AngularJS 中的 factory、 service 和 provider
description:
tags: [AngularJS]
keywords: angularjs, factory, service, provider
---

AngularJS 提供 factory 、 service 和 provider 来

```javascript
var app = angular.module('MyApp', []);

app.factory('MyFactory', function() {
    var result = {};
    
    result.greeting = 'Hello from factory.';
    
    return result;
});
```

```javascript
app.service('MyService', function() {
    this.greeting = 'Hello from service';
});
```

```javascript
app.provider('MyProvider', function() {
    
    this.$get = function() {
        var result = {};
        result.greeting = 'Hello from provider';
        return result;
    }
})
```

```javascript
app.controller('TestController', ['$scope', 'MyFactory', 'MyService', 'MyProvider', function($scope, myFactory, myService, myProvider) {
    $scope.greetingFromFactory = myFactory.greeting;
    $scope.greetingFromService = myService.greeting;
    $scope.greetingFromProvider = myProvider.greeting;
}]);
```

```html
<body ng-controller="TestController">
    <p>greeting from factory:  {{greetingFromFactory}}</p>
    <p>greeting from service:  {{greetingFromService}}</p>
    <p>greeting from provider: {{greetingFromProvider}}</p>
</body>
```

```javascript
app.provider('MyProvider', function() {
    
    var defaultName = 'anonymous';
    var name = defaultName;
    
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

```javascript
app.config(function(MyProviderProvider) {
    MyProviderProvider.setName('Angularjs Provider');
});
```

```javascript
app.controller('TestController', ['$scope', 'MyFactory', 'MyService', 'MyProvider', function($scope, myFactory, myService, myProvider) {
    $scope.greetingFromFactory = myFactory.greeting;
    $scope.greetingFromService = myService.greeting;
    $scope.greetingFromProvider = myProvider.greeting;
    
    $scope.defaultName = myProvider.defaultName;
    $scope.name = myProvider.name
}]);
```

```html
<body ng-controller="TestController">
    <p>greeting from factory:  {{greetingFromFactory}}</p>
    <p>greeting from service:  {{greetingFromService}}</p>
    <p>greeting from provider: {{greetingFromProvider}}</p>
    <p>defaultName: {{defaultName}}, config to: {{name}}</p>
</body>
```

![factory service provider](/assets/post-images/angularjs-factory-service-provider.png)