---
layout: post2
title: Vite 多 SPA 应用插件
description: 本文描述如何为 Vite 创建一个多 SPA 应用插件， 同时伺服多 SPA 应用时进行正确的路由回落。
keywords: monorepo, workspace, pnpm, vite, multiple app, spa fallback plugin
tags: [前端, Vite]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

[Vite](https://vitejs.dev/) 是目前非常流行的前端的构建工具， 越来越多的项目开始使用 Vite 作为构建工具， 基于插件的扩展机制， 支持多种前端项目 (React、 Vue 等) 都构建， 甚至连 Angular 17+ 都开始采用 Vite 作为开发服务器。

Vite 对于单个前端项目的路由支持的非常好， 不用任何配置，就会自动回落 (Fallback) 到默认页面 `/index.html` ， 因此对于单个前端项目来说非常的友好。

但是， 如果前端项目中采用了工作区 (monorepo) ， 通常会有多个前端应用，这时 Vite 的支持就没那么好了。 以 pnpm 的工作区为例， 目录结构如下：

```
- root/
  - apps/
    - app1/
      - index.html
      - ...
    - app2/
      - index.html
      - ...
  - packages/
    - lib1/
    - lib2/
  - package.json
  - pnpm-workspace.yaml
  - vite.config.js
```

`app1` 和 `app2` 分别是两个独立的前端应用，分别有自己的路由， `app1/xxx` 应该回落到 `app1/index.html` ， `app2/yyy` 应该回落到 `app2/index.html` 。 `lib1` 和 `lib2` 分别是两个共享的类库项目。

Vite 支持这种情景下的构建， 根据 Vite 官方文档中的[多页面应用模式](https://cn.vitejs.dev/guide/build.html#multi-page-app)， 进行如下配置即可：

```js
// vite.config.js
import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        app1: resolve(__dirname, 'apps/app1/index.html'),
        app2: resolve(__dirname, 'apps/app2/index.html'),
      },
    },
  },
})
```

有了上面的配置， 执行 `vite build` 命令，就可以同时编译两个前端应用。

但是在开发时，Vite 却不能同时处理两个前端应用的路由，即将 `app1/xxx` 回落到 `app1/index.html` ， `app2/yyy` 回落到 `app2/index.html` 。 而且翻看 Vite 的文档， 也没有找到相关的配置项。

其实这个问题很容易处理， 只要给 vite 内置的开发服务器 (dev server) 添加一个中间件， 修改一下浏览器的请求的路径即可。 不过 Vite 不像 [browser-sync](https://browsersync.io/) 那样， 没有直接给开发服务器配置[中间件](https://browsersync.io/docs/options#option-middleware)的选项，只能通过插件 API 对内部的开发服务器进行[配置](https://cn.vitejs.dev/guide/api-plugin.html#configureserver)，来添加处理 http 请求的中间件， 那就只能开发一个简单的插件来实现了， 代码如下：

```js
// spafallback-plugin.js
import fs from 'fs';

// 使用正则表达式定义一些 fallback 规则， 将 apps/app1/ 下除了 assets 目录之外
// 的请求都回落到 apps/app1/index.html
const fallbackRules = [
  { pattern: '^/apps/app1/(?!assets/).*', fallback: '/apps/app1/index.html' },
  { pattern: '^/apps/app2/(?!assets/).*', fallback: '/apps/app2/index.html' },
];

/** 定义一个 spaFallback 插件并导出 */
export default function spaFallbackPlugin() {
  // Vite 默认的 public 目录
  let publicDir = 'public';
  // 用正则表达式定义一些不需要处理的路径规则， 包括
  // 其它插件的路径， 源代码路径， node_modules 目录下的文件等，
  // 这些 URL 不需要在这个中间件中进行处理。
  // 如果还有其它的插件， 则下面的表达式可能还需要进行相应的修改。
  const bypassRegex = /@vite|@react-refresh|\/src\/|\/node_modules\/|\.map$/;
  // 定义一个处理请求的中间件， API 形式和 browser-sync 的中间件一致， 
  // vite 使用了相同的库 [connect](https://github.com/senchalabs/connect)
  // 来处理 http 请求。
  function spaFallbackMiddleware(req, res, next) {
    const baseURL =  (req.protocol || 'http') + '://' + req.headers.host + '/';
    const uri = new URL(req.url,baseURL);
    const pathname = uri.pathname;
    // 如果是不需要处理的 URL 的话， 直接调用 next 并返回；
    if (fs.existsSync(__dirname + pathname)
        || fs.existsSync(publicDir + pathname)
        || bypassRegex.test(pathname)
    ) {
      next();
      return;
    }
    // 接下来就是根据上面定义的回落规则进行匹配， 如果请求的 URL 被某一条规则匹配到，
    // 修改当前请求的 URL 为对应的回落地址。
    for (const rule of fallbackRules) {
      const regex = new RegExp(rule.pattern);
      if (regex.test(req.url)) {
        let url = rule.fallback;
        if (uri.search) {
          url += uri.search;
        }
        // 向控制台输出一下修改的路径信息，便于调试
        console.debug(`${pathname} change to: ${url}`);
        req.url = url;
        break;
      }
    }
    next();
  }
  // 返回 vite 插件定义 
  return {
    name: 'spa-fallback',
    enforce: 'pre',
    apply: 'serve',
    configureServer: (server) => {
      // 为 dev server 添加中间件， 这一步非常重要。
      publicDir = server.config.publicDir;
      server.middlewares.use(spaFallbackMiddleware);
    }
  }
}
```

上面的代码不算很难， 而且注释也很全面，就不再解释了。 接下来就是在 `vite.config.js` 中使用这个插件， 代码如下：

```js 
// vite.config.js
import { resolve } from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react';

// 导入上面定义的 spaFallback 插件
import spaFallback from './spafallback-plugin.js';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        app1: resolve(__dirname, 'apps/app1/index.html'),
        app2: resolve(__dirname, 'apps/app2/index.html'),
      },
    },
  },
  plugins: [
    spaFallback(), //  注意把 spaFallback 插件放在最前面
    react(),
  ]
})
```

现在 `vite serve` 应该就可以正确的处理多个前端项目的路由了！

最后，感觉 Vite 是把 esbuild 、 rollup 以及 browser-sync 这三个流行的工具整合到了一起，基本上做到了开箱可用， 确实节省了很多配置的工作，但是有些高级选项 (比如本文用到的 http 中间件配置) ，却不能直接进行配置， 只能通过插件 API 进行配置。
