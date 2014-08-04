---
layout: post
title: 给 c# 程序员的十个重要提示
keywords: c#, internal visible to, tuples, yiels, linq, defered execute,
description: 本文讲述我认为对 c# 程序员最重要的 10 个提示， 每个提示都会有一段对应的代码， 对新手来说也很容易掌握
tags: [转载, 参考, 教程]
---
本文讲述我认为对 c# 程序员最重要的 10 个提示， 每个提示都会有一段对应的代码， 对
新手来说也很容易掌握。

### 1:  为非公开的方法编写测试

你尝试过为组件的非公开方法写测试么？ 很多开发者都没有写过， 因为这些方法对测试项
目来说是不可见的。 c# 可以通过在 `AssemblyInfo.cs` 中添加下面的标记
(`InternalsVisibleToAttribute`) ， 让内部成员对其它组件可见。

``` csharp
//Make the internals visible to the test assembly
[assembly: InternalsVisibleTo("MyTestAssembly")]
```

### 2: 使用 Tuples 类型

曾经见到过有人仅仅因为函数要返回多个值而创建了一个 POCO 类， 其实 .Net 4.0 中的
`Tuples` 类型会更加适用， 例如：

``` csharp
public Tuple<int, string, string> GetEmployee() {
    int employeeId = 1001;
    string firstName = "Rudy";
    string lastName = "Koertson";
    
    //Create a tuple and return
    return Tuple.Create(employeeId, firstName, lastName);
}
```

### 3: 用 yield 替代临时集合

从集合中选出部分成员时， 通常会创建一个临时集合/列表来保存成员并返回， 例如下面
的代码：

``` csharp
public List<int> GetValuesGreaterThan100(List<int> masterCollection) {
    List<int> tempResult = new List<int>();

    foreach (var value in masterCollection) {
        if (value > 100) {
            tempResult.Add(value);
        }
    }
    return tempResult;
}
```

要避免这样的临时集合， 可以使用 `yield` 关键字， 示例如下：

``` csharp
public IEnumerable<int> GetValuesGreaterThan100(List<int> masterCollection) {
    foreach (var value in masterCollection) {
        if (value > 100) {
            yield return value;
        }
    }
}
```

当然， 也可是使用 LINQ 来解决上面的问题。

### 4: 告诉别人你将替换一个方法

当你有一个组件时， 并且你打算替换其中的一个方法时， 可以先为方法添加过时标记以通
知客户端， 示例代码如下：

``` csharp
[Obsolete("This method will be deprecated soon. You could use XYZ alternatively.")]
public void MyComponentLegacyMethod() {
    //Here is the implementation
}
```

使用这个方法客户端在编译时会发出一个警告， 如果你不再允许客户端使用过时的方法时，
可以为过时标记添加一个额外的布尔参数， 在下面的例子中， 客户但程序将编译失败：

``` csharp
[Obsolete("This method is deprecated. You could use XYZ alternatively.", true)]
public void MyComponentLegacyMethod() {
    //Here is the implementation
}
```

### 5: 牢记 LINQ 查询是延迟执行的

在 .NET 中编写 LINQ 查询时， 只有当你访问 LINQ 查询的结果时， LINQ 查询才会被执
行， LINQ 的这种特征被称为延迟执行， 不过值得注意的是每访问一次结果， LINQ 查询
都会被执行一次。

为了避免重复 LINQ 查询的重复执行， 可以先将查询转换成列表， 如下所示：

``` csharp
public void MyComponentLegacyMethod(List<int> masterCollection) {
    // 在下面示例中， 如果没有调用 ToList ， LINQ 查询将会被执行两次
    var result = masterCollection.Where(i => i > 100).ToList();
    Console.WriteLine(result.Count());
    Console.WriteLine(result.Average());
}
```

### 6: 使用 explicit 关键字转换业务实体类型

使用 `explicit` 关键字来定义业务实体类型之间的转换， 当代码中出现类型转换请求时，
转换方法会自动执行， 下面是示例代码：

