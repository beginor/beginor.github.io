<div class="box">
	<div class="box-title"> 最近发表 </div>
	<div class="box-content">
		<ol class="recent-post-list">
		{% for post in site.posts limit:10 %}
			<li><a href="{{post.url}}">{{ post.title }}</a> {{ post.date | date: "%Y-%m-%d" }}</li>
		{% endfor %}
		</ol>
	</div>
</div>