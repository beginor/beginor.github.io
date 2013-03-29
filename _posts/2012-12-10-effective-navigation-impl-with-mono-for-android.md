---
layout: post
title: Mono for Android 实现高效的导航
description: Android 4.0 系统定义了一系列的高效导航方式 (Effective Navigation) ， 主要包括标签、下拉列表、以及向上和返回等， 本文介绍如何用 Mono for Android 实现这些的导航方式。
tags: [Mono, Android]
---

Android 4.0 系统定义了一系列的[高效导航方式 (Effective Navigation)](http://developer.android.com/training/design-navigation/index.html)， 主要包括标签、下拉列表、以及向上和返回等， 本文介绍如何用 Mono for Android 实现这些的导航方式。

### 准备 Android 4.0 ICS 项目

#### 新建 Android ICS 项目

打开 MonoDevelop ， 新建一个 Mono for Android 项目， 并在项目的属性页将 Target Framework 设置为 `Android 4.0.3 (Ice Cream Sandwich)` ， 如下图所示：

![准备 Android 4.0 ICS 项目](/assets/post-images/eff-nav-setup-ics-proj.png)

#### 添加 Mono.Android.Support.v4 引用项

在解决方案窗口， 选中项目的引用节点， 右击选择编辑引用， 添加对 `Mono.Android.Support.v4.dll` 的引用， 如图所示：

![Mono.Android.Support.v4](/assets/post-images/eff-nav-ref-to-android-support-v4-dll.png)

在项目中新建一个目录 SupportLib ， 并添加对 android-support-v4.jar 文件（位于 android-sdk/extras/android/support/v4 目录， 如果没有， 需要用 SDK Manager 安装）的引用， 并将 jar 文件的编译动作 (BuildAction) 设置为 AndroidJavaLibrary ， 如下图所示：

![引用 android-support-v4.jar](/assets/post-images/eff-nav-ref-to-android-support-v4-jar.png)

本文提到的导航都是根据 Android 4.0 设计规范中推荐的 [ActionBar](http://developer.android.com/reference/android/app/ActionBar.html) 实现的， 因此整个应用程序启用带 ActionBar 的主题， 如果使用 Java 的话， 需要手工编辑 AppManifest.xml 文件的设置， 而用 Mono for Android 的话， 基本上不需要手工编辑这个文件。

Mono for Android 的做法是， 新建一个 App 类， 继承自 `Android.App.Application` 类， 并添加 `Android.App.ApplicationAttribute` 标记， 在编译时， Mono for Android 会根据这些标记自动生成一个 AppManifest.xml 文件并打包到最终的 apk 文件中。

App 类的代码如下：

	[Application(Label = "@string/AppName", Icon = "@drawable/ic_launcher",
					 Theme = "@android:style/Theme.Holo.Light.DarkActionBar")]
	public class App : Application {

		public App(IntPtr javaReference, JniHandleOwnership transfer)
			: base(javaReference, transfer) {
		}
	}

添加这个类之后， 项目中的每个 Activity 将默认都是用这个主题， 如果有 Activity 要使用其它的主题， 才需要添加自己的主题属性。

### 标签导航

Android 的标签用 ActionBar 实现， 用户既可以点击标签切换视图， 也可以水平滑动切换视图， 如下图所示：

![标签导航](/assets/post-images/eff-nav-with-actionbar-tab.png)
 
用户既可以点击上面的 'SECTION 0'、 'SECTION 1'、 'SECTION 2' 标签切换视图， 也可以在视图上水平拖动切换视图， 同时标签选中项也要同步选中， 实现的代码如下：

	[Activity (Label = "@string/AppName", Icon = "@drawable/ic_launcher", MainLauncher = true)]
	public class MainActivity : FragmentActivity {

		/// <summary>
		/// AppSectionsPagerAdapter 提供要显示的视图， 继承自
		/// Mono.Android.Support.V4.View.PagerAdapter, 所有加载过视图都保存在内存中， 
		/// 如果视图占用内存过多， 考虑替换成 FragmentStatePagerAdapter 。
		/// </summary>
		AppSectionsPagerAdapter _appSectionsPagerAdapter;

		/// <summary>
		/// 用 ViewPager 来显示视图三个主视图， 每次只显示一个。
		/// </summary>
		ViewPager _viewPager;

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);

			this.SetContentView(Resource.Layout.MainActivity);

			// 创建 Adapter
			this._appSectionsPagerAdapter = new AppSectionsPagerAdapter(this.SupportFragmentManager);
			// 设置 ActionBar
			var actionBar = this.ActionBar;
			// 首页不需要向上的 Home 按钮
			actionBar.SetHomeButtonEnabled(false);
			// 设置标签导航模式
			actionBar.NavigationMode = ActionBarNavigationMode.Tabs;
			// 设置 ViewPager 的 Adapter ， 这样用户就可以水平滑动切换视图了
			this._viewPager = this.FindViewById<ViewPager>(Resource.Id.Pager);
			this._viewPager.Adapter = this._appSectionsPagerAdapter;
			// 当水平滑动切换视图时， 设置选中的标签
			this._viewPager.PageSelected += delegate(object sender, ViewPager.PageSelectedEventArgs e) {
				actionBar.SetSelectedNavigationItem(e.P0);
			};

			// 依次添加三个标签， 并添加标签的选中事件处理函数， 设置当前的视图。
			for (var i = 0; i < this._appSectionsPagerAdapter.Count; i++) {
				var tab = actionBar.NewTab().SetText(this._appSectionsPagerAdapter.GetPageTitle(i));
				tab.TabSelected += delegate(object sender, Android.App.ActionBar.TabEventArgs e) {
					this._viewPager.CurrentItem = tab.Position;
				};
				actionBar.AddTab(tab);
			}
		}
	}