``` csharp
class Program {

    static void Main(string[] args) {
        var entity = new ExternalEntity {
            Id = 1001,
            FirstName = "Dave",
            LastName = "Johnson"
        };
        var convertedEntity = (MyEntity)entity;
    }
}
 
class MyEntity {

    public int Id { get; set; }
    public string FullName { get; set; }
 
    public static explicit operator MyEntity(ExternalEntity externalEntity) {
        return new MyEntity {
            Id = externalEntity.Id,
            FullName = externalEntity.FirstName + " " + externalEntity.LastName
        };
    }
}
 
class ExternalEntity {
    public int Id { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}
```

### 7: 保持异常的原始堆栈跟踪

在 c# 代码中， 如果你像下面的代码一样在 `catch` 代码块中抛出 `ConnectDatabase`
方法中出现的异常， 异常的堆栈就会只显示到 `RunDataOperation` 方法， 这样就会丢失
异常原始的堆栈跟踪信息导致不能找到确切的错误源头。

``` csharp
public void RunDataOperation() {
    try {
        Intialize();
        ConnectDatabase();
        Execute();
    }
    catch (Exception exception) {
        throw exception;
    }
}
```

保持原始堆栈跟踪的代码如下：

``` csharp
public void RunDataOperation() {
    try {
        Intialize();
        ConnectDatabase();
        Execute();
    }
    catch (Exception) {
        throw;
    }
}
```

### 8: 使用 Flags 标记将枚举作为位域处理

在 c# 中为枚举类型添加 `Flags` 标记可以将枚举作为位域（即一组标志）处理， 这样可
以对枚举值进行自由组合， 示例代码如下：

``` csharp
class Program {
    static void Main(string[] args) {
        int snakes = 14;
        Console.WriteLine((Reptile)snakes);
    }
}

[Flags]
enum Reptile {
    BlackMamba = 2,
    CottonMouth = 4,
    Wiper = 8,
    Crocodile = 16,
    Aligator = 32
}
```
 
上面代码的输出为 “BlackMamba, CottonMouth, Wiper” ， 如果没有 Flags 标记， 则上
面的输出为 14 。

### 9: 为泛型添加类型约束

创建泛型类型时， 需要指定提供的泛型类型必须实现指定的参数或者继承自特定的基类时，
可以这样做：

``` csharp
class MyGenricClass<T> where T : IMyInterface {
    //Body of the class come in here
}
```

当然， 也可以在方法级别这样做：

``` csharp
class MyGenricClass {

    public void MyGenericMethod<T>(T t) where T : IMyInterface {
        //Generic implementation goes in here
    }

}
```

### 10: IEnumerable 类型不能确保只读

在你创建的类型中， 暴露了一个类型为 `IEnumerable` 的只读属性， 但是调用者依然可
以通过类型转换来修改属性的内容， 比如这样：

``` csharp
class Program {

    static void Main(string[] args) {
        MyClass myClass = new MyClass();
        ((List<string>)myClass.ReadOnlyNameCollection).Add("######From Client#####");

        myClass.Print();
    }
}

class MyClass {

    List<string> _nameCollection = new List<string>();

    public MyClass() {
        _nameCollection.Add("Rob");
        _nameCollection.Add("John");
        _nameCollection.Add("Jummy");
        _nameCollection.Add("Derek");
    }
    
    public IEnumerable<string> ReadOnlyNameCollection {
        get { return _nameCollection.AsEnumerable(); }
    }

    public void Print() {
        foreach (var item in ReadOnlyNameCollection) {
            Console.WriteLine(item);
        }
    }
}
```

上面的代码修改了列表， 添加了一个新项目， 要避免这种情况， 应使用 `AsReadOnly`
而不是 `AsEnumerable` ：

``` csharp
public IEnumerable<string> ReadOnlyNameCollection {
    get { return _nameCollection.AsReadOnly(); }
}
```

希望这些提示对你有用！

原文地址： [Top 10 Tips for C# Programmers](http://www.developer.com/net/top-10-tips-for-c-programmers.html)