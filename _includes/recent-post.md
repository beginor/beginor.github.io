<div class="list-group">
	<div class="list-group-item">
		<h4 class="list-group-item-heading">最近发表</h4>
	</div>
	{% for post in site.posts limit:15 %}
	<div class="list-group-item">
		<a href="{{post.url}}">{{ post.title }}</a>
		<span class="label label-default">{{ post.date | date: "%Y-%m-%d" }}</span>
	</div>
	{% endfor %}
</div>