---
layout: post
title: 设计模式之装饰器模式
description: 向某个对象动态地添加更多的功能。修饰模式是除类继承外另一种扩展功能的方法。
tags: [设计模式]
keywords: 设计模式, 装饰器模式, decorator
---

## 结构

![装饰器模式](/assets/post-images/decorator.png)

## 说明

Attach additional responsibilities to an object dynamically keeping the same interface. Decorators provide a flexible alternative to subclassing for extending functionality.

向某个对象动态地添加更多的功能。修饰模式是除类继承外另一种扩展功能的方法。

## 适用条件

- 在不影响其他对象的情况下， 以动态且透明的方式添加单个对象的功能；
- 处理那些可以撤销的功能；
- 不能采用生成子类的方法扩充时；

## 实现

    interface IWindow {
    
       void Draw();
    
       string GetDescription();
    
    }
    
    class SimpleWindow : IWindow {
       
       public void Draw() {
          //
       }
    
       public string GetDescription() {
          return "Simple window";
       }
    }
    
    class WindowDecorator : IWindow {
       
       protected IWindow DecoratedWindow;
    
       public WindowDecorator(IWindow decoratedWindow) {
          this.DecoratedWindow = decoratedWindow;
       }
    
       public virtual void Draw() {
          this.DecoratedWindow.Draw();
       }
    
       public virtual string GetDescription() {
          return "Window decorator";
       }
    
    }
    
    class VerticalScrollbarWindow : WindowDecorator {
    
       public VerticalScrollbarWindow(IWindow decoratedWindow) : base(    decoratedWindow) {
       }
    
       public override void Draw() {
          base.Draw();
          this.DrawVerticalScrollbar();
       }
    
       private void DrawVerticalScrollbar() {
          //
       }
    
       public override string GetDescription() {
          return this.DecoratedWindow.GetDescription() + ", include vertical     scrollbars";
       }
    
    }
    
    class HorizontalScrollbarWindow : WindowDecorator {
    
       public HorizontalScrollbarWindow(IWindow decoratedWindow) : base(    decoratedWindow) {
       }
    
       public override void Draw() {
          base.Draw();
          this.DrawHorizontalScrollbar();
       }
    
       private void DrawHorizontalScrollbar() {
          //
       }
    
       public override string GetDescription() {
          return this.DecoratedWindow.GetDescription() + ", include horizontal     scrollbars";
       }
    
    }
    
    class Program {
       
       static void Main(string[] args) {
          IWindow window = new HorizontalScrollbarWindow(new VerticalScrollbarWindow    (new SimpleWindow()));
          Console.WriteLine(window.GetDescription());
    
          Console.ReadKey();
       }
    }