### 左右导航

标签导航并不适合所有的场景， 有时仅仅需要显示视图的标题即可， 但是同样可以水平滑动切换视图， 如下图所示：

![左右导航](/assets/post-images/eff-nav-with-left-right.png)

这种导航方式相当于标签式导航的简化版， 用户只可以左右滑动切换视图， 实现的代码如下：


	protected override void OnCreate(Bundle bundle) {
		base.OnCreate(bundle);
		this.SetContentView(Resource.Layout.CollectionDemoActivity);
		// 创建 Adapter
		this._demoCollectionPagerAdapter = new DemoCollectionPagerAdapter(this.SupportFragmentManager);

		// 设置 ViewPager 的 Adapter
		this._viewPager = this.FindViewById<ViewPager>(Resource.Id.Pager);
		this._viewPager.Adapter = this.mDemoCollectionPagerAdapter;
	}

因为要显示标题， 所以这个 Activity 的 Layout 添加了一个 PagerTitleStrip ， Layout 源代码如下：

	<android.support.v4.view.ViewPager
	    xmlns:android="http://schemas.android.com/apk/res/android"
		android:id="@+id/Pager"
		android:orientation="vertical"
		android:layout_width="match_parent"
		android:layout_height="match_parent"
		>
		<!--
		PaterTitleStrip 即可显示选中页面的标题， 也显示临近选中的几个视图的标题
		-->
		<android.support.v4.view.PagerTitleStrip android:id="@+id/PagerTitleStrip"
			android:layout_width="match_parent"
			android:layout_height="wrap_content"
			android:layout_gravity="top"
			android:background="#33b5e5"
			android:textColor="#fff"
			android:paddingTop="4dp"
			android:paddingBottom="4dp" />

	</android.support.v4.view.ViewPager>

### 下拉列表

下拉列表导航是在 ActionBar 中显示一个下拉列表 (Spinner)， 就像一个菜单， 只显示选中的菜单项对应的视图， 如下图所示：

![下拉列表导航](/assets/post-images/eff-nav-with-actionbar-list.png)

