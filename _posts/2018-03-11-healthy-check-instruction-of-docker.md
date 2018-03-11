---
layout: post2
title: Docker 容器的健康检查
description: Docker 容器的健康检查
keywords: docker, healthcheck, status
tags: [Docker]
---

## 健康检查 (`HEALTHCHECK`) 指令简介

健康检查 (`HEALTHCHECK`) 指令告诉 Docker 如何检查容器是否仍在工作。 它能够监测类似一个服务器虽然服务进程仍在运行， 但是陷入了死循环， 不能响应新的请求的情况。

当一个容器有指定健康检查 (`HEALTHCHECK`) 时， 它除了普通状态之外， 还有健康状态 (health status) 。 健康状态的初始状态是正在启动 (`starting`) ， 一旦通过了一个健康检查， 它将变成健康 (`healthy`) （不管之前的状态是什么）， 经过一定数量的连续失败之后， 它将变成不健康 (`unhealthy`) 。

健康检查 (`HEALTHCHECK`) 指令有两种形式：

- `HEALTHCHECK [OPTIONS] CMD command` 通过运行容器内的一个指令来检查容器的健康情况；
- `HEALTHCHECK NONE` 禁用任何（包括基层至父镜像）健康检查指令。

可以出现在 `CMD` 之前的选项有：

- `--interval=DURATION` 间隔时间， 默认 `30s` （30秒）;
- `--timeout=DURATION` 超时时间， 默认 `30s` （30秒）;
- `--start-period=DURATION` 启动时间， 默认 0s， 如果指定这个参数， 则必须大于 0s ；
- `--retries=N` 重试次数， 默认 3 ；

健康检查会在容器启动后的间隔时间内运行， 在上一次检查完成之后， 按照指定的间隔时间再次运行。

如果单次健康检查的时间超过了指定的超时时间， 则认为是失败的。

如果连续失败次数超过了指定的重试次数， 则容器的健康状态将被视为不健康 (unhealthy) 。

`start-period` 为需要启动的容器提供了初始化的时间段， 在这个时间段内如果检查失败， 则不会记录失败次数。 如果在启动时间内成功执行了健康检查， 则容器将被视为已经启动， 如果在启动时间内再次出现检查失败， 则会记录失败次数。

一个 Dockerfile 中只能有一个健康检查 (`HEALTHCHECK`) 指令生效， 如果出现了多个， 则只有最后一个有效。

在 `CMD` 关键字之后的 `command` 可以是一个 shell 命令（例如： `HEALTHCHECK CMD /bin/check-running`）或者一个 exec 数组（与其它 Dockerfile 命令相同， 参考 [ENTRYPOINT]）。

该命令的返回值说明了容器的状态， 可能是值为：

- 0: healthy - 容器健康， 可以使用；
- 1: unhealthy - 容器工作不正常， 需要诊断；
- 2: reserved - 保留， 不要使用这个返回值；

例如， 每隔 5 分钟检查一个网络服务器能够在 3 秒内响应主页的请求：

```
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

为了帮助调试失败信息， 任何向 stdout 或者 stderr 的文本输出会被记录下来（使用 UTF-8 编码）， 并保存在容器的健康状态中， 可以使用 `docker inspect` 命令查询。 健康健康检查的错误输出应该尽可能的简短， 目前只保存前面的 4k 字符。

当容器的健康状态发生变化时， 将会产生一个 `health_status` 事件， 这个时间将会携带新的状态。

健康检查 (`HEALTHCHECK`) 指令在 Docker 的 1.12 版本之后可用。

## 健康检查 (`HEALTHCHECK`) 指令使用示例

如果没有为容器指定健康检查 (`HEALTHCHECK`) 指令， 则使用 `docker ps` 时， 返回列表如下：

```
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                    NAMES
72d9db1c503d        beginor/jexus:5.8.3.0   "docker-entrypoint.s…"   9 days ago          Up 7 days           0.0.0.0:8088->80/tcp   jexus
```

在 status 那一列只能显示 `Up 7 days` ， 表示 7 天前启动， 不能显示容器的健康状况。

如果指定了容器指定健康检查 (`HEALTHCHECK`) 指令， 则输出为：

```
CONTAINER ID        IMAGE                           COMMAND             CREATED             STATUS                PORTS                                                 NAMES
10ec32c21b2e        beginor/jexus:5.8.3.1   "docker-entrypoint.s…"   2 weeks ago         Up 1 days (healthy)   0.0.0.0:8088->80/tcp   jexus
```

可以看到， 在 status 那一列显示为 `Up 1 days (healthy)` 。

由此可见， 健康检查 (`HEALTHCHECK`) 指令在容器的管理中是非常重要的， 因此需要为每一个容器添加这个指令。
