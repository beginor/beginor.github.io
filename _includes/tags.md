<div class="bg-white rounded-lg border border-gray-200 mb-3 dark:bg-gray-800 dark:border-gray-700">
  <div class="border-b border-gray-200 px-4 py-3 dark:border-gray-700">
    <i class="icon ti ti-tags"></i> 标签
  </div>
  <div class="px-4 py-3 flex flex-wrap gap-1">
    {% for tag in site.tags reversed %}
    <a class="inline-block bg-blue-600 text-white text-xs px-2.5 py-1 rounded-full hover:bg-blue-700" href="/pages-tags.html#{{ tag[0] }}-ref">{{ tag[0] }}({{ tag[1].size }})</a>
    {% endfor %}
  </div>
</div>
