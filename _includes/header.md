<header class="top" role="header">
  <div class="container">
    <nav class="navbar navbar-toggleable-md navbar-inverse">
      <button class="navbar-toggler navbar-toggler-right collapsed" type="button" data-toggle="collapse" data-target="#navbarColor01" aria-controls="navbarColor01" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
      </button>
      <a class="navbar-brand" href="/">张志敏的技术专栏</a>
      <div class="collapse navbar-collapse" id="navbarColor01">
        <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
          <li class="nav-item {% if page.navbar_active == 'pages' %}active{% endif %}">
            <a class="nav-link" href="/pages.html"><i class="fa fa-list"></i> 全部文章</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/atom.xml"><i class="fa fa-rss"></i> 订阅</a>
          </li>
          <li class="nav-item {% if page.navbar_active == 'library' %}active{% endif %}">
            <a class="nav-link" href="/libraries.html"><i class="fa fa-github"></i> 开源项目</a>
          </li>
          <li class="nav-item {% if page.navbar_active == 'about' %}active{% endif %}">
            <a class="nav-link" href="/about.html"><i class="fa fa-info"></i> 关于</a>
          </li>
        </ul>
        <form class="form-inline my-2 my-lg-0" role="search" method="get" target="_blank" action="https://www.google.com/search">
          <input type="text" class="form-control" placeholder="Google 搜索" name="q" maxlength="200"/>
          <input type="hidden" name="oe" value="GB2312" />
          <input type="hidden" name="hl" value="zh-CN" />
          <input type="hidden" name="as_sitesearch" value="beginor.github.io" />
        </form>
      </div>
    </nav>
  </div>
</header>
