<li class="nav-header">最近发表</li>
{% for post in site.posts limit:10 %}
<li><a href="{{post.url}}">{{ post.title }} (<small>{{ post.date | date: "%Y-%m-%d" }}</small>)</a></li>
{% endfor %}