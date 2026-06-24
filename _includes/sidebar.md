<div class="space-y-6">
  <div>
    <h3 class="text-xs font-semibold text-gray-900 tracking-wide uppercase mb-3">标签</h3>
    <div class="flex flex-wrap gap-1">
      {% for tag in site.tags reversed %}
      <a class="inline-block text-xs text-gray-900 no-underline border border-gray-400 rounded-sm px-2.5 py-1 hover:border-gray-600" href="/pages-tags.html#{{ tag[0] }}-ref">{{ tag[0] }}({{ tag[1].size }})</a>
      {% endfor %}
    </div>
  </div>

  <div>
    <h3 class="text-xs font-semibold text-gray-900 tracking-wide uppercase mb-3">最近发表</h3>
    <div class="space-y-0">
      {% for post in site.posts limit:10 %}
      <a class="block py-2 text-sm text-gray-900 hover:text-link no-underline border-b border-gray-400 last:border-b-0" href="{{post.url}}">
        <span>{{ post.title }}</span>
        <span class="text-xs text-gray-800 ml-2">{{ post.date | date: "%Y-%m-%d" }}</span>
      </a>
      {% endfor %}
    </div>
  </div>

  <div>
    <h3 class="text-xs font-semibold text-gray-900 tracking-wide uppercase mb-3">访问信息</h3>
    <a href="https://info.flagcounter.com/f6AT"><img src="https://s01.flagcounter.com/count2/f6AT/bg_FFFFFF/txt_000000/border_FFFFFF/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/" alt="Flag Counter" border="0"></a>
  </div>
</div>
