<header class="top" role="header">
    <div class="container">
        <nav class="navbar navbar-inverse" role="navigation">
            <div class="navbar-header">
                <button class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand pull-left" href="/">张志敏的技术专栏</a>
            </div>
            <div class="navbar-collapse collapse">
                <ul class="navbar-nav nav">
                    <li {% if page.navbar_active == 'pages' %}class="active"{% endif %}>
                        <a href="/pages.html">全部文章</a>
                    </li>
                    <li>
                        <a href="/atom.xml">订阅</a>
                    </li>
                    <li {% if page.navbar_active == 'library' %}class="active"{% endif %}>
                        <a href="/libraries.html">开源项目</a>
                    </li>
                    <li {% if page.navbar_active == 'about' %}class="active"{% endif %}>
                        <a href="/about.html">关于</a>
                    </li>
                </ul>
                <form class="navbar-form navbar-right" role="search" method="get" target="_blank" action="http://www.google.com/search">
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="Google 搜索" name="q" maxlength="200"/>
                        <input type="hidden" name="oe" value="GB2312" />
                        <input type="hidden" name="hl" value="zh-CN" />
                        <input type="hidden" name="as_sitesearch" value="beginor.github.io" />
                    </div>
                </form>
            </nav>
        </nav>
    </div>
</header>