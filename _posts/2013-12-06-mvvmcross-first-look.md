---
title: 跨平台开发框架 MvvmCross 初体验
description: 跨平台移动开发框架 MvvmCross 初体验
layout: post
tags: [MvvmCross, Xamarin, iOS, Android]
---

## MvvmCross 的特点

<ul>
<li>尽量使用<a href="https://msdn.microsoft.com/en-us/library/vstudio/gg597391(v=vs.100).aspx">可移植类库</a>进行编码， 可以包括 视图模型 (ViewModel) 、 模型 (Model) 、 服务 (Service) 甚至界面 (View)</li>
<li>使用 MVVM 模式和数据绑定 (Data Binding) 技术</li>
<li>使用目标平台的本地化界面</li>
<li>框架的任何部分都可以被重写</li>
</ul>

## 准备使用 MvvmCross 

推荐的方式是建立自己的 git 库， 然后将 [MvvmCross][2] 添加为 SubModule ， 有自己 github 账户的话就更方便了。 我的是：[MvvmCross-Learning][3]

MvvmCross 的文档主要是它在 github 上面的 [wiki][4] ， 另外就是 [MvvmCross-Tutorials][5]， 有大量的示例代码， 可以说是掌握 MvvmCross 的重要资料。

将 MvvmCross 和 MvvmCross-Tutorials 两个库添加为 submodule ，方便进行源代码调试和学习。

MvvmCross 的代码同步好了之后， 默认的分支是 v3.0, 基于 PCL 104， 在 windows 系统上， 可以直接编译； 而在 Mac 系统上， 需要切换到分支 v3.1 ， 这个分支基于 PCL 158， 可以在 Mac 系统上进行编译。 

## 使用 MvvmCross 创建跨平台应用

MvvmCross 应用至少包含两个项目， 一个是基于 PCL 的 Core 项目， 包含所有的视图模型、 服务以及应用程序逻辑代码； 一个是目标平台的界面项目， 包含目标平台的视图以及和 Core 进行交互的代码。

典型的 MvvmCross 跨平台应用应当包括： 一个独立的 Core 项目包含所有的逻辑代码；每个目标平台一个 UI 项目， 包含本地化的视图以及和 Core 进行交互的代码。

### Core 项目

在 Mac 系统上， 使用 Xamarin Studio 建立 Core PCL 项目， PCL项目的 Profile 选择为 158， 如下图所示：

![Core PCL Profile](/assets/post-images/pcl-profile-158.png)

接下来要添加对 MvvmCross 的引用， Core 项目需要引用的 dll 文件是 `Cirrious.CrossCore` 和 `Cirrious.MvvmCross` 。

MvvmCross Core 项目必须包含一个 `App` 类， 继承自 `MvxApplication` ， 负责 ViewModel 和逻辑代码的启动， 代码如下：

    using FirstMvxApp.ViewModels;
    using Cirrious.MvvmCross.ViewModels;
    
    namespace FirstMvxApp {
    
        public class App : MvxApplication {
    
            public override void Initialize() {
                base.Initialize();
                RegisterAppStart<FirstViewModel>();
            }
        }
    }

上面的代码很简单， 只是在 Initialize 方法中注册 `FirstViewModel` 为默认启动的 ViewModel 。

Core 项目还应该包含多个 ViewModel ， 上面的 `FirstViewModel` 的代码如下：

    using Cirrious.MvvmCross.ViewModels;
    using System.Windows.Input;
    
    namespace FirstMvxApp.ViewModels {
    
        public class FirstViewModel : MvxViewModel {
    
            private string firstName;
            private string lastName;
            private string fullName;
    
            public string FirstName {
                get {
                    return firstName;
                }
                set {
                    firstName = value;
                    RaisePropertyChanged("FirstName");
                }
            }
    
            public string LastName {
                get {
                    return lastName;
                }
                set {
                    lastName = value;
                    RaisePropertyChanged("LastName");
                }
            }
    
            public string FullName {
                get {
                    return fullName;
                }
                set {
                    fullName = value;
                    RaisePropertyChanged("FullName");
                }
            }
    
            public ICommand FullNameCommand {
                get {
                    return new MvxCommand(() => ｛
                        FullName = string.Format(
                            "{0} {1}",
                            FirstName,
                            LastName
                        );
                    });
                }
            }
        }
    }

最简单的 Core 项目到此就可以结束了， 只包含一个 App 和一个 FirstViewModel ， 接下来就是特定平台的界面项目。

### iOS 项目

新建一个 iOS 空项目， 添加对 MvvmCross 的引用， 需要的文件如下：

- Cirrious.CrossCore
- Cirrious.CrossCore.Touch
- Cirrious.MvvmCross
- Cirrious.MvvmCross.Touch
- Cirrious.MvvmCross.Binding
- Cirrious.MvvmCross.Binding.Touch

当然， 还有上面新建的 Core 项目。

添加一个 `Setup` 类， 负责 MvvmCross 在 iOS 应用中的启动， 代码如下：

    using Cirrious.MvvmCross.Touch.Platform;
    using MonoTouch.UIKit;
    using Cirrious.MvvmCross.ViewModels;
    using Cirrious.CrossCore.Platform;
    
    namespace FirstMvxApp {
    
        public class Setup : MvxTouchSetup {
    
            public Setup(MvxApplicationDelegate appDelegate, UIWindow window)
                : base(appDelegate, window) {
            }
    
            protected override IMvxApplication CreateApp() {
                return new FirstMvxApp.App();
            }
    
            protected override IMvxTrace CreateDebugTrace() {
                return new DebugTrace();
            }
    
        }
    
    }

