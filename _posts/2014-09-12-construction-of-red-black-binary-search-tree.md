---
layout: post
title: 红黑树的创建
description: 红黑树的创建
tags: [算法]
keywords: 算法, 红黑树, bst, balance search tree, red black bst
---

在[二叉查找树][1]的最后提到， 二叉树最终的形状如下图所示：

![二叉树最终形状](http://beginor.github.io/assets/post-images/bst-04.png)

实际上，为了避免二叉树形状向最坏情况靠拢， 通常会创建能够自平衡的 [2-3 树][3]。 而 [红黑树][2]
是 [2-3 树][3]比较简单的一种实现形式：

1. 红黑树将用二叉树表示 2-3 树， 实现起来相对容易； 
2. 内部使用向左倾斜的链接表示第三个节点；

![红黑树节点](http://beginor.github.io/assets/post-images/red-black-bst-01.png)

红黑树定义如下：

- 没有任意节点拥有两个红色链接；
- 从跟节点到末节点的黑色链接数目相等；
- 红色节点向左倾斜；

用红黑树来表示 2-3 树例子：

![红黑树来表示 2-3 树例子](http://beginor.github.io/assets/post-images/red-black-bst-02.png)

## 红黑树的节点定义

**节点定义**

在二叉查找树节点的基础上增加一个 Color 字段， 相关代码如下：

```c#
// Color Const, Red As true, Black as false
private const bool Red = true;
private const bool Black = false;

private class Node {
    public TKey Key;
    public TValue Val;
    public Node Left, Right;
    public bool Color; // Color
}

// Check node's color.
private static bool IsRed(Node h) {
    if (h == null) {
        return false;
    }
    return h.Color == Red;
}
```

## 红黑树的创建

红黑树的创建和二叉查找树类似， 为了在添加节点时维持节点的顺序和树的平衡性， 增加了如下一些操作：

**左旋**

将一个临时向右倾斜的红色链接向左旋转， 如下图所示：

<table>
<tr>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-rotate-left-1.png"/></td>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-rotate-left-2.png"/></td>
</tr>
</table>

对应的 c# 实现代码如下：

```c#
private Node RotateLeft(Node h) {
    Debug.Assert(h != null && IsRed(h.Right));
    Node x = h.Right;
    h.Right = x.Left;
    x.Left = h;
    x.Color = x.Left.Color;
    h.Color = Red;
    x.N = h.N;
    h.N = Size(h.Left) + Size(h.Right) + 1;
    return x;
}
```

**右旋**

将左倾的红色链接向右旋转为临时的向右倾斜的红色链接， 如下图所示：

<table>
<tr>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-rotate-right-1.png"/></td>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-rotate-right-2.png"/></td>
</tr>
</table>

对应的 c# 实现代码如下：

```c#
private Node RotateRight(Node h) {
    Debug.Assert(h != null && IsRed(h.Left));
    Node x = h.Left;
    h.Left = x.Right;
    x.Right = h;
    x.Color = x.Right.Color;
    h.Color = Red;
    x.N = h.N;
    h.N = Size(h.Left) + Size(h.Right) + 1;
    return x;
}
```

**翻转颜色**

将节点的左右链接（临时情况）由红色改为黑色， 如下图所示：

<table>
<tr>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-flip-color-1.png"/></td>
<td><img src="http://beginor.github.io/assets/post-images/red-black-bst-flip-color-2.png"/></td>
</tr>
</table>

对应的 c# 实现代码如下：

```c#
private void FlipColors(Node h) {
    Debug.Assert(h != null && h.Left != null && h.Right != null);
    Debug.Assert((!IsRed(h) && IsRed(h.Left) && IsRed(h.Right))
        || (IsRed(h) && !IsRed(h.Left) && !IsRed(h.Right)));
    h.Color = !h.Color;
    h.Left.Color = !h.Left.Color;
    h.Right.Color = !h.Right.Color;
}
```

**添加节点**

有了上面定义的几个操作， 添加节点分两种情况：

1. 向单节点添加新节点， 在底部形成双节点， 如下图所示：

    ![向单节点添加新节点](http://beginor.github.io/assets/post-images/red-black-bst-put-01.png)
    
    这种情况下比较容易处理， 需要的步骤如下：

   1. 按照二叉查找树的方式添加节点， 将新节点标记为红色；
   2. 如果新节点是其父节点的右链接， 则进行左旋操作；

2. 向双节点添加新节点， 在底部形成三节点， 如下图所示：

   ![向双节点添加新节点](http://beginor.github.io/assets/post-images/red-black-bst-put-02.png)

   这种情况稍微麻烦一些， 需要的步骤如下：

   1. 按照二叉查找树的方式添加节点， 将新节点标记为红色；
   2. 如果需要， 通过旋转形成临时的四节点；
   3. 翻转颜色， 将红色链接上移一层；
   4. 如果需要， 通过旋转形成左倾的红色节点；
   5. 如果需要， 以此方法向上递归；

   ![向双节点添加新节点](http://beginor.github.io/assets/post-images/red-black-bst-put-03.png)

最终红黑树添加节点的 c# 代码如下：

```c#
public void Put(TKey key, TValue val) {
    root = Put(root, key, val);
    root.Color = Black;
    Debug.Assert(Check());
}

private Node Put(Node h, TKey key, TValue val) {
    if (h == null) {
        return new Node(key, val, Red, 1);
    }
    int cmp = key.CompareTo(h.Key);
    if (cmp < 0) {
        h.Left = Put(h.Left, key, val);
    }
    else if (cmp > 0) {
        h.Right = Put(h.Right, key, val);
    }
    else {
        h.Val = val;
    }

    if (IsRed(h.Right) && !IsRed(h.Left)) {
        h = RotateLeft(h);
    }
    if (IsRed(h.Left) && IsRed(h.Left.Left)) {
        h = RotateRight(h);
    }
    if (IsRed(h.Left) && IsRed(h.Right)) {
        FlipColors(h);
    }

    h.N = Size(h.Left) + Size(h.Right) + 1;

    return h;
}
```

[1]: http://beginor.github.io/2014/09/06/binary-search-tree.html
[2]: http://zh.wikipedia.org/wiki/%E7%BA%A2%E9%BB%91%E6%A0%91
[3]: http://zh.wikipedia.org/wiki/2-3%E6%A0%91