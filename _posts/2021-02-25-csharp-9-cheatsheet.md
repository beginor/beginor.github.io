---
layout: post2
title: C# 9.0 特性备忘录
description: C# 9.0 特性备忘录
keywords: csharp, c# 9.0, features, top-level, pattern
tags: [.NET]
---

## 顶级语句

顶级语句可以删除程序中不必要的代码， 以最简单的 `Hello, world!` 为例：

```c#
using System;

namespace HelloWorld {

    class Program {

        static void Main(string[] args) {
            Console.WriteLine("Hello World!");
        }
    }
}
```

如果使用顶级语句的话， 可以简化为：

```c#
using System;

Console.WriteLine("Hello World!");
```

如果不使用 `using` ， 还可以更加简化：

```c#
System.Console.WriteLine("Hello World!");
```

顶级语句在很多命令行程序、小工具程序中会非常有用， 对应用程序的作用域或者复杂程度没有任何限制。

> 注意， 一个程序中， 只能有一个文件使用顶级语句， 并且顶级语句必须位于命名空间或类型定义之前！

## 弃元参数

在 lambda 表达式或者匿名函数中如果要忽略某个参数， 可以用 `_` 代替。

```c#
var button = new Button("Click Me!");

button.Click += (_, e) => { /* other code goes here. */ };
```

## 仅初始化设置器 （Init only setters）

创建只能通过对象初始化进行赋值的属性。

```c#
public class InitDemo {
    public string Start { get; init; }
    public string Stop { get; init; }
}

// initDemo.Start = "Now"; // Error
// initDemo.End = "Tomorrow"; // Error

var initDemo = new InitDemo {
    Start = "Now",
    Stop = "Tomorrow"
};
```

## 记录类型  (Record)

记录类型， 是一种引用类型， 默认是不可变的。 记录类型的相等判断可以通过引用或者结构进行判断的。

```c#
// 默认不可变的记录类型
public record Person(string Name, int Age);
// 可变记录类型
public record MutablePerson(string Name, int Age) {
    public string Name { get; set; } = Name;
    public int Age { get; set; } = Age;
}

var person1 = new Person("Zhimin Zhang", 40);
var person2 = new Person("Zhimin Zhang", 40);

Console.WriteLine(person1 == person2);   // True 结构相同
Console.WriteLine(person1.Equals(person2)); // True 结构相同
Console.WriteLine(ReferenceEquals(person1, person2)); // False, 引用不同

// 改变默认的记录！ --> 创建一个新的记录。
var person3 = person1 with { Age = 43 };
Console.WriteLine(person3 == person1); // False 结构不同

// 解构 (Destruct) 一个记录， 将记录的属性提取为本地变量
var (name, age) = person3;

var person4 = new MutablePerson("Zhimin zhang", 40);
person4.Age = 43;

var person5 = new Citizen("Zhimin Zhang", 40, "China");
Console.WriteLine(person1 == person5);

// 记录类型也可以被继承
public record Citizen(string Name, int Age, string Country) : Person(Name, Age);
var citizen = new Citizen("Zhimin Zhang", 40, "China");
Console.WriteLine(person1 == citizen); // False 类型不同；
```

- 优点：记录类型是轻量级的不可变类型，可以减少大量的代码， 可以按照结构和引用进行比较；
- 缺点：需要实例化大量的对象；

> 如果要更加深入的学习记录类型， 请查看微软的官方文档 [exploration of records](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/exploration/records) 。

## 模式匹配增强

C# 9 包含了一些新的模式匹配增强：

- ***Type patterns*** 类型匹配，判断一个变量的类型

  ```c#
  object obj = new int();
  var type = obj switch {
      string => "string",
      int => "int",
      _ => "obj"
  };
  Console.WriteLine(type); // int
  ```

- ***Relational patterns*** 关系匹配

  ```c#
  // Relational patterns
  var person1 = new Person("Zhimin Zhang", 40);
  var inRange = person1 switch {
      (_, < 18) => "less than 18",
      (_, > 18) => "greater than 18",
      (_, 18) => "18 years old!"
  };
  Console.WriteLine(inRange); // greater than 18
  ```

- ***Conjunctive `and` patterns*** 逻辑与匹配

  ```c#
  // And pattern
  var person1 = new Person("Zhimin Zhang", 40);
  var ageInRange = person1 switch {
      (_, < 18) => "less than 18",
      ("Zhang Zhimin", _) and (_, >= 18) => "Zhimin Zhang is greater than 18"
  };
  Console.WriteLine(ageInRange); // Zhimin Zhang is greater than 18
  ```

- ***Disjunctive `or` patterns*** 逻辑或匹配

  ```c#
  // Or pattern
  var person1 = new Person("Zhimin Zhang", 40);
  var ageInRange = person1 switch {
      (_, < 18) => "less than 18",
      (_, 18) or (_, > 18) => "18 or greater"
  };
  Console.WriteLine(ageInRange); // 18 or greater
  ```

- ***Negated `not` patterns*** 逻辑非匹配

  ```c#
  // Not pattern
  var person1 = new Person("Zhimin Zhang", 40);
  var meOrNot = person1 switch {
      not ("Zhimin Zhang", 40) => "Not me!",
      _ => "Me :-)"
  };
  Console.WriteLine(meOrNot); // Me :-)
  ```

- ***Parenthesized patterns*** 带括号的优先级匹配

  ```c#
  // Parenthesized patterns
  var is10 = new IsNumber(true, 10);
  var n10 = is10 switch {
      ((_, > 1 and < 5) and (_, > 5 and < 9)) or (_, 10) => "10",
      _ => "not 10"
  };
  Console.WriteLine(n10); // 10
  ```

