---
layout: post2
title: 发布 Angular 应用至生产环境
description: 介绍如何使用 Docker 将 Angular 应用发布至生产环境
keywords: angular, deploy, docker, nginx
tags: [Angular, Docker]
---

两年前， 写过一篇使用 [rollup](http://rollupjs.org) 来[为生产环境编译 Angular 2 应用](/2016/11/15/build-angular2-for-product.html)的文章， 因为当时还没有 [angular-cli](https://cli.angular.io/) 项目。 而如今 Angular 已经到了 7.x 版本， 对应的工具也是非常的完善， 也就不在使用 rollup 来处理 angular 项目。

angular-cli 用起来虽然方便， 但是针对生产环境编译的话， 还是有一些地方要注意的， 接下来就介绍我在项目部署时的一些做法。

#### 合理拆分功能模块， 按需加载

一个系统往往功能非常多， 因此就要根据项目的实际情况划分功能模块，一个功能模块对应一个 `NgModule` ， 编译成一个独立的 js 文件， 再结合 angular 的路由技术进行按需加载，就这一功能点来说， angular 的支持已经非常的完善了。

```typescript
const routes: Routes = [
    { path: '', redirectTo: '/home', pathMatch: 'full' },
    { path: 'home', loadChildren: './home/home.module#HomeModule' },
    { path: 'about', loadChildren: './about/about.module#AboutModule' },
    {
        path: 'arcgis',
        loadChildren: './arcgis/arcgis.module#ArcgisModule',
        canLoad: [EsriLoaderGuard]
    }
];
```

> 这一点经常容易被忽视， 曾经就出现过犹豫没有合理划分模块， 导致编译出来的 js 文件高达 5 兆， 造成的客户体验非常差。 （甚至还出现开发机内存不足，无法成功编译的情况）

#### 预先压缩 js 文件

当然， 仅仅考合理划分 js 模块的话， 还往往不太够， 因为单个模块也可能会比较大， 可能会超过 1 兆， 特别是使用了一些第三方控件（ng-bootstrap, ng-zorro 等）的情况下。

针对这种情况， 通常还需要对编译生成的 js 文件进行 gzip 压缩， 因此在执行 `ng build --prod` 编译之后， 再继续执行下面的 shell 命令：

```shell
find dist -name "*.js" -print0 | xargs -0 gzip -k
```

当然， 如果发现编译生成 css 文件比较大的话， 也可以通过下面的命令进行压缩：

```shell
find dist -name "*.css" -print0 | xargs -0 gzip -k
```

以一个仅仅使用了 ng-bootstrap 的模板项目为例， 生成的 js 文件如下所示：

```
 1.8K  dist/ng-seed/4.1495aba38157395f4a2d.js
 1.7K  dist/ng-seed/5.ec7eb27ea7c8eee53bcc.js
 482K  dist/ng-seed/main.6ee651175769ea64ed5f.js
  37K  dist/ng-seed/polyfills.5d61d41949cb87471fa8.js
 2.2K  dist/ng-seed/runtime.c66e13242c809a55bd2f.js
```

其中的 `main.6ee651175769ea64ed5f.js` 就有 482KB ， 而经过 gzip 压缩之后， 文件大小显著减小：

```
1.8K dist/ng-seed/4.1495aba38157395f4a2d.js
1.0K dist/ng-seed/4.1495aba38157395f4a2d.js.gz
1.7K dist/ng-seed/5.ec7eb27ea7c8eee53bcc.js
888B dist/ng-seed/5.ec7eb27ea7c8eee53bcc.js.gz
482K dist/ng-seed/main.6ee651175769ea64ed5f.js
124K dist/ng-seed/main.6ee651175769ea64ed5f.js.gz
 37K dist/ng-seed/polyfills.5d61d41949cb87471fa8.js
 12K dist/ng-seed/polyfills.5d61d41949cb87471fa8.js.gz
2.2K dist/ng-seed/runtime.c66e13242c809a55bd2f.js
1.2K dist/ng-seed/runtime.c66e13242c809a55bd2f.js.gz
```

`main.6ee651175769ea64ed5f.js.gz` 有 124KB ， 只有原来的 1/4 。

一般来说， 对于 angular 项目编译出的 js 文件， gzip 压缩能减少 3/4 甚至 4/5 的体积， 这样将会显著减轻网络传输的压力。

#### 使用 nginx 作为服务器

为什么使用 nginx 作为前端服务器呢？ 原因如下：

##### 支持传输预先压缩的 js 文件

将预先压缩好的 `.js.gz` 和原来的 `.js` 文件一起上传到服务器， 只要在 nginx 服务器的配置文件上加一句 `gzip_static on;` 即可启用，这样在客户端请求 `.js` 文件时， nginx 会先检查一下是否存在对应的 `.js.gz`文件， 如果存在的话， 就直接返回 `.js.gz` 文件的内容， 从而省去了在服务端进行压缩的过程， 节省服务器的资源。

```nginx
location /ng-app {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
    gzip_static on;
    try_files $uri /ng-app/index.html;
}
```

##### 作为后台接口的网关

nginx 支持反向代理， 可以作为后台接口的网关， 这样可以省去一些跨域调用 (cors) 的问题， 一般的反向代理配置如下：

```nginx
location /api {
    proxy_pass http://api-server:8080/api;
    proxy_read_timeout 600s;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

##### 官方的 docker 镜像

nginx 有 docker 的官方镜像， 部署、升级都是非常的方便。 不得不说docker 确实是好东西， 用了就停不下来了。

这几点都是在项目中积累的一些小技巧， 如果想要了解细节， 请查看这个 [ng-seed](https://github.com/beginor/ng-seed) 项目。