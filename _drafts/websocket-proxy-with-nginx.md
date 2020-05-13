---
layout: post2
title: nginx 配置 websocket 反向代理
description: 如何使用 nginx 配置 websocket 反向代理
keywords: nginx, reverse proxy, websocket, signalr
tags: [NGINX]
---

HTTP 级别增加一个 map 配置

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
```

反向代理配置

```nginx
location /web/r {
    proxy_pass http://webserver;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
}
```
