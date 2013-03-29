---
layout: post
title: Activity 生命周期及其栈管理方式
description: 介绍 Mono for Android 平台下的 Activity 生命周期， 以及 Actvity 的栈管理方式， 并给提供了测试代码。
tags: [Mono, Android]
---

Android 系统用栈的形式管理 Activity ， 当新的 Activity 被创建是， 会被放置到栈顶， 这个 Activity 会进入到运行状态， 而前一个 Activity 则会被压入栈， 直到新的 Activity 退出， 否则不会出现在前台。

### 单个 Activity 的生命周期状态以及生命周期方法

根据 Android 文档， 每一个 Activity 都有四个状态， 它们分别是：

* 当 Activity 位于屏幕的最前面（栈顶），称之为 **运行（活动）状态：** ；
* 当 Activity 失去焦点， 但是依旧可见， 比如被非全屏的对话框遮住部分， 称之为 **暂停状态** ， 暂停的 Activity 依然是活动的， 但是当系统内存严重不足时， 有可能被系统结束；
* 当 Activity 完全不可见时， 称之为 **停止状态** ， 这时 Activity 依然保持其状态以及成员信息， 不过由于此时 Activity 对用户不可见， 当系统其它地方需要内存时， 经常会被结束；
* 当 Activity 由不可见变成可见时， 称之为 **重启状态** ， 这时 Activity 必须迅速恢复它以前的状态。

下图表示 Activity 在这四种状态之间切换的生命周期， 以及状态切换时调用的对应的方法：

![Activity lifecycle](/assets/post-images/activity_lifecycle.png)

Activity 生命周期中的各个方法描述如下：

* **onCreate()**
  当 Activity 首次创建时调用， 这里通常的工作是创建视图， 绑定数据到列表等。 这个方法还有一个 Bundle 参数， 如果这个 Activity 之前由冻结的状态， 这个状态将包含在里面。 之后， 通常会接着调用 onStart() 方法。
* **onRestart()**
  Activity 已经被停止， 在其被重新开始之前调用。  接下来回调用 onStart() 方法。
* **onStart()**
  当 Activity 变到用户可见时调用， 接下来如果 Activity 变成不可见的话， 将会调用 onStop() ， 否则将调用 onResume() 。
* **onResume()**
  当 Activity 开始能和用户交互时调用， 此时的 Activity 位于栈顶， 接下来通常会调用 onPause() 。
* **onPause()**
  当系统准备开始一个新的 Activity 或者重置一个已有的 Activity 时调用。 通常需要在这里进行保存数据、 停止动画以及其它占用 CPU 资源的活动等。 这个方法完成之前， 下一个 Activity 不会继续， 所以这个方法的必须较快的完成。 接下来如果 Activity 又回到栈顶将调用 onResume() ， 如果 Activity 变的不可见， 将调用 onStop() 。
* **onStop()**
  当 Activity 不可见时调用， 如果 Activity 变的可见， 将会调用 onRestart() ， 如果 Activity 将销毁， 调用 onDestroy() 。
* **onDestroy()**
  这是 Activity 被销毁之前最后一次调用， 可能是调用了 Activity 的 finish() 方法， 或者系统要回收资源， 这两者可以通过 isFinishing() 方法进行区别。

### 多个 Activity 的栈管理方式

多个 Activity 之间采用的是栈道管理方式， 当用户启动新的 Activity 时， 新启动的 Activity 位于栈顶，当用户按后退按钮时， 栈顶的 Activity 被推出栈道并销毁， 如下图所示：

![Activity Stack Manage](/assets/post-images/diagram_backstack.png)

### 生命周期测试代码

我们在上次创建的程序中添加 Activity 的生命周期代码， 并加入一些输出， 以便清晰的理解：

	[Activity(Label = "MyFirstApp", MainLauncher = true)]
	public class MainActivity : Activity {
		
		public const string ExtraMessage = "Cn.Beginor.MyFirstApp.MainActivity.ExtraMessage";
		
		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);
			/** 其它代码省略 **/
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnStart() {
			base.OnStart();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnResume() {
			base.OnResume();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnPause() {
			base.OnPause();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnStop() {
			base.OnStop();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnRestart() {
			base.OnRestart();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
		}

		protected override void OnDestroy() {
			base.OnDestroy();
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + MethodBase.GetCurrentMethod().Name);
			Android.Util.Log.Debug("Debug", this.GetType().Name + "." + this.IsFinishing);
		}
	}

以上是 MainActivity 添加的生命周期代码， 由于代码完全一直， 就不在贴出来了。 接下来开始调试， 首先会启动 MainActivity ， 从输出窗口能看到下面的提示：

	MainActivity.OnCreate
	MainActivity.OnStart
	MainActivity.OnResume

点击“发送”按钮，启动 SecondActivity ，看到下面的提示：

	MainActivity.OnPause
	SecondActivity.OnCreate
	SecondActivity.OnStart
	SecondActivity.OnResume
	MainActivity.OnStop

点击返回按钮， 返回 MainActivity ， 得到的提示如下：

	SecondActivity.OnPause
	MainActivity.OnRestart
	MainActivity.OnStart
	MainActivity.OnResume
	SecondActivity.OnStop
	SecondActivity.OnDestroy
	SecondActivity.IsFinishing = True

再次点击“发送”按钮，启动 SecondActivity ，看到下面的提示（与第一次是一致的）：

	MainActivity.OnPause
	SecondActivity.OnCreate
	SecondActivity.OnStart
	SecondActivity.OnResume
	MainActivity.OnStop

这时， 如果点击 Home 按钮， 会得到下面的提示：

	SecondActivity.OnPause
	SecondActivity.OnStop

点击“最近程序”按钮， 打开 MyFirstApp ， 会看到下面的提示：

	SecondActivity.OnRestart
	SecondActivity.OnStart
	SecondActivity.OnResume

如果在 MainActivity 点击“返回”按钮， 应用将会退出， 可以看到下面的提示：

	MainActivity.OnPause
	MainActivity.OnStop
	MainActivity.OnDestroy
	MainActivity.IsFinishing = True

至此， 整个生命周期测试完成， 有了上面的测试， 应该可以对 Android 的 Activity 生命周期有一个比较清楚的认识。