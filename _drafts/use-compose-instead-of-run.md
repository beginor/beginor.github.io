---
layout: post2
title: 使用 docker-compose 替代 docker run 
description: 使用 docker-compose 替代 docker run
keywords: docker-compose, docker, run
tags: [Docker, Linux]
---

## 使用 docker run 运行镜像

要运行一个 docker 镜像， 通常都是使用 `docker run` 命令， 在运行的镜像的时候， 需要指定一些参数， 例如：容器名称、 映射的卷、 绑定的端口、 网络以及重启策略等等， 一个典型的 `docker run` 命令如下所示：

```sh
docker run \
  --detach \
  --name registry \
  --hostname registry \
  --volume $(pwd)/app/registry:/var/lib/registry \
  --publish 5000:5000 \
  --restart unless-stopped \
  registry:latest
```

为了保存这些参数， 可以将这个 `run` 命令保存成 shell 文件， 需要时可以重新运行 shell 文件。 对于只有单个镜像的简单应用， 基本上可以满足需要了。 只要保存对应的 shell 文件， 备份好卷的内容， 当容器出现问题或者需要迁移活着需要重新部署时， 使用 shell 文件就可以快速完成。

不过不是所有的应用都倾向于做成单个镜像， 这样的镜像会非常复杂， 而且不符合 docker 的思想。 因为 docker 更倾向于简单镜像， 即： 一个镜像只有一个进程。 一个典型的 web 应用， 至少需要一个 web 服务器来运行服务端程序， 同时还需要一个数据库服务器来完成数据的存储， 这就需要两个镜像， 一个是 web ， 一个是 db ， 如果还是按照上面的做法， 需要两个 shell 文件， 或者是在一个 shell 文件中有两个 `docker run` 命令：

```sh
# PostGIS DB
docker run \
  --datach \
  --publish 5432:5432 \
  --name postgis \
  --restart unless-stopped \
  --volume $(pwd)/db/data:/var/lib/postgresql/data \
  beginor/postgis:9.3

# GeoServer Web
docker run \
  --detach \
  --publish 8080:8080 \
  --name geoserver \
  --restart unless-stopped \
  --volume $(pwd)/geoserver/data_dir:/geoserver/data_dir \
  --volume $(pwd)/geoserver/logs:/geoserver/logs \
  --hostname geoserver \
  --link postgis:postgis \
  beginor/geoserver:2.11.0
```

在上面的例子中， web 服务器使用的是 geoserver ， db 服务器使用的是 postgis ， web 服务器依赖 db 服务器， 必须先启动 db 服务器， 再启动 web 服务器， 这就需要编写复杂的 shell 脚本， 需要的镜像越多， 脚本越复杂， 这个问题被称作 docker 的编排。

> 关于 docker run 的各个参数的使用方法， 请参阅 docker 网站的[说明文档](https://docs.docker.com/edge/engine/reference/commandline/run/)。

## 使用 docker-compose 编排镜像

docker 提供了一个命令行工具 `docker-compose` 帮助完成镜像的编排， 要使用 `docker-compose` ， 需要先编写一个 `docker-compose.yml` 文件， `yaml` 是一种常用配置文件格式， 维基百科中对 `yaml` 描述如下：

> YAML 是一个可读性高，用来表达数据序列的格式。YAML参考了其他多种语言，包括：C语言、Python、Perl，并从XML、电子邮件的数据格式（RFC 2822）中获得灵感。

如果想了解详细信息， 请[参考 YAML 官方网站](http://yaml.org/)或者[维基百科](https://zh.wikipedia.org/wiki/YAML)。

docker 网站上提供了 docker-compose 的[入门教程](https://docs.docker.com/compose/gettingstarted/)， 如果不熟悉的话可以去学习一下。

上面的脚本转换成对应的 docker-compose.yml 文件如下所示：

```yml
version: "3"
services:
  web:
    image: beginor/geoserver:2.11.1
    container_name: geoserver-web
    hostname: geoserver-web
    ports:
      - 8080:8080
    volumes:
      - ./web/data_dir:/geoserver/data_dir
      - ./web/logs:/geoserver/logs
    restart: unless-stopped
    links:
      - database:database
  database:
    image: beginor/postgis:9.3
    container_name: postgis
    hostname: postgis
    ports:
      - 5432:5432
    volumes:
      - ./database/data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: 1q2w3e4R
    restart: unless-stopped
```

 上面的 `docker-compose.yml` 文件定义了两个服务 web 和 database， 一个服务在运行时对应一个容器的实例， 上面的文件表示要启动两个实例。

在部署时， 通常将 `docker-compose.yml` 文件放到一个目录， 表示一个应用， docker 会为这个应用创建一个独立的网络， 便于和其它应用进行隔离。

要运行这个程序， 只要在这个目录下执行 `docker-compose up -d` 命令， 就会按照上面的配置启动两个容器的实例:

```sh
$ docker-compose up -d
Creating network "geoserver_default" with the default driver
Creating geoserver_database_1
Creating geoserver_web_1
```

要停止上面的容器， 只需要输入 `docker-compose down` 命令：

```sh
$ docker-compose down
Stopping geoserver_web_1 ... done
Stopping geoserver_database_1 ... done
Removing geoserver_web_1 ... done
Removing geoserver_database_1 ... done
Removing network geoserver_default
```

从上面的命令可以看出， docker-compose 不仅可以根据配置文件 `docker-compose.yml` 自动创建网络， 启动响应的容器实例， 也可以根据配置文件删除停止和删除容器实例， 并删除对应的网络， 确实是 `docker run` 命令更加方便， 因此推荐在测试环境或者生产环境中使用。
