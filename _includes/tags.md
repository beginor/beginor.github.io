<div class="card">
    <div class="card-header">标签</div>
    <div class="list-group list-group-flush">
        {% for tag in site.tags reversed %}
        <div class="list-group-item">
            <a href="/pages-tags.html#{{ tag[0] }}-ref">{{ tag[0] }}</a>
            <span class="tag tag-pill tag-default">{{ tag[1].size }}</span>
        </div>
        {% endfor %}
    </div>
</div>
