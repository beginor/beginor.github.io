---
layout: post
title: 设计模式之原型模式
description: 用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象
tags: [设计模式]
keywords: 设计模式, 原型模式, prototype
---

## 结构

![原型模式](/assets/post-images/prototype.png)

## 说明

Specify the kinds of objects to create using a prototypical instance, and create new objects by copying this prototype.

用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。

## 适用条件

原型模式多用于创建复杂的或者耗时的实例，因为这种情况下，复制一个已经存在的实例使程序运行更高效；或者创建值相等，只是命名不一样的同类数据。

## 实现

    abstract class Prototype : ICloneable {

       public abstract int X {
          get;
          set;
       }

       public abstract void PrintX();

       public abstract object Clone();

    }

    class PrototypeImpl : Prototype {

       private int _x;

       public override int X {
          get {
             return this._x;
          }
          set {
             this._x = value;
          }
       }

       public PrototypeImpl(int x) {
          this._x = x;
       }

       public override void PrintX() {
          Console.WriteLine("value : {0}", this.X);
       }

       public override object Clone() {
          return new PrototypeImpl(this._x);
       }
    }

    class Program {

       static void Main(string[] args) {
          Prototype prototype = new PrototypeImpl(1000);

          for (int i = 1; i < 10; i++) {
             var tempotype = (Prototype)prototype.Clone();

             // Usage of values in prototype to derive a new value.
             tempotype.X = tempotype.X * i;
             tempotype.PrintX();
          }

          Console.ReadKey();
       }
    }
