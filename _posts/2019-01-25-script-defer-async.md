---
layout: post2
title: Script 标记的 defer 和 async 属性说明
description: 介绍 Script 标记的 defer 和 async 属性， 高效加载 script 。
keywords: script, async, defer
tags: [参考]
---

Script 标记的 defer 和 async 属性可能会显著影响页面加载的性能， 总结说明一下。

## 没有标记 defer 或 async 时

浏览器立即停止 HTML 渲染，同步获取并执行脚本文件， 然后再继续渲染后续的 HTML 内容。

```html
<header>
  <script src="app.js"></script>
</header>
```

![没有标记 defer 或 async 时](/assets/post-images/without-defer-async-head.png)

<Blockquote>
block
</Blockquote>

## 标记 defer 时

异步获取脚本， 不会停止 HTML 渲染， 在 DOM 事件 domInteractive 之后， 开始执行脚本， 执行完成之后， 触发 domComplete 事件， 然后是 onLoad 事件。

```html
<header>
  <script defer src="app.js"></script>
</header>
```

> 除非特殊情况， 一般不采取这种做法。

![标记 defer 时](/assets/post-images/with-defer.png)

> 标记了 defer 的脚本在执行时会按照页面标记的顺序执行， 多数情况下时最佳选择。

## 标记 async 时

异步获取脚本， 之后如果 HTML 没有渲染完毕， 中断 HTML 渲染， 执行脚本， 然后继续渲染后续的 HTML 内容。

```html
<header>
  <script async src="app.js"></script>
</header>
```

![标记 async 时](/assets/post-images/with-async.png)

> 标记了 async 的脚本在执行时不会按照页面标记的顺序执行。

## 简单粗暴的做法

将 script 放在 body 的最尾部， 保证 HTML 渲染， 同步执行脚本。

```html
<body>
  <!-- 其它的 html 内容 -->
  <script src="app.js"></script>
</body>
```

![在 body 的最尾部](/assets/post-images/without-defer-async-body.png)

> 这种做法确实是简单粗暴， 也是最容易实现的， 所以一些自动化的工具链都采用这种做法。

## 最后

async 和 defer 都不能保证一定不会中断 HTML 渲染， 所以请确认你的脚本在 onLoad 事件之后才开始运行。
