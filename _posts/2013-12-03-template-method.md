---
layout: post
title: 设计模式之模板方法模式
description: 模板方法模式准备一个抽象类，将部分逻辑以具体方法及具体构造子类的形式实现，然后声明一些抽象方法来迫使子类实现剩余的逻辑
tags: [设计模式]
keywords: 设计模式, 模板方法模式, template method
---

## 结构

![模板方法模式](/assets/post-images/template-method.png)

## 说明

Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.

模板方法模式准备一个抽象类，将部分逻辑以具体方法及具体构造子类的形式实现，然后声明一些抽象方法来迫使子类实现剩余的逻辑。不同的子类可以以不同的方式实现这些抽象方法，从而对剩余的逻辑有不同的实现。先构建一个顶级逻辑框架，而将逻辑的细节留给具体的子类去实现。

## 适用条件

1. 一次性实现一个算法的不变的部分， 将可变得行为留给子类来实现；  
2. 各子类中公共的行为应该被提取出来并集中到一个公共父类中以避免代码重复；  
3. 控制子类扩展。

## 实现

    public abstract class Game {
    
       protected int PlayerCount;
    
       public abstract void InitializeGame();
    
       protected abstract void MakePlay(int player);
    
       protected abstract bool EndOfGame();
    
       protected abstract void PrintWinner();
    
       public void PlayOneGame(int playerCount) {
          this.PlayerCount = playerCount;
    
          this.InitializeGame();
    
          var j = 0;
          while (!this.EndOfGame()) {
             this.MakePlay(j);
             j = (j + 1) % this.PlayerCount;
          }
          this.PrintWinner();
       }
    
    }
    
    public class Monopoly : Game {
       
       public override void InitializeGame() {
          Console.WriteLine("Initialize players");
          Console.WriteLine("Initialize money");
       }
    
       protected override void MakePlay(int player) {
          Console.WriteLine("Process one turn of player");
       }
    
       protected override bool EndOfGame() {
          Console.WriteLine("Return true if game is over, according to Monopoly rules.");
          return true;
       }
    
       protected override void PrintWinner() {
          Console.WriteLine("Whow won ?");
       }
    
    }
    
    public class Chess : Game {
       
       public override void InitializeGame() {
          throw new NotImplementedException();
       }
    
       protected override void MakePlay(int player) {
          throw new NotImplementedException();
       }
    
       protected override bool EndOfGame() {
          throw new NotImplementedException();
       }
    
       protected override void PrintWinner() {
          throw new NotImplementedException();
       }
    
    }
    
    class Client {
       
       static void Main(string[] args) {
          Game monopolyGame = new Monopoly();
          monopolyGame.PlayOneGame(4);
    
          Console.ReadKey();
       }
    }
