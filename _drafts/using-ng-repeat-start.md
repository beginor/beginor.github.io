---
layout: post
title: 使用 ng-repeat-start 进行自定义显示 
description: post description
keywords: angularjs, ng-repeat, ng-repeat-start, ng-repeat-end
tags: [AngularJS]
---

AngularJS 中

```js
angular.module('app', [])
.controller('MyController', MyController);

MyController.$inject = ['$scope'];
function MyController($scope) {
    // 要显示的产品列表；
    $scope.products = [
        {
            id: 1,
            name: 'Product 1',
            description: 'Product 1 description.'
        },
        {
            id: 2,
            name: 'Product 3',
            description: 'Product 2 description.'
        },
        {
            id: 3,
            name: 'Product 3',
            description: 'Product 3 description.'
        }
    ];
}
```

对应的 HTML 视图如下：

```xml
    <table class="table">
        <tr>
            <th>id</th>
            <th>name</th>
            <th>description</th>
            <th>action</th>
        </tr>
        <tr ng-repeat="p in products">
            <td>{{p.id}}</td>
            <td>{{p.name}}</td>
            <td>{{p.description}}</td>
            <td><a href="#">Buy</a></td>
        </tr>
    </table>
```

运行效果图：

![ng-repeat](/assets/post-images/ng-repeat-demo.png)

自定义显示：

```xml
    <table class="table table-bordered">
        <tr ng-repeat-start="p in products">
            <td>{{p.name}}</td>
            <td rowspan="2"><a href="#">Buy</a></td>
        </tr>
        <tr ng-repeat-end>
            <td>{{p.description}}</td>
        </tr>
    </table>
```

结果：

![ng-repeat-start](/assets/post-images/ng-repeat-start-demo.png)