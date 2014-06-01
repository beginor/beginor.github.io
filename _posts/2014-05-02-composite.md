---
layout: post
title: 设计模式之组合模式
description: 把多个对象组成树状结构来表示局部与整体，这样用户可以一样的对待单个对象和对象的组合
tags: [设计模式]
keywords: 设计模式, 组合模式, composite
---

## 结构

![组合模式](/assets/post-images/composite.png)

## 说明

Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly.

把多个对象组成树状结构来表示局部与整体，这样用户可以一样的对待单个对象和对象的组合。

## 适用条件

- 四则运算、逻辑运算以及 SQL 语句等都可以用组合模式表示；
- 命令： 一个命令经常可以有若干个子命令表示；
- 事务： 最典型的事务时测试用例。

## 实现

    interface IGraphic {
    
       void Print();
    
    }
    
    class CompositeGraphic : IGraphic {
    
       private readonly IList<IGraphic> _childGraphics = new List<IGraphic>();
    
       public void Print() {
          foreach (var childGraphic in _childGraphics) {
             childGraphic.Print();
          }
       }
    
       public void Add(IGraphic graphic) {
          this._childGraphics.Add(graphic);
       }
    
       public void Remove(IGraphic graphic) {
          this._childGraphics.Remove(graphic);
       }
    
    }
    
    class Ellipse : IGraphic {
    
       public void Print() {
          Console.WriteLine("Ellipse");
       }
    }
    
    class Program {
    
       static void Main(string[] args) {
          var ellipse1 = new Ellipse();
          var ellipse2 = new Ellipse();
          var ellipse3 = new Ellipse();
          var ellipse4 = new Ellipse();
    
          var graphic = new CompositeGraphic();
          var graphic1 = new CompositeGraphic();
          var graphic2 = new CompositeGraphic();
    
          graphic1.Add(ellipse1);
          graphic1.Add(ellipse2);
          graphic1.Add(ellipse3);
                   
          graphic2.Add(ellipse4);
    
          graphic.Add(graphic1);
          graphic.Add(graphic2);
    
          graphic.Print();
    
          Console.ReadKey();
       }
    }
