---
layout: post
title: 为生产环境编译 Angular 2 应用
description: 本文介绍如何为生产环境编译编译 Angular 2 应用
keywords: angular2, production, treeshake, rollup, browserify, uglifyjs
tags: [Angular, TypeScript]
---

Angular 2 已经发布了 2.1.2 版本， 相信很多人已经在使用（试用）了， 相比 AngularJS 1.x ， Angular 2 在性能上有了长足的进步， 同时 Angular 2 也变得非常的庞大， 动辄几兆的脚本， 如何部署到生产环境？ 接下来就介绍如何为生产环境编译 Angular 2 应用， 在本文中， 我们将 Angular 2 官方文档中的 `Hello Angular` 应用编译到 50K 以下， 以用于生产环境。

## 未经优化的应用

根据 [Angular2][1] 官方的 [QuickStart][2] 快速创建一个 `Hello Angular` 应用， 在没有任何优化的情况下， 运行情况如下图所示：

![Hello, world](/assets/post-images/hello-world-ng2.jpg)

从上图可以看出， 仅仅一个 Hello 应用， 就产生了 40 个请求， 加载了 1.8M 的脚本， 这个在生产环境下（特别是移动端）是无法接受的。

要看这一步的完整源代码， 请移步 [GitHub][3] 。 

## 打包与压缩

传统的方式无非就是进行打包和压缩， 我使用 browserify 和 uglifyjs 来进行打包与压缩， 首先是安装这两个工具类库：

```sh
npm i -D browserify uglifyjs
```

在 package.json 文件中添加这两个 npm 命令：

```json
{
  "scripts": {
    "bundle": "browserify -s main app/main.js > dist/bundle.js",
    "minify": "uglifyjs dist/bundle.js --screw-ie8 --compress --mangle --output dist/bundle.min.js"
  }
}
```

现在运行这两个命令， 看看会怎么样：

```sh
npm run bundle && npm run minify
```

经过一大堆 WARN 之后， 没有出现 ERROR ， 也没有出现 npm-debug.log 文件， 证明没有错误， 现在来分析一下大小：

```sh
ls -hl dist
-rw-r--r--   1 zhang  staff   1.4M Nov 14 14:08 bundle.js
-rw-r--r--   1 zhang  staff   528K Nov 14 14:10 bundle.min.js
```

bundle.js 有 1.4M ， 不过 bundle.min.js 被压缩到了 528K ， 看起来还不错， 还可以再优化一下， 那就是 gzip 压缩， 通常在服务器上都会启用：

```sh
gzip dist/bundle.min.js -c > dist/bundle.min.js.gz && ls -hl dist
-rw-r--r--   1 zhang  staff   1.4M Nov 14 14:08 bundle.js
-rw-r--r--   1 zhang  staff   528K Nov 14 14:10 bundle.min.js
-rw-r--r--   1 zhang  staff   129K Nov 14 14:15 bundle.min.js.gz
```

经过 gzip 之后， bundle.min.js.gz 有 129K ， 似乎应该可以了吧？ 但是我觉得还有优化的空间。

要看这一步的完整源代码， 请移步 [GitHub][4] 。

## AOT 以及 Tree Shaking

ES2016 (ES6) 有一个很重要的特性， 那就是 Tree Shaking ， 可以移除项目中不需要的部分， 接下来我们使用 [rollup][5] 进行 Tree Shaking 。

为了能够使用 Tree Shaking ， 我们需要将项目中的 TypeScript 编译成 ES2015 脚本， 需要修改 TypeScript 配置， 新建一个 `tsconfig-es2015.json` 的配置文件， 内容如下：

```json
{
  "compilerOptions": {
    "target": "es2015",
    "module": "es2015",
    "moduleResolution": "node",
    "declaration": false,
    "removeComments": true,
    "noLib": false,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "lib": ["es6", "es2015", "dom"],
    "sourceMap": true,
    "pretty": true,
    "allowUnreachableCode": false,
    "allowUnusedLabels": false,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noImplicitUseStrict": false,
    "noFallthroughCasesInSwitch": true,
    "typeRoots": [
      "./node_modules/@types",
      "./node_modules"
    ],
    "types": [
    ]
  },
  "files": [
    "app/main-aot.ts"
  ]
}
```

在 Angular2 应用中， 包含了一个即时编辑器 (JIT) ， 在预编译好的应用中不是必需的， 使用 Angular2 的 AOT 编译可以移除即时编译器 (JIT) ， 因此需要先安装 Angular 的编译器：

```sh
npm i -D @angular/compiler-cli
```

为了使用 aot 编译出来的文件， main.ts 文件也要做相应的修改， 将 main.ts 文件另存为 `main-aot.ts` ， 修改内容如下：

