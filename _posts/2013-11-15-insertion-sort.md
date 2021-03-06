---
layout: post
title: 插入排序
description: 构建有序序列，对于未排序数据，在已排序序列中从后向前扫描，找到相应位置并插入
tags: [算法]
keywords: 算法, 插入排序, insertion sort
---

插入排序（Insertion Sort）的算法描述是一种简单直观的排序算法。它的工作原理是通过
构建有序序列，对于未排序数据，在已排序序列中从后向前扫描，找到相应位置并插入。插
入排序在实现上，通常采用in-place排序（即只需用到O(1)的额外空间的排序），因而在从
后向前扫描过程中，需要反复把已排序元素逐步向后挪位，为最新元素提供插入空间。

使用插入排序为一列数字进行排序的过程

![使用插入排序为一列数字进行排序的过程](/assets/post-images/insertion_sort_animation.gif)

![使用插入排序为一列数字进行排序的过程](/assets/post-images/insertion-sort-example-300px.gif)

一般来说，插入排序都采用in-place在数组上实现。具体算法描述如下：

1. 从第一个元素开始，该元素可以认为已经被排序
2. 取出下一个元素，在已经排序的元素序列中从后向前扫描
3. 如果该元素（已排序）大于新元素，将该元素移到下一位置
4. 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置
5. 将新元素插入到该位置后
6. 重复步骤2~5

如果比较操作的代价比交换操作大的话，可以采用二分查找法来减少比较操作的数目。该算
法可以认为是插入排序的一个变种，称为二分查找排序。

C# 实现代码

```c#
static void InsertionSort(int[] array) {
  int count = array.Length;
    for (int i = 1; i < count; i++) {
      int t = array[i];
      int j = i;
      while (j > 0 && array[j - 1] > t) {
         array[j] = array[j - 1];
         --j;
      }
      array[j] = t;
   }
}
```

插入排序在数组元素较少或者已经部分排序的情况下， 表现良好， 通常会作为其它快速排
序算法的补充。