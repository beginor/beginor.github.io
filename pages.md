---
title: 全部页面
layout: default
---

<h2> All Pages </h2>

<ol>
{% for post in site.posts %}
	<li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ol>