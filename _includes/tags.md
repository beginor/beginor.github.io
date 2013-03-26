<div class="span3 side-bar hidden-print" valign="top">
	<div class="well well-large" style="max-width: 340px; padding: 0px 0;">
		<ul class="nav nav-list">
			<li class="nav-header">标签</li>
			{% for tag in site.tags %}
			<li><a href="/pages.html#{{ tag[0] }}-ref"><span>{{ tag[0] }}</span>({{ tag[1].size }})</a></li>
			{% endfor %}
		</ul>
	</div>
</div>