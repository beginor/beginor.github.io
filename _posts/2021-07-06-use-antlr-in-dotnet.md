---
layout: post2
title: 在 .NET 应用中使用 ANTLR
description: 介绍如何在 .NET 应用中使用 ANTLR
keywords: dotnet, antlr, grammar, parser, dotnet core
tags: [.NET, ANTLR]
---

## 什么是 ANTLR ？

[ANTLR](https://www.antlr.org/) 是功能强大的解析器生成器，用于读取，处理，执行或翻译结构化文本或二进制文件。它被广泛用于构建语言，工具和框架。ANTLR从语法中生成一个解析器，该解析器可以构建和遍历解析树。

## ANTLR 语法库

ANTLR 为常见的语言构建了语法文件， 可以直接下载使用 <https://github.com/antlr/grammars-v4> 。 如果需要在程序中处理常用的语言， 可以先来这里找一下。

## 如何在 .NET 中使用 ANTLR ？

ANTLR 被广泛应用与大数据分析、 人工智能等领域的语法分析， 网上的相关资料确实非常多， 但是 .NET 相关的资料却很少， 有的也是年代久远， 几乎没有什么参考价值。

经过一番摸索， 终于找到了在 .NET 中使用 ANTLR 的正确方法， 于是记录下来。

### 新建 .NET 命令行项目

1. 首先， 当然是新建一个 .NET 项目， 命令如下：

   ```sh
   dotnet new console AntlrDemo
   ```

2. 添加 NuGet 包 [Antlr4.Runtime.Standard](https://www.nuget.org/packages/Antlr4.Runtime.Standard/) ， 目前的版本是 4.9.2 ， 这是一个 .NET Standard 2.0 标准类库， 可以在大多数 .NET 环境中使用：

   ```sh
   dotnet add package Antlr4.Runtime.Standard --version 4.9.2
   ```

### 生成 C# 代码

1. 下载 ANTLR 工具包

   访问 ANTLR 的 [下载](https://www.antlr.org/download.html) 页面， 下载完整的 ANTLR jar 包， 需要用这个来生成 C# 源代码。

   > 由于要运行 jar 文件， 所以还得装一个 jre ， 不过运行时不需要 jre 。

2. 根据语法文件生成对应的 C# 代码

   以 ANTLR 提供的 SQLite 语法文件为例， 生成代码的命令为：

   ```sh
   java -jar .tools/antlr-4.9.2-complete.jar \
     -Dlanguage=CSharp \ # 指定生成的语言为 C#
     -package AntlrDemo.Generated \ # 指定输出代码的命名空间
     -o ./src/AntlrDemo/Generated \ # 指定输出的目录
     SQLiteParser.g4 SQLiteLexer.g4 # 提供语法文件
   ```

3. 编译一下， 确认没有错误

   ```sh
   dotnet build
   ```

### 使用生成的 C# 代码

要使用生成的 C# 代码， 根据 [ANTLR 针对的 C# 说明](https://github.com/antlr/antlr4/blob/master/doc/csharp-target.md) ， 对应的代码如下：

```c#
var sql = "select * from t where id < 10";
ICharStream charStream = CharStreams.fromString(sql);
ITokenSource lexer = new SQLiteLexer(charStream);
ITokenStream stream = new CommonTokenStream(lexer);
SQLiteParser parser = new SQLiteParser(stream);
parser.BuildParseTree = true;
IParseTree tree = parser.parse();
```

上面的代码创建了解释器 (`parser`) 和 对应的语法树 (`tree`) 两个对象， 有了它们之后， 可以做类似下面的操作：

- 判断是否存在语法错误

  如果要简单判断 sql 的内容有没有语法错误的话， 可以读取 `parser` 的 `NumberOfSyntaxErrors` 属性进行判断

  ```c#
  if (parser.NumberOfSyntaxErrors > 0) {
      throw new Exception("Invalid SQL!");
  }
  ```

- 检查语法树的每一个节点

  比如 where 后面的每一个表达式是否合法， 不能出现 `1=1` 之类的表达式， 则需要使用 `ParseTreeWalker` 来循环整个语法树。

  先创建一个自定义的监听器， 代码如下：

  ```c#
  public class SqliteParserListener : SQLiteParserBaseListener {

      // 只监听退出表达式的方法， 根据提供的语法文件， 还会有很多其它的方法可以重写。
      public override void ExitExpr(
          [NotNull] SQLiteParser.ExprContext context
      ) {
          var text = context.GetText();
          Console.WriteLine(text);
      }
  }
  ```

  调用监听器 `SqliteParserListener` 并循环整个语法树的代码为：

  ```c#
  var listener = new SqliteParserListener();
  ParseTreeWalker.Default.Walk(listener, tree);
  ```

## ANTLR 使用小结

ANTLR 是一个通用的解析器生成器， 只要能够构建语法文件， 就能生成对应的解析器， 生成对应的语法树进行分析。 不仅提供了大量的语法文件， 也可以根据语法创建自定义的语法文件， 各家的 IDE 工具 (JetBrains, Visual Studio, Visual Studio Code, Eclipse 等)也都对其语法文件提供了可视化支持， 如果需要在代码中动态分析解释特定的语法， ANTLR 可以说是首选工具。
