---
layout: post2
title: 使用 Vite 处理项目中的 glsl 文件
description: 介绍如何用 vite 正确处理项目中的 WebGL 相关的 glsl 文件
keywords: esbuild, loader, glsl, vite, plugin, webgl
tags: [前端, Vite]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

项目中有一些 WebGL 相关的着色器 (shader) 代码， 后缀名为 `.glsl` 。 目录文件结构为：

```txt
- src
- src/layers/particle-layer.ts
- src/layers/particle-layer.fragment.glsl
- src/layers/particle-layer.vertex.glsl
```

原来用 `esbuild` 进行转译和打包， 配置起来非常的容易， 直接使用内置的 `loader` 就可以处理， `esbuild` 的配置如下：

```js
export default {
  entryPoints: './src/main.ts',
  outdir: './dist',
  splitting: true,
  chunkNames: 'chunks/[name]-[hash]',
  tsconfig: './tsconfig.json',
  loader: {
    '.glsl': 'text'
  }
}
```

上面的配置就是告诉 esbuild 将 `glsl` 作为文本来加载， 在 ts 或 js 文件中可以直接 import 导入使用，代码如下：

```js
import vertex from './particle-layer.vertex.glsl'
import fragment from './particle-layer.fragment.glsl'
```

现在切换到 Vite 做转译和打包工具， 发现没有类似 esbuild 这样指定文件类型的处理方式。 虽然 Vite 有调用 esbuild ， 其配置文件也支持 [esbuild](https://vite.dev/config/shared-options.html#esbuild) 选项， 但是只是 esbuild 的 [transform](https://esbuild.github.io/api/#transform) 选项， 不是完整的 build 选项， 因此不能像 esbuild 那样简单指定 loader 来解决。

查看了 Vite 配置文件的 `resolve` 选项， 发现更多是关于路径方面的配置， 而不是文件内容相关的配置， 也无法解决这个问题。

也尝试了 Vite 配置文件的 [optimizeDeps.esbuildOptions](https://vite.dev/config/dep-optimization-options.html#optimizedeps-esbuildoptions) ， 虽然是完整的 esbuild 选项， 能够指定 loader ， 运行时会出错。

```js
export default {
  base: '',
  publicDir: 'public',
  server: {
    host: '127.0.0.1',
    port: 3000,
  },
  optimizeDeps: {
    esbuildOptions: {
      loader: {
        '.glsl': 'text'
      }
    }
  },
}
```

运行时错误信息如下：

```txt
vite v6.0.7 building for production...
✓ 38 modules transformed.
x Build failed in 530ms
error during build:
src/layers/particle-layer/particle-layer-vertex.glsl (1:8): Expected ';', '}' or <eof> (Note that you need plugins to import files that are not JavaScript)
file: ~/Developer/javascript//wind-demo/src/layers/particle-layer/particle-layer-vertex.glsl:1:8

1: #define SHADER_NAME particle-layer-vertex-shader
           ^
2: #ifdef GL_ES
3: precision highp float;
```

这看起来应该是直接把 `glsl` 文件的内容当作 js 了。

那看起来应该是不能通过配置来实现 esbuild 原来的功能， 只能写一个插件来解决吧， 好在插件比较简单， 很容易实现， 代码如下：

```js
function glslPlugin() {
  return {
    name: 'glsl-plugin',
    transform(code, id) {
      if (id.endsWith('.glsl')) {
        return {
          code: 'export default `' + code + '`;',
          map: null,
        };
      }
    },
  };
}
```

当然， 插件也可以写的更加复杂一些， 比如去除 glsl 文件中的空格/注视，甚至混淆等， 不过这些都可以后期再处理， 先能用再说。

最终的 Vite 配置文件如下：

```js
export default defineConfig({
  base: '',
  publicDir: 'public',
  server: {
    host: '127.0.0.1',
    port: 3000,
  },
  plugins: [
    glslPlugin()
  ],
  build: {
    target: 'esnext',
  }
});
```
