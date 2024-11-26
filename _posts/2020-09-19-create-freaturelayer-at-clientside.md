---
layout: post2
title: 在客户端创建要素图层 (FeatureLayer)
description: 本文介绍如何使用 ArcGIS JS API 在客户端创建要素图层 FeatureLayer 。
keywords: arcgis js api, featurelayer, creation, client side
tags: [GIS, TypeScript]
---

在 ArcGIS JS API 的开发中， FeatureLayer 可以说是让人又爱又恨， 特别是 ArcGIS JS API 4.x ， FeatureLayer 从服务端加载数据的策略不可控制， 或者说默认的数据加载策略不适合所有的场景， 某些场景下， 需要从先加载数据， 然后在客户端创建 FeatureLayer 。

要在客户端创建 FeatureLayer ， 根据 FeatureLayer 的[文档](https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-FeatureLayer.html#client-side)， 这几个属性必须设置：

- `fields` 指定一个 [Field](https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-support-Field.html) 数组来描述 FeatureLayer 的架构， 并且必须包含一个类型为 `oid` 的字段；
- `source` 指定一个 [Graphic](https://developers.arcgis.com/javascript/latest/api-reference/esri-Graphic.html) 数组来表示 FeatureLayer 的数据， 如果没有数据， 则设置一个空数组；
- `geometryType` 如果 source 为空， 则必须设置这个属性， 如果 source 不为空， 则会自动从 source 数组中寻找并判断；
- `spatialReference` 如果 source 为空， 则必须设置这个属性， 如果 source 不为空， 则会自动从 source 数组中寻找并判断；
- `objectIdField` 如果 source 为空， 则必须设置这个属性， 如果 source 不为空， 则会自动从 source 数组中寻找并判断；

## 从 ArcGIS Server 读取 JSON 数据创建 FeatureLayer

如果有 ArcGIS Server 的话， 要在客户端创建 FeatureLayer 需要加载两个模块， 它们是 `esri/tasks/QueryTask` 和 `esri/layers/FeatureLayer` ， 代码如下：

```ts
import { loadModules } from 'esri-loader';

// 使用 esri-loader 提供的 loadModules 方法加载这两个模块
const [QueryTask, FeatureLayer] = await loadModules<[
    __esri.QueryTaskConstructor,
    __esri.FeatureLayerConstructor
]>([
    'esri/tasks/QueryTask',
    'esri/layers/FeatureLayer'
]);
// 使用 FeatureLayer 服务的地址创建 QueryTask ， 并请求数据
const queryTask: __esri.QueryTask = new QueryTask({
    url: 'https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/Landscape_Trees/FeatureServer/0'
});
const featureSet: __esri.FeatureSet = await queryTask.execute({
    where: '1 = 1',
    outFields: ['*'],
    outSpatialReference: { wkid: 4326 },
    returnGeometry: true
});
// QueryTask 返回的结果是一个 FeatureSet ， 可以很方便的创建 FeatureLayer
const featureLayer: __esri.FeatureLayer = new FeatureLayer({
    geometryType: featureSet.geometryType as any,
    fields: featureSet.fields,
    source: featureSet.features,
    spatialReference: featureSet.spatialReference,
    objectIdField: featureSet.fields.find(f => f.type === 'oid').name
});
// 将 FeatureLayer 添加到地图
view.map.add(featureLayer);
```

## 从自定义 JSON 数据创建 FeatureLayer

如果没有 ArcGIS Server ， 或者是从其他的数据服务加载的 json 数据， 会稍微麻烦一些， 但是也是可以的， 只要在客户端构造出符合要求的 json 数据结构即可。

```ts
import { loadModules } from 'esri-loader';

// 使用 esri-loader 提供的 loadModules 方法加载 FeatureLayer 模块
const [FeatureLayer] = await loadModules<[
    __esri.FeatureLayerConstructor
]>([
    'esri/layers/FeatureLayer'
]);
// 根据 FeatureLayer 的属性， 构造 json 数据以创建 FeatureLayer ；
const featureLayer: __esri.FeatureLayer = new FeatureLayer({
    fields: [
        { name: 'FID', type: 'oid' },
        { name: 'Tree_ID', type: 'integer' }
    ],
    geometryType: 'point',
    spatialReference: { wkid: 4326 },
    objectIdField: 'FID',
    source: [
        {
            attributes: { 'FID': 1, 'Tree_ID': 102 },
            geometry: { x: -82.44119300239268, y: 35.610448315062335, type: 'point' }
        },
        {
            attributes: { 'FID': 2, 'Tree_ID': 103 },
            geometry: { x: -82.441111192058187, y: 35.6104788975222, type: 'point' }
        }
    ]
});
```

> 在上面的例子中， `fields` 和 `source` 两个属性的值比较繁琐， 不过这两个属性是可以通过后台服务根据数据库表结构和数据表内容来返回， 而不必在前端进行硬编码。

## 客户端创建 FeatureLayer 的优点和缺点

先来说一下这么做的优点， 主要有如下几个：

- 不依赖 ArcGIS Server ， 毕竟是很贵的商业产品；
- 可以控制数据加载， 无需理会 FeatureLayer 内置的所谓的优化加载策略， 内置的策略不能满足所有的使用场景；
- 同样可以使用 FeatureLayer 的其它特性， 比如 `renderer` `labelingInfo` 等等；
- 可以在客户端修改 Graphic 的属性值并刷新图层的显示， 而不必重新加载整个图层；

同时， 缺点也是有的：

- 只适合数据量较小的场景， 如果需要显示大量的数据， 特别是线或者面的矢量数据， 则不建议这么做；
- 没有 ArcGIS Server 情况下， 客户端以及服务端会增加一些额外的工作量；
