---
layout: post2
title: 使用 Rollup 打包 Angular 应用
description: 本文介绍如何使用 Rollup 打包 Angular 应用
keywords: angular, angular-cli, ngcc, ngc, ivy, rollup, typescript
tags: [Angular, Rollup, 前端]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## Rollup 简介

<img src="/assets/post-images/20211015172901.png" alt="rollup.js" style="zoom: 25%;" />

[Rollup](https://rollupjs.org/) 是一个 JavaScript 模块打包器， 可以将小块代码编译成大块复杂的代码， 例如类库或应用程序。 Rollup 使用 JavaScript 标准的 ES6 模块， 而不是以前的 CommonJS 或者 AMD 模块。 和 Webpack 相比， Rollup 一个显著的优势是可以输出 ES6 模块，非常的简洁， 现代化的浏览器都可以直接加载， 跨项目重用也非常的方便。 而 Webpack 的输出则必须的依赖晦涩的 Webpack 运行时， 同时也很难跨项目重用。

Rollup 也是非常的流行， npm 上 大部分 JavaScript 类库都在使用它进行打包。 但是使用 Rollup 打包应用的似乎不太多，因此本文就介绍一下如何使用 Rollup 来打包一个典型的 Angular 应用。

## 创建 Angular 应用

要创建 Angular 应用，首选还是 angular-cli ， 因为 Angular 应用和 React/Vue 比起来还是稍微复杂一些， 打开终端， 输入下面的命令：

```sh
npx @angular/cli@latest new rollup-angular --skip-git --minimal \
  --style scss --routing true --skip-tests true
```

等待命令安装完成之后， 再输入 `npx ng serve --configuration development` ， 打开浏览器访问 <http://localhost:4200> ， 可以看到如下的界面：

<img src="/assets/post-images/image-20211016115154405.png" alt="image-20211016115154405" style="zoom: 33%;" />

现在 Angular 应用就创建好了， 接下来就是进行一些预处理， 以便使用 Rollup 来对它进行打包。

## 预处理 Angular 应用

- 使用 ivy 视图引擎预处理全部的 Angular 类库

  在终端中输入命令 `npx ngcc` ， 这个命令会查找位于 `node_modules` 目录下的所有 Angular 相关的类库并使用 ivy 视图引擎进行预处理， 可以看到类似下面的输出：

  ```bash
  Compiling @angular/core : fesm2015 as esm2015
  Compiling @angular/animations : fesm2015 as esm2015
  Compiling @angular/compiler/testing : fesm2015 as esm2015
  Compiling @angular/animations : esm2015 as esm2015
  Compiling @angular/animations : main as umd
  Compiling @angular/compiler/testing : esm2015 as esm2015
  Compiling @angular/compiler/testing : main as umd
  Compiling @angular/animations/browser : fesm2015 as esm2015
  ```

- 在 Angular 应用中强制使用 ivy 视图引擎

  打开 `src/main.ts` 做如下修改：

  ```diff
  - import { enableProdMode } from '@angular/core';
  + import { enableProdMode, ɵNgModuleFactory as NgModuleFactory } from '@angular/core';
  - import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
  + import { platformBrowser } from '@angular/platform-browser';
  
  import { AppModule } from './app/app.module';
  import { environment } from './environments/environment';
  
  if (environment.production) {
    enableProdMode();
  }
  
  - platformBrowserDynamic().bootstrapModule(AppModule)
  + platformBrowser().bootstrapModuleFactory(new NgModuleFactory(AppModule))
    .catch(err => console.error(err));
  
  ```

  > 注意 `ɵNgModuleFactory` 只有在 ngcc 命令处理过之后才会出现。

## 使用 ngc 编译 Angular 应用

Angular 应用虽然是使用 TypeScript 进行编写， 但是却不能直接使用 TypeScript 的 tsc 命令进行编译， 而必需使用 angular-cli 的 ngc 命令进行编译， 使用 ngc 编译的命令参数和 tsc 基本一致：

```shell
npx ngc -p tsconfig.app.json
```

输出结果在 `out-tsc` 目录下， 入口文件有两个， 分别是 `out-tsc/app/main.js` 和 `out-tsc/app/polyfills.js` , 接下来就可以使用 Rollup 进行打包了。

> 如果当前工作区有多个 angular 项目的话， 可以修改对应的 tsconfig.app.json 文件， 自定义 ngc 的输出结果。

## Angular 类库项目的编译

如果工作区中存在 Angular 类库项目， 则可以直接使用 angular-cli 的 ng 命令进行编译， 命令如下：

```sh
npx ng build app-shared --configuration=development
```

注意的是，一定要指定 `--configuration=development` 才能得到完整兼容 Ivy 视图引擎的输出， 如果不指定则默认的配置是 `production`，无法得到完整兼容 Ivy 视图引擎的输出 。

## 安装 Rollup 及配套插件

要用 Rollup 来打包上面的 Angular 应用， 需要安装 Rollup 以及对应的插件，说明如下：

- `rollup` 这个是 rollup 本尊， 自然不必多说； 
- `@rollup/plugin-alias` 如果项目中用到了 Angular 类库项目， 可以用 alias 来指定别名；
- `@rollup/plugin-commonjs` 使用到的第三方类库有可能是 commonjs 模块化的， 这个插件可以讲 commonjs 模块转换为 ES6 模块；
- `@rollup/plugin-node-resolve` 这个插件负责从 `node_modules` 目录中查找模块；
- `rollup-plugin-scss` 以及 `sass` 因为用到了 scss 作为样式， 所以需要这个插件来处理 scss 样式；
- `rollup-plugin-esbuild` 以及 `esbuild` ， 负责发布时的压缩/混淆。

为了不打乱 package.json 文件中依赖项的顺序， 先编辑 package.json 文件， 讲下面的内容添加到 `devDependencies` 的尾部

```diff
{
  "devDependencies": {
    "@angular-devkit/build-angular": "~12.2.10",
    "@angular/cli": "~12.2.10",
    "@angular/compiler-cli": "~12.2.0",
    "@types/node": "^12.11.1",
    "ng-packagr": "^12.1.1",
    "typescript": "~4.3.5",
+    "rollup": "^2.58.0",
+    "@rollup/plugin-alias": "^3.1.5",
+    "@rollup/plugin-commonjs": "^21.0.0",
+    "@rollup/plugin-node-resolve": "^13.0.5",
+    "@rollup/plugin-replace": "^3.0.0",
+    "@rollup/plugin-typescript": "^8.2.5",
+    "rollup-plugin-scss": "^3.0.0",
+    "rollup-plugin-esbuild": "^4.5.0",
+    "sass": "^1.43.2",
+    "esbuild": "^0.13.6"
  }
}
```

保存 package.json 文件， 再在终端中执行 `npm -i` 并等待完成。

## 编写 Rollup 配置文件

接下来编写一个 rollup 的配置文件 `rollup.config.js`  

```js
import alias from '@rollup/plugin-alias';
import commonjs from '@rollup/plugin-commonjs';
import { nodeResolve } from '@rollup/plugin-node-resolve';
import scss from 'rollup-plugin-scss';
import esbuild from 'rollup-plugin-esbuild';

import path from 'path';

// `npm run build` -> `production` is true
// `npm run dev` -> `production` is false
const production = !process.env.ROLLUP_WATCH;

/** @type {import('rollup').RollupOptions} */
const rollupOptions = {
    input: [
        './out-tsc/app/main.js',
        './out-tsc/app/polyfills.js'
    ],
    output: {
        dir: path.resolve(__dirname, 'dist'),
        format: 'esm',
        // manualChunks: (id) => {},
        sourcemap: !production,
    },
    watch: { clearScreen: false },
    treeshake: production,
    plugins: [
        nodeResolve({}),
        esbuild({ legalComments: 'none', minify: production })
    ]
};

export default rollupOptions;
```

有了这个配置文件， 就可以使用 rollup 进行打包了， rollup 打包命令为

```sh
npx rollup -c rollup.config.js
```

执行完毕之后， 输出结果为 `dist/main.js` 和 `dist/polyfills.js` 。

## 使用 Rollup 的优缺点分析

先说一下使用 Rollup 进行打包的缺点， 主要有：

- 配置比较多，需要额外编写 rollup 的配置文件，没有 angular-cli 来的简单直接；
- 依赖 angular-cli 的 ngc 命令进行编译；
- Rollup 暂时不支持对 node_modules 目录下的类库进行 treeshake ， 输出的结果会稍微大一些；

但是， Rollup 的优势也是很明显的：

- 虽然配置比较多， 但是胜在可以灵活， 输出结果可控，比如可以将整个 Angular 输出为单个的 js 文件， 在和其它应用集成时会有很大的优势；
- 输出结果纯净，不像 webpack 那样夹带私货 (webpack runtime) ；

