---
layout: post
title: 我的第一个 Mono for Android 应用
description: Mono for Android 初体验， 学习怎么使用 Mono for Anrdoid 创建 android 应用， 如何使用 Intent 启动 Activity ， 如何在 Activity 之间传递参数。
tags: [Mono, Android]
---

Mono for Android 初体验， 学习怎么使用 Mono for Anrdoid 创建 android 应用， 如何使用 Intent 启动 Activity ， 如何在 Activity 之间传递参数。

### 准备开发环境

#### 下载并安装 Mono for Android

在 OSX 系统下准备 Mono for Android 开发环境时比较容易的， 只要去 [Xamarin](http://xamarin.com/monoforandroid) 下载一个在线安装程序， 安装程序会自动下载并安装所有的文件， 甚至包括 JDK、 Android SDK 等， 没什么好说的， 一句话， 很简单。

#### 配置 Android 模拟器

启动 MonoDevelop ， 在 Tools 菜单下找到点击 “Open AVD Manager” ， 将会启动 “Android Virtual Device Manager”， 创建一个新的 Android 虚拟设备， Name 为 Droid4.1， Target 选择 4.1， SD 卡选择 256， Skin 选择内置的 WXGA720 ， 等等， 一切可以参考 Google 的文档。

需要注意的是， 要添加一个硬件选项 GPU emulation ， 并设置为 true ， 开启 GPU 模拟， 可以加快模拟器运行速度， 否则模拟器运行真的会很慢。

创建好了之后， 先运行一下模拟器， 确认一切配置正常了， 整个开发环境就算准备好了。

### 创建 Mono for Android 应用

打开 MonoDevelop ， 选择新建解决方案， 左边的分类选择 "Mono for Android" ， 右边选择 "Mono for Android Application" ， 使用默认的模板新建一个 Mono for Android 应用程序， 如下图所示， 项目名称为 “MyFirstApp” 。

![Create first Mono for Android Application](/assets/post-images/create-new-mono-for-android-app.png)

#### 熟悉默认项目模板

现在， 先不要做其它的， 先来熟悉一下这个项目， 打开项目属性对话框， 看看每个节点都有什么设置项， 重点熟悉下面几个节点：

*  Build/General ， 选择 Target Framework ，设置编译应用使用的 Android SDK 版本；
*  Build/Mono for Android Build ， 设置如 Linker 、 部署方式、 以及高级标签下的的 CPU架构、 国际化等；
*  Build/Mono for Android Application ， 设置应用程序信息， 也就是 AndroidManifest.xml 文件的信息；

项目默认的目录结构如下如所示：

![项目默认的目录结构](/assets/post-images/mono-for-android-project-structor.png)

注意 Assets 和 Resource 目录：

**Assets** 目录， 如果应用需要用到二进制资源文件， 比如特殊字体、声音等， 放在这个目录下， 并将 BuildAction 设置为 AndrioidAsset ， 资源将会和应用程序一起部署， 在运行时可以通过 AssetManager 使用类似下面的代码进行访问：

	public class ReadAsset : Activity
	{
		protected override void OnCreate (Bundle bundle)
		{
			base.OnCreate (bundle);
			InputStream input = Assets.Open ("my_asset.txt");
		}
	}

另外，字体文件可以这样加载：

	Typeface tf = Typeface.CreateFromAsset(
		Context.Assets, "fonts/samplefont.ttf");

**Resource** 目录, 包含应用程序所需的图片、 布局描述、 二进制文件和字符串字典等资源文件。 比如， 一个简单的 Android 应用包含一个界面描述文件 (main.axml) ， 一个国际化的字符串字典 (strings.xml) 以及图标 (icon.png) ， 这些文件按照下面的结构保存在 “Resource” 目录内：

	Resources/
	   drawable/
	      icon.png
	   layout/
	      main.axml
	   values/
	      strings.xml

为了让编译系统能够将资源文件识别出 Android 资源， 需要将其编译动作 (Build Action) 设置为 “Android Resource”。 上面的目录结构经过编译之后， 将会生成类似下面的文件：

	public class Resource {

		public class Drawable {
			public const int icon = 0x123;
		}

		public class Layout {
			public const int main = 0x456;
		}

		public class Strings {
			public const int FirstString = 0xabc;
			public const int SecondString = 0xbcd;
		}
	}

使用 `Resource.Drawable.icon` 可以引用 drawable/icon 文件， `Resource.Layout.main` 可以引用 /layout/main.axml 文件， 而使用 `Resource.Strings.FirstString` 则可以引用 values/strings.xml 文件中的第一个字符串。

以上这些和 Android SDK 文档中介绍的都是大同小异的， 在 Mono for Android 环境下又加上了一些 .Net 特有的风格而已， 对于有经验的 .Net 开发人员来说， 一看就懂了。

#### 创建 Activity 及 View

与其它平台的应用程序不同， 这些平台上的应用程序通常都有一个单一的入口 main 函数， 应用程序都由这个入口函数启动， 创建窗口、 维护界面。 而 Android 程序则不同， 一个 Android 程序由一些松散的 Activity 提供的界面组成， 因此看起来有点儿像 Web 应用程序， 任何一个 Activity 都可以通过 URL 启动。

现在来新建一个 Activity ， 在菜单栏上选择 File -> New -> File ， 在弹出的新建文件对话框中选择 Android Activity ， 如下图所示：

![Create new Activity](/assets/post-images/create-new-activity.png)

新建的 Activity 的代码如下：

	[Activity(Label = "MyFirstApp", MainLauncher = true)]
	public class MainActivity : Activity {

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);
		}

	}

