---
layout: post
title: Angular2 初体验
description: Angular2 初体验， 介绍 Angular2 的开发环境， 以及使用 es5 和 ts 开发 Angular2 应用
keywords: Angular2, es5, typescript, npm
tags: [Angular]
---

Angular2 已经发布 beta9 ， 是时候折腾一下了。 Angular2 和 AngularJS 1.x 相比， 可以说是全新的框架， 除了名字有延续性之外， 能延续的真的不多。

## 准备开发环境

Angular2 通过 npm 发布， 因此推荐使用 node/npm 环境， 要开始使用 Angular2 ， 先准备一个目录 `learning-angular` ， 在这个目录中初始化项目： 

```sh
mkdir learning-angular
cd learning-angular
npm init
```

编辑生成的 `package.json` 文件， 添加 angular2 的 npm 包及其依赖项：

```json
{
    "angular2": "^2.0.0-beta.9",
    "es6-promise": "^3.0.2",
    "es6-shim": "^0.33.3",
    "reflect-metadata": "0.1.2",
    "rxjs": "5.0.0-beta.2",
    "zone.js": "0.5.15"
}
```

保存 `package.json` 文件， 在命令行中输入 `npm install` 下载这些包， 下载完成之后， 开发环境就准备好了。

```sh
npm install
```

## 使用 es5 开发 Angular2 应用

Angular2 是个客户端框架， 在浏览器中运行， 因此使用 Javascript (es5) 来做开发也是完全可行的。

首先在 HTML 页面中添加 Angular2 的 UMD 版本 js 文件的引用， 代码如下：

```html
<script src="node_modules/rxjs/bundles/Rx.umd.min.js"></script>
<script src="node_modules/es6-shim/es6-shim.min.js"></script>
<script src="node_modules/angular2/bundles/angular2-polyfills.min.js"></script>
<script src="node_modules/angular2/bundles/angular2-all.umd.min.js"></script>
```

> UMD 的全称是 Universal Module Definition， 符合 UMD 定义的 Javascript 模块可以在任意的 Javascript 环境中执行。

下面就是一个最简单的 Angular2 的组件示例， 代码如下：

```javascript
(function () {
    var myApp = ng.core.Component({
        template: '<h2>Hello, Angular 2</h2>' +
                  '<button (click)="doTest()">Click me.</button>',
        selector: 'my-app'
    })
    .Class({
        constructor: function () {

        },
        doTest: function () {
            alert('You have clicked a button');
        }
    });
    //ng.core.enableProdMode();
    ng.platform.browser.bootstrap(myApp);
})();
```

上面完整的 html 源代码请[在 github 上的项目中查看](https://github.com/beginor/learning-angular2/blob/master/ng2-es5.html)。

## 使用 TypeScript 开发 Angular2 应用

虽然完全能够使用 Javascript es5 来开发， 但是这并不是官方推荐的做法， 官方推荐的是 TypeScript ， 默认的教程也都是使用 TypeScript 的。

TypeScript 最终会被编译成 JavaScript 的模块 (commonjs/amd/system) ， 因此需要一个模块加载器， 官方使用的是 [SystemJS](https://github.com/systemjs/systemjs)， 因此我们要安装 SystemJS 模块：

```sh
npm install systemjs --save
```

还需要 TypeScript 编译器， gulp、 gulp-typescript 来实现 ts 文件的自动编译：

```sh
npm install typescript gulp gulp-typescript --save-dev
```

完整的 `package.json` 可以在[我的 github 项目中查看](https://github.com/beginor/learning-angular2/blob/master/package.json)。

安装完需要的包之后， 我们需要一个 TypeScript 的配置文件 `tsconfig.json` 来配置 TypeScript 的编译， 这个文件的代码如下：

```json
{
  "compilerOptions": {
    "target": "es5",
    "module": "system",
    "moduleResolution": "node",
    "sourceMap": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "removeComments": false,
    "noImplicitAny": false
  },
  "exclude": [
    "node_modules", ".idea"
  ]
}
```

现在， 在 HTML 页面中引入 Angular 的 SystemJS 模块版本， 代码如下：

```html
<script src="node_modules/systemjs/dist/system.js"></script>
<script src="node_modules/rxjs/bundles/Rx.min.js"></script>
<script src="node_modules/es6-shim/es6-shim.min.js"></script>
<script src="node_modules/angular2/bundles/angular2-polyfills.min.js"></script>
<script src="node_modules/angular2/bundles/angular2.dev.js"></script>
```

现在用 TypeScript 来重写上面 es5 版本的组件：

```typescript
import { Component } from 'angular2/core';
import { bootstrap } from 'angular2/platform/browser';

@Component({
    selector: 'my-app',
    template: `
        <h2>Hello, Angular2</h2>
        <button (click)="doTest()">Click me.</button>
    `
})
export class AppComponent {
    
    constructor() {
    }
    
    doTest() {
        alert('You have clicked a button');
    }

}

bootstrap(AppComponent);
```

最后， 我们使用 gulp 来实现 TypeScript 的自动编译， 添加文件 gulpfile.js ， 内容如下：

```javascript
var gulp = require('gulp'),
    tsc = require('gulp-typescript'),
    sourcemaps = require('gulp-sourcemaps');

gulp.task('ts:app', function () {
    var tsResult = gulp.src('app/**/*.ts')
        .pipe(sourcemaps.init())
        .pipe(tsc({
            "target": "es5",
            "module": "system",
            "moduleResolution": "node",
            "sourceMap": true,
            "emitDecoratorMetadata": true,
            "experimentalDecorators": true,
            "removeComments": false,
            "noImplicitAny": false
        }));
    return tsResult.js.pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('dist'));
});

gulp.task('dev', function () {
    gulp.watch('app/**/*.ts', function () {
       gulp.start('ts:app');
    });
});
```

打开命令窗口， 输入：

```sh
gulp dev
```

然后可以开始愉快的使用 TypeScript 编写 Angular2 应用了。