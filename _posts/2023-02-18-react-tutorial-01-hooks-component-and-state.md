---
layout: post2
title: React 入门 01 - 函数组件和状态
description: React 入门第一篇， 函数组件与状态
keywords: reactjs, hooks, function component, state, useState, useCallback, useEffect
tags: [React, 教程]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

之前一直使用 [Angular](https://angular.io) 作为前端开发的基础框架， 虽然 Angular 一直是一个非常优秀的框架， 现在也是， 甚至未来也会是， 但是鉴于目前国内 (中国大陆) 的现状， 再掌握一个流行的前端框架是很有必要的， 在认真对比了 React 和 Vue 之后， 选择了 React 作为前端基础框架。

在我看来， React 的优势主要有：

- 生态好

  主流的 IDE ， 不管是 VSCode 及其衍生产品， 还是 JetBrains 家族的 IDE 及其衍生产品， 都内置 React 支持， 而 Angular 和 Vue 则都需要安装插件才行。TypeScript 的转译器 `tsc` 能直接处理 React 的 `tsx/jsx` 文件， 现在流行的前端 ES6 转译器 [esbuild](http://esbuild.github.io) 也能直接处理  `tsx/jsx` 文件， 虽然 React 官方使用的是 babel 作为转译器， 但是可以有更多的选择。

- 入门容易， 学习曲线平缓， 几乎没有上限

  React 的入门非常简单， 不需要像 Angular/Vue 那样去记忆模板语法和指令， 特别是有了 React Hooks 之后， 只需要熟悉几个函数就可以开始 React 开发了， 入门非常容易。 如果以后需要高级的功能， 就再学习几个函数， 就可以继续晋级。 最终的上限， 可能就是开发者的上限了。 这大概也是 React 的高级玩法非常多的原因吧。

- 贴近原生 JavaScript

  网上流传这种说法， 用 React 开发感觉是在用原生 JavaScript 开发。 我 React 用的不算多， 已经有这样的感觉。

当然， 上面只是我个人的一些粗浅的看法， 接下来就正式开始介绍本文的内容。

## 函数组件

函数组件其实一直存在于 React 中， 在 React 16.8 出现之后， 函数组件的功能到了增强， 提出了 Hooks 的概念。 一个函数函数组件就是一个函数：

```ts
import { createElement } from 'react';

export function Hello() {
  return createElement(
    'div',
    { className: 'card', children: 'Hello, world!' }
  );
}
```

函数组件可以有参数， 给上面的函数组件加上参数：

```ts
import { createElement } from 'react';

export function Hello(props: HelloProps) {
  return createElement(
    'div',
    { className: 'card', children: `Hello, ${props.message} !` }
  );
}

export interface HelloProps {
  message: string;
}
```

如果组件的界面比较复杂时， 调用 `createElement` 会显得非常复杂， 因此需要采用表达界面更加清晰的 `jsx/tsx` 格式。

```tsx
import { createElement } from 'react';

export function Hello(props: HelloProps) {
  return (
    <div className='card'>
      Hello, {props.message} !
    </div>
  )
}

export interface HelloProps {
  message: string;
}
```

## 状态

组件页面要和用户进行交互， 因此需要保持状态， 函数组件使用 `useState` 函数来保持状态， 以 React 官方的教程中的 `LikeButton` 为例：

```jsx
import { useState } from 'react';

export function LikeButton() {

    const [liked, setLiked] = useState(false);

    if (liked) {
        return 'You liked this.'
    }

    return (
      <button className='btn m-2' onClick={() => setLiked(true)}>
        Like
      </button>
    );
}
```

`useState` 返回一个数组， 数组的第一个元素是当前的状态， 第二个是是改变状态的函数， 调用这个函数时， 会改变状态值， 同时会触发函数组件重新渲染， 函数组件根据不同的状态返回相应的界面元素，然后 React 再根据返回元素和上次的差异进行渲染。

上面的 `setLiked` 其实有两种用法：

```ts
// 直接传入新的状态值
setLiked(false);

// 新的状态值依赖旧的状态值时，可以类似这样调用， prev 表示旧的状态
setLiked(prev => {
  return !prev;
});
```

> 在上面的例子中， 直接修改 `liked` 的值没有任何作用， 只有调用 `setLiked` 方法才会改变 `liked` 的指， 并出发函数组件的重新渲染， React 就是这种半自动更新的机制。

## 建议做法

- 使用函数组件时， 尽可能的拆分组件， 组件越小， 重用的可能性就越高， 因此当你觉得某个组件复杂时， 就要考虑进一步拆分组件了；
- 状态尽量使用 ts/js 的原子类型 (number, string, date ...)， 尽量不要使用复杂的自定义类型作为函数组件的状态， 如果需要使用复杂类型做状态时， 参考上一条。
