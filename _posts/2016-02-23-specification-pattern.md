---
layout: post
title: 设计模式之规格模式
description: 介绍规格设计模式
keywords: design pattern, specification pattern, c#
tags: [设计模式]
---

在计算机程序中， **规格模式**是一种特殊的[软件设计模式](https://en.wikipedia.org/wiki/Software_design_pattern)，[业务规则](https://en.wikipedia.org/wiki/Business_rules)可以使用布尔逻辑组成规则连而重新组合， 这种模式通常在[领域驱动设计](https://en.wikipedia.org/wiki/Domain-driven_design)中使用。

规格模式描述的是一个业务规则可以和另外的业务规则聚合， 在这种模式中， 业务逻辑单元继承自可聚合的抽象规格基类类，该基类有一个返回布尔值的方法 `IsSatisfiedBy` 。 在初始化之后， 规格可以和其它规格进行逻辑组合， 使新的规格很容易维护， 实现高度自定义的业务逻辑。

规格模式的 UML 图如下：

![规格模式](/assets/post-images/specification-uml-v2.png)

实现代码如下：

```csharp
public interface ISpecification<TTarget> {

    bool IsSatisfiedBy(TTarget candidate);

    ISpecification<TTarget> And(ISpecification<TTarget> specification);

    ISpecification<TTarget> Or(ISpecification<TTarget> specification);

    ISpecification<TTarget> Not(ISpecification<TTarget> specification);

}
```

上面是规格模式的接口定义， 通常会实现一个抽象的 `CompositSpecification` 做为基类， 代码如下：

```csharp
public abstract class CompositSpecification<TTarget> : ISpecification<TTarget> {

    public abstract bool IsSatisfiedBy(TTarget candidate);

    public ISpecification<TTarget> And(ISpecification<TTarget> specification) {
        return new AndSpecification<TTarget>(this, specification);
    }

    public ISpecification<TTarget> Or(ISpecification<TTarget> specification) {
        return new OrSpecification<TTarget>(this, specification);
    }

    public ISpecification<TTarget> Not(ISpecification<TTarget> specification) {
        return new NotSpecification<TTarget>(specification);
    }

}
```

`AndSpecification` 实现两种规格通过逻辑与尽兴组合：

```csharp
public class AndSpecification<TTarget> : CompositSpecification<TTarget> {

    readonly ISpecification<TTarget> x;
    readonly ISpecification<TTarget> y;

    public AndSpecification(ISpecification<TTarget> x, ISpecification<TTarget> y) {
        this.x = x;
        this.y = y;
    }

    public override bool IsSatisfiedBy(TTarget candidate) {
        return x.IsSatisfiedBy(candidate) && y.IsSatisfiedBy(candidate);
    }

}
```

`OrSpecification` 实现两种规格通过逻辑或进行组合：

```csharp
public class OrSpecification<TTarget> : CompositSpecification<TTarget> {

    readonly ISpecification<TTarget> x;
    readonly ISpecification<TTarget> y;

    public OrSpecification(ISpecification<TTarget> x, ISpecification<TTarget> y) {
        this.x = x;
        this.y = y;
    }

    public override bool IsSatisfiedBy(TTarget candidate) {
        return x.IsSatisfiedBy(candidate) || y.IsSatisfiedBy(candidate);
    }

}
```

`NotSpecification` 实现规格的逻辑否：

```csharp
public class NotSpecification<TTarget> : CompositSpecification<TTarget> {

    readonly ISpecification<TTarget> x;

    public NotSpecification(ISpecification<TTarget> x) {
        this.x = x;
    }

    public override bool IsSatisfiedBy(TTarget candidate) {
        return !x.IsSatisfiedBy(candidate);
    }

}
```

至此， 规格模式就基本上实现了， 不过实际使用中， 通常会实现一个范型的规格模式作为入口， 代码如下：

```csharp
public class ExpressionSpecification<TTarget> : CompositSpecification<TTarget> {

    readonly Func<TTarget, bool> expression;

    public ExpressionSpecification(Func<TTarget, bool> expression) {
        this.expression = expression;
    }

    public override bool IsSatisfiedBy(TTarget candidate) {
        return expression(candidate);
    }

}
```

现在看一个实际的例子， 我们有一些手机， 代码如下：

```csharp
var mobiles = new List<Mobile>() {
    new Mobile(MobileBrand.Apple, MobileType.Smart),
    new Mobile(MobileBrand.Samsung, MobileType.Smart),
    new Mobile(MobileBrand.Samsung, MobileType.Basic)
};
```

使用规格模式选出所有的智能手机， 代码如下：

```csharp
var smartSpecification = new ExpressionSpecification<Mobile>(
    mobile => mobile.Type == MobileType.Smart
);
// find all smart mobiles;
var smartMobiles = mobiles.FindAll(
    mobile => smartSpecification.IsSatisfiedBy(mobile)
);
```

使用两种规格模式进行逻辑与组合， 选出品牌是 Apple 的智能手机， 代码如下：

```csharp
var appleSpecification = new ExpressionSpecification<Mobile>(
    mobile => mobile.Brand = MobileBrand.Apple
);

// find all apple smart mobiles;
var andSpecification = new AndSpecification<Mobile>(
    smartSpecification, appleSpecification
);
var appleSmartMobiles = mobiles.FindAll(
    mobile => andSpecification.IsSatisfiedBy(mobile)
);
```

值得一提的是， .NET 3.5 之后引入的 Linq 就是基于规格模式的， 可以说是规格模式的典范。