---
layout: post
title: CocoaTouch 中的 NSString
description: CocoaTouch 中的 NSString
tags: [iOS]
keywords: iOS, NSString, NSNumber, NSInteger
---

## initWithFormat 还是 stringWithFormat ? ##

**initWithFormat 是实例方法**，用法如下：

    NSString* str = [[NSString alloc] initWithFormat:@"%@", @"Hello, world!"];
    self.label.text = str;
    [str release];

如果是运行在在 iOS 5.0 之前或者没有使用 ARC 的情况下， 需要手工调用 release 方法进行回收。

**stringWithFormat 是类方法**， 用法如下：

    NSString* str = [NSString stringWithFormat:"%@", @"Hello, world!"];
    sef.label.text = str;

stringWithFormat 不需要手工调用 release 方法进行回收。

## NSString 到 NSInteger、 int ##

    NSString* str = @"123";
    NSInteger intVal = [str integerValue];
    int val = [str intValue];

## NSString 到 NSNumber ##

    NSString* str = @"123";
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* num = [f numberFromString:str];

## 常用字符串格式化说明 ##