注意 MainActivity 的 ActivityAttribute 标记， 这里指定了两个属性， `Label="MyFirstApp"` 表示 Activity 的显示名称， `MainLauncher=true` 表示在应用程序列表中显示， 在编译时， Mono for Android 会根据这些标记生成一个 AndroidManifest.xml ， 并打包倒最终的 Android 应用程序中。

现在来创建 MainActivity 的视图， 先选中项目的 Resources/layout 目录， 在菜单栏上选择 File -> New -> File ， 在弹出的新建文件对话框中选择 Android Layout ， 如下图所示：

![Create Android Layout](/assets/post-images/create-android-layout.png)

文件名输入 MainActivityLayout ， MonoDevelop 默认会打开设计视图， 先切换到代码视图， 粘贴下面的代码：

	<?xml version="1.0" encoding="utf-8"?>
	<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
	    android:orientation="horizontal"
	    android:layout_width="match_parent"
	    android:layout_height="match_parent">
	    <EditText
	        android:layout_width="0dp"
	        android:layout_height="wrap_content"
	        android:id="@+id/MessageEditText"
	        android:layout_weight="1"
	        android:hint="@string/MessageEditTextHint" />
	    <Button
	        android:text="@string/SendButtonText"
	        android:layout_width="wrap_content"
	        android:layout_height="wrap_content"
	        android:id="@+id/SendButton" />
	</LinearLayout>

然后切换到设计视图， 看起来如下图所示：

![Main Activity](/assets/post-images/first-layout-screen.png)

在 MainActivity.cs 文件中的 base.OnCreate(bundle) 下面加入下面一句代码， 让 MainActivity 使用 MainActivityLayout ：

	this.SetContentView(Resource.Layout.MainActivityLayout);

用同样的方法， 创建 SecondActivity 以及 SecondActivityLayout ， SecondActivityLayout 的代码以及设计界面如下：

	<?xml version="1.0" encoding="utf-8"?>
	<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
	    android:orientation="vertical"
	    android:layout_width="fill_parent"
	    android:layout_height="fill_parent">
	    <TextView
	        android:text="Large Text"
	        android:textAppearance="?android:attr/textAppearanceLarge"
	        android:layout_width="fill_parent"
	        android:layout_height="wrap_content"
	        android:id="@+id/MessageTextView" />
	</LinearLayout>

![Second Activity Layout](/assets/post-images/second-activity-screen.png)

#### 使用 Intent 启动 Activity 并传递参数

如果现在运行程序， 将只能看到 MainActivity ， 看不到 SecondActivity ， 如果要想启动 SecondActivity ， 就需要用到 Intent 。 Android 通过 Intent 来启动 Activity ， 以及在 Activity 之间传递参数。

打开 MainActivity ， 添加一些代码， 使其看起来如下所示：

	[Activity(Label = "MyFirstApp", MainLauncher = true)]
	public class MainActivity : Activity {

		public const string ExtraMessage = "Cn.Beginor.MyFirstApp.MainActivity.ExtraMessage";

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);
			// 设置布局文件
			this.SetContentView(Resource.Layout.MainActivityLayout);
			var sendBtn = this.FindViewById<Button>(Resource.Id.SendButton);
			// 为发送按钮添加事件处理函数
			sendBtn.Click += SendButtonClick;
		}

		void SendButtonClick (object sender, EventArgs e) {
			// 获取用户输入的信息
			var msgEditText = this.FindViewById<EditText>(Resource.Id.MessageEditText);
			if (msgEditText == null) {
				return;
			}
			var msg = msgEditText.Text;
			// 创建 Intent 并传递用户输入的信息
			var intent = new Intent(this, typeof(SecondActivity));
			intent.PutExtra(ExtraMessage, msg);
			// 启动第二个 Activity
			this.StartActivity(intent);
		}
	}

再打开 SecondActivity ， 添加接收 ExtraMessage 并显示的代码：

	protected override void OnCreate(Bundle bundle) {
		base.OnCreate(bundle);
		// 设置布局文件
		this.SetContentView(Resource.Layout.SecondActivityLayout);
		// 从 Intent 中获取 ExtraMessage 
		var intent = this.Intent;
		var msg = intent.GetStringExtra(MainActivity.ExtraMessage);
		// 将 ExtraMessage 显示在 TextView 上
		var textView = this.FindViewById<TextView>(Resource.Id.MessageTextView);
		textView.Text = msg;
	}

现在运行这个程序， 可以看到首先启动的是 MainActivity ， 显示界面如下：

![MainActivity](/assets/post-images/first-activity-runtime-screen.png)

点击 Send 按钮， 会启动 SecondActivity ， 并将输入的信息显示在界面上：

![SecondActivity](/assets/post-images/second-activity-runtime-screen.png)

### 总结 

Mono for Android 初体验感觉不错， 对于有经验的 .Net 开发人员来讲， 上手的速度非常快， 只要稍微学习一下 Android 的 UI 方面的知识就可以了。 MonoDevelop 的界面和 VS 很相似， 上手也是很容易的事情。 还是那句话， Mono for Android 最大的好处是可以利用现有的 .Net 代码， CodePlex 以及 Github 上有丰富的资源可以利用， 如果你熟悉 .Net 开发， Mono for Android 也是值得一试的。