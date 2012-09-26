<div class="box">
	<div class="box-title"> 标签 </div>
	<div class="box-content">
		<ul class="tag-list">
		{% for tag in site.tags %}
		<li><a href="/pages.html#{{ tag[0] }}-ref"><span>{{ tag[0] }}</span>({{ tag[1].size }})</a></li>
		{% endfor %}
		</ul>
	</div>
</div>