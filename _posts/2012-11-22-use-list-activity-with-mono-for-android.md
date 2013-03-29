---
layout: post
title: Mono for Android 下的 ListActivity
description: 介绍 Mono for Android 平台下 ListActivity 的使用， 以及如何进行自定义 ListActivity 的 Adapter
tags: [Mono, Android]
---

介绍 Mono for Android 平台下 ListActivity 的使用， 以及如何进行自定义 ListActivity 的 Adapter。

### 使用 ListActivity 最简单的方式

ListActivity 是 android 开发中很常用的布局组件， 通常用于显示可以滚动的列表项。 以 `ArrayAdapter<T>` 为例， 最简单的使用方法如下： 

1、 新建一个 Activity ， 名称为 MyListActivity ， 并修改其基类为 Android.App.ListActivity, 代码如下： 

	[Activity (Label = "MyListApp", MainLauncher = true)]
	public class MyListActivity : ListActivity {

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);
		}
	}

2、 添加一个字符串数组字段作为数据源， 代码如下： 

	// 最简单的方法， 用数组作为数据源
	private readonly string[] _countries = new String[] {
		"Afghanistan","Albania","Algeria","American Samoa","Andorra",
		"Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina",
		"Armenia","Aruba","Australia","Austria","Azerbaijan",
		"Bahrain","Bangladesh","Barbados","Belarus","Belgium",
		"Belize","Benin","Bermuda","Bhutan","Bolivia",
		"Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil",
		"British Indian Ocean Territory"
	};

3、 在 OnCreate 方法中设置 ListView 的数据源， 代码如下：

	protected override void OnCreate(Bundle bundle) {
		base.OnCreate(bundle);
		// 设置 ListAdapter 为 ArrayAdapter<string>
		this.ListAdapter = new ArrayAdapter<string>(this, Resource.Layout.MyListActivityItemLayout, this._countries);
		this.ListView.TextFilterEnabled = true;
		// 添加一个建大的事件处理函数， 以通知的形式显示选中项。
		this.ListView.ItemClick += (object sender, AdapterView.ItemClickEventArgs e) => {
			var toast = Toast.MakeText(this.Application, ((TextView)e.View).Text, ToastLength.Short);
			toast.Show();
		};

	}

现在， 完整的 MyListActivity.cs 看起来应该是这样子的：

	[Activity(Label = "ListDemo", MainLauncher = true)]
	public class MyListActivity : ListActivity {

		private readonly string[] _countries = new String[] {
			"Afghanistan","Albania","Algeria","American Samoa","Andorra",
			"Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina",
			"Armenia","Aruba","Australia","Austria","Azerbaijan",
			"Bahrain","Bangladesh","Barbados","Belarus","Belgium",
			"Belize","Benin","Bermuda","Bhutan","Bolivia",
			"Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil",
			"British Indian Ocean Territory"
		};

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);

			// Create your application here
			this.ListAdapter = new ArrayAdapter<string>(this, Resource.Layout.MyListActivityItemLayout, this._countries);
			this.ListView.TextFilterEnabled = true;

			this.ListView.ItemClick += (object sender, AdapterView.ItemClickEventArgs e) => {
				var toast = Toast.MakeText(this.Application, ((TextView)e.View).Text, ToastLength.Short);
				toast.Show();
			};
		}
	}

如果现在运行程序， 看到的效果如下：

![List Activity](/assets/post-images/list-activity-screen-shot.png)

ListActivity的使用就是这么简单， 但是这往往不是我们所需要的， 接下来将会对上面的代码进行一些重构。

### 使用 String-Array 作为 ListActivity 数据源

