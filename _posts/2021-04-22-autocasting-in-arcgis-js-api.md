---
layout: post2
title: ArcGIS API for JavaScript 中的 Autocasting
description: 介绍如何使用 ArcGIS API for JavaScript 中的 Autocasting 并使用 esri-loader 进行扩展
keywords: arcgis js api, autocasting, esr-loader, loadModules
tags: [ArcGIS]
---

## Autocasting 简介

`Autocasting` 是 ArcGIS API for JavaScript 4.x 的一个新特性， 将 json 对象转换成对应的 ArcGIS API for JavaScript 类型实例， 而不需要导入对应的 js 模块。

在下面的示例代码中， 为 [FeatureLayer](https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-FeatureLayer.html) 创建一个 [SimpleRenderer](https://developers.arcgis.com/javascript/latest/api-reference/esri-renderers-SimpleRenderer.html) 需要导入 5 个模块：

```javascript
require([
  'esri/Color',
  'esri/symbols/SimpleLineSymbol',
  'esri/symbols/SimpleMarkerSymbol',
  'esri/renderers/SimpleRenderer',
  'esri/layers/FeatureLayer',
], function (
  Color, SimpleLineSymbol, SimpleMarkerSymbol, SimpleRenderer, FeatureLayer
) {

  const layer = new FeatureLayer({
    url: 'https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/WorldCities/FeatureServer/0',
    renderer: new SimpleRenderer({
      symbol: new SimpleMarkerSymbol({
        style: 'diamond',
        color: new Color([255, 128, 45]),
        outline: new SimpleLineSymbol({
          style: 'dash-dot',
          color: new Color([0, 0, 0])
        })
      })
    })
  });

});
```

使用 `Autocasting` ， 不必导入 `renderer` 和 `symbol` 相关模块， 只需要导入 `esri/layers/FeatureLayer` 模块即可：

```js
require([ "esri/layers/FeatureLayer" ], function (FeatureLayer) {

  const layer = new FeatureLayer({
    url: "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/WorldCities/FeatureServer/0",
    renderer: {                        // autocasts as new SimpleRenderer()
      type: "simple",
      symbol: {                        // autocasts as new SimpleMarkerSymbol()
        type: "simple-marker",
        style: "diamond",
        color: [ 255, 128, 45 ],       // autocasts as new Color()
        outline: {                     // autocasts as new SimpleLineSymbol()
          style: "dash-dot",
          color: [ 0, 0, 0 ]           // autocasts as new Color()
        }
      }
    }
  });

});
```

要知道一个类能否被自动转换， 得查看这个类在 ArcGIS API for JavaScript 中的对应类的文档， 如果一个属性能够进行自动转换， 就会出现 `Autocast` 标记。

比如 `FeatureLayer` 的 [renderer](https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-FeatureLayer.html#renderer) 就有 `autocast` 标记。

上面的两段代码是等价的， 很显然使用 `autocasting` 的代码更加简单， 只需写一个 json 对象， 而这个 json 对象和 ArcGIS API for JavaScript 对应类型的属性相同， ArcGIS API for JavaScript 会内部进行处理， 将这个 json 对象传递给对应类型的构造函数进行初始化。

当模块类型是已知的，或者是固定的， 则不需要指定 `type` 属性， 比如在下面代码中的 `SimpleMarkerSymbol` 的 [outline](https://developers.arcgis.com/javascript/latest/api-reference/esri-symbols-SimpleMarkerSymbol.html#outline) 属性， 这个属性是固定的， 只能是 `SimpleLineSymbol` 。

```js
const diamondSymbol = {
  type: "simple-marker",
  outline: {
    type: "simple-line", // Not needed, as type `simple-line` is implied
    style: "dash-dot",
    color: [ 255, 128, 45 ]
  }
};
```

当类型更加的宽泛时， 比如 `FeatureLayer` 的 `renderer` ， 就有多种实现， 必须指定 `type` 才能让 `Autocasting` 正常工作。

> ArcGIS API for JavaScript 官方文档中[所有的示例代码](https://developers.arcgis.com/javascript/latest/sample-code/) 都尽可能的使用了 Autocasting 。

## Autocasting 扩展

然而遗憾的是， ArcGIS API for JavaScript 只实现了部分属性的 Autocasting ， 并没有将 `Autocasting` 进行到底， 比如创建一个 `WebScene` 时， 还需要根据图层类型导入多个模块：

```js
require([
  'esri/WebScene',
  'esri/layers/TileLayer',
  'esri/layers/FeatureLayer',
  'esri/layers/VectorTileLayer'
], function(WebScene, TileLayer, FeatureLayer, VectorTileLayer) {
  var scene = new WebScene({
    basemap: 'streets',
    layers: [
      new TileLayer({ url: '' }),
      new VectorTileLayer({ url: '' }),
      new FeatureLayer({ url: '' })
    ]
  })
});
```

如果将 `Autocasting` 进行到底， 可以通过下面的 json 来创建一个 `WebScene` :

```jsonc
{
  "basemap": "streets",
  "ground": "world-elevation",
  "layers": [
    {
      "type": "tile", // For TileLayer the type is always "tile".
      "url": "https://services.arcgisonline.com/arcgis/rest/services/World_Terrain_Base/MapServer",
      "title": "World Terrain Base"
    },
    {
      "type": "vector-tile", // For VectorTileLayer the type is always "vector-tile".
      "url": "https://basemaps.arcgis.com/arcgis/rest/services/World_Basemap_v2/VectorTileServer",
      "style": { /* ... */ }
    },
    {
      "type": "feature", // For FeatureLayer the type is feature.
      "url": "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/WorldCities/FeatureServer/0",
      "renderer": {
        "type": "simple",
        "symbol": {
          "type": "simple-marker",
          "style": "diamond",
          "color": [ 255, 128, 45 ],
          "outline": { "style": "dash-dot", "color": [ 0, 0, 0 ] }
        }
      }
    }
  ],
}
```

如果能够像上面这样， 从 json 来创建 WebScene ， 使用起来将会非常的方便。 但是不知道是什么原因， ArcGIS API for Javascript 并没有实现这个功能， 不过可以使用 ESRI 官方维护的 [esri-loader](https://github.com/esri/esri-loader/) 对 Autocasting 进行扩展， 实现这样的功能， 部分代码如下：

```ts
import { loadModules } from 'esri-loader';

/**
 * create a webscene instance by json;
 * @param properties webscene json properties
 */
export async function createWebScene(
    properties: __esri.WebSceneProperties
): Promise<__esri.WebScene> {
    await createMapLayers(properties);
    let webscene: __esri.WebScene;
    const [WebScene] = await loadModules(['esri/WebScene']);
    webscene = new WebScene(properties);
    return webscene;
}

/** Create a FeatureLayer from properties */
export function createFeatureLayer(
  properties: __esri.FeatureLayerProperties
): Promise<__esri.FeatureLayer> {
  Object.assign(properties, { type: 'feature' });
  return createLayer<__esri.FeatureLayer>(properties);
}

/** Create a TileLayer from properties. */
export function createTileLayer(
  properties: __esri.TileLayerProperties
): Promise<__esri.TileLayer> {
  Object.assign(properties, { type: 'tile' });
  return createLayer<__esri.TileLayer>(properties);
}

/**
 * Create a layer from properties;
 * @param props layer's properties
 */
export async function createLayer<T extends __esri.Layer>(
  props: any
): Promise<T> {
  const layerType = props.type;
  delete props.type; // type is readonly, need delete it here from properties
  let layer: T;
  switch (layerType) {
    case 'feature':
      const [FeatureLayer] = await loadModules([
        'esri/layers/FeatureLayer'
      ]);
      layer = new FeatureLayer(props);
      break;
    case 'tile':
      const [TileLayer] = await loadModules([
        'esri/layers/TileLayer'
      ]);
      layer = new TileLayer(props);
      break;
    case 'vector-tile':
      const [VectorTileLayer] = await loadModules([
        'esri/layers/VectorTileLayer'
      ]);
      layer = new VectorTileLayer(props);
      break;
    default:
      throw new Error(`Unknown layer type: ${layerType}`);
  }
  return layer;
}
```

这里只贴出了部分代码， 如果继续了解详细的实现， 请查看这个 [esri-service](https://github.com/beginor/esri-service/blob/master/src/esri-service.ts) 的代码。

这个类库也发布了 npm 包 [esri-service](https://www.npmjs.com/package/esri-service)， 如果使用了 nodejs 的话， 只要通过命令 `npm i esri-service` 即可安装。

有了 `esri-service` 之后， 可以更加方便的创建图层和地图：

### 创建要素图层

```ts
import * as arcgis from 'esri-service';

const featureLayer = await arcgis.createFeatureLayer({
  url: "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/WorldCities/FeatureServer/0",
  renderer: {
    type: "simple",
    symbol: {
      type: "simple-marker",
      style: "diamond",
      color: [ 255, 128, 45 ],
      outline: { style: "dash-dot", color: [ 0, 0, 0 ] }
    }
  }
});
```

### 创建切片地图

```ts
const tileLayer = await arcgis.createTileLayer({
  url: "https://services.arcgisonline.com/arcgis/rest/services/World_Terrain_Base/MapServer",
  title: "World Terrain Base"
});
```

### 创建矢量切片图层

```ts
const vectorLayer = await arcgis.createVectorTileLayer({
  url: "https://basemaps.arcgis.com/arcgis/rest/services/World_Basemap_v2/VectorTileServer",
  style: { /* ... */ }
});
```

### 创建 WebMap

```ts
const map = await arcgis.createMap({
  basemap: 'satellite',
  ground: 'world-elevation',
  layers: [
    {
      type: "tile", // For TileLayer the type is always "tile".
      url: "https://services.arcgisonline.com/arcgis/rest/services/World_Terrain_Base/MapServer",
      title: "World Terrain Base"
    },
    {
      type: "vector-tile", // For VectorTileLayer the type is always "vector-tile".
      url: "https://basemaps.arcgis.com/arcgis/rest/services/World_Basemap_v2/VectorTileServer",
      style: { /* ... */ }
    },
    {
      type: "feature", // For FeatureLayer the type is feature.
      url: "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/WorldCities/FeatureServer/0",
      renderer: {
        type: "simple",
        symbol: {
          type: "simple-marker",
          style: "diamond",
          color: [ 255, 128, 45 ],
          outline: { style: "dash-dot", color: [ 0, 0, 0 ] }
        }
      }
    }
  ]
});
```

### 创建地图视图

```ts
const sceneView = await arcgis.createSceneView({
    container: document.getElementById('map'),
    map,
    zoom: 7,
    center: { longitude: 113.2, latitude: 23.4 },
    viewingMode: 'local'
});
```

甚至再进一步， 可以将 WebMap 或者 WebScene 以 json 的形式保存到服务器或者数据库， 实现类似 ArcGIS Portal 的场景式地图管理。

## 最后

最后说一下， `esri-loader` 一直是 ArcGIS API for JavaScript 的加载神器， 隔离了 dojo 的入侵性， 让 ArcGIS API for JavaScript 轻松加载到常见的前端开发环境中， 包括今天的对 Autocasting 的扩展， 也是用到了 `esri-loader`。

不过从 4.18 开始， ArcGIS API for JavaScript 提供了原生 ES6 模块 [@arcgis/core](https://www.npmjs.com/package/@arcgis/core) ， 可以直接在受支持的浏览器中运行， 不用在依赖第三方加载器， 也可以很轻松的在各种前端框架中使用。
