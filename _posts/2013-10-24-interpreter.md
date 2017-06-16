---
layout: post
title: 设计模式之解释器模式
description: 给定一个语言, 定义它的文法的一种表示，并定义一个解释器, 该解释器使用该表示来解释语言中的句子
tags: [设计模式]
keywords: 设计模式, 解释器模式, interpreter
---

## 结构

![解释器模式](/assets/post-images/interpreter.png)

## 说明

Given a language, define a representation for its grammar along with an interpreter that uses the representation to interpret sentences in the language.

给定一个语言, 定义它的文法的一种表示，并定义一个解释器, 该解释器使用该表示来解释语言中的句子。

## 适用条件

当有一个语言需要解释执行， 并且可以将语言中的句子表示为一个抽象的表达式树时， 可以使用解释器模式。

## 实现

以[逆波兰表示法][1]为例， 其语法为：

    expression ::= plus | minus | variable | number
    plus ::= expression expression '+'
    minus ::= expression expression '-'
    variable  ::= 'a' | 'b' | 'c' | ... | 'z'
    digit = '0' | '1' | ... '9'
    number ::= digit | digit number

波兰表示法的例子：

    a b +
    a b c + -
    a b + c a - -

以下是逆波兰表示法的解释器实现 ：

    public interface IExpression {
    
       int Interpret(Dictionary<string, IExpression> variables);
    
    }
    
    public class Number : IExpression {
    
       private readonly int _number;
    
       public Number(int number) {
          this._number = number;
       }
    
       public int Interpret(Dictionary<string, IExpression> variables) {
          return this._number;
       }
    
    }
    
    public class Variable : IExpression {
    
       private readonly string _name;
    
       public Variable(string name) {
          this._name = name;
       }
    
       public int Interpret(Dictionary<string, IExpression> variables) {
          if (string.IsNullOrEmpty(this._name)) {
             return 0;
          }
          return variables[this._name].Interpret(variables);
       }
    }
    
    public class Plus : IExpression {
    
       private readonly IExpression _leftOperand;
       private readonly IExpression _rightOperand;
    
       public Plus(IExpression leftOperand, IExpression rightOperand) {
          this._leftOperand = leftOperand;
          this._rightOperand = rightOperand;
       }
    
       public int Interpret(Dictionary<string, IExpression> variables) {
          return this._leftOperand.Interpret(variables) + this._rightOperand.Interpret(variables);
       }
    
    }
    
    public class Minus : IExpression {
       
       private readonly IExpression _leftOperand;
       private readonly IExpression _rightOperand;
    
       public Minus(IExpression leftOperand, IExpression rightOperand) {
          this._leftOperand = leftOperand;
          this._rightOperand = rightOperand;
       }
    
       public int Interpret(Dictionary<string, IExpression> variables) {
          return this._leftOperand.Interpret(variables) - this._rightOperand.Interpret(variables);
       }
    
    }
    
    public class Evaluator : IExpression {
    
       private readonly IExpression _expressionTree;
    
       public Evaluator(string expression) {
          var stack = new Stack<IExpression>();
          foreach (var token in expression.Split(' ')) {
             if (token == "+") {
                stack.Push(new Plus(stack.Pop(), stack.Pop()));
             }
             else if (token == "-") {
                var right = stack.Pop();
                var left = stack.Pop();
                stack.Push(new Minus(left, right));
             }
             else {
                stack.Push(new Variable(token));
             }
          }
          this._expressionTree = stack.Pop();
       }
       
       public int Interpret(Dictionary<string, IExpression> variables) {
          return this._expressionTree.Interpret(variables);
       }
    }
    
    
    class Client {
    
       static void Main(string[] args) {
          const string expression = "w x z - +";
          var evaluator = new Evaluator(expression);
          var sentence = new Dictionary<string, IExpression>();
          sentence["w"] = new Number(5);
          sentence["x"] = new Number(10);
          sentence["z"] = new Number(42);
          var result = evaluator.Interpret(sentence);
          Console.WriteLine(result);
    
          Console.ReadKey();
       }
    }

[1]: https://zh.wikipedia.org/wiki/Reverse_Polish_notation
