---
layout: post
title: TypeScript 中的 export 和 import
description: 介绍 TypeScript 中的 export 和 import 及其用法
keywords: typescript, es6, export, import, module, file
tags: [TypeScript]
---

在 TypeScript 中， 经常要使用 `export` 和 `import` 两个关键字， 这两个关键字和 `es6` 中的语法是一致的， 因为 `TypeScript = es6 + type` ! 

> **注意：** 目前没有任何浏览器实现 `export` 和 `import` ，要在浏览器中执行， 必须借助 TypeScript 或者其它的转换器！

## export

`export` 语句用于从文件（或模块）中导出函数， 对象或者基础类型， 语法如下：

```typescript
export { name1, name2, …, nameN };
export { variable1 as name1, variable2 as name2, …, nameN };
export let name1, name2, …, nameN; // also var
export let name1 = …, name2 = …, …, nameN; // also var, const

export default expression;
export default function (…) { … } // also class, function*
export default function name1(…) { … } // also class, function*
export { name1 as default, … };

export * from …;
export { name1, name2, …, nameN } from …;
export { import1 as name1, import2 as name2, …, nameN } from …;
```

 **nameN** 表示要导出的标识符， 可以在另一个文件中通过 `import` 语句导入。
 
有两种类型的导出， 分别对应上面的语法：

- 命名的导出

  ```typescript
  export { myFunction } // 导出已经声明的函数
  export const foo = Math.sqrt(2) // 导出一个常量
  ```
  
  当需要导出多个值的时候， 命名的导出就非常有用了， 在导入时， 可以使用同样的名字来引用对应的值， 示例：
  
  ```typescript
  // mylib.ts
  export function cube(x: number): number {
      return x * x * x;
  }
  const foo: number = Math.PI * Math.sqrt(2);
  export { foo }
  ```
  
  在另一个文件 `main.ts` 中， 这样使用：
  
  ```typescript
  // main.ts
  import { cube, foo } from './mylib';
  console.log(cube(3)); // 27
  console.log(foo); // 4.555806215962888
  ```
  
- 默认的导出

  ```typescript
  export default function () {} // 导出默认的函数， 不使用花括号
  ```
  
  一个文件（模块）默认的导出只能有一个， 可以是类，函数， 对象等， 示例：
  
  ```typescript
  // mylib.ts
  export default function (x: number): number {
      return x * x * x;
  }
  ```
  
  在另一个文件 `main.ts` 中， 这样使用：
  
  ```typescript
  // main.ts
  import cube from './mylib';
  console.log(cute(3)); // 27
  ```

## import

`import` 与 `export` 对应， 用于导入其它文件（模块）导出的函数， 对象或者其他基础类型， 语法如下：

```typescript
import defaultMember from "module-name";
import * as name from "module-name";
import { member } from "module-name";
import { member as alias } from "module-name";
import { member1 , member2 } from "module-name";
import { member1 , member2 as alias2 , [...] } from "module-name";
import defaultMember, { member [ , [...] ] } from "module-name";
import defaultMember, * as name from "module-name";
import "module-name";
```

- **name** 用来接收导入的值的对象的名称；
- **member, memberN** 要导入的外部模块的导出名称；
- **defaultMember** 要导入的外部模块的默认导出的名称；
- **alias, aliasN** 要导入的外部模块的导出的别名；
- **module-name** 要导入的外部模块的名称， 通常是文件名；

`import` 常见的用法有：

- 导入整个模块的内容， 在当前作用域插入 `myModule` 变量， 包含 `my-module.ts` 文件中全部导出的绑定：

  ```typescript
  import * as myModule from 'my-module';
  ```

- 导入模块的某一个导出成员， 在当前作用域插入 `myMember` 变量：

  ```typescript
  import { myMember } from 'my-module';
  
- 导入模块的多个导出成员， 在当前作用域插入 `foo` 和 `bar` 变量：

  ```typescript
  import {foo, bar} from 'my-module';
  ```

- 导入模块的成员， 并使用一个更好用的名字：

  ```typescript
  import {reallyReallyLongModuleMemberName as shortName} from 'my-module';
  import {reallyReallyLongModuleMemberName as shortName, anotherLongModuleName as short} from 'my-module';
  ```

- 将整个模块座位附加功能导入， 但是不导入模块的额导出成员

  ```typescript
  import 'my-module';
  ```

- 导入模块的默认导出：

  ```typescript
  import myDefault from 'my-module';
  ```

- 导入模块的默认导出和命名导出：

  ```typescript
  import myDefault, * as myModule from 'my-module';
  // myModule used as a namespace
  ```
  
  或者
  
  ```typescript
  import myDefault, {foo, bar} from 'my-module';
  // specific, named imports
  ```