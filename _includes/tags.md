<li class="nav-header">标签</li>
{% for tag in site.tags %}
<li style="display: inline-block; margin: 0px 6px"><a href="/pages.html#{{ tag[0] }}-ref"><span>{{ tag[0] }}</span>({{ tag[1].size }})</a></li>
{% endfor %}