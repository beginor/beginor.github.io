---
layout: post2
title: React 入门 02 - Effect
description: 本文介绍 React 函数组件的 useEffect 以及 useLayoutEffect
keywords: reactjs, hooks, function component, useeffect, uselayouteffect
tags: [React, 教程]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

React 组件既然有状态， 就肯定需要根据状态的进行交互和同步， 在 React Hooks 使用 `useEffect` 和 `useLayoutEffect` 函数进行同步。

> 吐槽一点, Effect 虽然是被用作同步的， 但是 Effect 本身的字面意思和同步没有任何关系， 导致很多中文文档中都翻译成 `效应` ， `副作用` 之类的， 感觉有点儿不伦不类， 至少和同步不搭边。 这一点， React 官方也没有一个说法， 至今没有一个 `信达雅` 的中文翻译。

## useEffect

`useEffect` 的函数定义是这样的：

```ts
function useEffect(
  effect: () => (void | Destructor),
  deps?: ReadonlyArray<unknown>
): void;
```

我的理解是：

1. 第一个参数是一个无参数的同步函数， 这个函数可以返回一个清理的函数;
2. 第二个参数是依赖项数组， 依赖项可以是任意可变的变量、 函数等， 所以参数类型为 `unknown` ；
3. 当依赖项数组的内容发生变化时， React 会主动执行同步函数；
4. 如果同步函数返回了清理函数的话， React 会在执行同步函数之前，先执行清理函数；
5. 如果同步函数返回了清理函数， 当组件销毁的时， React 会执行清理函数；

常见用法有：

- `useEffect` 的依赖项为空数组， 相当于和函数组件的生命周期进行同步， 即当控件加载之后和销毁时执行同步；

  ```tsx
  useEffect(() => {
    // 当控件加载完成时执行
    function onClick() {
        console.log('click');
    }
    document.body.addEventListener('click', onClick);
    // 返回一个清理函数， 在控件销毁时执行
    return () => {
        document.body.removeEventListener('click', onClick);
    };
  }, []);
  ```

- `useEffect` 的依赖项不为空， 任意依赖项发生变化时， 会自动进行同步；

```tsx
useEffect(() => {
  // 当 state1 或者 state2 发生变化时， 会执行同步， 调用这个函数；
  console.log(`effect for {state1: ${state1},  state2: ${state2}}`);
  // 返回一个清理函数， 再次变化之前， 会调用这个清理函数；
  return () => {
    console.log(`cleanup for {state1: ${state1},  state2: ${state2}}`);
  };
}, [state1, state2]);
```

## useLayoutEffect

`useLayoutEffect` 是 `useEffect` 的另一个版本， 在浏览器重绘界面之前调用， 用法和 `useEffect` 一样， 但是会影响性能。

`useLayoutEffect` 典型的用法是在浏览器重绘之前测量布局。

```tsx
function Tooltip() {
  const ref = useRef(null);
  const [tooltipHeight, setTooltipHeight] = useState(0); // 现在不知道真正的高度

  useLayoutEffect(() => {
    const { height } = ref.current.getBoundingClientRect();
    setTooltipHeight(height); // 计算得到高度
  }, []);

  // ...使用计算得到的高度进行后面的渲染工作 ...
}
```

> 除非有必要， 请尽可能地使用 `useEffect` 。

## 建议做法

个人觉得， 一个 Effect 应当只做一件事情， 不要在一个 Effect 中做太多事情， 可以使用多个 Effect 。

不建议的用法：

```ts
useEffect(() => {
    doSomethingA();
    doSomethingB();
    doSomethingC();
}, [])；
```

建议的用法， 因为这样不仅更加清晰， 而且更加有利于在重构时提取控件。

```ts
useEffect(() => {
    doSomethingA();
}, [])；

useEffect(() => {
    doSomethingB();
}, [])；

useEffect(() => {
    doSomethingC();
}, [])；
```
