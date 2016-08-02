---
layout: post
title: Angular 2 版本的 UI Bootstrap 初体验
description: 介绍 Angular 2 版本 UI Bootstrap 的安装与使用
keywords: angular2, bootstrap, npm, gulp
tags: [Angular,教程]
---

最近 angular-ui 团队终于正式发布了基于 Angular 2 的 Bootstrap 界面库 [ng-bootstrap](https://ng-bootstrap.github.io) ， 工作中一直用 AngularJS 1.x 的 [UI Bootstrap](https://angular-ui.github.io/bootstrap/) ， 因此对这个 `ng-bootstrap` 也是很感兴趣， 第一时间进行试用。

## 准备 Angular 2 环境

`ng-bootstrap` 是基于 Angular 2 的， 因此需要先准备 Angular 2 的环境， 参考 Angular 2 的 [5 MIN QUICKSTART](https://angular.io/docs/ts/latest/quickstart.html) 配置好 Angular 2 的环境， 这一步已经有了详细的说明， 就不在啰嗦了。

## 使用 ng-bootstrap

ng-bootstrap 使用 bootstrap 4.0 alpha2 ， 因此需要先下载 bootstrap ， 推荐使用 npm 包的形式：

```sh
npm install bootstrap@4.0.0-alpha.2 --save
```

接着下载 ng-bootstrap ， 同样使用 npm 包的形式：

```sh
npm install @ng-bootstrap/ng-bootstrap --save
``` 

现在需要修改一下 `systemjs.config.js` 文件， 让 `SystemJS` 能够正确加载 `ng-bootstrap` :

```js
// map tells the System loader where to look for things
var map = {
  'app':                        'dist', // 'dist',
  '@angular':                   'node_modules/@angular',
  'angular2-in-memory-web-api': 'node_modules/angular2-in-memory-web-api',
  'rxjs':                       'node_modules/rxjs',
  // add ng-bootstrap location map 
  '@ng-bootstrap':              'node_modules/@ng-bootstrap'
};
// packages tells the System loader how to load when no filename and/or no extension
var packages = {
  'app': { main: 'main.js',  defaultExtension: 'js', format: 'amd' },
  'rxjs': { defaultExtension: 'js' },
  'angular2-in-memory-web-api': { main: 'index.js', defaultExtension: 'js' },
  // add ng-bootstrap package config
  '@ng-bootstrap/ng-bootstrap': { main: 'index.js', defaultExtension: 'js' }
};
```

index.html 文件也要修改一下， 把 bootstrap 的样式表关联进来：

```html
<link rel="stylesheet" href="node_modules/bootstrap/dist/css/bootstrap.css"/>
```



## 小结

实现 ng-bootstrap 的人还是原来做 angular-ui 的那些人， 可以说配方还是原来的配方， 但是这味道么就跟原来有很大的不同了， 呵呵。

不过总的来说， ng-bootstrap 的推出将会极大的推进 Angular 2 在实际项目中的应用， 而不只是停留在 demo 阶段， 因为 AngularJS 1.x 时期， 很多项目都是以 AngularJS + UI-Bootstrap 为基础的， 现在有了 Angular 2 的 ng-bootstrap ， 相信已经由很多人蠢蠢欲动了吧！