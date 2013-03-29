---
layout: post
title: 在 Windows 系统上配置 Apache  Git 服务器
description: 在 Windows 系统上配置 Apache  Git 服务器， 以及使用 AD 进行认证用户认证。
tags: [Git]
---

本文介绍如何在 Windows 系统上配置 Apache  Git 服务器， 以及使用 AD 进行认证用户认证。

### 软件环境 ###

- Windows Server 2003
- Apache 2.2
- Git 1.8

### 安装 Apache ###

从 [httpd] 的主页下载 [Apache Httpd 的 Windows 最新版]， 我下载的版本是 2.2.22 ， 下载下来之后， 根据提示安装即可， 我的安装目录是 C:\Apache2.2 ， 下面的配置都是根据这个目录进行的。

### 安装 Git ###

下载并安装 [msysgit] , 推荐使用 Portable 版本的， 下载后解压到 C:\Git 目录下。 然后新建目录 C:\GitRepos ， 作为代码库的根目录， 下面的配置都是根据这两个目录进行的。

### 配置 Apache 使用 AD 认证 ###

停止 Apache 服务器， 打开 C:\Apache2.2\conf\httpd.conf ， 搜索 `<Directory />` ， 修改根目录配置， 允许所有位置访问， 如下：

    <Directory />
        Options FollowSymLinks
        AllowOverride None
        Order deny,allow
        # 默认是 Deny from all ， 修改为 Allow from all
        Allow from all
    </Directory>

在 httpd.conf 文件中搜索 ldap ， 确认 authnz_ldap_module 和 ldap_module 都已经被加载（行首没有#）。

新建一个 git.conf , 与 httpd.conf 保存在同一个目录， 然后再在 httpd.conf 的末尾添加一句 `Include conf/git.conf` 包含这个文件。

保存 httpd.conf ，打开 git.conf ， 添加下面一句：

    Alias /git "C:/GitRepos"

将 C:\Repos 映射为 /git ， 接下来是这个目录的认证设置：

    <Directory "C:/GitRepos">
        # 设置认证名称、类型
        AuthName "Git Access"
        AuthType Basic
        AuthBasicProvider ldap
        # 设置 LDAP 搜索的目录， 使用 sAmAccountName 登录， 位于这个 AD 目录下的所有用户都可以登录
        AuthLDAPURL "ldap://company.local:389/O=MyOrg,DC=company,DC=localcn?sAMAccountName?sub?(objectClass=*)"
        AuthzLDAPAuthoritative on
        # 设置 Apache 搜索 AD 时使用的凭据
        AuthLDAPBindDN "username@company.local"
        AuthLDAPBindPassword userpassword
        # 设置使用 AD 组过滤时搜索的条件
        AuthLDAPGroupAttributeIsDN on
        AuthLDAPGroupAttribute member
        # 通过认证的用户都可以访问
        Require valid-user
    </Directory>

现在保存 httpd.conf 、 git.conf， 启动 Apache http 服务， 如果顺利的话， 访问 http://localhost 会显示 **It works!** 表示 http 服务正常运行， 访问 http://localhost/git 会弹出登录框， 输入用户名以及密码之后可以顺利访问。

### 配置 Git Smart Http ###

先运行一下 C:\Git\libexec\git-core\git-http-backend.exe ， 如果弹出下面的错误提示框:

![git-http-backend.exe - System Error](/assets/post-images/git-http-backend-error.png)

则需要将 C:\Git\bin, C:\Git\cmd 添加到 Path 环境变量中， 然后再运行 git-http-backend.exe ， 就应该不会有错误提示框了。

接下来修改 git.conf ， 让 Apache 来启动 git-http-backend.exe ， 打开 git.conf ， 将原来的

    Alias /git "C:/GitRepos"

