---
layout: post
title: 设计模式之享元模式
description: 通过共享以便有效的支持大量小颗粒对象
tags: [设计模式]
keywords: 设计模式, 享元模式, flyweight
---

## 结构

![享元模式](/assets/post-images/flyweight.png)

## 说明

Use sharing to support large numbers of similar objects efficiently.

通过共享以便有效的支持大量小颗粒对象。

## 适用条件

1. 一个程序使用了大量的对象；
2. 完全由于使用大量的对象， 造成了很大的存储开销；
3. 对象的大多数状态都可以变为外部状态；
4. 如果删除对象的外部状态， 那么可以使用相对较少的共享对象取代很多组对象；
5. 应用程序不依赖于对象标识， 由于享元对象可以被共享， 所以概念上明显有别的对象， 标识测试将返回真值；

## 实现

    public interface ICoffeeOrder {
    
       void ServeCoffee(CoffeeOrderContext context);
    
    }
    
    public class CoffeeFlavor : ICoffeeOrder {
    
       public string Flavor {
          get;
          private set;
       }
    
       public CoffeeFlavor(string newFlavor) {
          this.Flavor = newFlavor;
       }
    
       public void ServeCoffee(CoffeeOrderContext context) {
          Console.WriteLine("Serving coffee flavor {0} to table     {1} .", this.Flavor, context.Table);
       }
    
    }
    
    public class CoffeeOrderContext {
    
       public int Table {
          get;
          private set;
       }
    
       public CoffeeOrderContext(int tableNumber) {
          this.Table = tableNumber;
       }
    
    }
    
    public class CoffeeFlavorFactory {
    
       private readonly IDictionary<string, CoffeeFlavor> _flavors     = new Dictionary<string, CoffeeFlavor>();
    
       public CoffeeFlavor GetCoffeeFlavor(string flavorName) {
          CoffeeFlavor flavor;
          if (this._flavors.TryGetValue(flavorName, out flavor)) {
             return flavor;
          }
          flavor = new CoffeeFlavor(flavorName);
          this._flavors.Add(flavorName, flavor);
          return flavor;
       }
    
       public int TotalFlaversMade {
          get {
             return this._flavors.Count;
          }
       }
    
    }
    
    class Program {
    
       private static CoffeeFlavor[] _flavors = new     CoffeeFlavor[100];
       private static CoffeeOrderContext[] _tables = new     CoffeeOrderContext[100];
       private static int _ordersMade;
       private static CoffeeFlavorFactory _factory;
    
       private static void TakeOrder(string flaver, int table) {
          _flavors[_ordersMade] = _factory.GetCoffeeFlavor(flaver);
          _tables[_ordersMade++] = new CoffeeOrderContext(table);
       }
    
       static void Main(string[] args) {
          _factory = new CoffeeFlavorFactory();
    
          TakeOrder("Cappuccino", 2);
          TakeOrder("Cappuccino", 2);
          TakeOrder("Frappe", 1);
          TakeOrder("Frappe", 1);
          TakeOrder("Xpresso", 1);
          TakeOrder("Frappe", 897);
          TakeOrder("Cappuccino", 97);
          TakeOrder("Cappuccino", 97);
          TakeOrder("Frappe", 3);
          TakeOrder("Xpresso", 3);
          TakeOrder("Cappuccino", 3);
          TakeOrder("Xpresso", 96);
          TakeOrder("Frappe", 552);
          TakeOrder("Cappuccino", 121);
          TakeOrder("Xpresso", 121);
    
          for (int i = 0; i < _ordersMade; i++) {
             _flavors[i].ServeCoffee(_tables[i]);
          }
    
          Console.WriteLine();
          Console.WriteLine("Total CoffeeFlavor objects made {0}",     _factory.TotalFlaversMade);
          Console.ReadKey();
       }
    }
