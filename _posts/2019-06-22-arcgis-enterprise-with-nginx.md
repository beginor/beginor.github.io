---
layout: post2
title: ArcGIS Enterprise 配置 nginx 反向代理
description: 使用 nginx 作为 ArcGIS Enterprise 的反向代理
keywords: arcgis enterprise, arcgis portal, arcgis server, reverse proxy, nginx
tags: [参考]
---

三台服务器， 部署软件分别为：

| 服务器         | 软件              | Web 地址                            |
| -------------- | ----------------- | ----------------------------------- |
| agportal.local | Portal for ArcGIS 10.6 | https://agportal.local:7443/arcgis/ |
| agserver.local | Server for ArcGIS 10.6 | https://agserver.local:6443/arcgis/ |
| nginx.local    | Nginx             | https://nginx.local/                |

nginx 作为反向代理， 实现用下面的URL地址来访问 Portal 和 Server 

- 使用 https://nginx.local/gisportal/ 访问 Portal for ArcGIS；
- 使用 https://nginx.local/gisserver/ 访问 Server for ArcGIS；

## ArcGIS Server 配置

- 访问 https://agserver.local:6443/arcgis/admin ， 以管理员身份登录；
- 选择 `System` > `Properties` > `Update`；
- 在 `Properties` 文本框中，插入以下 JSON:

  ```json
  {
    "WebContextURL": "https://nginx.local/gisserver"
  }
  ```

- 点击 `Update` 按钮， 等待服务器更新完成；
- 登录到服务器， 重启 ArcGIS Server ；

## ArcGIS Portal 配置

- 访问 https://agportal.local:7443/arcgis/portaladmin ， 以管理员身份登录；
- 选择 `System` > `Properties` > `Update`；
- 在 `Properties` 文本框中，插入以下 JSON:

  ```json
  {
    "WebContextURL": "https://nginx.local/gisportal"
  }
  ```

- 登录到服务器， 重启 ArcGIS Portal ；

## NGINX 配置

- nginx 配置 https 证书， 这个是必须的。

- 反代 Server for ArcGIS 配置：

  ```properties
  location /gisserver {
    proxy_pass https://agserver.local:6443/arcgis;
    proxy_read_timeout 600s;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    # ArcGIS Server 要求必须添加 X-Forwarded-Host 反代标头
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
  ```

- 反代 Portal for ArcGIS 配置

  ```properties
  location /gisportal {
    proxy_pass https://agportal.local:7443/arcgis;
    proxy_read_timeout 600s;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    # ArcGIS Server 要求必须添加 X-Forwarded-Host 反代标头
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
  ```

- 使用命令 `nginx -s reload` 重新加载配置

