---
layout: post
title: Android 应用保存状态
description: Android 应用保存状态的几种方法
tags: [Android]
keywords: xamarin, mono, c#, android, retain state, mono, activity, fragment, onSaveInstanceState,  onRestoreInstanceState, bundle,  shared preference
---

最近开发的 Android 应用中需要添加保存用户状态的功能， 经过查阅 Android 的文档， 保存用户状态的几种方法如下：

## 1、 使用 Bundle 保存界面状态

Android 系统提供的 [Bundle][1] 类似于哈希表， 以 key、 value 的形式保存数据， 支持存取几种常见的类型。 最先找到的文档就是通过 [Activity][2] 的 onSaveInstanceState 和 onRestoreInstanceState 方法来保存用户状态， 虽然最终测试发现这种方法不是肯靠谱， 还是记录下来了。

### onSaveInstanceState 保存状态

当系统销毁 Android 程序， 进行内存回收时， 会调用 Activity 的 onSaveInstanceState 方法， 传入一个 Bundle 实例参数， 通过重写这个方法， 可以保存 Activity 的状态， 示例代码如下：

    protected override void OnSaveInstanceState(Bundle outState) {
        base.OnSaveInstanceState(outState);
        outState.PutInt("main_activity_click_count", _count);
        outState.PutString("main_activity_button_text", _myButton.Text);
    }

对于 Fragment 来说， 也是重写这个方法。

### onRestoreInstanceState 恢复状态

当系统重新回到以前被系统回收的应用时， 会调用 onRestoreInstanceState 方法， 如果之前用 onSaveInstanceState 保存了状态， 则可以通过重写 onRestoreInstanceState 方法恢复状态。

#### Activity 恢复状态

对于 Activity 来说， 可以在 onCreate 方法中读取保存的状态， 代码如下：

    protected override void OnCreate(Bundle bundle) {
        base.OnCreate(bundle);
        if (bundle != null) {
           /* retain ui state */
        }
    }

也可以在 onRestoreInstanceState 方法中读取保存的状态， 代码如下：

    protected override void OnRestoreInstanceState(Bundle savedInstanceState) {
        base.OnRestoreInstanceState(savedInstanceState);
        _count = savedInstanceState.GetInt("main_activity_click_count", _count);
        _myButton.Text = savedInstanceState.GetString("main_activity_button_text", "Nothing in state.");
    }

#### Fragment 恢复状态

对于 Fragment 来说， 可以在 onCreate 、 onActivityCreated 、 onCreateView 中读取 onSaveInstanceState 方法中保存的状态， 这三个方法分别如下：

    public override void OnCreate(Bundle savedInstanceState) {
        base.OnCreate(savedInstanceState);
    }

    public override void OnActivityCreated(Bundle savedInstanceState) {
        base.OnActivityCreated(savedInstanceState);
    }

    public override View OnCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return base.OnCreateView(inflater, container, savedInstanceState);
    }

**经过测试， 这种方法最大的缺点就是不靠谱** ， 因为 onSaveInstanceState 和 onResotreInstanceState 不是每次都能被系统调用， 因为应用可能在调用 onRestoreInstanceState 方法之前应用就被结束了， 大家都喜欢装杀进程的软件， 应用程序总免不了被结束的命运， 所以这种方法不是很可靠的。

## 2、 使用 SharedPreference 保存状态

Android 推荐在 onPause 方法中使用 [SharedPreference][3] 保存状态是比较可靠的， 因为 SharedPreference 是基于文件的， 所以被结束进程也不怕。 

### 保存状态

不管是 Activity 还是 Fragment ， 都可以通过重写 onPause 方法来保存状态， 代码如下：

    protected override void OnPause() {
        base.OnPause();
        var pref = this.GetPreferences(FileCreationMode.Private);
        var editor = pref.Edit();
        editor.PutInt("main_activity_click_count", _count);
        editor.PutString("main_activity_button_text", _myButton.Text);
        editor.Commit();
    }

### 恢复状态

虽然可以在任何时候读取保存的 SharedPreference ， 但是还是推荐在 onCreate 方法中读取保存的内容， 示例代码如下：

    protected override void OnCreate(Bundle bundle) {
        base.OnCreate(bundle);
        /* setup code here */
        var pref = this.GetPreferences(FileCreationMode.Private);
        _count = pref.GetInt("main_activity_click_count", _count);
        _myButton.Text = pref.GetString("main_activity_button_text", "Nothing in state.");
    }

### 注意问题

Activity 有两个方法来创建 SharedPreference ， [getPreferences][4] 和 [getSharedPreferences][5] ,  getPreference 创建的 SharedPreference 只能在当前的 Activity 中访问， 而 getSharedPreference 创建的选项则可以在整个应用中访问。

保存用户状态建议积极一些， 不要总是等待系统调用 onPause 方法， 只要用户操作了界面， 就可以进行状态保存， 这样会让应用更加可靠一些。

[1]:http://developer.android.com/reference/android/os/Bundle.html
[2]:http://developer.android.com/reference/android/app/Activity.html
[3]:http://developer.android.com/reference/android/content/SharedPreferences.html
[4]:https://developer.android.com/reference/android/app/Activity.html#getPreferences(int)
[5]:https://developer.android.com/reference/android/content/Context.html#getSharedPreferences(java.lang.String, int)