将 ActionBar 设置为下拉列表导航时， 一般不显示 Activity 自身的标题， 因此需要将 Activity 的 Label 标记为空字符串， 并且 Activity 需要实现接口 `ActionBar.IOnNavigationListener` ， ListNavigationActivity 的部分实现代码如下：

	[Activity (Label = "")]
	public class ListNavigationActivity
			: FragmentActivity, ActionBar.IOnNavigationListener {

		ListNavSectionsPagerAdapter _navSectionsPagerAdapter;
		
		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);
			/* 其他代码省略 … */

			// 设置 ActionBar
			var actionBar = this.ActionBar;
			// 将 Home 设置为向上
			actionBar.SetDisplayHomeAsUpEnabled(true);
			// 设置 ActionBar 的导航模式为下拉列表
			actionBar.NavigationMode = ActionBarNavigationMode.List;
			
			var titles = new string[this._navSectionsPagerAdapter.Count];
			for (var i = 0; i < titles.Length; i++) {
				titles[i] = this._navSectionsPagerAdapter.GetPageTitle(i);
			}
			// 设置列表导航的回调参数
			actionBar.SetListNavigationCallbacks(
				new ArrayAdapter(
					actionBar.ThemedContext,
					Resource.Layout.ListNavigationActivityActionbarListItem,
					Android.Resource.Id.Text1,
					titles
				),
				this
			);
			// 设置 ViewPager
			this._viewPager = this.FindViewById<ViewPager>(Resource.Id.Pager);
			this._viewPager.Adapter = this._navSectionsPagerAdapter;
			// 当 ViewPager 的选中页切换时， 同步 actionBar 的选中项。
			this._viewPager.PageSelected += delegate(object sender, ViewPager.PageSelectedEventArgs e) {
				actionBar.SetSelectedNavigationItem(e.P0);
			};
		}
		
		// ActionBar.IOnNavigationListener
		public bool OnNavigationItemSelected(int itemPosition, long itemId) {
			this._viewPager.CurrentItem = itemPosition;
			return true;
		}
	}

### 向上导航

所谓的向上导航， 就是在 Activity 的图标上显示一个向左的箭头， 点击图标返回应用程序的上一级 Activity ， 注意是上一级 Activity ， 不是上一个 Activity ， 关于向上与返回的区别， 可以看看 Android SDK 中的 [Providing Ancestral and Temporal Navigation](http://developer.android.com/training/design-navigation/ancestral-temporal.html) 一文， 将向上和返回讲解的非常清楚， 在这里只讨论 Mono for Android 的实现方式。

要显示向上导航的按钮， 需要在 `OnCreate` 方法中对 ActionBar 做如下设置：

	// 设置 ActionBar
	var actionBar = this.ActionBar;
	// 将 Home 按钮显示为向上， 提示用户点击这个按钮可以返回应用程序的上一级。
	actionBar.SetDisplayHomeAsUpEnabled(true);

同时还需要重写 `OnOptionsItemSelected` 方法， 当用户点击 Home 按钮时， 做相应的处理， 实现向上导航的代码如下：

	public override bool OnOptionsItemSelected(Android.Views.IMenuItem item) {
		// 作为示例， 只处理用户点击 Home 按钮的情况。
		if (item.ItemId == Android.Resource.Id.Home) {
			// 当 Home 按钮被点击时会调用到这里
			// 创建启动上级 Activity 的 Intent
			var upIntent = new Intent(this, typeof(MainActivity));
			// 使用 Suport Package 中的 NavUtils 来正确处理向上导航
			if (NavUtils.ShouldUpRecreateTask(this, upIntent)) {
				// 上级 Activity 没有起动过， 需要创建一个新的导航栈道
				TaskStackBuilder.Create(this)
					// If there are ancestor activities, they should be added here.
					.AddNextIntent(upIntent)
					.StartActivities();
				this.Finish();
			}
			else {
				// 上级 Activity 已经创建过了， 直接导航就行。
				NavUtils.NavigateUpTo(this, upIntent);
			}
			return true;
		}
		return base.OnOptionsItemSelected(item);
	}

## 总结

Android 系统的导航与 iOS 相比复杂很多， 实现起来也相对麻烦一些， 好在有 Google 的 Support Package 已经多大部分操作提供了比较好的封装， 还是比较容易掌握的。  文中的完整的源代码已经提交的 Github 上， 地址是 [https://github.com/beginor/MonoDroid/tree/master/EffectiveNavigation](https://github.com/beginor/MonoDroid/tree/master/EffectiveNavigation) 。