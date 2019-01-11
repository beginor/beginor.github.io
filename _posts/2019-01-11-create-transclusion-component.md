---
layout: post2
title: 在 Angular 应用中创建包含组件
description: 介绍如何在 Angular 应用中创建可包含其它组件的组件
keywords: angular, ng-content, transclusion, 
tags: [Angular]
---

## 理解组件包含

包含组件就是指可以包含其它组件的组件， 以 Bootstrap 的卡片 (Card) 为例， 它包含页眉 (header) 、 主体 (body) 和 页脚 (footer) ， 如下图所示：

![Card](/assets/post-images/bootstrap-card-component.png)

```html
<div class="card text-center">
  <div class="card-header">
    Featured
  </div>
  <div class="card-body">
    <h5 class="card-title">Special title treatment</h5>
    <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>
    <a href="#" class="btn btn-primary">Go somewhere</a>
  </div>
  <div class="card-footer text-muted">
    2 days ago
  </div>
</div>
```

那么问题来了， 如何用 angular 来实现这样的一个组件？

- 卡片的页眉和页脚只能显示文本；
- 卡片的主体能够显示任意内容， 也可以是其它组件；

这就是所谓的包含。

## 创建包含组件

在 angular 中， 所谓的包含就是在定义固定视图模板的同时， 通过 `<ng-content>` 标签来定义一个可以放动态内容的位置。 下面就来实现一个简单的卡片组件。

卡片组件的类定义为：

```ts
// card.component.ts
import { Component, Input, Output } from '@angular/core';

@Component({
  selector: 'app-card',
  templateUrl: 'card.component.html',
})
export class CardComponent {
  @Input() header: string = 'this is header';   
  @Input() footer: string = 'this is footer';
}
```

> `@Input` 是一个声明， 允许从父组件传入任意的文本。

卡片组件的的视图模板定义为：

```html
<!-- card.component.html -->
<div class="card">
  <div class="card-header">
    {{ header }}
  </div>
  <div class="card-body">
    <!-- single slot transclusion here -->
    <ng-content></ng-content>
  </div>
  <div class="card-footer">
    {{ footer }}
  </div>
</div>
```

为了能够在其它组件中使用， 需要在对应的 AppModule 中添加声明：

```ts
import { NgModule }      from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent }   from './app.component';
import { CardComponent } from './card.component'; // import card component

@NgModule({
  imports:      [ BrowserModule ],
  declarations: [ AppComponent, CardComponent ], // add in declaration
  bootstrap:    [ AppComponent ],
})
export class AppModule { }
```

> 如果使用了 `angular-cli` 来生成这个组件的话， 会自动在 AppModule 中添加声明。

## 使用卡片组件

在另外一个组件 `AppComponent` 中使用刚刚创建的卡片组件的话， 代码如下所示：

```html
<!-- app.component.html -->
<h1>Single slot transclusion</h1>
<app-card header="my header" footer="my footer">
  <!-- put your dynamic content here -->
  <div class="card-block">
    <h4 class="card-title">You can put any content here</h4>
    <p class="card-text">For example this line of text and</p>
    <a href="#" class="btn btn-primary">This button</a>
  </div>
  <!-- end dynamic content -->
<app-card>
```

当然， 可以使用 `[header]` 以及 `[footer]` 进行数据绑定。

## 选择符

`<ng-content>` 接受一个 `select` 属性， 允许定义选择符， 可以更加精确选择被包含的内容。 打开 `card.component.html` ， 做一些修改

```html
<!-- card.component.html -->
<div class="card">
  <div class="card-header">
    {{ header }}
  </div>
  <!-- add the select attribute to ng-content -->
  <ng-content select="[card-body]"></ng-content>
  <div class="card-footer">
    {{ footer }}
  </div>
</div>
```

注意， 添加了 `select="[card-body]"` ， 这意味着将被包涵的元素必须有 `card-body` 属性， 用法也需要响应的调整一下

```html
<!-- app.component.html -->
<h1>Single slot transclusion</h1>
<app-card header="my header" footer="my footer">
  <!-- put your dynamic content here -->
  <div class="card-block" card-body><!--  We add the card-body attribute here -->
    <h4 class="card-title">You can put any content here</h4>
    <p class="card-text">For example this line of text and</p>
    <a href="#" class="btn btn-primary">This button</a>
  </div>
  <!-- end dynamic content -->
<app-card>
```

> `<ng-content>` 的 `select` 属性接受标准的 css 选择符， 比如： `select="[card-type=body]"` ， `select=".card-body"` ， `select="card-body"` 等等。

## 包含多个位置

使用 `select` 属性， 可以在一个组件中定义多个包含位置。 现在继续修改卡片组件， 允许页眉和页脚包含动态内容。

```html
<!-- card.component.html -->
<div class="card">
  <div class="card-header">
    <!-- header slot here -->
    <ng-content select="[card-header]"></ng-content>
  </div>
  <!-- add the select attribute to ng-content -->
  <ng-content select="[card-body]"></ng-content>
  <div class="card-footer">
    <!-- footer slot here -->
    <ng-content select="[card-footer]"></ng-content>
  </div>
</div>
```

用法也相应的修改一下：

```html
<!-- app.component.html -->
<h1>Single slot transclusion</h1>
<app-card>
  <!-- header -->
  <span card-header>New <strong>header</strong></span>
  <!-- body -->
  <div class="card-block" card-body>
    <h4 class="card-title">You can put any content here</h4>
    <p class="card-text">For example this line of text and</p>
    <a href="#" class="btn btn-primary">This button</a>
  </div>
  <!-- footer -->
  <span card-footer>New <strong>footer</strong></span>
<app-card>
```

## 小结

使用包含组件， 可以将布局提取成组件， 动态指定加载的内容， 应该也是很常用的。 而至于选择符 (select)， 则建议使用属性， 这样可读性比较好， 也不会破坏 html 的结构。
