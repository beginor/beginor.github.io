<header class="top navbar navbar-dark" role="header">
    <div class="container">
        <nav>

            <div class="clearfix">
                <button class="navbar-toggler hidden-sm-up pull-xs-right collapsed" style="color: #FFF;" type="button" data-toggle="collapse" data-target="#collapsenav">
                    <i class="fa fa-bars" aria-hidden="true"></i>
                </button>
                <a class="navbar-brand hidden-sm-up" href="/">张志敏的技术专栏</a>
            </div>

            <div class="collapse navbar-toggleable-xs" id="collapsenav">
                <a class="navbar-brand hidden-xs-down" href="/">张志敏的技术专栏</a>
                <ul class="nav navbar-nav">
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

                <form class="form-inline pull-sm-right" role="search" method="get" target="_blank" action="http://www.google.com/search">
                    <input type="text" class="form-control" placeholder="Google 搜索" name="q" maxlength="200"/>
                    <input type="hidden" name="oe" value="GB2312" />
                    <input type="hidden" name="hl" value="zh-CN" />
                    <input type="hidden" name="as_sitesearch" value="beginor.github.io" />
                </form>
            </div>
            
        </nav>
    </div>
</header>