接下来就是创建 Core 项目中 ViewModel 对应视图， Core 项目中包含 `FirstViewModel` ， 需要在 iOS 项目中创建对应的 `FirstView` 视图。 在 iOS 项目中添加 `Views` 目录， 然后添加一个 `iPhone View Controller` ， 名称为 `FirstView` 。 这是 MvvmCross 中默认的基于约定的命名方式， 在运行时会自动将 FirstView 的 ViewModel 设置为 FirstViewModel 。

FirstView 的界面如下图所示：

![FirstView iOS UI](/assets/post-images/mvvm-cross-core-app-first-view.png)

界面上控件的 outlet 名称分别为： `FirstNameTextField`, `LastNameTextField`, `GetFullNameButton`, `FullNameLabel`， 接下来的工作就是将这些界面控件与 ViewModel 的属性进行绑定， MvvmCross 实现了跨平台的数据绑定机制， 代码如下：

    using Cirrious.MvvmCross.Touch.Views;
    using Cirrious.MvvmCross.Binding.BindingContext;
    using FirstMvxApp.ViewModels;
    
    namespace FirstMvxApp.Views {
    
        public partial class FirstView : MvxViewController {
    
            public FirstView() : base("FirstView", null) {
            }
    
            public override void ViewDidLoad() {
                base.ViewDidLoad();
                this.Title = "First Mvx View";
                // Perform any additional setup after loading the view, typically from a nib.
                var bindings = this.CreateBindingSet<FirstView, FirstViewModel>();
                bindings.Bind(FirstNameTextField).TwoWay().To(vm => vm.FirstName);
                bindings.Bind(LastNameTextField).TwoWay().To(vm => vm.LastName);
                bindings.Bind(GetFullNameButton).To("FullNameCommand");
                bindings.Bind(FullNameLabel).To(vm => vm.FullName);
                bindings.Apply();
            }
        }
    }

绑定数据的代码非常简洁， 以后再详细介绍， 现在编译一下， 如果没有什么错误的话， 就可以直接运行了。

### Android 项目

由于使用了相同的框架， 创建 Android 项目的过程和上面的 iOS 项目非常类似的， 这里只列出不同的部分。

Android 项目需要引用的文件是：

- Cirrious.CrossCore
- Cirrious.CrossCore.Droid
- Cirrious.MvvmCross
- Cirrious.MvvmCross.Droid
- Cirrious.MvvmCross.Binding
- Cirrious.MvvmCross.Binding.Droid

从引用列表可以看出， 和 iOS 项目添加的引用是等价的。

Android 版本的 `Setup` 和 iOS 版本相比， 除了基类不同之外， 其余完全相同， 代码如下：

    using Cirrious.MvvmCross.Droid.Platform;
    using Android.Content;
    using Cirrious.MvvmCross.ViewModels;
    using Cirrious.CrossCore.Platform;
    
    namespace FirstMvxApp {
    
        public class Setup : MvxAndroidSetup {
    
            public Setup(Context applicationContext)
                : base(applicationContext) {
            }
    
            protected override IMvxApplication CreateApp() {
                return new App();
            }
    
            protected override IMvxTrace CreateDebugTrace() {
                return new DebugTrace();
            }
    
        }
    }

另外， Android 还需要一个 SplashScreen 做为启动项， 代码很简单， 如下所示：

    using Android.App;
    using Cirrious.MvvmCross.Droid.Views;
    
    namespace FirstMvxApp {
    
        [Activity(Label = "FirstMvxApp", MainLauncher = true, NoHistory = true)]
        public class SplashScreen : MvxSplashScreenActivity {
    
            public SplashScreen() : base(Resource.Layout.splash_screen) {
            }
        }
    }

Android 的界面一般是以 xml 的形式声明的， MvvmCross 做了一些扩展， 可以再 xml 界面中直接进行数据绑定， first_view.axml 的内容如下所示：

    <?xml version="1.0" encoding="utf-8"?>
    <LinearLayout xmlns:android="https://schemas.android.com/apk/res/android"
        xmlns:mvx="https://schemas.android.com/apk/res-auto"
        android:orientation="vertical"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent">
        <EditText
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:id="@+id/first_name_edit_text"
            android:hint="Enter first name"
            mvx:MvxBind="Text FirstName" />
        <EditText
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:id="@+id/last_name_edit_text"
            android:hint="Enter last name"
            mvx:MvxBind="Text LastName" />
        <Button
            android:text="Get full name"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:id="@+id/get_full_name_button"
            mvx:MvxBind="Click FullNameCommand" />
        <TextView
            android:textAppearance="?android:attr/textAppearanceLarge"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:id="@+id/full_name_text_view"
            android:hint="Full name is empty."
            android:gravity="center_horizontal"
            mvx:MvxBind="Text FullName" />
    </LinearLayout>

从上面的代码中能看到， 数据绑定全部通过 `mvx:MvxBind` 指令完成了， 不需要再添加数据绑定的代码。

## 小结

MvvmCross 给我的第一印象非常好， MVVM， DataBinding， 这些技术都是每一个 c# 开发者耳熟能详的， 而将这些技术跨平台使用是 MvvmCross 特有的， 接下来还会继续深入学习这个项目， 希望它能越来越好！

[1]: https://msdn.microsoft.com/en-us/library/vstudio/gg597391(v=vs.100).aspx
[2]: https://github.com/MvvmCross/MvvmCross
[3]: https://github.com/beginor/MvvmCross-Learning.git
[4]: https://github.com/MvvmCross/MvvmCross/wiki
[5]: https://github.com/MvvmCross/MvvmCross-Tutorials
