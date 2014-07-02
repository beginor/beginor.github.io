---
layout: post
title: 快速排序
description: 
tags: [算法]
keywords: 算法, 快速排序, quick sort
---

## 基本特征

- 将数组随机重新排序
- 按照某一个元素 j 分区， 对于元素 j
    - 确保元素 j 位于正确的位置
    - 左边的元素都不比元素 j 大
    - 右边的元素都不比元素 j 小
- 对分区进行递归排序

## 排序过程

<img id="quick-sort-demo1" src="/assets/post-images/quick-sort-0.gif"
      onclick="quick_sort_demo1(this.id,'/assets/post-images/quick-sort.gif')"
      style="width:240px; height:240px "
      title="点击图片开始排序" alt="/assets/post-images/quick-sort.gif">
<script type="text/javascript">
function quick_sort_demo1(id, src) {
    $('#' + id).attr('src', src);
}
</script>

<div class="alert alert-info">
	<strong>提示：</strong> 点击图片开始排序， 图片引用自
	<a class="alert-link" href="http://www.sorting-algorithms.com">
	www.sorting-algorithms.com
	</a> 。
</div>

## 实现


## 特点

- 如果不能很好的分区， 比如已经排好顺序的数组或者数组中有大量的相同元素的情况， 
分区起不到应有的作用， 快速排序就不能很好的工作， 因此得采用更好的三段分区方法。