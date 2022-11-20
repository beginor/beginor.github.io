<div class="sticky-top">
  <header class="navbar navbar-expand-md navbar-light d-print-none">
    <div class="container-xl">
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar-menu" aria-controls="navbar-menu" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <h1 class="navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3">
        <a href="index.html">张志敏的技术专栏</a>
      </h1>
      <div class="navbar-nav flex-row order-md-last">
        <div class="nav-item d-none d-md-flex me-3">
          <div class="btn-list">
            <a href="https://github.com/beginor" class="btn" target="_blank" rel="noreferrer">
              <i class="icon ti ti-brand-github"></i>
              GitHub
            </a>
            <a href="http://paypal.me/beginor" class="btn" target="_blank" rel="noreferrer">
              <i class="icon ti ti-brand-paypal text-red"></i>
              PayPal.Me
            </a>
          </div>
        </div>
        <div class="d-none d-md-flex">
          <a href="?theme=dark" class="nav-link px-0 hide-theme-dark" data-bs-toggle="tooltip" data-bs-placement="bottom" aria-label="启用深色模式" data-bs-original-title="启用深色模式">
            <i class="icon ti ti-moon"></i>
          </a>
          <a href="?theme=light" class="nav-link px-0 hide-theme-light" data-bs-toggle="tooltip" data-bs-placement="bottom" aria-label="启用浅色模式" data-bs-original-title="启用浅色模式">
            <i class="icon ti ti-sun"></i>
          </a>
        </div>
        <div class="nav-item ms-3">
          <a href="#" class="nav-link d-flex lh-1 text-reset p-0">
            <span class="avatar avatar-sm" style="background-image: url(https://avatars.githubusercontent.com/u/159065?v=4?v=3&s=88)"></span>
            <div class="d-none d-xl-block ps-2">
              <div>敏哥</div>
              <div class="mt-1 small text-muted">靠谱码农</div>
            </div>
          </a>
        </div>
      </div>
    </div>
  </header>
  <div class="navbar-expand-md">
    <div class="collapse navbar-collapse" id="navbar-menu">
      <div class="navbar navbar-light">
        <div class="container-xl">
          <ul class="navbar-nav">
            <li class="nav-item {% if page.navbar_active == 'index' %}active{% endif %}">
              <a class="nav-link" href="/index.html">
                <i class="icon ti ti-home me-1"></i> 首页
              </a>
            </li>
            <li class="nav-item {% if page.navbar_active == 'pages' %}active{% endif %}">
              <a class="nav-link" href="/pages.html">
                <i class="icon ti ti-list me-1"></i> 全部文章
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="/atom.xml">
               <i class="icon ti ti-rss me-1"></i> 订阅
              </a>
            </li>
            <li class="nav-item {% if page.navbar_active == 'libraries' %}active{% endif %}">
              <a class="nav-link" href="/libraries.html">
                <i class="icon ti ti-brand-github me-1"></i> 开源项目
              </a>
            </li>
            <li class="nav-item {% if page.navbar_active == 'about' %}active{% endif %}">
              <a class="nav-link" href="/about.html">
                <i class="icon ti ti-info-square me-1"></i> 关于
              </a>
            </li>
          </ul>
          <div class="my-2 my-md-0 flex-grow-1 flex-md-grow-0 order-first order-md-last">
            <form role="search" method="get" target="_blank" action="https://www.google.com/search">
              <div class="input-icon">
                <span class="input-icon-addon">
                  <i class="icon ti ti-search"></i>
                </span>
                <input type="text" class="form-control" placeholder="Google 搜索" name="q" maxlength="200"/>
              </div>
              <input type="hidden" name="oe" value="GB2312" />
              <input type="hidden" name="hl" value="zh-CN" />
              <input type="hidden" name="as_sitesearch" value="beginor.github.io" />
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
