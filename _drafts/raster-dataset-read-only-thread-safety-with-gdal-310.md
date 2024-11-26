---
layout: post2
title: GDAL 3.10 中的线程安全的只读栅格数据集
description: 介绍 GDAL 3.10 中实现的线程安全的只读栅格数据集及其简单实用
keywords: GDAL, raster dataset, readonly, thread-safety
tags: [GIS, GDAL, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

GDAL 最近发布了 3.10 版本， 其中最重要的一个更新就是 [栅格数据集只读线程安全](https://gdal.org/en/latest/development/rfc/rfc101_raster_dataset_threadsafety.html) 。 许多栅格算法，都需要独立和并发的方式读取栅格数据， 在以前的 GDAL 版本中， 由于 Dataset 不是线程安全的， 这些操作需要在单个线程中处理 I/O ， 或者通过互斥锁来防止并发实用， 或者每个工作线程打开一个单独的 GDALDataset ， 实现起来都会比较复杂。 因此 GDAL 在 3.10 版本中实现了 `栅格数据集只读线程安全` ， 提供可以从多个线程安全使用的特殊 GDALDataset 实例， 不需要用户再考虑线程安全的问题， 多线程读取栅格数据的操作将大大简化。

在 GDAL 的文档中， 已经详细介绍了 C/C++ 语言增加的 [函数和使用方法](https://gdal.org/en/latest/development/rfc/rfc101_raster_dataset_threadsafety.html#c-and-c-api-extensions) ，本文就不再介绍。 接下来主要介绍一下如何 C# 和 Python 两种语言中如何使用这一功能。

## 在 C# 中线程安全的读取栅格数据

GDAL 在 C# 语言绑定中， 为栅格数据集 `Dataset` 增加了 `IsThreadSafe` 和 `GetThreadSafeDataset` 两个成员函数， 定义如下：

```c#
public class Dataset : MajorObject {
  
  public Dataset GetThreadSafeDataset(int nScopeFlags) {}

  public bool IsThreadSafe(int nScopeFlags) {}

}
```

这样我们就可以判断一个栅格数据集是否是线程安全的，如果不是，则再打开一个线程安全的数据集，代码如下：

```c#
// 从第三方类库获取一个已经打开的数据集
var dataset = GetDatasetFromOtherLibs();
// 判断是不是线程安全的
var isThreadSafe = dataset.IsThreadSafe(GDAL_OF_RASTER);
// 如果不是，再打开一个线程安全的栅格数据集
if (!isThreadSafe) {
  dataset = dataset.GetThreadSafeDataset(GDAL_OF_RASTER);
}
```

当然， 如果能够自行打开栅格数据， 则推荐使用 `Gdal.OpenEx` 方法直接打开线程安全的数据集：

```c#
public static class GdalExtensions {
  // GDAL 并没有为在 C# 绑定中定义这些常量， 自己定义一下需要的常量
  const int GDAL_OF_READONLY = 0x00;
  const int GDAL_OF_RASTER = 0x02;
  const int GDAL_OF_THREAD_SAFE = 0x800;

  public static Dataset OpenThreadSafeDataset(string tiffFile) {
    // reffer [GDALOpenEx](https://gdal.org/en/latest/api/raster_c_api.html#gdal_8h_1a9cb8585d0b3c16726b08e25bcc94274a)
    var threadSafeDataset = Gdal.OpenEx(
      tiffFile,
      (uint)(GDAL_OF_RASTER | GDAL_OF_READONLY | GDAL_OF_THREAD_SAFE),
      null,
      null,
      null
    );
    return threadSafeDataset;
  }
}
```

> 1. `GDAL_OF_XXX` 常量的值在 [gdal.h](https://github.com/OSGeo/gdal/blob/master/gcore/gdal.h) 文件中可以找到；
> 2. `OpenEx` 函数个参数的意义参考 C 语言函数 [GDALOpenEx](https://gdal.org/en/latest/api/raster_c_api.html#gdal_8h_1a9cb8585d0b3c16726b08e25bcc94274a) ；

可以通过上面定义的扩展函数直接打开一个线程安全的只读栅格数据集：

```c#
var dataset = GdalExtensions.OpenThreadSafeDataset("mydata.tif");
```

这样获取到线程安全的 dataset 之后，可以轻松实现一个栅格数据切片服务，示例代码如下：

```c#
using MaxRev.Gdal.Core;
using OSGeo.GDAL;
using SkiaSharp;

GdalBase.ConfigureAll();
Gdal.UseExceptions();

// 墨卡托坐标系的 GeoTiff 文件
var tiffFile = "mydata.tif";

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("api/tile/{z:int}/{y:int}/{x:int}", (int z, int x, int y) => {
    Dataset? dataset = null;
    try {
        var tile = new Tile(x, y, z);
        dataset = GdalExtensions.OpenThreadSafeDataset(tiffFile);
        // 参照 https://cogeotiff.github.io/rio-tiler/ 实现了一个 ReadTile 函数，
        // 从 GeoTiff 文件读取按墨卡托坐标系下的地图切片对应的图片
        var image = dataset.ReadTile(tile);
        if (image == null)  {
            return Results.NotFound();
        }
        var buffer = image.Encode(
            SKEncodedImageFormat.Png, 90
        ).ToArray();
        return Results.File(buffer, "image/png");
    }
    catch (Exception ex) {
        Console.WriteLine(ex);
        throw;
    }
    finally {
        dataset?.Dispose();
    }
}).WithName("GetTile");

app.Run();
```

## 在 Python 中线程安全的读取栅格数据

Python 和 C# 都是 GDAL 官方支持的，因此用法也基本上是一样的。

判断一个栅格数据集是否是线程安全的，如果不是，则再获取一个新的线程安全的数据集：

```python
from osgeo import gdal

gdal.UseExceptions()

dataset: gdal.Dataset = open_dataset_from_other_lib()

is_thread_safe = dataset.IsThreadSafe(gdal.OF_RASTER)
print(f'is thread safe: {is_thread_safe}')

if not is_thread_safe:
    safe_dataset: gdal.Dataset = dataset.GetThreadSafeDataset(gdal.OF_RASTER)
    is_thread_safe = safe_dataset.IsThreadSafe(gdal.OF_RASTER)
    print(f'is thread safe: {is_thread_safe}')
    safe_dataset.Release()

dataset.Release()
```

也可以通过 `gdal.OpenEx` 直接打开线程安全的栅格数据集：

```python
from osgeo import gdal

gdal.UseExceptions()

dataset: gdal.Dataset = gdal.OpenEx(
    'mydata.tif',
    gdal.OF_READONLY | gdal.OF_RASTER | gdal.OF_THREAD_SAFE
)

is_thread_safe = dataset.IsThreadSafe(gdal.OF_RASTER)

print(f'is thread safe: {is_thread_safe}') # True

dataset.Release()
```

> GDAL 的 Python 绑定定义的常量比 C# 多一些， 但是类型提示则大多都是 `Any` 。
