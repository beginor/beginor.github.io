<div class="card mb-3">
    <div class="card-header"><i class="fa fa-tags"></i> 标签</div>
    <div class="card-block">
        {% for tag in site.tags reversed %}
        <a class="p-1 d-inline-block" href="/pages-tags.html#{{ tag[0] }}-ref">{{ tag[0] }}({{ tag[1].size }})</a>
        {% endfor %}
    </div>
</div>
