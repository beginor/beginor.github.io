---
layout: post
title: 使用 ng-repeat-start 进行自定义显示 
description: post description
keywords: angularjs, ng-repeat, ng-repeat-start, ng-repeat-end
tags: [AngularJS]
---

AngularJS 中使用 `ng-repeat` 显示列表数据应该都不陌生了， 用起来很简单， 也很方便， 比如要显示一个产品表格， Controller 的 Javascript 代码如下：

```js
angular.module('app', [])
.controller('MyController', MyController);

MyController.$inject = ['$scope'];
function MyController($scope) {
    // 要显示的产品列表数据；
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

对应的 HTML 视图代码如下：

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

可是如果全部页面都是每个产品占一行来显示， 未免太枯燥了， 比如用户希望这样子自定义显示：

![ng-repeat-start](/assets/post-images/ng-repeat-start-demo.png)

每个产品占表格的两行， 这样的效果用 `ng-repeat` 就没办法实现了。 不过 AngularJS 提供了 `ng-repeat-start` 和 `ng-repeat-end` 来实现上面的需求， `ng-repeat-start` 和 `ng-repeat-end` 的语法如下： 

```xml
    <header ng-repeat-start="item in items">
      Header {{ item }}
    </header>
    <div class="body">
      Body {{ item }}
    </div>
    <footer ng-repeat-end>
      Footer {{ item }}
    </footer>
```

假设提供了 `['A','B']` 两个产品， 则生成的 HTML 结果如下：

```html
    <header>
      Header A
    </header>
    <div class="body">
      Body A
    </div>
    <footer>
      Footer A
    </footer>
    <header>
      Header B
    </header>
    <div class="body">
      Body B
    </div>
    <footer>
      Footer B
    </footer>
```

了解了 `ng-repeat-start` 和 `ng-repeat-end` 的用法之后， 上面要求的界面就很容易实现了， 代码如下：

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

本文参考资料： [https://code.angularjs.org/1.3.15/docs/api/ng/directive/ngRepeat](https://code.angularjs.org/1.3.15/docs/api/ng/directive/ngRepeat)