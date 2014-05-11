---
layout: post
title: 设计模式之单例模式
description: 确保一个类只有一个实例，并提供对该实例的全局访问。
tags: [设计模式]
keywords: 设计模式, 单例模式, singleton
---

## 结构

![单例模式](/assets/post-images/singleton.png)

## 说明

Ensure a class has only one instance, and provide a global point of access to it.

确保一个类只有一个实例，并提供对该实例的全局访问。

## 适用条件

当类只能有一个实例存在， 并且可以在全局进行访问时， 这个唯一的实例应该可以通过子类实现扩展， 并且用户无需更改代码即可使用。

## 实现

    public class DoublecheckSingleton {

       private volatile static DoublecheckSingleton _instance;

       private DoublecheckSingleton() {
       }

       public static DoublecheckSingleton Instance {
          get {
             if (_instance == null) {
                lock (typeof(DoublecheckSingleton)) {
                   if (_instance == null) {
                      Console.WriteLine("Initialize a double check singleton.");
                      _instance = new DoublecheckSingleton();
                   }
                }
             }
             return _instance;
          }
       }
    }

    public class LazySingleton {

       private static readonly Lazy<LazySingleton> LazyInstance = new Lazy<LazySingleton>(() => {
          Console.WriteLine("Initialize a lazy singleton.");
          return new LazySingleton();
       });

       private LazySingleton() {
       }

       public static LazySingleton Instance {
          get {
             return LazyInstance.Value;
          }
       }
    }

    class Program {

       static void Main(string[] args) {

          for (int i = 0; i < 100; i++) {
             Task.Factory.StartNew(() => Console.WriteLine(DoublecheckSingleton.Instance.ToString()));
          }

          for (int i = 0; i < 100; i++) {
             Task.Factory.StartNew(() => Console.WriteLine(LazySingleton.Instance.ToString()));
          }

          Console.ReadKey();
       }
    }
