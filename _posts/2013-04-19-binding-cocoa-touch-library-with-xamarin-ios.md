---
title: MonoTouch绑定CocoaTouch类库
description: 互联网上有很多热心网友提供的 CacoaTouch 类库， 如果想使用这些类库， 完全用 C# 重写是不可取的， 所以就要用到 MonoTouch 的绑定技术。
layout: post
tags: [Mono, iOS]
---

#### 绑定概述

在 Windows/Linux 平台上， .Net/Mono 可以通过平台调用 (P/Invoke) 技术调用本地类库， 通过互操作 (Interop) 技术调用 COM 组件， 在 iOS 平台上， MonoTouch 也有类似的技术， 可以调用 iOS 的 CocoaTouch 类库， 这种技术在 MonoTouch 叫做绑定 (Binding) ， 整个 monotouch.dll 就是用绑定技术完成的。

互联网上有很多热心网友提供的 CacoaTouch 类库， 如果想使用这些类库， 完全用 C# 重写是不可取的， 所以就要用到 MonoTouch 的绑定技术。

绑定技术听起来高深， 其实仔细研究起来， 其实并不难。 接下来， 以 [KKGridView](https://github.com/kolinkrewinkel/KKGridView) 为例， 说明怎样绑定 CocoaTouch 类库项目。

#### 准备 MonoTouch 绑定项目

新建一个名称为 KKGridView 的空白解决方案， 作为工作区， 再新建一个绑定项目， 名称为 Binding ， 项目建好之后， 设置绑定项目的默认命名空间为 MonoTouch.KKGrid ， 并设置项目的输出为 KKGridView ， 相关截图如下：

![新建绑定项目](/assets/post-images/prepair-binding-project.png)

如下， 包含两个文件： ApiDeginition.cs 和 StructsAndEnums.cs ， 其中 ApiDefinition 用于绑定 CacoaTouch 类库定义的 interface 、 delegate 与 protocol 及其成员， 而 StructsAndEnums 用于绑定 ApiDefinition 所需的结构、 枚举以及其它。 这两个文件的编译方式是不同的， 所以对应的 C# 类型必须对号入座才行。

![绑定项目默认结构](/assets/post-images/binding-project-structor.png)

#### 获取 KKGridView 源代码并编译

KKGridView 在 GitHub 上的主页是 [https://github.com/kolinkrewinkel/KKGridView.git](https://github.com/kolinkrewinkel/KKGridView.git) ， 使用 git 可以轻松获取其源代码。 打开一个命令行窗口， 切换到绑定项目目录， 输入下面的命令：

    git clone https://github.com/kolinkrewinkel/KKGridView.git

等命令行运行完毕， 源代码就获取好了， 接下来要编译 KKGridView ， 接着输入下面的命令：

    cd KKGridView
    xcodebuild -project KKGridView.xcodeproj -target KKGridView -sdk iphonesimulator -configuration Release clean build
    xcodebuild -project KKGridView.xcodeproj -target KKGridView -sdk iphoneos -configuration Release clean build
    lipo -create -output libKKGridView.a build/Release-iphonesimulator/libKKGridView.a build/Release-iphoneos/libKKGridView.a

现在打开 MonoDevelop 将最终生成的 libKKGridView.a 添加到绑定项目 ， 现在可以开始进行绑定了。

#### 绑定 Objective-C 类型至 C#

绑定的语法定义为：

<pre><code>
    [BaseType(typeof(TypeBase))]
    interface MyType [: Prodocol1, Protocol2] {
       IntPtr Constructor(string foo);
    }
</code></pre>

MyType 与 ObjC 的类型对应， TypeBase 与 ObjC 的基类对应， Protocol1 、 Prodocol2 与 ObjC 类型实现的协议对应。

**interface**

ObjC 的 interface 定义如下：

    @interface KKGridView : UIScrollView
    @end

对应的绑定语法如下：

<pre><code>
    [BaseType(typeof(UIScrollView))]
    interface KKGridView {
    }
</code></pre>
>
**protocol**

ObjC 的 protocol 定义语法如下：

    @protocol KKGridViewDataSource <NSObject>
    @end

或者

    @protocol KKGridViewDelegate <NSObject , UIScrollViewDelegate>
    @end

ObjC 的 protocol 与 C# 的 interface 有些类似， 但是 protocol 中定义的方法有两种， optional 和 required ， 又有点儿像抽象类， MonoTouch 将其绑定为类， 并添加 ModelAttribute 标记， 对应的绑定语法分别为：

<pre><code>
    [Model, BaseType(typeof(NSObject))]
    interface KKGridViewDataSource {
    }
 
    [Model, BaseType(typeof(UIScrollViewDelegate))]
    interface KKGridViewDelegate {
    }
</code></pre>
>
**instance method**

实例方法绑定为对应的 C# 实例方法：

    - (NSString *)gridView:(KKGridView *)gridView titleForHeaderInSection:(NSUInteger)section;
 
    [Export("gridView:titleForHeaderInSection:")]
    string GridViewTitleFoHeaderInSection(KKGridView gridView, uint section);

如果是 protocol 的 required 方法， 则在对应的 C# 方法上添加 Abstract 标记， 例如：

    - (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section;

    [Abstract, Export("gridView:numberOfItemsInSection:")]
    uint GridViewNumberOfItemsInSection(KKGridView gridView, uint section);

**class method**

ObjC 中的 class method 与 C# 中的静态方法概念一致， 因此绑定为 C# 的静态方法， 例如：

    + (id)cellForGridView:(KKGridView *)gridView;

    [Static, Export("cellForGridView:")]
    KKGridViewCell CellFroGridView(KKGridView gridView);

**property**

ObjC 的属性通常由 setPropertyName 、 propertyName 两个方法组成， 绑定为 C# 的属性：

    @property (nonatomic) BOOL allowsMultipleSelection;

    [Export("allowsMultipleSelection")]
    bool AllowsMultipleSelection { get; set; }

如果不是由默认的两个方法组成， 例如：

    @property (nonatomic, getter = isSelected) BOOL selected;

    [Export("selected")]
    bool Selected { [Bind("isSelected")]get; set; }

对应的绑定为：

    [Export("selected")]
    bool Selected { [Bind("isSelected")]get; set; }

**enum**

枚举的绑定是最容易的， 不过要放在 enums.cs 文件中， 例如：

    typedef enum {
       KKGridViewAnimationFade,
       KKGridViewAnimationResize,
       KKGridViewAnimationSlideLeft,
       KKGridViewAnimationSlideTop,
       KKGridViewAnimationSlideRight,
       KKGridViewAnimationSlideBottom,
       KKGridViewAnimationExplode,
       KKGridViewAnimationImplode,
       KKGridViewAnimationNone
    } KKGridViewAnimation;

    public enum KKGridViewAnimation {
       Fade,
       Resize,
       SlideLeft,
       SlideTop,
       SlideRight,
       SlideBottom,
       Explode,
       Implode,
       None
    }

#### 添加 Makefile

    # 定义一些常量
    PROJECT_ROOT=KKGridView
    PROJECT=$(PROJECT_ROOT)/$(PROJECT_ROOT).xcodeproj
    BUILD_ROOT=$(PROJECT_ROOT)/Build
    TARGET=$(PROJECT_ROOT)
    SDK=lib$(TARGET).a
    BTOUCH=/Developer/MonoTouch/usr/bin/btouch
    SMCS=/Developer/MonoTouch/usr/bin/smcs
    XBUILD=/Developer/usr/bin/xcodebuild
     
    # 从github获取源代码
    $(PROJECT_ROOT):
       git clone https://github.com/kolinkrewinkel/$(PROJECT_ROOT).git
       cd $(PROJECT_ROOT) && git pull
     
    # 编译模拟器版本
    simulator: $(PROJECT_ROOT)
       mkdir -p libs
       $(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -configuration Release clean build
       mv -f $(BUILD_ROOT)/Release-iphoneSimulator/lib$(TARGET).a ./libs/lib$(TARGET)-simulator.a
     
    # 编译设备版本
    iphoneos: $(PROJECT_ROOT)
       mkdir -p libs
       $(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -configuration Release clean build
       mv -f $(BUILD_ROOT)/Release-iphoneos/lib$(TARGET).a ./libs/lib$(TARGET)-iphoneos.a
     
    # 讲两个版本合成为一个
    sdk:
       lipo -create -output $(SDK) libs/lib$(TARGET)-simulator.a libs/lib$(TARGET)-iphoneos.a
     
    # 编译 MonoTouch 组件
    asm:
       # 使用 btouch 编译出的 dll 文件总是无法运行， 不知是怎么回事， 只能用 MonoDevelop 进行编译， 所以把这里注释掉了。
       #$(BTOUCH) -d=MONOTOUCH -out:bin/$(TARGET).dll api.cs -s:enum.cs --link-with=$(SDK),$(SDK)
     
    # 清理
    clean:
       rm -rf $(PROJECT_ROOT) libs ios *.a *.dll *.stamp
     
    # 全部任务
    all: clean simulator iphoneos sdk asm

#### 绑定项目源代码

KKGridView 的全部绑定源代码放在 GitHub ， 地址为 [https://github.com/beginor/MonoTouch.KKGridView](https://github.com/beginor/MonoTouch.KKGridView) ， 有兴趣的可以围观。