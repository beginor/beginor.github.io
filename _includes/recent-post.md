<div class="card mb-3">
    <div class="card-header"><i class="fa fa-clock-o"></i> 最近发表</div>
    <div class="list-group list-group-flush">
        {% for post in site.posts limit:15 %}
        <a class="list-group-item list-group-item-action" href="{{post.url}}">
            <span>{{ post.title }} <span class="badge badge-default">{{ post.date | date: "%Y-%m-%d" }}</span>
            </span>
        </a>
        {% endfor %}
    </div>
</div>
