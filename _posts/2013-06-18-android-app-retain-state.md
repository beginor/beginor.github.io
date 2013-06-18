---
layout: post
title: Android 应用保存状态
description: 扁平化设计原则
tags: [Android]
keywords: xamarin, android, retain state, mono, activity, fragment, onSaveInstanceState,  onRestoreInstanceState, bundle,  shared preference
---

## Bundle 

### onSaveInstanceState 保存状态

    protected override void OnSaveInstanceState(Bundle outState) {
        base.OnSaveInstanceState(outState);
        outState.PutInt("main_activity_click_count", _count);
        outState.PutString("main_activity_button_text", _myButton.Text);
    }

### onRestoreInstanceState 恢复状态

#### Activity

    protected override void OnCreate(Bundle bundle) {
        base.OnCreate(bundle);
        if (bundle != null) {
           /* retain ui state */
        }
    }

    protected override void OnRestoreInstanceState(Bundle savedInstanceState) {
        base.OnRestoreInstanceState(savedInstanceState);
        _count = savedInstanceState.GetInt("main_activity_click_count", _count);
        _myButton.Text = savedInstanceState.GetString("main_activity_button_text", "Nothing in state.");
    }

#### Fragment

    public override void OnCreate(Bundle savedInstanceState) {
        base.OnCreate(savedInstanceState);
    }

    public override void OnActivityCreated(Bundle savedInstanceState) {
        base.OnActivityCreated(savedInstanceState);
    }

    public override View OnCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return base.OnCreateView(inflater, container, savedInstanceState);
    }

## SharedPreference

### 保存状态

    protected override void OnPause() {
        base.OnPause();
        var pref = this.GetPreferences(FileCreationMode.Private);
        var editor = pref.Edit();
        editor.PutInt("main_activity_click_count", _count);
        editor.PutString("main_activity_button_text", _myButton.Text);
        editor.Commit();
    }

## 恢复状态

    protected override void OnCreate(Bundle bundle) {
        base.OnCreate(bundle);
        /* setup code here */
        var pref = this.GetPreferences(FileCreationMode.Private);
        _count = pref.GetInt("main_activity_click_count", _count);
        _myButton.Text = pref.GetString("main_activity_button_text", "Nothing in state.");
    }