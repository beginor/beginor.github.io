<div class="list-group">
	<div class="list-group-item">
		<h4 class="list-group-item-heading">最近发表</h4>
	</div>
	{% for post in site.posts limit:10 %}
	<div class="list-group-item">
		<a href="{{post.url}}">
			{{ post.title }} (<small>{{ post.date | date: "%Y-%m-%d" }}</small>)
		</a>
	</div>
	{% endfor %}
</div>