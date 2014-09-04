---
layout: post
title: 快速排序与三路快速排序
description: 快速排序， 三路快速排序， 分区
tags: [算法]
keywords: 算法, 快速排序, quick sort, 三路快速排序, quick 3 sort
---

## 快速排序 (Quick Sort)

### 算法简介

快速排序是非常常用的排序方法， 采用[分治法][1]的策略将数组分成两个子数组， 基本
思路是：

1. 从数组中取一个元素作为基准元素， 通常取数组的第一个或者最后一个元素；
2. 分区， 即将数组中比基准元素小的元素放到基准元素的左边， 比基准元素大的元素放
   到右边；
3. 递归， 分别对比基准元素小的部分和比基准元素大的子数组用相同的方式进行排序；

递归的最底部情形，是数列的大小是零或一，也就是永远都已经被排序好了。虽然一直递归
下去，但是这个算法总会退出，因为在每次的迭代（iteration）中，它至少会把一个元素
摆到它最后的位置去。

排序过程如下图所示：

![快速排序](/assets/post-images/Sorting_quicksort_anim.gif)
图片来自[维基百科][2]

### 优点与缺点

快速排序最大的优点速度快， 通常能够达到 `O(NlogN)` 的速度， 原地排序， 不需要额
外的空间， 是非常优秀的算法， 在不考虑稳定性的情况下， 通常会考虑使用快速排序。

不过， 快速排序的缺点也是很明显的：

- 首先就是不稳定， 会打乱数组中相同元素的相对位置；
- 算法的速度严重依赖分区操作， 如果不能很好的分区， 比如数组中有重复元素的情况，
  最坏情况下（对于已经排序的数组）， 速度有可能会降到 `O(N^2)` 。

通常在快排实现中， 会对数组进行一次随机排序， 防止最坏的情况出现。

### C# 代码实现

```c#
public static class Quick<T> where T : IComparable {

    public static void Sort(T[] a) {
        StdRandom.Shuffle(a);
        Sort(a, 0, a.Length - 1);
    }

    public static void Sort(T[] a, IComparer c) {
        StdRandom.Shuffle(a);
        Sort(a, 0, a.Length - 1, c);
    }

    private static void Sort(T[] a, int lo, int hi) {
        if (lo >= hi) {
            return;
        }
        int j = Partition(a, lo, hi);
        Sort(a, lo, j - 1);
        Sort(a, j + 1, hi);
    }

    private static void Sort(T[] a, int lo, int hi, IComparer c) {
        if (lo >= hi) {
            return;
        }
        int j = Partition(a, lo, hi, c);
        Sort(a, lo, j - 1, c);
        Sort(a, j + 1, hi, c);
    }

    private static int Partition(T[] a, int lo, int hi) {
        int i = lo, j = hi + 1;
        while (true) {
            while (Less(a[++i], a[lo])) {
                if (i == hi) {
                    break;
                }
            }
            while (Less(a[lo], a[--j])) {
                if (j == lo) {
                    break;
                }
            }
            if (i >= j) {
                break;
            }
            Exch(a, i, j);
        }
        Exch(a, lo, j);
        return j;
    }

    private static int Partition(T[] a, int lo, int hi, IComparer c) {
        int i = lo, j = hi + 1;
        while (true) {
            while (Less(a[++i], a[lo], c)) {
                if (i == hi) {
                    break;
                }
            }
            while (Less(a[lo], a[--j], c)) {
                if (j == lo) {
                    break;
                }
            }
            if (i >= j) {
                break;
            }
            Exch(a, i, j);
        }
        Exch(a, lo, j);
        return j;
    }

    public static T Select(T[] a, int k) {
        StdRandom.Shuffle(a);
        int lo = 0, hi = a.Length - 1;
        while (lo < hi) {
            int j = Partition(a, lo, hi);
            if (j < k) {
                lo = j + 1;
            }
            else if (j > k) {
                hi = j - 1;
            }
            else {
                return a[k];
            }
        }
        return a[k];
    }

    public static T Select(T[] a, int k, IComparer c) {
        StdRandom.Shuffle(a);
        int lo = 0, hi = a.Length - 1;
        while (lo < hi) {
            int j = Partition(a, lo, hi, c);
            if (j < k) {
                lo = j + 1;
            }
            else if (j > k) {
                hi = j - 1;
            }
            else {
                return a[k];
            }
        }
        return a[k];
    }

    private static bool Less(IComparable v, IComparable w) {
        return v.CompareTo(w) < 0;
    }

    private static bool Less(object v, object w, IComparer c) {
        return c.Compare(v, w) < 0;
    }

    private static void Exch(T[] a, int i, int j) {
        var tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }
}
```

## 三路快速排序 (Quick 3 Sort)

三路快速排序是快速排序的的一个优化版本， 将数组分成三段， 即小于基准元素、 等于
基准元素和大于基准元素， 这样可以比较高效的处理数组中存在相同元素的情况， 其它特
征与快速排序基本相同。

C# 代码实现如下：

```c#
public static class Quick3<T> where T : IComparable {

    public static void Sort(T[] a) {
        Sort(a, 0, a.Length - 1);
    }

    public static void Sort(T[] a, IComparer c) {
        Sort(a, 0, a.Length - 1, c);
    }

    private static void Sort(T[] a, int lo, int hi) {
        if (hi <= lo) {
            return;
        }
        int lt = lo, gt = hi;
        var v = a[lo];
        int i = lo;
        while (i <= gt) {
            int c = a[i].CompareTo(v);
            if (c < 0) {
                Exch(a, lt++, i++);
            }
            else if (c > 0) {
                Exch(a, i, gt--);
            }
            else {
                i++;
            }
        }

        Sort(a, lo, lt - 1);
        Sort(a, gt + 1, hi);
    }

    private static void Sort(T[] a, int lo, int hi, IComparer comp) {
        if (hi <= lo) {
            return;
        }
        int lt = lo, gt = hi;
        var v = a[lo];
        int i = lo;
        while (i <= gt) {
            int c = comp.Compare(a[i], v);
            if (c < 0) {
                Exch(a, lt++, i++);
            }
            else if (c > 0) {
                Exch(a, i, gt--);
            }
            else {
                i++;
            }
        }

        Sort(a, lo, lt - 1, comp);
        Sort(a, gt + 1, hi, comp);
    }

    private static void Exch(T[] a, int i, int j) {
        var tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }
}
```
考虑使用快速排序算法时， 通常应优先考虑三路快速排序。

[1]: http://zh.wikipedia.org/wiki/%E5%88%86%E6%B2%BB%E6%B3%95
[2]: http://upload.wikimedia.org/wikipedia/commons/6/6a/Sorting_quicksort_anim.gif