---
layout: post
title: 在 Ubuntu Server 上安装配置 Mono 生产环境
description: 介绍在 Ubuntu Server 上安装和配置 Apache2 ＋ Mono 生产环境
tags: [Mono, Linux]
keywords: Linux, Ubuntu Server, Apache2, mod_mono, mono
---

在 Ubuntu Server 上安装和配置 Apache2 ＋ Mono 生产环境的记录。 服务器环境是 Ubuntu Server 13.04 虚拟机模式 (Virtual Machine Mode)， 安装的 Mono 的版本是 3.2.1 ， 最终环境如下图所示：

![Ubuntu Server And Mono Version Infomation](/assets/post-images/ubuntu-server-mono-version-info.png)

### 准备编译环境

还是老话题， 先准备 GCC 编译环境， 这样才可以从源代码编译安装所需要的软件。  首先需要安装的是基本的编译工具， 只要输入下面的命令即可：

    sudo apt-get install g++ gettext autoconf

接下来输入用户名和密码， 就可以自动安装必须的命令行编译工具了。

### 从源代码编译安装 libgdiplus

对于服务器来说， 主要运行 Apache、 ASP.Net、 Mvc 以及 WCF 等服务端程序， 一般不会运行图形界面， 因为图形界面会消耗额外的内存和处理器资源， 所以说 libgdiplus 不是必须安装的， 不过一个常见的场景是需要在服务端动态生成图片， 也会用到 libgdiplus ， 因此 libgdiplus 还是推荐安装的。 如果服务器上不需要生成图片， 则可以不用安装 libgdiplus 。

先安装编译 libgdiplus 所需的依赖项， 输入下面的命令：

    sudo apt-get install libglib2.0-dev libpng12-dev libexif-dev libx11-dev libfreetype6-dev libfontconfig1-dev libjpeg62-dev libgif-dev libxrender-dev

下载 libgdiplus 最新版的源代码：

    wget http://download.mono-project.com/sources/libgdiplus/libgdiplus-2.10.9.tar.bz2

下载完成之后解压， 并且换到源代码的目录：

    tar -jxvf libgdiplus-2.10.9.tar.bz2
    cd libgdiplus-2.10.9

配置并检查 libgdiplus 的编译选项：

    ./configure

这是最关键的步骤， 如果 `configure` 命令中途出错， 则一般是缺少了某个依赖的库， 只要根据提示安装相应的依赖库就可以了， `configure` 命令运行结果如果如下图所示， 则表示可以进行下一步了：

![Libgdiplus configure summary](/assets/post-images/libgdiplus-configure-summary.png)

> 上图中的配置结果不支持 tiff ， 因为在服务端动态生成 tiff 图片的需求很小， 所以这个 tiff 可以直接忽略了， 如果需要生成 tiff， 只要安装 `libtiff-dev` 再次执行 `configure` 命令即可。

接下来接着输入下面的命令就可以编译并安装 libgdiplus 了：

    make
    sudo make install

**常见问题：**

如果在 `make` 的过程中出现类似如下错误：

    Making all in pixman
    make[4]: Entering directory `/usr/local/src/libgdiplus-2.10.9/pixman/pixman'
    source='pixman-access.c' object='pixman-access.lo' libtool=yes \
            DEPDIR=.deps depmode=none /bin/sh ../depcomp \
            /bin/sh ../libtool --tag=CC   --mode=compile gcc -DHAVE_CONFIG_H -I. -I..     -g -O2 -Wall -fvisibility=hidden -c -o pixman-access.lo pixman-access.c
    ../libtool: line 852: X--tag=CC: command not found
    ../libtool: line 885: libtool: ignoring unknown tag : command not found
    ../libtool: line 852: X--mode=compile: command not found
    ../libtool: line 1018: *** Warning: inferring the mode of operation is deprecated.: command not found
    ../libtool: line 1019: *** Future versions of Libtool will require --mode=MODE be specified.: command not found
    ../libtool: line 1162: Xgcc: command not found
    ../libtool: line 1162: X-DHAVE_CONFIG_H: command not found
    ../libtool: line 1162: X-I.: command not found
    ../libtool: line 1162: X-I..: command not found
    ../libtool: line 1162: X-g: command not found
    ../libtool: line 1162: X-O2: command not found
    ../libtool: line 1162: X-Wall: command not found
    ../libtool: line 1162: X-fvisibility=hidden: command not found
    ../libtool: line 1162: X-c: command not found
    ../libtool: line 1214: Xpixman-access.lo: command not found
    ../libtool: line 1219: libtool: compile: cannot determine name of library object from `': command not found
    make[4]: *** [pixman-access.lo] Error 1
    make[4]: Leaving directory `/usr/local/src/libgdiplus-2.10.9/pixman/pixman'
    make[3]: *** [all-recursive] Error 1
    make[3]: Leaving directory `/usr/local/src/libgdiplus-2.10.9/pixman'
    make[2]: *** [all] Error 2

