---
layout: post
title: Scss (Sass) 语法简介
keywords: sass, Scss, variables, nesting, partials, import, mixins, inheritance
description: Scss SASS 语法简介 变量、 嵌套、 混合、 导入
tags: [参考, 教程]
---

### 什么是 Scss

[Scss][4] 是 CSS 的扩展， 在保证兼容性的基础上， 允许使用变量、 嵌套、 混合、 导入等特性， 在编写大量的 CSS 文件时很有帮助。

### 特色

- 完全兼容 CSS3
- 在语法上扩展了变量、 嵌套以及混合等
- 操作颜色以及其它的有用的[函数][1]
- 高级特性， 比如针对类库的[控制声明][2]
- 格式良好并且可控制的输出
- [Firebug 集成][3]

### 基本语法

Scss 是 CSS3 的扩展， 在 CSS3 的基础上， 添加了下面几个重要的特性：

#### 变量

Scss 使用 `$` 符号来定义变量， 支持的变量类型有 `数字（可带单位）`、 `字符串` 、`颜色` 以及 `布尔值` 等， 示例如下：

```scss
$font-stack:    Helvetica, sans-serif;
$primary-color: #333;

body {
  font: 100% $font-stack;
  color: $primary-color;
}
```

输出的 CSS 代码为：

```css
body {
  font: 100% Helvetica, sans-serif;
  color: #333;
}
```

#### 嵌套

CSS 本身支持嵌套， 但是并不直观， Scss 提供了更加直观的嵌套语法：

```scss
nav {
  ul {
    margin: 0;
    padding: 0;
    list-style: none;
  }

  li { display: inline-block; }

  a {
    display: block;
    padding: 6px 12px;
    text-decoration: none;
  }
}
```

输出的 CSS 代码为：

```css
nav ul {
  margin: 0;
  padding: 0;
  list-style: none;
}

nav li {
  display: inline-block;
}

nav a {
  display: block;
  padding: 6px 12px;
  text-decoration: none;
}
```

#### 分部

以下划线开头的文件 (`_partial.Scss`) 不会被输出， 可以被导入到其它文件。

#### 导入

比如有这样的一个部分文件 (`_reset.Scss`)：

```scss
// _reset.Scss

html,
body,
ul,
ol {
   margin: 0;
  padding: 0;
}
```

在 `base.css` 文件中导入这个文件：

```scss
/* base.Scss */

@import 'reset';

body {
  font-size: 100% Helvetica, sans-serif;
  background-color: #efefef;
}
```

最后， 输出的 CSS 代码为：

```css
html, body, ul, ol {
  margin: 0;
  padding: 0;
}

body {
  background-color: #efefef;
  font-size: 100% Helvetica, sans-serif;
}
```

#### 混合

定义 `border-radius` ， 并将其添加到 `.box` 类：

```scss
@mixin border-radius($radius) {
  -webkit-border-radius: $radius;
     -moz-border-radius: $radius;
      -ms-border-radius: $radius;
          border-radius: $radius;
}

.box { @include border-radius(10px); }
```

输出的 CSS 代码为：

```css
.box {
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  -ms-border-radius: 10px;
  border-radius: 10px;
}
```

#### 继承

Scss 扩展了 CSS 的继承， 例如：

```scss
.message {
  border: 1px solid #ccc;
  padding: 10px;
  color: #333;
}

.success {
  @extend .message;
  border-color: green;
}

.error {
  @extend .message;
  border-color: red;
}

.warning {
  @extend .message;
  border-color: yellow;
}
```

输出的 CSS 代码为：

```css
.message, .success, .error, .warning {
  border: 1px solid #cccccc;
  padding: 10px;
  color: #333;
}

.success {
  border-color: green;
}

.error {
  border-color: red;
}

.warning {
  border-color: yellow;
}
```

#### 操作符

Scss 可以支持 `+` `-` `*` `/` 等常用的运算符号：

```scss
.container { width: 100%; }

article[role="main"] {
  float: left;
  width: 600px / 960px * 100%;
}

aside[role="complimentary"] {
  float: right;
  width: 300px / 960px * 100%;
}
```

输出的 CSS 代码为：

```css
.container {
  width: 100%;
}

article[role="main"] {
  float: left;
  width: 62.5%;
}

aside[role="complimentary"] {
  float: right;
  width: 31.25%;
}
```

以上只是基本的 Scss 语法， 想了解更多请参考 [Sass 官方网站][4] 。 

[1]: http://sass-lang.com/documentation/Sass/Script/Functions.html
[2]: http://sass-lang.com/documentation/file.SASS_REFERENCE.html#control_directives
[3]: https://addons.mozilla.org/en-US/firefox/addon/103988
[4]: http://sass-lang.com/