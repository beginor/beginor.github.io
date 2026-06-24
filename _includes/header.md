<div class="sticky-top headroom bg-surface d-print-none">
  <header class="max-w-screen-xl mx-auto flex items-center justify-between px-6 h-14">
    <button id="navbar-toggler" class="md:hidden p-2 text-gray-900 hover:text-link" type="button" aria-label="Toggle navigation">
      <i class="icon ti ti-menu-2 text-xl"></i>
    </button>
    <h1 class="text-sm font-semibold tracking-tight">
      <a class="text-gray-950 hover:text-link no-underline" href="/index.html">张志敏的技术专栏</a>
    </h1>
    <div class="flex items-center gap-3">
      <div class="hidden md:flex items-center gap-1">
        <a href="https://github.com/beginor" class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-900 hover:text-link no-underline" target="_blank" rel="noreferrer">
          <i class="icon ti ti-brand-github"></i>
          <span>GitHub</span>
        </a>
        <a href="http://paypal.me/beginor" class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-900 hover:text-link no-underline" target="_blank" rel="noreferrer">
          <i class="icon ti ti-brand-paypal text-blue-700"></i>
          <span>PayPal.Me</span>
        </a>
      </div>
      <button id="theme-toggler" class="p-2 text-gray-900 hover:text-link" aria-label="切换主题">
        <i id="theme-icon" class="icon ti ti-moon text-xl"></i>
      </button>
      <div class="flex items-center gap-2">
        <span class="w-8 h-8 rounded-full bg-cover bg-center" style="background-image: url(https://avatars.githubusercontent.com/u/159065?v=4?v=3&s=88)"></span>
        <div class="hidden xl:block leading-tight">
          <div class="text-sm font-medium text-gray-950">敏哥</div>
          <div class="text-xs text-gray-900">靠谱码农</div>
        </div>
      </div>
    </div>
  </header>
  <nav class="hidden md:flex max-w-screen-xl mx-auto items-center justify-between px-6 h-10">
    <ul class="flex items-center gap-0 text-sm">
      <li class="{% if page.navbar_active == 'index' %}active{% endif %}">
        <a class="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-900 hover:text-link no-underline {% if page.navbar_active == 'index' %}text-link{% endif %}" href="/index.html">
          <i class="icon ti ti-home"></i> 首页
        </a>
      </li>
      <li class="{% if page.navbar_active == 'pages' %}active{% endif %}">
        <a class="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-900 hover:text-link no-underline {% if page.navbar_active == 'pages' %}text-link{% endif %}" href="/pages.html">
          <i class="icon ti ti-list"></i> 全部文章
        </a>
      </li>
      <li>
        <a class="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-900 hover:text-link no-underline" href="/atom.xml">
          <i class="icon ti ti-rss"></i> 订阅
        </a>
      </li>
      <li class="{% if page.navbar_active == 'libraries' %}active{% endif %}">
        <a class="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-900 hover:text-link no-underline {% if page.navbar_active == 'libraries' %}text-link{% endif %}" href="/libraries.html">
          <i class="icon ti ti-brand-github"></i> 开源项目
        </a>
      </li>
      <li class="{% if page.navbar_active == 'about' %}active{% endif %}">
        <a class="inline-flex items-center gap-1 px-3 py-1 text-sm text-gray-900 hover:text-link no-underline {% if page.navbar_active == 'about' %}text-link{% endif %}" href="/about.html">
          <i class="icon ti ti-info-square"></i> 关于
        </a>
      </li>
    </ul>
    <form role="search" method="get" target="_blank" action="https://www.google.com/search">
      <div class="flex items-center border border-gray-400 rounded-sm px-2 py-1">
        <i class="icon ti ti-search text-gray-800 text-sm"></i>
        <input type="text" class="ml-1.5 text-sm bg-transparent border-none outline-none w-36 text-gray-950 placeholder-gray-800" placeholder="Google 搜索" name="q" maxlength="200"/>
      </div>
      <input type="hidden" name="oe" value="GB2312" />
      <input type="hidden" name="hl" value="zh-CN" />
      <input type="hidden" name="as_sitesearch" value="beginor.github.io" />
    </form>
  </nav>
</div>

<!-- Mobile menu drawer -->
<div id="navbar-overlay" class="fixed inset-0 bg-black/50 z-40 hidden" onclick="toggleMobileMenu()"></div>
<div id="navbar-drawer" class="fixed top-0 left-0 bottom-0 w-64 bg-surface z-50 transform -translate-x-full transition-transform duration-150 ease-out">
  <div class="flex items-center justify-between px-6 h-14 border-b border-gray-400">
    <span class="text-sm font-semibold text-gray-950">菜单</span>
    <button onclick="toggleMobileMenu()" class="p-1 text-gray-900 hover:text-link">
      <i class="icon ti ti-x text-xl"></i>
    </button>
  </div>
  <ul class="py-2 text-sm">
    <li><a class="block px-6 py-2.5 text-gray-950 hover:text-link no-underline" href="/index.html"><i class="icon ti ti-home"></i> 首页</a></li>
    <li><a class="block px-6 py-2.5 text-gray-950 hover:text-link no-underline" href="/pages.html"><i class="icon ti ti-list"></i> 全部文章</a></li>
    <li><a class="block px-6 py-2.5 text-gray-950 hover:text-link no-underline" href="/atom.xml"><i class="icon ti ti-rss"></i> 订阅</a></li>
    <li><a class="block px-6 py-2.5 text-gray-950 hover:text-link no-underline" href="/libraries.html"><i class="icon ti ti-brand-github"></i> 开源项目</a></li>
    <li><a class="block px-6 py-2.5 text-gray-950 hover:text-link no-underline" href="/about.html"><i class="icon ti ti-info-square"></i> 关于</a></li>
  </ul>
  <div class="border-t border-gray-400 px-6 py-3 flex flex-col gap-1">
    <a href="https://github.com/beginor" class="text-sm text-gray-900 hover:text-link no-underline" target="_blank"><i class="icon ti ti-brand-github"></i> GitHub</a>
    <a href="http://paypal.me/beginor" class="text-sm text-gray-900 hover:text-link no-underline" target="_blank"><i class="icon ti ti-brand-paypal text-blue-700"></i> PayPal.Me</a>
  </div>
</div>

<script>
(function() {
  // Theme toggle
  var themeIcon = document.getElementById('theme-icon');
  var themeToggler = document.getElementById('theme-toggler');
  if (themeToggler && themeIcon) {
    function updateThemeIcon() {
      themeIcon.className = 'icon ti text-xl ' + (document.body.classList.contains('theme-dark') ? 'ti-sun' : 'ti-moon');
    }
    themeToggler.addEventListener('click', function() {
      var isDark = document.body.classList.contains('theme-dark');
      document.body.classList.remove('theme-dark', 'theme-light');
      document.body.classList.add(isDark ? 'theme-light' : 'theme-dark');
      localStorage.setItem('tablerTheme', isDark ? 'light' : 'dark');
      updateThemeIcon();
    });
    updateThemeIcon();
  }

  // Mobile menu toggle
  window.toggleMobileMenu = function() {
    var drawer = document.getElementById('navbar-drawer');
    var overlay = document.getElementById('navbar-overlay');
    var isOpen = !drawer.classList.contains('-translate-x-full');
    drawer.classList.toggle('-translate-x-full', isOpen);
    overlay.classList.toggle('hidden', isOpen);
  };
  document.getElementById('navbar-toggler')?.addEventListener('click', window.toggleMobileMenu);
})();
</script>
