<div class="card">
<div class="card-block">
    <h4 class="card-title">最近发表</h4>
</div>
<div class="list-group list-group-flush">
    {% for post in site.posts limit:15 %}
    <div class="list-group-item">
        <a href="{{post.url}}">{{ post.title }}</a>
        <span class="label label-default">{{ post.date | date: "%Y-%m-%d" }}</span>
    </div>
    {% endfor %}
</div>
</div>