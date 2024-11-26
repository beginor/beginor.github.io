---
layout: post2
title: 使用现代化的脚本进行 ArcGIS JS API 开发
description: 本文介绍如何使用现代化的脚本 (ES6+, TypeScript) 进行 ArcGIS JS API 开发
keywords: arcgis js api, modernization, es6, typescript
tags: [GIS, JavaScript, TypeScript]
---

ArcGIS JS API 基于古老的 JavaScript 框架 [Dojo](https://dojotoolkit.org/) 开发， dojo 虽然是曾经的王者， 但是2020年的前端开发， 早已是 Angular、 React 和 Vue 三大框架的天下， JavaScript 的新特性可以说是日新月异， 国内也几乎没有人基于 dojo 进行开发， 因此本文介绍如何使用现代化的脚本 (ES6, ES7, ES2018 等， 以下统称 ES6+, TypeScript) 进行 ArcGIS JS API 开发。

## ArcGIS JS API 模块化概述

- ArcGIS JS API 提供的基于 dojo 的模块是 [Asynchronous Module Definition (AMD)](https://en.wikipedia.org/wiki/Asynchronous_module_definition)， 是 ES5 时代的浏览器 JavaScript 模块化标准， 现在依然可以在浏览器中使用；
- ArcGIS JS API 提供 AMD 模块严重依赖 dojo 的加载器， 无法在 ES6 的环境中直接使用；
- dojo 的入侵性比较强， 很容易和其它的框架发生冲突；

由于以上几点原因， 导致 ArcGIS JS API 在前端开发中比较难使用新的 JavaScript 语法， 和当今前端开发三大框架门槛集成的难度比较大。

## esri-loader 简介

[esri-loader](https://github.com/esri/esri-loader) 是 ESRI 官方开源的加载器， 对 dojo 的加载器进行封装， 转换成 ES6 标准的 Promise 模式进行加载， 可以比较方便的在 ES6+ 的环境中使用。

`esri-loader` 使用 TypeScript 开发， 以 npm 包的形式发布。

### esri-loader 安装

- 如果安装了 nodejs 环境， `esri-loader` 可以通过 `npm` 包的形式安装， 只需要输入 `npm install esri-loader` 即可安装。
- 如果还没有安装 nodejs 环境， 也可以在页面中通过在通过 [upkg.com](https://unpkg.com) 来引入这个脚本， 示例代码如下：

  ```html
  <script src="https://unpkg.com/esri-loader@2.15.0/dist/umd/esri-loader.js"></script>
  ```

> 这里强烈推荐安装 nodejs 环境， 这个已经是前端开发的标准工具链了。

### 使用 esri-loader 加载 ArcGIS JS API

`esri-loader` 提供了 `loadScript` 函数， 来加载 arcgis-js-api 的初始化脚本， 这个函数的定义如下：

```ts
export interface ILoadScriptOptions {
  version?: string;
  url?: string;
  css?: string | boolean;
  dojoConfig?: { [propName: string]: any };
  insertCssBefore?: string;
}

export function loadScript(options: ILoadScriptOptions = {}): Promise<HTMLScriptElement>;
```

根据这个定义， 使用 esri-loader 加载 ArcGIS JS API 的代码如下：

- 如果是直接在页面引入 upkg.com 的脚本的， 代码如下：

  ```js
  var AGS_API = 'http://localhost/arcgis-js-api/library/4.16';

  esriLoader.loadScript({
    url: `${AGS_API}/init.js`,
    css: `${AGS_API}/esri/themes/light/main.css`
  })
  .then(() => {
    console.log('ArcGIS JS SDK loaded!')
  })
  .catch(() => {
      console.error('Failed to load ArcGIS JS SDK');
  });
  ```

- 如果是以 npm 包的形式引入的， 代码如下：

  ```js
  import { loadScript } from 'esri-loader';

  const AGS_API = 'http://localhost/arcgis-js-api/library/4.16';

  loadScript({
    url: `${AGS_API}/init.js`,
    css: `${AGS_API}/esri/themes/light/main.css`
  })
  .then(() => {
    console.log('ArcGIS JS SDK loaded!')
  })
  .catch(ex => {
    console.error('Failed to load ArcGIS JS SDK', ex);
  });
  ```

因为 `loadScript` 返回的是一个 ES6 标准的 Promise ， 可以使用 `async/await` 则更加简洁：

```js
import { loadScript } from 'esri-loader';

const AGS_API = 'http://localhost/arcgis-js-api/library/4.16';

async function loadArcGisJsSdk() {
  try {
    await loadScript({
      url: `${AGS_API}/init.js`,
      css: `${AGS_API}/esri/themes/light/main.css`
    });
    console.log('ArcGIS JS SDK loaded!')
  }
  catch (ex) {
    console.error('Failed to load ArcGIS JS SDK', ex);
  }
}
```

使用 `async/await` 结合 `try-catch` ， 可以避免大量无意义的回调函数， 让代码变得更加简洁。

### 加载 ArcGIS JS API 中提供的模块

要使用 ArcGIS JS API 中提供的模块， 根据 ArcGIS JS API 提供的文档， 需要使用 `dojo` 提供的 `require` 函数， 示例代码如下：

```js
require(['esri/Map', 'esri/views/SceneView'], function(Map, SceneView) {
  // init map and sceie view in callback
  var map = new Map({ basemap: 'satellite' });
  var mapView = new SceneView({
    map: map,
    container: 'viewDiv',
    extent: { /* ... */ }
  });
})
```

如果使用 `esri-loader` ， 则完成同样的功能， 需要的代码如下：

```js
const [Map, SceneView] = await esriLoader.loadModules(['esri/Map', 'esri/views/SceneView']);
const map = new Map({ basemap: 'satellite' });
const mapView = new SceneView({
  map: map,
  container: 'viewDiv',
  extent: { /* ... */ }
});
```

`loadModules` 对 `require` 函数进行了二次封装， 返回 ES 标准的 Promise ， 可以方便的在更加高级的 JavaScript 环境中使用， 同时也尽可能的避免了 dojo 框架的入侵性。

## 使用 ES6+ 脚本进行 ArcGIS JS API 开发

如果目标浏览器不包括 IE11 的话， 则可以放心的使用 `async/await` 和 `import` 等这些 JavaScript 最新的功能， 现代化的浏览器都支持这些功能。

- `async` 方法的浏览器支持情况 <https://caniuse.com/#feat=async-functions>
- `import` 语句的浏览器支持情况 <https://caniuse.com/#feat=mdn-javascript_statements_import>

![can-i-use-await](/assets/post-images/can-i-use-await.png)

以 ESRI 官方 ArcGIS JS SDK 中的示例 [Intro to FeatureLayer](https://developers.arcgis.com/javascript/latest/sample-code/layers-featurelayer/index.html) 为例， 使用 ES6+ 和 esri-loader 实现同样的功能， 代码如下：

```js
export class MapApp {

  async loadScript() {
    const AGS_SDK = 'http://localhost/arcgis-js-api/library/4.16';
    await esriLoader.loadScript({
      url: `${AGS_SDK}/init.js`,
      css: `${AGS_SDK}/esri/themes/light/main.css`
    });
  }

  async initMap(container) {
    const [Map, MapView] = await esriLoader.loadModules(['esri/Map', 'esri/views/MapView']);
    const map = new Map({ basemap: 'satellite' });
    this.mapView = new MapView({
      map, container,
      extent: {
        // autocasts as new Extent()
        xmin: -9177811,
        ymin: 4247000,
        xmax: -9176791,
        ymax: 4247784,
        spatialReference: 102100
      }
    });
  }
  // add a feature layer to map
  async addFeatureLayer() {
    const [FeatureLayer] = await esriLoader.loadModules(['esri/layers/FeatureLayer']);
    const layer = new FeatureLayer({
      url: 'https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/Landscape_Trees/FeatureServer/0'
    });
    this.mapView.map.layers.add(layer);
  }

}
```

> 以上代码保存为 `es6.js`。

对应的 html 页面代码如下：

```html
<script src="https://unpkg.com/esri-loader@2.15.0/dist/umd/esri-loader.js"></script>
<script type="module">
import { MapApp } from './es6.js';

window.dojoConfig = {
  async: true,
  packages: [
    // { name: 'THREE', location: 'https://unpkg.com/three@0.117.1/build', main: 'three.min' },
  ]
};
window.esriConfig = { locale: 'zh-cn' };

window.addEventListener('load', async () => {
  const app = new MapApp();
  await app.loadScript();
  await app.initMap('viewDiv');
  await app.addFeatureLayer();
});
</script>
```

## 使用 TypeScript 进行 ArcGIS JS API 开发

### TypeScript 简介

TypeScript 是一种开源的编程语言， 该语言项目由微软进行维护和管理。 TypeScript 不仅包含 JavaScript 的语法， 而且还提供了静态类型检查以及使用看起来像基于类的面向对象编程语法操作 Prototype。 C# 的首席架构师以及 Delphi 和 Turbo Pascal 的创始人安德斯·海尔斯伯格参与了 TypeScript 的开发。

TypeScript 是为开发大型应用而设计的， 并且 TypeScript 可转译成JavaScript。 由于 TypeScript 是 JavaScript 的严格超集，任何现有的 JavaScript 程序都是合法的 TypeScript 程序。

TypeScript 支持为现存 JavaScript 库添加类型信息的定义文件， 方便其他程序像使用静态类型的值一样使用现有库中的值。 目前几乎所有流行的 JavaScript 类库如 jQuery、 MongoDB、 Node.js 和 D3.js 等提供了 TypeScript 的类型定义文件。

> 以上是维基百科中对 [TypeScript](https://zh.wikipedia.org/wiki/TypeScript) 的描述， 简单说就是 TypeScript 为 JavaScript 增加了类型系统， 带来更好的开发体验 （语法检查、 智能提示等）， 并且现在已经非常的流行。

### ArcGIS JS API 对 TypeScript 的支持情况

ArcGIS JS API 非常庞大， 可以说是一个巨无霸的 JavaScript 类库， 包括的提供了大量的模块，每个模块都提供了很多方法和属性， 需要随时翻阅 sdk 文档， 查找某个属性名称或者方法的参数列表， 这样的效率确实不高。

根据 ArcGIS JS API 的[发行说明](https://developers.arcgis.com/javascript/latest/guide/4.13/index.html)中的描述， 大约有 96% 的代码直接使用 TypeScript 进行开发， 提供了完整的 TypeScript 类型定义 [@types/arcgis-js-api](https://www.npmjs.com/package/@types/arcgis-js-api) ， 所以说 ArcGIS JS API 对 TypeScript 的支持也是非常好的。

使用 TypeScript 进行开发， 充分利用 TypeScript 的静态类型系统， 实现下面的功能：

- 严格的静态类型与拼写检查；

  ![严格的静态类型与拼写检查](/assets/post-images/Screen Shot 2020-08-30 at 15.50.28.png)

  ![严格的静态类型与拼写检查](/assets/post-images/Screen Shot 2020-08-30 at 15.51.27.png)

- 基于上下文的智能提示；

  ![基于上下文的智能提示；](/assets/post-images/Screen Shot 2020-08-30 at 15.52.24.png)

### 在线体验

[StackBlitz](https://stackblitz.com/) 提供了在线的 TypeScript 开发体验， 可以直接在浏览器中体验使用 TypeScript 开发而无需在自己的电脑上安装任何软件， 下面就是就是本文的使用 TypeScript 进行 ArcGIS JS API 开发例子， 可以直接在下面的浏览器窗格 (Frame) 中进行修改。

<iframe src="https://stackblitz.com/edit/esri-demo?embed=1&file=map-app.ts&hideNavigation=1&theme=light&view=editor" frameborder="1" style="width: 100%; height: 480px;"></iframe>

### 本地环境搭建

上面 StackBlitz 上的例子只是示例而已， 要想完整的体验使用 TypeScript 进行 ArcGIS JS API 开发， 最好还是搭建本地开发环境， 需要安装的工具有：

- [Node.js](https://nodejs.org/) 这个上面已经提到了， 前端开发的标准工具了， 可以内置了 npm 命令， 主要用于下载各种 npm 包；
- [VS Code](https://code.visualstudio.com/) 微软推出的开源编辑器， 对 TypeScript 提供最佳的支持；

这两款工具都支持跨平台， 根据自己的操作系统进行安装即可。 要注意的是如果是 Windows 系统， 一定要选择将 Node.js 添加到环境变量， 否则会出现找不到 npm 命令的错误提示。 关于这两款工具的安装， 网上已经有很多教程， 本文就不再多说。

为了简化配置， 可以直接用 git 克隆我配置好的模板项目 [esri-ts-demo](https://github.com/beginor/esri-ts-demo.git) ， 如果没有安装 git 也可以直接下载 [esri-ts-demo.zip](https://github.com/beginor/esri-ts-demo/archive/master.zip) 。


这个模版项目配置了已经配置好了使用 TypeScript 进行开发所需的环境， 用 VS Code 打开之后， 在集成的终端窗口中输入命令：

```sh
npm install
```

等依赖项安装完成之后， 再输入命令：

```sh
npm start
```

然后， 打开浏览器， 访问 `http://localhost:3000/index.html` 就可以看到地图页面， 如下图所示：

![ArcGIS JS Demo with TypeScript](/assets/post-images/esri-ts-demo.png)

如果需要分发开发完成的成果， 只需要执行：

```sh
npm run build
```

然后将 `dist` 目录打包分发即可。
