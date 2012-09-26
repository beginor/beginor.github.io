---
title: 首页
layout: default
---

{% for p in site.posts %}
<div class="box">
	<div class="box-title">
		<span class="post-title"><a href="{{ p.url }}">{{ p.title }}</a></span>
		<span class="post-date">{{ p.date | date: "%Y-%m-%d" }}</span>
	</div>
	<div class="box-content">
		{{ p.content | strip_html | truncate: 300 }}
		<a class="read-more" href="{{ p.url }}">阅读全文</a>
	</div>
</div>
{% endfor %}