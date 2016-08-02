<div class="card">
    <div class="card-header">标签</div>
    <div class="list-group list-group-flush">
        {% for tag in site.tags reversed %}
        <a class="list-group-item list-group-item-action" href="/pages-tags.html#{{ tag[0] }}-ref">
            {{ tag[0] }}
            <span class="tag tag-pill tag-default pull-xs-right">{{ tag[1].size }}</span>
        </a>
        {% endfor %}
    </div>
</div>
