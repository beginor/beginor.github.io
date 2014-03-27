---
layout: post
title: 在 MvvmCross 下使用 iOS Storyboard
description: 介绍如何在 MvvmCross 框架下使用 iOS Storyboard
keywords: xamarin, ios, mvvmcross, mvx, storyboard, MvxTouchViewsContainer, MvxTouchViewPresenter
tags: [Xamarin, iOS, MvvmCross]
---

![Storyboard](/assets/post-images/storyboard.jpg)

Storyboard 的优点

- 可视化;
- XamarinStudio 自带 Storyboard 编辑器， 不用启动 Xcode 。

Storyboard 的缺点：

- 只有一个文件， 不利于多人同时编辑；
- 在 MvvmCross 不推荐使用 UIStoryboardSegue ， 因为和 Mvx 的 Command 功能上冲突， 这里以 Mvx 为主。

可能是因为上面的缺点吧， Mvx 没有提供内置的 Storyboard 支持。 不过 Mvx 的扩展性是很强大的， 通过自定义 `MvxTouchViewsContainer` 就可以实现对 Storyboard 的支持。

## 添加 Storyboard 支持需要的步骤

### 初始化 Storyboard

在 `AppDelegate` 中添加一个 `Storyboard` 属性， 并在 `FinishedLaunching` 方法中加载 Storyboard 文件， 代码如下所示：

    [Register("AppDelegate")]
    public partial class AppDelegate : MvxApplicationDelegate {

        public override UIWindow Window { get; set; }

        public UIStoryboard Storyboard { get; set; }

        public override bool FinishedLaunching(UIApplication application, NSDictionary launchOptions) {
            Window = new UIWindow(UIScreen.MainScreen.Bounds);

            Storyboard = UIStoryboard.FromName("MainStoryboard", null);

            var setup = new Setup(this, Window);
            setup.Initialize();
            var startup = Mvx.Resolve<IMvxAppStart>();
            startup.Start();

            Window.MakeKeyAndVisible();
            return true;
        }
    }

### 自定义 ViewsContainer

Mvx 使用 `MvxTouchViewsContainer` 创建视图的实例， 因此需要创建自定义的 `StoryboardViewsContainer` ， 继承自 `MvxTouchViewsContainer` ， 并重写 `CreateViewOfType` 方法， 示例代码如下：

    public class StoryboardViewsContainer : MvxTouchViewsContainer {

        protected override IMvxTouchView CreateViewOfType(Type viewType, MvxViewModelRequest request) {
            var typeName = viewType.Name;
            var appDelegate = UIApplication.SharedApplication.Delegate as AppDelegate;
            if (appDelegate != null) {
                var view = appDelegate.Storyboard.InstantiateViewController(typeName);
                return (IMvxTouchView)view;
            }
            // 无法通过 Storyboard 找到对应的 ViewController ， 尝试调用基类的方法创建 ViewController
            return base.CreateViewOfType(viewType, request);
        }
    }

### 在 Setup 中设置使用自定义的 StoryboardViewsContainer

重写 `Setup` 中的 `CreateTouchViewsContainer` 方法， 返回上面自定义的 `StoryboardViewsContainer`， 示例代码如下：

    public class Setup : MvxTouchSetup {

        public Setup(MvxApplicationDelegate applicationDelegate, UIWindow window) : base(applicationDelegate, window) {
        }

        protected override IMvxApplication CreateApp() {
            return new MvxTabs.Core.App();
        }

        protected override IMvxTouchViewsContainer CreateTouchViewsContainer() {
            return new StoryboardViewsContainer();
        }
    }

> 需要注意的是， Mvx 需要一个 `UINavigationController` 作为整个程序的入口， 上面自定义的 ViewContainer 并不包含这个， 如果要创建自定义的 `UINavigationController` ， 则需要重写 `MvxTouchViewPresenter` 的 UINavigationController 方法。

对于 Storyboard 的要求

- ViewController 的 identifier 必须填写， 因为 Storyboard 只能通过 InstantiateViewController 来创建 ViewController 实例；
- 修改 ViewController 对应类型的基类， 继承自对应的 Mvx***ViewController；
- 在本文的例子中， 必须与 ViewController 对应的类名相同。