把要显示的列表作为 Android 资源是个不错的注意， 减少对显示内容的硬编码， 必要时还可以方便的实现多语言显示， 在 Assets/values/strings.xml 文件中添加下面的内容：

	<string-array name="CountryArray">
		<item>Afghanistan</item>
		<item>Albania</item>
		<item>Algeria</item>
		<item>American Samoa</item>
		<item>Andorra</item>
		<item>Angola</item>
		<item>Anguilla</item>
		<item>Antarctica</item>
		<item>Antigua and Barbuda</item>
		<item>Argentina</item>
		<item>Armenia</item>
		<item>Aruba</item>
		<item>Australia</item>
		<item>Austria</item>
		<item>Azerbaijan</item>
		<item>Bahrain</item>
		<item>Bangladesh</item>
		<item>Barbados</item>
		<item>Belarus</item>
		<item>Belgium</item>
		<item>Belize</item>
		<item>Benin</item>
		<item>Bermuda</item>
		<item>Bhutan</item>
		<item>Bolivia</item>
		<item>Bosnia and Herzegovina</item>
		<item>Botswana</item>
		<item>Bouvet Island</item>
		<item>Brazil</item>
		<item>British Indian Ocean Territory</item>
	</string-array>

然后， 在 OnCreate 方法中这样初始化 ArrayAdapter ：

	var countries = Resources.GetStringArray(Resource.Array.CountryArray);
	this.ListAdapter = new ArrayAdapter<string>(this,
	 	Resource.Layout.MyListActivityItemLayout, countries);

现在的 MyListActivity 的源代码如下：

	[Activity(Label = "ListDemo", MainLauncher = true)]
	public class MyListActivity : ListActivity {

		protected override void OnCreate(Bundle bundle) {
			base.OnCreate(bundle);

			// 获取资源中定义的字符串数组
			var countries = Resources.GetStringArray(Resource.Array.CountryArray);
			this.ListAdapter = new ArrayAdapter<string>(this, Resource.Layout.MyListActivityItemLayout, countries);
			this.ListView.TextFilterEnabled = true;

			this.ListView.ItemClick += (object sender, AdapterView.ItemClickEventArgs e) => {
				var toast = Toast.MakeText(this.Application, ((TextView)e.View).Text, ToastLength.Short);
				toast.Show();
			};
		}
	}

### 使用自定义 ListAdapter

在很多情况下， 还需要使用自定义的 ListAdapter ， Mono for Android 版本的自定义 BaseAdapter 实现如下：

	public class MyListAdapter : BaseAdapter<string> {

		private string[] _data;
		private Activity _activity;
		
		public MyListAdapter(Activity activity) {
			// 引用当前的 activity 是必须的， 否则貌似没办法调用 LayoutInflater
			this._activity = activity;
			// 从资源中加载数组数据
			this._data = activity.Resources.GetStringArray(Resource.Array.CountryArray);
		}

		// 重写 GetItemId 方法， 
		public override long GetItemId(int position) {
			return position;
		}

		// 重写 GetView 方法， 获取每个数据的单元格。
		public override View GetView(int position, View convertView, ViewGroup parent) {
			TextView view = convertView as TextView;
			if (view == null) {
				// 貌似只有通过 Activity 才能使用 LayoutInflactor ， 
				view = (TextView)this._activity.LayoutInflater.Inflate(Resource.Layout.MyListActivityItem, null);
			}
			view.Text = this._data[position];
			return view;
		}

		// 重写 Count 属性， 只有 Mono for Android 才有
		public override int Count {
			get {
				return this._data.Length;
			}
		}

		// 实现 this 索引器， 这个也是 Mono for Android 才有的
		public override string this[int position] {
			get {
				return this._data[position];
			}
		}

	}

从上面的代码可以看出， Mono for Android 提供的 `BaseAdapter<T>` 有着浓厚的 .Net 风格， 比如 Count 属性， this 索引器 等， 当然， 这些对于有经验的 .net 开发人员来说， 都是已经掌握的知识了。 使用这个自定义 Adapter 也是非常方便的， 只要用将 ListActivity 的初始化代码改成这样就行：

	var arrayAdapter = new MyListAdapter(this);
	this.ListAdapter = arrayAdapter;
	this.ListView.TextFilterEnabled = true;

