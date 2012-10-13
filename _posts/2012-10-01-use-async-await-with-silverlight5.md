---
layout: post
title: 在 Silverlight 5 项目中使用 async/await
description: .Net 4.5 提供了 async/await 让异步编程回归同步， 不过， async/await 不是只能在 .Net 4.5 下才能使用， 通过使用 Async Targeting Pack 就可以在 .Net 4.0 以及 Silverlight 5 项目中使用 async/await。
tags: [Silverlight]

---

.Net 4.5 提供了 async/await 让异步编程回归同步， 不过， async/await 不是只能在 .Net 4.5 下才能使用， 通过使用 Async Targeting Pack 就可以在 .Net 4.0 以及 Silverlight 5 项目中使用 async/await。

先来看一段 Silverlight 代码， 不使用 async/await 时是这样子的：

	private void DistanceTestButtonClick(object sender, RoutedEventArgs routedEventArgs) {
		// 假设这是用户输入的坐标
		var point1 = GeometryUtil.CreateMapPointWgs84(113.3, 23.07);
		// 假设用户输入目的地坐标
		var point2 = GeometryUtil.CreateMapPointWgs84(110.3, 20);
		// 全局地图控件
		var map = App.ObjContainer.Resolve(typeof(Map));
		// 从当前 UI 上下文创建 TaskScheduler
		var uiContext = TaskScheduler.FromCurrentSynchronizationContext();
		// 创建三个几何服务
		var geoSvc1 = GeoFactory.CreateGeometryService();
		var geoSvc2 = GeoFactory.CreateGeometryService();
		var geoSvc3 = GeoFactory.CreateGeometryService();
		// 将用户输入的坐标投影为地图的坐标系坐标
		var task1 = geoSvc1.ProjectPointAsync(point1, map.SpatialReference);
		task1.ContinueWith(t1 => {
			point1 = task1.Result;
			// 目的地坐标投影为地图坐标
			var task2 = geoSvc2.ProjectPointAsync(point2, map.SpatialReference);
			task2.ContinueWith(t2 => {
				point2 = task2.Result;
				var buffParam = this.CreateBufferParameters(point2);
				var buffTask = geoSvc3.BufferTaskAsync(buffParam);
				// 做一次缓冲查询
				buffTask.ContinueWith(t3 => {
					var buffGeometry = buffTask.Result.First();
					var disParam = new DistanceParameters {
						DistanceUnit = LinearUnit.Meter,
						Geodesic = true
					};
					// 求距离
					var disTask1 = geoSvc1.DistanceTaskAsync(point1, point2, disParam);
					disTask1.ContinueWith(t4 => {
						var disTask2 = geoSvc2.DistanceTaskAsync(point1, buffGeometry.Geometry, disParam);
						disTask2.ContinueWith(t5 => {
							//最后求得最终距离
							var dis1 = disTask1.Result;
							var dis2 = disTask2.Result;
						}, uiContext);
					}, uiContext);
				}, uiContext);
			}, uiContext);
		}, uiContext);
	}

看上面的代码， 做 Silverlight 开发的可真伤不起啊， Silverlight 阉割了所有的同步方法， 只能做异步查询， 本来是可以放在后台线程中模拟同步的，可偏偏 ArcGIS 提供的 Silverlight API 在回调函数中创建了 UI 元素以及 DepedencyObject ， 想放到后台线程中计算也不行， 真是悲剧。

下面就请出 Async Targeting Pack 来拯救一下吧， 打开 NuGet 管理器， 输入 await 查询， 找到 Async Targeting Pack for Visual Studio 11 ， 然后下载并添加引用到 Silverlight 项目， 开始用 async/await 改造上面的代码， 最终的结果如下， 看看是不是清爽了好多呢？

	async private void DistanceTestButtonClick(object sender, RoutedEventArgs routedEventArgs) {
		 var point1 = GeometryUtil.CreateMapPointWgs84(113.3, 23.07);
		 var point2 = GeometryUtil.CreateMapPointWgs84(110.3, 20);
	 
		 var map = App.ObjContainer.Resolve(typeof(Map));
	 
		 var geoSvc1 = GeoFactory.CreateGeometryService();
		 var geoSvc2 = GeoFactory.CreateGeometryService();
		 var geoSvc3 = GeoFactory.CreateGeometryService();
	 
		 point1 = await geoSvc1.ProjectGeometryAsync(point1, map.SpatialReference) as MapPoint;
		 point2 = await geoSvc2.ProjectGeometryAsync(point2, map.SpatialReference) as MapPoint;
	 
		 var buffParam = this.CreateBufferParameters(point2);
		 var buffGeometry = (await geoSvc3.BufferTaskAsync(buffParam)).First();
	 
		 var disParam = new DistanceParameters {
			  DistanceUnit = LinearUnit.Meter,
			  Geodesic = true
		 };
	 
		 var dist1 = await geoSvc1.DistanceTaskAsync(point1, point2, disParam);
		 var dist2 = await geoSvc2.DistanceTaskAsync(point1, buffGeometry.Geometry, disParam);
	 
		 var d = dist2 - dist1;
	}

这样编译出来的 xap 包只是多了一个 dll， 依然可以在 Silverlight5 下运行， 客户端不需要安装任何软件。

大家赶快升级 VS2012 吧， 异步编程回归同步了！ 