解决方法是输入下面的命令， 然后再继续执行 `make` 命令：

    export echo=echo

如果出现类似这样的错误：

    /usr/lib64/libglib-2.0.so.0: could not read symbols: Invalid operation
    collect2: error: ld returned 1 exit status
    make[2]: *** [testgdi] Error 1
    make[2]: Leaving directory `/usr/local/src/libgdiplus-2.10.9/tests'
    make[1]: *** [all-recursive] Error 1
    make[1]: Leaving directory `/usr/local/src/libgdiplus-2.10.9'
    make: *** [all] Error 2

解决方法是：

* 先执行 `./configure` 命令， 然后编辑 `test/Makefile` 文件；
* 将 130 行的 `LIBS = -lpthread -lfontconfig` 改为 ` LIBS = -lpthread -lfontconfig -lglib-2.0 -lX11`；
* 再次执行 `make` 命令即可。

最终， 在 `make` 命令执行成功之后， 在继续执行 `sudo make install` 命令进行安装。

### 从源代码编译安装 mono 、 xsp

安装好了 libgdiplus 之后， 接下来的 mono 和 xsp 就是一路顺风了， 只要简单的敲几行命令就可以了：

    wget http://download.mono-project.com/sources/mono/mono-3.2.3.tar.bz2
    tar -jxvf mono-3.2.3.tar.bz2
    cd mono-3.2.3
    make
    sudo make install

    wget http://download.mono-project.com/sources/xsp/xsp-2.10.2.tar.bz2
    tar -jxvf xsp-2.10.2.tar.bz2
    cd xsp-2.10.2.tar.bz2
    make
    sudo make install

执行上面的命令， 一般都不会出现什么错误了。 现在可以测试一下安装的 mono 和 xsp ， 在终端输入：

    mono --version

可以得到如下图的提示：

![Mono 3.2.3 Version Info](/assets/post-images/mono-3.2.3-version-info.png)

编译安装 xsp 之后， 会在 `/usr/local/lib/xsp/test` 目录下生成一个 .net 测试网站， 我们可以用这个测试站点来测试 mono + xsp 的安装， 输入下面的命令：

    cd /usr/local/lib/xsp/test
    ls
    xsp

可以看到的命令行输出如下：

![Xsp Test Server](/assets/post-images/xsp-test-server.png)

打开浏览器， 访问服务器的 8080 端口， 可以看到的如下的画面， 说明 mono + xsp 已经安装成功了。

![xsp test site info](/assets/post-images/xsp-test-site-info.png)

### 安装 apache2 和 apache2-dev

前面已经安装好了 mono + xsp ， 用来测试应用的话足够了， 但是不能做为服务器生产环境使用， 因此还需要继续安装 apache http server ， 并将 mono 做为 apache 的模块挂载上去。 Apache http server 我们选择从 Ubuntu Server 的软件仓库中安装， 只要输入下面的命令即可：

    sudo apt-get install apache2 apache2-prefork-dev apache2-threaded-dev

第一个软件包是 Apache Http 服务器， 另外两个是 Apache 的开发包， 接下来要安装的 mod_mono 依赖这两个开发包， 因此一并安装。