> 注意， 如果没有匹配到全部的情况， 将会出现异常。

## 新的初始化表达式

在C＃9.0中，当已创建对象的类型已知时，可以在[`new`表达式中](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/new-operator)省略该类型。

```c#
public class MyClass {
    private List<WeatherObservation> _observations = new();
}

Point p = new(1, 1);
Dictionary<string, int> dict = new();

Point[] points = { new(1, 1), new (2, 2), new (3, 3) };
var list = new List<Point> {
    new(1, 1), new(2, 2), new(3, 3)
};
```

- **优点**： 可以让代码更加简洁；
- **缺点**： 某些情况下会让代码更难理解；

## 目标类型条件表达式

可以隐式转换 `null` 值， 在 C#9.0 中得到了增强。

```c#
void TestMethod(int[] list, uint? u) {
    int[] x = list ?? new int[0];
    var l = u ?? -1u;
}
```

## GetEnumerator 扩展

可以为任意类型添加一个 `GetEnumerator<T>` 扩展， 返回一个 `IEnumerator<T>` 或者 `IAsyncEnumerator<T>` 实例， 从而在 foreach 循环中使用。

```c#
public static class Extensions {
    public static IEnumerator<T> GetEnumerator<T>(this IEnumerator<T> enumerator) => enumerator;
}

IEnumerator<string> enumerator = new Collection<string> {
    "A", "B", "C"
}.GetEnumerator();

foreach (var item in enumerator) {
    Console.WriteLine(item);
}
```

## 在本地函数上添加标记

允许在本地函数上添加标记。

```c#
static void Main(string[] args) {
  
  [Conditional("DEBUG")]
  static void DoSomething([NotNull] string test) {
    Console.WriteLine("Do it!");
  }
  
  DoSomething("Doing!");
}
```

## 分部方法扩展

在C#9.0中，移除了分部方法的几个限制：

1. 必须具有 `void` 返回类型。
2. 不能具有 `out` 参数。
3. 不能具有任何可访问性（隐式 `private` ）。

```c#
partial class Doing {
  internal partial bool DoSomething(string s, out int i);
}

partial class Doing {
  internal partial bool DoSomething(string s, out int i) {
    i = 0;
    return true;
  }
}
```

## 静态 lambda 表达式

从 C＃9.0 开始，可以将 `static` 修饰符添加到 [lambda 表达式](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/lambda-expressions)或 [匿名方法](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/delegate-operator) 。静态 lambda 表达式类似于 `static` 局部函数：静态lambda或匿名方法无法捕获局部变量或实例状态。 所述 `static` 可以防止意外捕获其他变量。

lambda 表达式会捕获上下文的变量，不仅会有性能的问题，而且还可能出现错误，比如：

```c#
int number = 0;

Func<string> toString = () => number.ToString(); // number 被自动捕获进 toString 函数中
```

可以在 lambda 表达式前添加 `static` 关键字， 来解决这个问题：

```c#
int number = 0;
Func<string> toString = static () => number.ToString(); // 这里无法再使用 number ；
```

## 模块初始化代码

可以使用 [ModuleInitializerAttribute](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.compilerservices.moduleinitializerattribute) 为组件 (assembly) 定义初始化代码， 当初始化/加载时执行， 可以类比类的静态构造函数， 但是是组件级别的， 要求如下：

- 必须是静态的、无参数的、无返回值的方法；
- 不能是范型方法，也不能包含在范型类中；
- 不能是私有函数，必须是公开 (public) 或者内部 (internal) 的函数；

```c#
[ModuleInitializer]
public static void DoSomethingBeforeMain() {
    Console.WriteLine(“Huhu”);
}
```

## 协变返回类型

协变返回类型为[重写](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/override)方法的返回类型提供了灵活性。覆盖方法可以返回从覆盖的基础方法的返回类型派生的类型。这对于记录和其他支持虚拟克隆或工厂方法的类型很有用。 比如：

```c#
public virtual Person GetPerson() { return new Person(); }

public override Person GetPerson() { return new Student(); }
```

在 C# 9.0 中， 可以在子类中返回更加详细的类型：

```c#
public virtual Person GetPerson() { return new Person(); }

public Student Person GetPerson() { return new Student(); }
```

## 原生整数类型

C#9 添加了两个新的整数类型 (`nint` 和 `nunit`) ， 依赖宿主机以及编译设定。

```c#
nint nativeInt = 55;
Console.WriteLine(nint.MaxValue);

// 在 x86 平台上， 输出为 2147483647

// 在 x64 平台上， 输出为 9223372036854775807
```

- **优点**：可以更好的兼容原生API；
- **缺点**：缺失平台无关性；

## 跳过本地初始化 (SkipLocalInit)

在 C#9.0 中，可以使用 [SkipLocalsInitAttribute](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.compilerservices.skiplocalsinitattribute) 来告知编译器不要发射 (Emit) .locals init 标记。

```c#
[System.Runtime.CompilerServices.SkipLocalsInit]
static unsafe void DemoLocalsInit() {
    int x;
    // 注意， x 没有初始化， 输出结果不确定；
    Console.WriteLine(*&x);
}
```

- **优点**：跳过本地初始化可以提升程序的性能；
- **缺点**：性能的影响通常不大，建议只在极端情况下才使用这个；

## 函数指针

使用 `delegate*` 可以声明函数指针。

```c#
unsafe class FunctionPointer {
  static int GetLength(string s) => s.Length;
  delegate*<string, int> functionPointer = &GetLength;
}

public void Test() {
  Console.WriteLine(functionPointer("test")); // 4;
}
```