```typescript
import { enableProdMode } from '@angular/core';
import { platformBrowser } from '@angular/platform-browser';
import { AppModuleNgFactory } from './app.module.ngfactory';
enableProdMode();
const platform = platformBrowser();
platform.bootstrapModuleFactory(AppModuleNgFactory);
```

不再使用 `platform-browser-dynamic` , 改为使用 `platform-browser` 。

同时 index.html 也另存为 `index-aot.html` ， 也做相应的修改， 不在加载 system.js ， 改为直接使用最终的 aot 脚本：

```html
<!--
<script src="node_modules/systemjs/dist/system.src.js"></script>
-->
<!-- 2. Configure SystemJS -->
<!--
<script src="systemjs.config.js"></script>
<script>
System.import('app').catch(function(err){ console.error(err); });
</script>
-->
</head>
<!-- 3. Display the application -->
<body>
<my-app>Loading...</my-app>
<script src="dist/bundle-aot.min.js"></script>
</body>
```

接下来的整体的思路是：

  1. 使用 ngc 进行 aot 编译；

     ```sh
     npm run ngc -- -p tsconfig-es2015.json
     ```

     这一步将会生成一系列 `*.ngfactory.ts` `*.module.metadata.json` 临时文件， 可以更新 `.gitignore` 来忽略这些文件， 避免对代码库造成污染；

  2. 将 typescript 文件编译成 es2015 (es6) 脚本；

     ```sh
     npm run tsc -- -p tsconfig-es2015.json
     ```

  3. 使用 rollup 进行 tree shaking ， 移除项目不使用的功能；

     ```sh
     rollup -f iife -c rollup.config.js -o dist/bundle-aot-es2015.js
     ```

  4. 再次使用 typescript 将 tree shaking 之后的脚本编译成 es5 脚本；

     ```sh
     tsc --target es5 --allowJs dist/bundle-aot-es2015.js -out dist/bundle-aot.js
     ```

  5. 使用 uglifyjs 再次压缩上一部生成的 es5 脚本；

     ```sh
     uglifyjs dist/bundle-aot.js --screw-ie8 --compress --mangle --output dist/bundle-aot.min.js
     ```

这几个命令对应的 npm 脚本如下：

```json
{
  "scripts": {
    "ngc": "ngc",
    "rollup": "rollup -f iife -c rollup.config.js -o dist/bundle-aot-es2015.js",
    "es5": "tsc --target es5 --allowJs dist/bundle-aot-es2015.js -out dist/bundle-aot.js",
    "minify-aot": "uglifyjs dist/bundle-aot.js --screw-ie8 --compress --mangle --output dist/bundle-aot.min.js",
    "prod-aot": "npm run ngc -- -p tsconfig-es2015.json && npm run tsc -- -p tsconfig-es2015.json && rollup && npm run es5 && npm run minify-aot"
  }
}
```

最终只要运行一个命令即可：

```sh
npm run prod-aot
```

最后来看一下最终的文件大小：

```sh
ls -hl
-rw-r--r--  1 zhang  staff   595K Nov 14 15:59 bundle-aot-es2015.js
-rw-r--r--  1 zhang  staff   669K Nov 14 16:01 bundle-aot.js
-rw-r--r--  1 zhang  staff   194K Nov 14 16:01 bundle-aot.min.js
-rw-r--r--  1 zhang  staff    46K Nov 14 16:02 bundle-aot.min.js.gz
-rw-r--r--  1 zhang  staff   1.4M Nov 14 15:54 bundle.js
-rw-r--r--  1 zhang  staff   528K Nov 14 15:54 bundle.min.js
-rw-r--r--  1 zhang  staff   129K Nov 14 16:02 bundle.min.js.gz
```

最终生成的 bundle-aot.min.js.gz 只有 46K ， 比没有使用 aot 编译的最终文件 bundle.min.js.gz 少了将近 2/3 ， 可以说 aot + tree shaking 效果非常的显著。

要看这一步的完整源代码， 请移步 [GitHub][6] 。

经过这样的终极编译优化编译之后， 应该可以放心的部署到生产环境了。

参考资料：

  - [Angular Quick Start][7]
  - [AoT Compilation][9]
  - [Building an Angular 2 Application for Production][8]

[1]:https://angular.io
[2]:https://angular.io/docs/ts/latest/quickstart.html
[3]:https://github.com/beginor/ng-app-aot-rollup-build/releases/tag/step1
[4]:https://github.com/beginor/ng-app-aot-rollup-build/releases/tag/step2
[5]:https://rollupjs.org/
[6]:https://github.com/beginor/ng-app-aot-rollup-build/releases/tag/step3
[7]:https://angular.io/docs/ts/latest/quickstart.html
[8]:https://blog.mgechev.com/2016/06/26/tree-shaking-angular2-production-build-rollup-javascript/
[9]:https://angular.io/docs/ts/latest/cookbook/aot-compiler.html