### 从源代码编译安装 mod_mono

现在， 安装 mod_mono 也是非常简单的：

    wget http://origin-download.mono-project.com/sources/mod_mono/mod_mono-2.10.tar.bz2
    tar -jxvf mod_mono-2.10.tar.bz2
    cd mod_mono-2.10
    ./configure
    make
    sudo make install

这个一般也不会出现什么错误， 基本上都能正确安装。

### 配置 apache2 和 mod_mono

现在， 可以说万事具备， 只欠东风， 只要将 mod_mono 配置并加载到 apache 中就可以了， apache 在 Ubuntu Server 上的配置目录是 `/etc/apache2` ， 在编译安装 mod_mono 的时候， 已经将 mod_mono.conf 复制到这个目录了， 我们只要修改 apache2 的配置， 引用这个文件即可， `/etc/apache2` 的目录结构如下：

![/etc/apache2 directory structure](/assets/post-images/etc-apache2-dir-structure.png)

通过查看 `/etc/apache2/apache2.conf` 文件可以知道各个目录的含义， 只要在 `/etc/apache2/mods_enabled` 目录新建一个链接文件， 指向 `/etc/apache2/mod_mono.conf` 即可加载 mod_mono ， 切换到 `/etc/apache2/mods-enabled` 目录， 输入下面的命令添加链接：

    cd /etc/apache2/mod-enabled
    sudo ln -s ../mod_mono.conf ./mod_mono.conf

现在输入 `ls -l /etc/apache2/mods-enabled/mod_*.conf` ， 输出如下所示：

    ls -l /etc/apache2/mods-enabled/mod_*.conf
    lrwxrwxrwx 1 root root 16 Sep  6 13:34 mod_mono.conf -> ../mod_mono.conf

看到有 `mod_mono.conf -> ../mod_mono.conf` 的输出提示， 说明链接链接已经做好了， 重启 Apache 服务就会加载 mod_mono 。

> 有兴趣的可以输入命令 `more /etc/apache2/mod_mono.conf` 查看一下这个文件的内容， 看是不是很熟悉的 aspx 、 asmx 、 ashx 等都出现了。

现在在默认站点下添加一个名为 `MonoTest` 的测试程序， 需要编辑 `/etc/apache2/sites-available/default` 文件， 在文件的最后， `CustomLog` 指令之前， 插入下面的配置：

    Alias /MonoTest "/usr/local/lib/xsp/test"
    MonoServerPath MonoTest "/usr/bin/mod-mono-server2"
    MonoDebug MonoTest true
    MonoSetEnv MonoTest MONO_IOMAP=all

    MonoApplications MonoTest "/MonoTest:/usr/local/lib/xsp/test"
    <Location "/MonoTest">
      Allow from all
      Order allow,deny
      MonoSetServerAlias MonoTest
      SetHandler mono
      SetOutputFilter DEFLATE
      SetEnvIfNoCase Request_URI "\.(?:gif|jpe?g|png)$" no-gzip dont-vary
    </Location>
    <IfModule mod_deflate.c>
      AddOutputFilterByType DEFLATE text/html text/plain text/xml text/javascript
    </IfModule>

> 这些配置可以在 [Configure Apache Mod_Mono](http://go-mono.com/config-mod-mono/Default.aspx) 生成， 不比逐行输入。

保存并关闭这个文件， 然后输入下面的命令重启 Apache2 服务：

    sudo service apache2 restart

然后再次打开浏览器， 输入地址： `http://server-name-or-address/MonoTest` ， 看到类似下面的画面就大功告成了：

![mod_mono + Apache2 Success](/assets/post-images/mod-mono-apache2-success.png)

当然， 一切只是个开始， 接下来将继续测试 ASP.Net MVC 、 EntityFramework 、 NHibernate 等常用组件在 Mono 上的表现。

### 参考资料

* [http://download.mono-project.com/sources/](http://download.mono-project.com/sources/)
* [Mod mono](http://www.mono-project.com/Mod_mono)
* [Configure Apache Mod_Mono](http://go-mono.com/config-mod-mono/Default.aspx)