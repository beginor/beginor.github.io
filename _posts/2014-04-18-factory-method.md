---
layout: post
title: 设计模式之工厂方法模式
description: 定义一个接口用于创建对象，但是让子类决定初始化哪个类。工厂方法把一个类的初始化下放到子类
tags: [设计模式]
keywords: 设计模式, 工厂方法模式, factory method
---

## 结构

![工厂方法模式](/assets/post-images/factory-method.png)

## 说明


Define an interface for creating an object, but let subclasses decide which class to instantiate. Factory Method lets a class defer instantiation to subclasses .

定义一个接口用于创建对象，但是让子类决定初始化哪个类。工厂方法把一个类的初始化下放到子类。

## 适用条件

当一个类不知道它所必须创建对象的类或一个类希望由子类指定它所创建的对象时， 可以采用工厂方法。

## 实现

    abstract class MazeGame {
    
       private readonly IList<Room> _rooms = new List<Room>();
       
       protected MazeGame() {
          var room1 = this.MakeRoom();
          var room2 = this.MakeRoom();
          room1.Connect(room2);
          this.AddRoom(room1);
          this.AddRoom(room2);
       }
    
       private void AddRoom(Room room) {
          this._rooms.Add(room);
       }
    
       protected abstract Room MakeRoom();
    
    }
    
    class MagicMazeGame : MazeGame {
    
       protected override Room MakeRoom() {
          return new MagicRoom();
       }
    }
    
    class Room {
    
       private Room _next;
    
       public void Connect(Room other) {
          this._next = other;
       }
    }
    
    class MagicRoom : Room {
       
    }
    
    class Program {
       
       static void Main(string[] args) {
    
          MazeGame game = new MagicMazeGame();
    
          Console.ReadKey();
       }
    }

.Net Framework 之中， Ado.Net 的 IDbConnection 的 CreateCommand 方法， 可以说是典型的 工厂方法模式。