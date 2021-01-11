---
layout: post2
title: 以 Mapbox Terrain-RGB 模型发布高程数据
description: 本文介绍如何发布 MapBox Terrain-RGB 格式的高程数据服务
keywords: mapbox, terrain-rgb, rasterio, rio, rgbify, gdal
tags: [教程, MapBox]
---

MapBox 的 mapbox-gl-js 最近发布了 2.0 版本， 支持 3D 地形， 对于它的 3D 地形很感兴趣， 于是就研究了一下如何发布它的数据格式以及如何发布它需要的地形数据服务 (Terrain-RGB)。

![Add 3D terrain to a map](/assets/post-images/mapbox-terrain.png)

## Mapbox Terrain-RGB 简介

**Mapbox Terrain-RGB** 包含以 PNG 栅格切片编码的全球数字高程数据， 这些颜色值可以解码为以米为单位的原始高度。 您可以将 Terrain-RGB 数据用于各种视觉和分析应用程序， 从设计地形坡度和山体阴影样式到生成用于视频游戏的 3D 地形网格。

有关Terrain-RGB的一些细节：

- **水平精度为 5 米** 对于 256x256 分辨率的切片， 缩放级别到 15 级， 512x512 分辨率的切片， 缩放级别到 14 级；
- **垂直精度为 0.1 米** 数据以 0.1 米的高度增量进行映射；
- **坐标系为 WGS84 Web 墨卡托** wkid 为 EPSG:3389 的 Web 墨卡托坐标系， 是 WebGIS 的事实标准；

## Terrain-RGB 数据解码