注释掉， 改为：

    # 设置 Git 代码库的根目录
    SetEnv GIT_PROJECT_ROOT C:/GitRepos
    # 默认通过 HTTP 导出所有的 Git 代码库
    SetEnv GIT_HTTP_EXPORT_ALL
    # 将 git-http-backend.exe 映射为 cgi 程序， 请求 /git/ 下的所有请求都由
    # git-http-backend.exe 处理
    ScriptAlias /git/ C:/Git/libexec/git-core/git-http-backend.exe/

将原来配置的 `<Directory "C:/GitRepos">`  修改为 `<Location /git/>` ， 如下所示：

    <Location /git/>
        # 设置认证名称、类型
        AuthName "Git Access"
        AuthType Basic
        AuthBasicProvider ldap
        # 设置 LDAP 搜索的目录， 使用 sAmAccountName 登录， 位于这个 AD 目录下的所有用户都可以登录
        AuthLDAPURL "ldap://company.local:389/O=MyOrg,DC=company,DC=local?sAMAccountName?sub?(objectClass=*)"
        AuthzLDAPAuthoritative on
        # 设置 Apache 搜索 AD 时使用的凭据
        AuthLDAPBindDN "username@company.local"
        AuthLDAPBindPassword userpassword
        # 设置使用 AD 组过滤时搜索的条件
        AuthLDAPGroupAttributeIsDN on
        AuthLDAPGroupAttribute member
        # 通过认证的用户都可以访问
        Require valid-user
    </Location>

保存 git.conf ， 重启 Apache httpd 服务。 现在， 可以用 git 新建一个测试库， 打开一个命令行窗口， 在 C:\GitRepos 目录下输入下面的命令：

    git init --bare Test.git

再开一个新的命令行窗口， 输入下面的命令进行测试：

   git clone http://localhost/git/Test.git

接下来会提示让你输入用户名和密码， 最后看到下面的提示就表示成功了：

    C:\temp>git clone http://localhost/git/Test.git
    Cloning into 'Test'...
    Username for 'http://localhost': zhangzhimin
    Password for 'http://zhangzhimin@localhost':
    warning: You appear to have cloned an empty repository.

如果出错， 则可以看看 C:\Apache2.2\logs\error.log ，如果错误原因是 “Repository not exported”， 需要在 Test.git 目录下建一个名称为 git-daemon-export-ok 的空文件即可。 如果是提示关于 git-http-backend.exe 的问题， 则应该是 git-http-backend.exe 无法运行造成的。

### 设置代码库权限 ###

现在， Windows 上的 Git 服务器已经可以运行了， 通常情况下， 需要为每个库配置权限， 比如上面的 Test.git 只允许特定用户或者特定用户组访问， 则需要在 git.conf 文件中添加下面的配置：

    <Location /git/AppFx.git>
        AuthName "Private Git Access"
        # 允许特定用户访问
        Require ldap-user zhangzhimin
        # 允许用户组访问，把下面一行行首的#去掉即可
        #Require ldap-group CN=Developers,OU=GitUsers,O=MyOrg,DC=company,DC=local
    </Location>

改完之后保存 git.conf 并重启 Apache httpd 服务即可。

### 注意问题 ###

整个配置过程比较复杂， 在 Windows 上配置的资料也比较少， 很容易出错， 所以在配置的过程中， 给出如下的建议：

- 将 Apache 的 LogLevel 设置为 DEBUG （在http.conf中修改）， 可以在 C:\Apache2.2\logs\error.log 文件中看到详细的调试信息， 有时很有帮助；
- 多运行 Apache 的 Test Configuration 快捷方式， 如果配置有错， 会有详细提示， 并等待 30 秒钟；
- 用事件查看器查看系统日志， 有时这里也会有详细的错误信息。

[httpd]:http://httpd.apache.org/
[Apache Httpd 的 Windows 最新版]:http://www.fayea.com/apache-mirror//httpd/binaries/win32/
[msysgit]:https://code.google.com/p/msysgit/downloads/list

