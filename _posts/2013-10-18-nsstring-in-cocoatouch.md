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

**%@**  
Objective-C object, printed as the string returned by descriptionWithLocale: if available, or description otherwise. Also works with CFTypeRef objects, returning the result of the CFCopyDescription function.

**%%**  
'%' character

**%d, %D, %i**  
Signed 32-bit integer (int)

**%u, %U**  
Unsigned 32-bit integer (unsigned int)

**%hi**  
Signed 16-bit integer (short)

**%hu**  
Unsigned 16-bit integer (unsigned short)

**%qi**  
Signed 64-bit integer (long long)

**%qu**  
Unsigned 64-bit integer (unsigned long long)

**%x**  
Unsigned 32-bit integer (unsigned int), printed in hexadecimal using the digits 0–9 and lowercase a–f

**%X**  
Unsigned 32-bit integer (unsigned int), printed in hexadecimal using the digits 0–9 and uppercase A–F

**%qx**  
Unsigned 64-bit integer (unsigned long long), printed in hexadecimal using the digits 0–9 and lowercase a–f

**%qX**  
Unsigned 64-bit integer (unsigned long long), printed in hexadecimal using the digits 0–9 and uppercase A–F

**%o, %O**  
Unsigned 32-bit integer (unsigned int), printed in octal

**%f**  
64-bit floating-point number (double)

**%e**  
64-bit floating-point number (double), printed in scientific notation using a lowercase e to introduce the exponent

**%E**  
64-bit floating-point number (double), printed in scientific notation using an uppercase E to introduce the exponent

**%g**  
64-bit floating-point number (double), printed in the style of %e if the exponent is less than –4 or greater than or equal to the precision, in the style of %f otherwise

**%G**  
64-bit floating-point number (double), printed in the style of %E if the exponent is less than –4 or greater than or equal to the precision, in the style of %f otherwise

**%c**  
8-bit unsigned character (unsigned char), printed by NSLog() as an ASCII character, or, if not an ASCII character, in the octal format \\ddd or the Unicode hexadecimal format \\udddd, where d is a digit

**%C**  
16-bit Unicode character (unichar), printed by NSLog() as an ASCII character, or, if not an ASCII character, in the octal format \\ddd or the Unicode hexadecimal format \\udddd, where d is a digit

**%s**  
Null-terminated array of 8-bit unsigned characters. %s interprets its input in the system encoding rather than, for example, UTF-8. 

**%S**  
Null-terminated array of 16-bit Unicode characters

**%p**  
Void pointer `(void *)`, printed in hexadecimal with the digits 0–9 and lowercase a–f, with a leading 0x

**%L** 
Length modifier specifying that a following a, A, e, E, f, F, g, or G conversion specifier applies to a long double argument

**%a** 
64-bit floating-point number (double), printed in scientific notation with a leading 0x and one hexadecimal digit before the decimal point using a lowercase p to introduce the exponent

**%A**  
64-bit floating-point number (double), printed in scientific notation with a leading 0X and one hexadecimal digit before the decimal point using a uppercase P to introduce the exponent

**%F** 
64-bit floating-point number (double), printed in decimal notation

**%z**  
Length modifier specifying that a following d, i, o, u, x, or X conversion specifier applies to a size_t or the corresponding signed integer type argument

**%t**  
Length modifier specifying that a following d, i, o, u, x, or X conversion specifier applies to a ptrdiff_t or the corresponding unsigned integer type argument

**%j**  
Length modifier specifying that a following d, i, o, u, x, or X conversion specifier applies to a intmax_t or uintmax_t argument

更多格式化文档， 参考苹果文档 [String Format Specifiers](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html) 。
