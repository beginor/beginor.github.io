---
layout: post2
title: React 入门 03 - Callback 和 Memo
description: 本文介绍 React 函数组件的 useCallback 和 useMemo reactjs, hooks, function component, usecallback, usememo
tags: [React, 教程]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

`useCallback` 和 `useMemo` 是 React 函数组件开发中非常重要的两个函数， 分别用于缓存方法和变量， 可以避免不必要的渲染， 提升性能。

## 为什么要缓存？

React 函数组件就是一个 TypeScript/JavaScript 函数，当组件状态变化时， React 会重新调用这个函数进行渲染， 如果不使用缓存的话， 会导致函数组件內定义的函数和变量都会被重新定义和初始化， 从而导致错误的更新和渲染。

比如下面的代码：

```tsx
import { useEffect, useState } from 'react';

export function MyComp() {
  
  const [data, setData] = useState('');
  // 注意： 每次都会重新定义 loadData 导致循环渲染；
  const loadData = () => {
    setData(Date.now().toString());
  };
  
  useEffect(() => {
    loadData();
  }, [loadData]);
  
  return (
    <div>{data}</div>
  );
}
```

这样的代码看起来非常的符合 React 的规范， 但是实际运行起来， 就会无限循环下去。 因为每次调用 `MyComp` 这个组件， 都会重新定义 `loadData` 这个函数， 从而导致循环更新。

而使用 `useCallback` 来缓存 `loadData` 方法， 就可以避免这种情况：

```tsx
import { useCallback, useEffect, useState } from 'react';

export function MyComp() {
  
  const [data, setData] = useState('');
  // 使用 `useCallback` 缓存 loadData ， 避免循环渲染；
  const loadData = useCallback(() => {
    setData(Date.now().toString());
  }, []);
  
  useEffect(() => {
    loadData();
  }, [loadData]);
  
  return (
    <div>{data}</div>
  );
}
```

## useCallback

`useCallback` 缓存的是函数定义， 即使在 React 函数组件在多次渲染时传入了新的函数， 只要依赖数组不变， 返回函数定义依然是旧的函数定义， 调用函数返回的函数， 依然会得到旧的结果。

`useCallback` 的 TypeScript 定义为：

```ts
function useCallback<T extends Function>(callback: T, deps: DependencyList): T;
```

> 如果 `useCallback` 的依赖数组项为空数组， 将会返回一个固定的函数， 那么就应该考虑将这个函数移至组件之外了。

## useMemo

`useMemo` 缓存的是的结果， 传入的计算函数不能有参数， 必须有返回值。 即使在 React 函数组件在多次渲染时传入了新的计算函数， 只要依赖数组不变， 返回的依然是旧的结果。

```ts
function useMemo<T>(factory: () => T, deps: DependencyList | undefined): T;
```

> 如果 `useMemo` 的依赖数组为空数组， 将返回一个不变的常量， 则和 `useRef` 似乎又有了一些类似。

## 两者的相同与不同之处

### 相同之处

- 两者都巧妙的运用了 JavaScript 的闭包特性；
- 两者都接受一个函数、和一个依赖数组作为参数；
- 两者的缓存机制相同， 都是根据依赖数组进行判断，是否返回新的结果；

### 不同之处

- `useCallback` 缓存的是函数本身， 而 `useMemo` 返回的则是函数的结果；
- 两者函数参数要求不同：
  - `useCallback` 的函数参数可以是有参数的函数， 而 `useMemo` 的函数参数则不能有参数；
  - `useCallback` 的函数参数对返回值不做要求， 而 `useMemo` 的函数参数则必须有返回值；
