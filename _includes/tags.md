<div class="list-group">
	<div class="list-group-item">
		<h4 class="list-group-item-heading">标签</h4>
	</div>
	{% for tag in site.tags %}
	<div class="list-group-item">
		<span class="badge">{{ tag[1].size }}</span>
		<a href="/pages.html#{{ tag[0] }}-ref">{{ tag[0] }}</a>
	</div>
	{% endfor %}
</div>
