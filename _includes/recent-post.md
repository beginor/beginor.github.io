<div class="card">
    <div class="card-header">最近发表</div>
    <div class="list-group list-group-flush">
        {% for post in site.posts limit:15 %}
        <a class="list-group-item list-group-item-action" href="{{post.url}}">
            {{ post.title }}
            <span class="tag tag-default">{{ post.date | date: "%Y-%m-%d" }}</span>
        </a>
        {% endfor %}
    </div>
</div>