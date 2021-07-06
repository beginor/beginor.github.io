---
layout: post2
title: 基于 PostGIS 的矢量切片服务器
description: 本文介绍基于 PostGIS 3.0+ 创建自己的矢量切片服务器
keywords: postgresql, postgis, vectortile, mapboxgl, arcgis-js-api, webgis
tags: [PostgreSQL]
---

## 矢量切片简介

矢量切片是 [MapBox](https://www.mapbox.com/) 定义的一种开放的 [矢量地图标准](https://github.com/mapbox/vector-tile-spec) ， 已经成为开放地理联盟 (OGC) 的标准之一。

个人认为矢量切片的主要优点有：

- 服务端只关注数据， 无需进行繁琐的配图；
- 网络传输快， 因为只有括矢量数据；
- 客户端渲染， 服务端的一套矢量数据， 在客户端可以有多种的表现形式；
- 充分利用客户端硬件
  - 适配客户端屏幕， 根据屏幕解析度进行高精度矢量渲染；
  - 利用 OpenGL/WebGL 实现海量空间数据渲染；

目前制作矢量切片的方式主要有：

- 使用 ArcGIS Pro 生成矢量切片包， 上传到 ArcGIS Portal 和 Server ， 这套工具最完善， 但是也最贵；
- 使用开源的 GeoServer 来配置生成矢量切片， 配置比较繁琐， 而且对于矢量切片标准的支持也也比较慢；

这两种方式都能生成质量比较高的矢量切片， 并提供可靠的矢量切片服务， 但是都需要对数据做预处理， 如果修改了数据， 往往不能及时响应。

## PostGIS 对矢量切片的支持

PostGIS 是关系数据库 PostgreSQL 的空间扩展， 提供了强大的空间数据查询和处理能力， 对矢量切片也提供了支持， 相关的函数有：

- [ST_AsMVTGeom](https://postgis.net/docs/ST_AsMVTGeom.html) 将数据库存储的空间坐标转换为矢量切片坐标；
- [ST_AsMVT](http://postgis.net/docs/ST_AsMVT.html) 将矢量空间坐标聚合为符合矢量切片格式规范的二进制数据；
- [ST_TileEnvelope](http://postgis.net/docs/ST_TileEnvelope.html) 在 [Web墨卡托坐标系 (SRID:3857)](https://en.wikipedia.org/wiki/Web_Mercator_projection) 下使用 [xyz 切片架构](https://en.wikipedia.org/wiki/Tiled_web_map) 计算切片切片坐标范围；

通过者上面这三个相关函数， 可以将数据库存储的空间数据快速转换成矢量切片标准的二进制数据。

将单表输出为单图层矢量切片的 SQL 语句为：

```sql
with mvt_geom as (
  select
    ST_AsMVTGeom(
      geom,
      ST_TileEnvelope(15, 26696, 14219),
      extent => 4096, buffer => 64
    ) as geom,
    id, name, fclass, ref, oneway, maxspeed, bridge, tunnel, layer
  from public.sr3857_guangzhou_road
  where geom && ST_TileEnvelope(15, 26696, 14219, margin => (64.0 / 4096))
)
select ST_AsMVT(mvt_geom, 'guangzhou_road', 4096, 'geom', 'id')
from mvt_geom
```

也可以使用 `||` 算符将多个图层生成矢量切片

```sql
select (
  (
    with mvt_geom as (
      select
        ST_AsMVTGeom(
          geom,
          ST_TileEnvelope(15, 26696, 14219),
          extent => 4096, buffer => 64
        ) as geom,
        id, name, fclass, ref, oneway, maxspeed, bridge, tunnel, layer
      from public.sr3857_guangzhou_road
      where geom && ST_TileEnvelope(15, 26696, 14219, margin => (64.0 / 4096))
    )
    select ST_AsMVT(mvt_geom, 'guangzhou_road', 4096, 'geom', 'id')
    from mvt_geom
  ) || (
    with mvt_geom as (
      select
        ST_AsMVTGeom(
          geom,
          ST_TileEnvelope(15, 26696, 14219),
          extent => 4096, buffer => 64
    ) as geom,
        objectid, name, height, flag, type, area_id
      from public.sr3857_guangzhou_building
      where geom && ST_TileEnvelope(15, 26696, 14219, margin => (64.0 / 4096))
    )
    select ST_AsMVT(mvt_geom, 'guangzhou_building', 4096, 'geom', 'objectid')
    from mvt_geom
  )
);
```

## 矢量切片服务器

有了上面的 SQL 语句， 开发矢量切片服务器就是非常简单的了， 任何开发语言都可以实现， 下面以 C# 代码为例：

```c#
[HttpGet("{source}/{z:int}/{y:int}/{x:int}")]
public async Task<ActionResult> GetTile(string source, int z, int y, int x) {
    try {
        var buffer = await provider.GetTileContentAsync(source, z, y, x);
        if (buffer == null || buffer.Length == 0) {
            return NotFound();
        }
        return File(buffer, "application/vnd.mapbox-vector-tile");
    }
    catch (Exception ex) {
        logger.LogError(ex.Message);
        return StatusCode(500);
    }
}
```

通过 appsettings.json 配置两个矢量切片源：

```jsonc
{
  "connectionStrings": {
    "geo_db": "server=127.0.0.1;port=5432;database=geo_db;user id=geo_db_user;password=********;"
  },
  "vectors": {
    "guangzhou": {
      "connectionString": "geo_db",
      "layers": [
        {
          "name": "road",
          "minzoom": 9,
          "maxzoom": 15,
          "srid": 3857,
          "schema": "public",
          "tableName": "sr3857_guangzhou_road",
          "idColumn": "id",
          "geometryColumn": "geom",
          "attributeColumns": "name, fclass, ref, oneway, maxspeed, bridge, tunnel, layer"
        },
        {
          "name": "building",
          "minzoom": 13,
          "maxzoom": 17,
          "srid": 3857,
          "schema": "public",
          "tableName": "sr3857_guangzhou_building",
          "idColumn": "objectid",
          "geometryColumn": "geom",
          "attributeColumns": "name, height, flag, type, area_id"
        }
      ]
    }
  }
}
```

这样生成的矢量切片服务的地址是： <http://127.0.0.1:5000/api/vector/guangzhou/{z}/{y}/{x}> ， 包含了 `road` 和 `building` 两个图层。

## 使用矢量切片服务

生成的是基于 Web 墨卡托坐标系的 xyz 切片架构的标准的矢量切片服务， 可以直接任意支持矢量切片的客户端中使用 (mapboxgl, openlayers, arcgis js api 等）， 配置参照下面的矢量切片样式：

```json
{
  "version": 8,
  "sources": {
    "guangzhou": {
      "type": "vector",
      "scheme": "xyz",
      "tiles": ["http://127.0.0.1:5000/api/vectortiles/guangzhou/{z}/{y}/{x}"],
      "minzoom": 9,
      "maxzoom": 17
    }
  },
  "layers": [
    {
      "id": "road",
      "source": "guangzhou",
      "source-layer": "road",
      "type": "line",
      "minzoom": 9,
      "maxzoom": 15,
      "paint": {
        "line-color": "#00FF00",
        "line-width": 2
      }
    },
    {
      "id": "building",
      "source": "guangzhou",
      "source-layer": "guangzhou_building",
      "type": "fill",
      "minzoom": 13,
      "maxzoom": 17,
      "paint": {
        "fill-opacity": 0.8,
        "fill-color": "#8c2d04"
      }
    }
  ]
}
```

## 注意问题

- PostGIS 版本要求最新的 3.1.x ；
- 虽然 PostGIS 3.x 最低支持 PostgreSQL 9.6.x ， 但是建议使用高版本的 PostgreSQL (12+)， 因为 PostgreSQL 12 以上的版本提供了更好的查询性能；
- 虽然 PostGIS 提供了坐标系转换函数 [ST_Transform](http://postgis.net/docs/ST_Transform.html) ， 但是进行实时转换会消耗一些性能， 建议将空间数据转换为 [Web墨卡托坐标系 (SRID:3857)](https://en.wikipedia.org/wiki/Web_Mercator_projection) 存储在数据库， 这样在运行时就无需进行坐标系转换， 效率最高；
