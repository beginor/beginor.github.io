<div class="span3 side-bar hidden-print" valign="top">
	<div class="well well-large" style="max-width: 340px; padding: 0px 0;">
		<ul class="nav nav-list">
			<li class="nav-header">最近发表</li>
			{% for post in site.posts limit:10 %}
			<li><a href="{{post.url}}">{{ post.title }}</a> {{ post.date | date: "%Y-%m-%d" }}</li>
			{% endfor %}
		</ul>
	</div>
</div>