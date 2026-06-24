<div class="bg-white rounded-lg border border-gray-200 mb-3 dark:bg-gray-800 dark:border-gray-700">
  <div class="border-b border-gray-200 px-4 py-3 dark:border-gray-700">
    <i class="icon ti ti-clock"></i> 最近发表
  </div>
  <div class="divide-y divide-gray-200 dark:divide-gray-700">
    {% for post in site.posts limit:10 %}
    <a class="block px-4 py-2.5 text-sm hover:bg-gray-50 dark:hover:bg-gray-700" href="{{post.url}}">
      <span>{{ post.title }} <span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-0.5 rounded dark:bg-blue-900 dark:text-blue-200">{{ post.date | date: "%Y-%m-%d" }}</span>
      </span>
    </a>
    {% endfor %}
  </div>
</div>
