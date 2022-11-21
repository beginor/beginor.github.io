<div class="card mb-3">
  <div class="card-header"><i class="icon ti ti-tags"></i> 标签</div>
  <div class="card-body">
    {% for tag in site.tags reversed %}
    <a class="badge my-1 rounded-pill text-light" href="/pages-tags.html#{{ tag[0] }}-ref">{{ tag[0] }}({{ tag[1].size }})</a>
    {% endfor %}
  </div>
</div>
