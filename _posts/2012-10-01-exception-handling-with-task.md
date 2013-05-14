---
layout: post
title: Task 编程中的异常处理
description: 在 .Net 开发中， 使用 Task 、 Task<T> 进行异步编程是非常方便的， 但是在处理 Task 产生的异常时， 也有一些需要注意的问题。
tags: [.Net]

---

在 .Net 开发中， 使用 `Task` 、 `Task<T>` 进行异步编程是非常方便的， 但是在处理 Task 产生的异常时， 需要注意一个问题， 比如下面的代码：

	static Task<int> TestAsync(int a, int b) {
		var tcs = new TaskCompletionSource<int>();
		Task.Factory.StartNew(() => {
			if (a + b < 0) {
				tcs.TrySetException(new InvalidOperationException("a + b < 0"));
			}
			else {
				tcs.TrySetResult(a + b);
			}
		});
		return tcs.Task;
	}

当输入的两个参数之和小于 0 时， tcs 会设置一个 InvalidOperationException ， 如果直接运行这段代码， 当这个函数返回的 Task 被 GC 回收时， 将会产生 AggregateException was unhandled 的异常， 运行代码如下：

	static void Main(string[] args) {
	
		TestAsync(5, -10);
	
		Thread.Sleep(TimeSpan.FromMilliseconds(3000));
	 
		GC.Collect();
	 
		Console.WriteLine("Completed.");
	}

当程序运行结束时， 会产生下图所示的异常：

![AggregateException was unhandled](http://beginor.github.com/assets/post-images/agg-exp-was-unhandled.png)

关键的是这段文字：

> A Task's exception(s) were not observed either by Waiting on the Task or accessing its Exception property. As a result, the unobserved exception was rethrown by the finalizer thread.

> 没有在等待 Task 完成时捕获其异常， 也没有读取 Task 的 Exception 属性， 结果导致异常被终结线程重新抛出。 也就是说， Task 异常有两种处理方式：

**1、 调用 Task 的 Wait 方法时使用 try-catch 捕获异常：**

	var testTask = TestAsync(5, -10);
	try {
		testTask.Wait();
	}
	catch(Exception ex) {
		Console.WriteLine(ex);
	}

**2、 在 Task 的 ContinueWith 方法中读取 Task 的 Exception 属性：**

	var testTask = TestAsync(5, -10);
	testTask.ContinueWith(task => {
		if (task.IsFaulted) {
			Console.WriteLine(task.Exception.GetBaseException());
		}
		else {
			Console.WriteLine(task.Result);
		}
	});

在 .Net 4.0 、 Sliverlight 5.0 、以及 MonoTouch 中均有类似的问题， 因此， 必须小心翼翼的处理 Task 产生的异常， 否则将会导致你的程序异常退出。