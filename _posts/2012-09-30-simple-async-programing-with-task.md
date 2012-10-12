---
layout: post
title: 使用 Task 简化异步编程
description: 本文介绍了常见的 .Net 异步编程模式， 以及如何用 Task 对象包装这些异步编程模式， 并给出了一个使用 Task 对象包装异步操作， 简化代码的例子。
tags: [.Net Framework]

---
## 使用 Task 简化异步编程

### .Net 传统异步编程概述

.NET Framework 提供以下两种执行 I/O 绑定和计算绑定异步操作的标准模式：

* 异步编程模型 (APM)，在该模型中异步操作由一对 Begin/End 方法（如 FileStream.BeginRead 和 Stream.EndRead）表示。 
* 基于事件的异步模式 (EAP)，在该模式中异步操作由名为“操作名称Async”和“操作名称Completed”的方法/事件对（例如 WebClient.DownloadStringAsync 和 WebClient.DownloadStringCompleted）表示。 （EAP 是在 .NET Framework 2.0 版中引入的）。

### Task 的优点以及功能

通过使用 Task 对象，可以简化代码并利用以下有用的功能：

* 在任务启动后，可以随时以任务延续的形式注册回调。 
* 通过使用 ContinueWhenAll 和 ContinueWhenAny 方法或者 WaitAll 方法或 WaitAny 方法，协调多个为了响应 Begin_ 方法而执行的操作。 
* 在同一 Task 对象中封装异步 I/O 绑定和计算绑定操作。 
* 监视 Task 对象的状态。 
* 使用 TaskCompletionSource 将操作的状态封送到 Task 对象。

### 使用 Task 封装常见的异步编程模式

1、 使用 Task 对象封装 APM 异步模式， 这种异步模式是 .Net 标准的异步模式之一， 也是 .Net 最古老的异步模式， 自 .Net 1.0 起就开始出现了，通常由一对 Begin/End 方法同时出现， 以 WebRequest 的 BeginGetResponse 与 EndGetResponse 方法为例：

	var request = WebRequest.CreateHttp(UrlToTest);
	request.Method = "GET";
	var requestTask = Task.Factory.FromAsync<WebResponse>(
		request.BeginGetResponse,
		request.EndGetResponse,
		null
	);
	requestTask.Wait();
	var response = requestTask.Result;

2、使用 Task 对象封装 EPM 异步模式， 这种模式从 .Net 2.0 开始出现， 同时在 Silverlight 中大量出现， 这种异步模式以 “操作名称Async” 函数和 “操作名称Completed” 事件成对出现为特征， 以 WebClient 的 DownloadStringAsync 方法与 DownLoadStringCompleted 事件为例：

	var source = new TaskCompletionSource<string>();
	var webClient = new WebClient();
	webClient.DownloadStringCompleted += (sender, args) => {
		if (args.Cancelled) {
			source.SetCanceled();
			return;
		}
		if (args.Error != null) {
			source.SetException(args.Error);
			return;
		}
		source.SetResult(args.Result);
	};
	webClient.DownloadStringAsync(new Uri(UrlToTest, UriKind.Absolute), null);
	source.Task.Wait();
	var result = source.Task.Result;

3、 使用 Task 对象封装其它非标准异步模式， 这种模式大量出现在第三方类库中， 通常通过一个 Action 参数进行回调， 以下面的方法为例：

	void AddAsync(int a, int b, Action<int> callback)

封装方法与封装 EPM 异步模式类似：

	var source = new TaskCompletionSource<int>();
	Action<int> callback = i => source.SetResult(i);
	AddAsync(1, 2, callback);
	source.Task.Wait();
	var result = source.Task.Result;

通过上面的例子可以看出， 用 Task 对象对异步操作进行封装之后， 异步操作简化了很多， 只要调用 Task 的 Wait 方法， 可以直接获取异步操作的结果， 而不用转到回调函数中进行处理， 接下来看一个比较实际的例子。

### 缓冲查询示例

以 Esri 提供的缓冲查询为例， 用户现在地图上选择一个合适的点， 按照一定半径查询查询缓冲区， 再查询这个缓冲区内相关的建筑物信息， 这个例子中， 我们需要与服务端进行两次交互：

1. 根据用户选择的点查询出缓冲区；
2. 查询缓冲区内的建筑物信息；

这个例子在 GIS 查询中可以说是非常简单的， 也是很典型的， [ESRI 的例子中也给出了完整的源代码](http://help.arcgis.com/en/webapi/silverlight/samples/start.htm#BufferQuery)， 这个例子的核心逻辑代码是：

	_geometryService = new GeometryService(GeoServerUrl);
	_geometryService.BufferCompleted += GeometryService_BufferCompleted;
	 
	_queryTask = new QueryTask(QueryTaskUrl);
	_queryTask.ExecuteCompleted += QueryTask_ExecuteCompleted;
	 
	void MyMap_MouseClick(object sender, Map.MouseEventArgs e) {
		// 部分代码省略， 开始缓冲查询
		_geometryService.BufferAsync(bufferParams);
	 
	}
	 
	void GeometryService_BufferCompleted(object sender, GraphicsEventArgs args) {
		// 部分代码省略， 获取缓冲查询结果， 开始查询缓冲区内的建筑物信息
		_queryTask.ExecuteAsync(query);
	}
	 
	void QueryTask_ExecuteCompleted(object sender, QueryEventArgs args) {
		// 将查询结果更新到界面上
	}

这只是一个 GIS 开发中很简单的一个查询， 上面的代码却将逻辑分散在三个函数中， 在实际应用中， 与服务端的交互次数会更多， 代码的逻辑会分散在更多的函数中， 导致代码的可读性以及可维护性降低。 如果使用 Task 对象对这些任务进行封装， 那么整个逻辑将会简洁很多， GeometryService 和 QueryTask 提供的是 EPM 异步模式， 相应的封装方法如上所示， 最后， 用 Task 封装异步操作之后的代码如下：

	void MyMap_MouseClick(object sender, Map.MouseEventArgs e) {
		Task.Factory.StartNew(() => {
			// 省略部分 UI 代码， 开始缓冲查询
			var bufferParams = new BufferParameters() { /* 初始化缓冲查询参数 */};
			var bufferTask = _geometryService.CreateBufferTask()
			// 等待缓冲查询结果
			bufferTask.Wait();
			// 省略更新 UI 的代码， 开始查询缓冲区内的建筑物信息
			var query = new Query() { /* 初始化查询参数 */ };
			var queryExecTask = _queryTask.CreateExecTask(query);
			queryExecTask.Wait();
			// 将查询结果显示在界面上， 代码省略
		});
	}

从上面的代码可以看出， 使用 Task 对象可以把原本分散在三个函数中的逻辑集中在一个函数中即可完成， 代码的可读性、可维护性比原来增加了很多。

Task 能完成的任务远不止这些，比如并行计算、 协调多个并发任务等， 有兴趣的可以进一步阅读[相关的 MSDN 资料](http://msdn.microsoft.com/zh-cn/library/dd997405.aspx)。