Terrain-RGB 使用每个颜色通道以 256 进制数的来表示高度，从而允许有 16,777,216 个唯一值。 收到图块后， 将需要获取各个像素的红色（R），绿色（G）和蓝色（B）值。 您可以使用浏览器中的[画布层](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D)（[示例](https://www.mapbox.com/bites/00307/?elev=10#8/38.055/-121.976)）或使用诸如 [get-pixel](https://github.com/scijs/get-pixels) 之类的工具来执行此操作。

使用下面的公式可以将像素值解码得到高度值， 高度值以米为单位：

```txt
height = -10000 + ((R * 256 * 256 + G * 256 + B) * 0.1)
```

## 如何发布 Mapbox Terrain-RGB 格式的高程数据服务

MapBox 提供的服务只能在线使用， 精度也不是很高， 如果需要在使用精度更高的 dem 数据服务或者离线使用的话， 就必须自行发布高层数据服务。

### 所需的工具

MapBox 是一家非常开放的公司， 所提供的工具也都以开源的形式提供。

1. [gdal](https://gdal.org/) 开源的空间数据处理程序；
2. [rasterio](https://github.com/mapbox/rasterio/) MapBox 在 gdal 基础上开发的栅格工具；
3. [rio-rgbify](https://github.com/mapbox/rio-rgbify/) MapBox 发布的将 dem 栅格编码为 rgb 栅格的 rasterio 插件；

### 数据预处理

首先手上得有高层数据， 通常是 GeoTiff 格式的灰度栅格图片， 看起来如下图所示

![terrain gray](/assets/post-images/terrain-gray.png)

需要注意的是， GeoTiff 的坐标系必须是 WGS84 Web 墨卡托 (EPSG:3857) ， 如果不清楚的话， 可以用 rasterio 提供的命令行工具来获取：

```sh
rio info --indent 2 3857_gd_dem.tif
```

得到的结果如下：

```json
{
  "blockxsize": 128,
  "blockysize": 128,
  "bounds": [
    12183017.913668174,
    2289826.9714713152,
    13080213.182794277,
    2960586.2512246673
  ],
  "colorinterp": [
    "gray"
  ],
  "compress": "lzw",
  "count": 1,
  "crs": "EPSG:3857",
  "descriptions": [
    null
  ],
  "driver": "GTiff",
  "dtype": "float32",
  "height": 25736,
  "indexes": [
    1
  ],
  "interleave": "band",
  "lnglat": [
    113.47173310097894,
    22.943659365328124
  ],
  "mask_flags": [
    [
      "nodata"
    ]
  ],
  "nodata": -3.4028230607370965e+38,
  "res": [
    26.0630742832356,
    26.063074283235625
  ],
  "shape": [
    25736,
    34424
  ],
  "tiled": true,
  "transform": [
    26.0630742832356,
    0.0,
    12183017.913668174,
    0.0,
    -26.063074283235625,
    2960586.2512246673,
    0.0,
    0.0,
    1.0
  ],
  "units": [
    null
  ],
  "width": 34424
}
```

从上面的结果可以看出：

- 坐标系 (crs) 是 `EPSG:3857` ， 不需要进行坐标转换， 如果不是 dem 数据的坐标系是其他值的话， 就需要进行坐标转换；

  > 转换坐标系的工具很多， 可以使用 ArcMap ， QGIS 等界面工具进行转换， 也可以使用 gdal 提供的 gdalwarp 命令行工具进行转换。

- 用 `-3.4028230607370965e+38` 来表示无数据， Terrain-RGB 无法表示负值， 需要进一步处理；

使用 gdal 提供的 gdalwarp 是最简单直接的办法， 输入下面的命令：

```bash
gdalwarp -t_srs EPSG:3857 -dstnodata None -co TILED=YES -co COMPRESS=DEFLATE -co BIGTIFF=IF_NEEDED 3857_gd_dem.tif 3857_gd_dem_n.tif
```

上面的命令一次完成上面的两部操作， 转换坐标系和清除表示无数据的负数值。

再次用 `rio info` 命令来查看 dem 数据的信息， 结果如下：

```json
{
  "blockxsize": 256,
  "blockysize": 256,
  "bounds": [
    12183017.913668174,
    2289826.9714713157,
    13080213.182794277,
    2960586.2512246673
  ],
  "colorinterp": [
    "gray"
  ],
  "compress": "deflate",
  "count": 1,
  "crs": "EPSG:3857",
  "descriptions": [
    null
  ],
  "driver": "GTiff",
  "dtype": "float32",
  "height": 25736,
  "indexes": [
    1
  ],
  "interleave": "band",
  "lnglat": [
    113.47173310097894,
    22.943659365328138
  ],
  "mask_flags": [
    [
      "all_valid"
    ]
  ],
  "nodata": null,
  "res": [
    26.063074283235608,
    26.063074283235608
  ],
  "shape": [
    25736,
    34424
  ],
  "tiled": true,
  "transform": [
    26.063074283235608,
    0.0,
    12183017.913668174,
    0.0,
    -26.063074283235608,
    2960586.2512246673,
    0.0,
    0.0,
    1.0
  ],
  "units": [
    null
  ],
  "width": 34424
}
```

现在， 无数据已经是 null ， 不再是负数了， 因为删除了表示无数据的负数值， 这一步可能会显著减小 dem 数据的文件大小。

### 转换成 RGB 格式

接下来就是使用 `rgbify` 将灰度数据转换成 rgb 数据， 计算高度的公式是

```txt
height = -10000 + ((R * 256 * 256 + G * 256 + B) * 0.1)
```

因此设置 ribify 的参数 `base value` 的参数为 `-10000` ， `interval` 为 `0.1` ， 继续输入下面的命令：

```bash
rio rgbify -b -10000 -i 0.1 3857_gd_dem_n.tif 3857_gd_dem_n_rgb.tif
```

完成之后， 得到的 `3857_gd_dem_n_rgb.tif` 看起来是这样子的：

![terrain rgb](/assets/post-images/terrain-rgb.png)

Terrain-RGB 用 3 个 byte 通过 rgb 三通道来表示高程， 比原来的灰度 tiff 要小很多。

### 发布服务

有了 rgb 格式的 dem 数据之后， 发布服务就是很简单的事情了， 可以使用 ArcGIS Server 或者 GeoServer 发布切片服务即可。

当然， 也可以使用 gdal 提供的 `gdal2tiles.py` 命令行工具来直接生成切片， 方便离线使用：

```bash
gdal2tiles.py --zoom=5-15 3857_gd_dem_n_rgb.tif ./tiles
```

耐心等待生成完全部切片， 把 tiles 目录复制到任意的 http 服务器就可以试用了。
