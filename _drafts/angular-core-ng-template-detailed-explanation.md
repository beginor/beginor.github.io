---
layout: post2
title: Angular 模板 (ng-template) 详解
description: 本文详细介绍 Angular 模板 (ng-template) 的用法
keywords: angular, ng-template, ng-container, ngIf, ngFor, ngTemplateOutlet, TemplateRef
tags: [Angular, 前端]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## ng-template

`ng-template` 是 Angular 内置的元素 (Element) 之一， 通过 `ng-template` 元素， 可以定义默认不渲染的模板， 配合其它结构指令 `ngIf` `ngFor` 进行使用， 完全掌控模板内容显示的方式和时机。

接下来的示例代码都以 `TodoItem` 接口为例。

```ts
export interface TodoItem {
    id?: number;
    title?: string;
    completed?: boolean;
}
```

## ng-template 与 ngIf

`ng-template` 与 `ngIf` 一起使用， 是最常用的组合之一， 比如这样：

```html
<div class="todo-list" *ngIf="items?.length > 0; else emptyTpl;">...</div>

<ng-template #emptyTpl>
  Nothing ...
</ng-template>
```

`*ngIf` 是 Angular 的简写语法， 完整的写法如下所示：

```html
<ng-template [ngIf]="items?.length > 0" [ngIfElse]="emptyTpl">
  <div class="todo-list">...</div>
</ng-template>

<ng-template #emptyTpl>
  Nothing ...
</ng-template>
```

如果不喜欢隐式模板 (因为不可以重用) ， 还可以这样写：

```html
<ng-container *ngIf="items?.length > 0; then dataTpl; else loadingTpl;">
</ng-container>    

<ng-template #dataTpl>
  <div class="todo-list">...</div>
</ng-template>

<ng-template #loadingTpl>
  Loading ...
</ng-template>
```

> 这里为了避免创建额外的 div 元素， 使用了 `ng-container` ， 下面会进一步介绍。

## ng-template 与 ngFor

`ng-template` 与 `ngFor` 也是最常用的组合之一， 比如：

```html
<ol>
  <li *ngFor="let item of items; let i=index;">
    {{item.title}}
  </li>
</ol>
```

同样， `*ngFor` 也是 Angular 的简写语法， 完整的语法是这样的：

```html
<ol>
  <ng-template ngFor let-item [ngForOf]="items" let-i="index">
    <li>...</li>
  </ng-template>
</ol>
```

`ng-template` 也可以与 `ngIf` 以及 `ngFor` 两个指令一起使用：

```html
<div *ngIf="items?.length > 0; else emptyTpl;">
  <ol>
    <li *ngFor="let item of items; let i = index;">{{item.title}}</li>
  </ol>
</div>

<ng-template #emptyTpl>
  Nothing ...
</ng-template>
```

注意， `ngIf` 和 `ngFor` 不能出现在同一个元素上， 即不能这样写：

```html
<div *ngIf="items" *ngFor="let item of items">
  ...
</div>
```

## ng-template 与 ng-container

`ng-template` 还有一个好搭档， 那就是 `ng-container` 

## ng-template 上下文 (context)

## ng-template 与 TemplateRef
