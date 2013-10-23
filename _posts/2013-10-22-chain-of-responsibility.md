---
layout: post
title: 设计模式之职责链模式
description: 使多个对象都有机会处理请求， 从而避免了请求的发送者与接收者之间的耦合。 将接收对象组成链， 在链上传递请求， 知道有一个对象处理请求为止。
tags: [设计模式]
keywords: 设计模式, 职责链模式, chain of responsibility
---

## 结构

![职责链模式](/assets/post-images/chain-of-responsibility.jpg)

## 说明

This pattern avoids coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. It chains the receiving objects and passes the request along the chain until an object handles it.

使多个对象都有机会处理请求， 从而避免了请求的发送者与接收者之间的耦合。 将接收对象组成链， 在链上传递请求， 直到有一个对象处理请求为止。

## 适用条件

1. 有多个对象可以处理一个请求， 具体由哪个对象处理在运行时确定；  
2. 在不明确接收者的情况下， 向多个对象发送请求；  
3. 可处理请求的对象的集合应被动态指定。  

## 实现

    class Client {
            
        static void Main(string[] args) {
            Handler handlerChain = new ConcreteHandler1(new ConcreteHandler2(null));
    
            Request request1 = new ConcreteRequest1();
            handlerChain.HandleRequest(request1);
    
            Request request2 = new ConcreteRequest2();
            handlerChain.HandleRequest(request2);
    
            Console.ReadKey();
        }
    }
    
    public abstract class Handler {
    
        private readonly Handler _successor;
    
        protected Handler(Handler successor) {
            this._successor = successor;
        }
    
        protected Handler Successor {
            get {
                return this._successor;
            }
        }
    
        public abstract void HandleRequest(Request request);
    
    }
    
    public class ConcreteHandler1 : Handler {
            
        public ConcreteHandler1(Handler successor) : base(successor) {
        }
    
        public override void HandleRequest(Request request) {
            if (request is ConcreteRequest1) {
                Console.WriteLine("ConcreteRequest1 is handled by ConcreteHandler1");
            }
            else {
                this.Successor.HandleRequest(request);
            }
        }
    }
    
    public class ConcreteHandler2 : Handler {
    
        public ConcreteHandler2(Handler successor) : base(successor) {
        }
    
        public override void HandleRequest(Request request) {
            if (request is ConcreteRequest2) {
                Console.WriteLine("ConcreteRequest2 is handled by ConcreteHandler2");
            }
            else {
                this.Successor.HandleRequest(request);
            }
        }
    }
    
    public abstract class Request {
    }
    
    public class ConcreteRequest1 : Request {
    }
    
    public class ConcreteRequest2 : Request {
    
    }