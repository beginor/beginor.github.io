---
title: 首页
layout: default
---

{% for p in site.posts %}
<div class="box">
	<div class="box-title">
		<span class="post-title"><a href="{{ p.url }}">{{ p.title }}</a></span>
		<span class="post-date">{{ p.date | date: "%Y-%m-%d" }}</span>
		<span class="post-comment-count"><a href="{{ p.url }}#disqus_thread">评论</a></span>
	</div>
	<div class="box-content">
		{{ p.content | strip_html | truncate: 300 }}
		<a class="read-more" href="{{ p.url }}">阅读全文</a>
	</div>
</div>
{% endfor %}