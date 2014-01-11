---
layout: post
title: 设计模式之抽象工厂模式
description: 为一个产品族提供了统一的创建接口。当需要这个产品族的某一系列的时候，可以从抽象工厂中选出相应的系列创建一个具体的工厂类
tags: [设计模式]
keywords: 设计模式, 抽象工厂模式, abstract factory
---

## 结构

![抽象工厂模式](/assets/post-images/abstractfactory.png)

## 说明

Provide an interface for creating families of related or dependent objects without specifying their concrete classes.

为一个产品族提供了统一的创建接口。当需要这个产品族的某一系列的时候，可以从抽象工厂中选出相应的系列创建一个具体的工厂类。

## 适用条件

1. 一个系统要独立于其产品的创建、组合和表示时；
2. 一个系统需要由多个产品系列中的一个来配置时；
3. 需要提供一个产品类库， 而只想显示他们的接口， 而隐藏他们的实现时。

## 实现

    public interface IButton {
    
       void Paint();
    
    }
    
    public interface IGuiFactory {
    
       IButton CreateButton();
    
    }
    
    public class OsxButton : IButton {
    
       public void Paint() {
          Console.WriteLine("I'm an OSXButton");
       }
    
    }
    
    public class WinButton : IButton {
    
       public void Paint() {
          Console.WriteLine("I'm a WinButton");
       }
    
    }
    
    public class OsxFactory : IGuiFactory {
    
       IButton IGuiFactory.CreateButton() {
          return new OsxButton();
       }
    
    }
    
    public class WinFactory : IGuiFactory {
    
       IButton IGuiFactory.CreateButton() {
          return new WinButton();
       }
    
    }
    
    public class Application {
    
       public Application(IGuiFactory factory) {
          var button = factory.CreateButton();
          button.Paint();
       }
    
    }
    
    public class ApplicationRunner {
    
       static IGuiFactory CreateOsSpecificFactory() {
          var sysType = ConfigurationManager.AppSettings["OS_TYPE"] ?? "Win";
          if (sysType == "Win") {
             return new WinFactory();
          }
          return new OsxFactory();
       }
    
       static void Main(string[] args) {
          new Application(CreateOsSpecificFactory());
          Console.ReadKey();
       }
    
    }
