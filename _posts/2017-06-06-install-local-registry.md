---
layout: post2
title: 本地 Docker Registry 的安装与使用
description: 介绍如何安装与使用本地的 registry 
keywords: docker, registry, linux
tags: [Docker, Linux]
---

[安装 Docker 环境](https://beginor.github.io/2017/06/04/install-docker-env.html)之后， 可以开始下载和运行 Docker 镜像了， 比如要下载一个 nginx 服务器， 只要输入下面的命令：

```sh
docker pull nginx:alpine
```

就能下载到基于 alpine 的最新版本的 nginx 服务器镜像， 然后再输入：

```sh
docker run \
    --detach \
    --name nginx \
    --volume $(pwd)/nginx/conf.d:/etc/nginx/conf.d:ro \
    --volume $(pwd)/nginx/html:/usr/share/nginx/html \
    --volume $(pwd)/nginx/log:/var/log/nginx \
    --publish 80:80 \
    --restart unless-stopped \
    nginx:alpine
```

就可以开始运行 nginx 服务器了， 使用起来非常方便。

作为开发者， 自然会自己制作一些镜像， 在公司内网分发， 或者开发团队制作镜像， 然后交付给测试团队进行测试， 这就需要一个内部分发镜像的服务器， 这个 Docker 团队自然也想到了， 并且提供了一个镜像 [retistry](https://hub.docker.com/r/library/registry/) ， 先把这个镜像拉倒本地：

```sh
docker pull registry:latest
```

等待下载完成之后， 运行这个镜像：

```sh
docker run \
  --detach \
  --name registry \
  --hostname registry \
  --volume $(pwd)/registry:/var/lib/registry/docker/registry \
  --publish 5000:5000 \
  --restart unless-stopped \
  registry:latest
```

在地址栏输入 `http://127.0.0.1:5000/v2/_catalog` ， 将会看到类似下面的输出：

```json
{"repositories":[]}
```

接下来我们尝试将上面的 `nginx:alpine` 上传到本地的 registry 服务器， 首先为这个镜像定义一个新的标签：

```sh
docker tag nginx:alpine 127.0.0.1:5000/nginx:alpine
```

然后确认存在这个标签

```sh
docker images
```

输出如下：

```
REPOSITORY                                        TAG                 IMAGE ID            CREATED             SIZE
127.0.0.1:5000/nginx                              alpine              0ae090dba3ab        3 months ago        54.3 MB
nginx                                             alpine              0ae090dba3ab        3 months ago        54.3 MB
```

现在可以上传这个镜像：

```sh
docker push 127.0.0.1:5000/nginx:alpine

```

输出如下

```
The push refers to a repository [127.0.0.1:5000/nginx]
4a8d9a67e458: Pushed 
c0ab80890b7f: Pushed 
d4930e247b49: Pushed 
9f8566ee5135: Pushed 
alpine: digest: sha256:bf63c02f35f7f8d0a95af4904d38ea17ef3f0c86e6b95d716200bdd9963f5ec5 size: 1154
```

现在来浏览 `http://127.0.0.1:5000/v2/_catalog` ， 将会看到这样的结果：

```json
{"repositories":["nginx"]}
```

表示已经有了 `nginx` 这个镜像， 如果要看这个镜像有什么版本， 需要输入地址 `http://127.0.0.1:5000/v2/nginx/tags/list` ， 结果如下：

```json
{"name":"nginx","tags":["alpine"]}
```

如果要在其它装了 docker 的电脑上获取这个镜像， 或者下载局域网其它 registry 服务器上的镜像， 有两个选择：

 1. 配置 HTTPS 证书， 因为是内网分发， 没有必要去折腾证书。 如果需要的话， 可以参考[这个教程](https://docs.docker.com/registry/deploying/#running-a-domain-registry)来配置域证书或者[这个教程](https://docs.docker.com/registry/insecure/#using-self-signed-certificates)来配置自签名证书;
 2. 参考[这个教程](https://docs.docker.com/registry/insecure/#deploying-a-plain-http-registry)修改 docker 的 `daemon.json` 文件， 配置 `insecure-registries` 选项。
