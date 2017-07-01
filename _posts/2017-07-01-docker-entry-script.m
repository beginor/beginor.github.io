---
layout: post2
title: Docker Entry Script 详解
description: 详细介绍 Docker Entry Script 的编写， 让应用正确的启动和关闭
keywords: docker, entry script, trap, sigterm, sigint, shutdown app
tags: [Docker, Linux]
---

Dockerfile 的 `ENTRYPOINT` 通常是一个脚本文件， 用来启动和关闭 Docker 中的应用。 接下来就以 Linux 下常用的 Jexus 服务器为例， 来说明如何正确的启动和关闭 Docker 应用。

## Docker 应用启动

根据 Jexus 的文档， Jexus 服务器启动只需要使用命令 `/usr/jexus/jws start` 即可， 所以启动非常简单， 只要定义一个函数来调用 `/usr/jexus/jws start` 即可：

```sh
# a function to start jexus server
function start_jws {
  /usr/jexus/jws start
}
```

调用完 `jws start` 之后， 用 `ps a` 命令查看， 可以看到如下进程：

```
# ps
  PID TTY          TIME CMD
    1 pts/0    00:00:00 bash
   36 pts/0    00:00:00 JwsMain
   43 pts/0    00:00:00 jwss
   95 pts/0    00:00:00 ps
```

只要有 `JwsMain` 和 `jwss` 两个进程在运行， 则表示 Jexus 服务器正在运行。

## 等待应用关闭

由于 Docker 是单进程的， 如果 Jexus 服务关闭了， Docker 进程也应该退出， 所以需要一个函数来判断 Jexus 服务器的运行。

`JwsMain` 和 `jwss` 两个命令位于 `/usr/jexus` 目录下， 只要这两个进程在运行， 就表示 Jexus 还在运行。 如果没有了这两个进程， 则表示 Jexus 已经退出。 所以判断 Jexus 运行的标志就是位于 `/usr/jexus` 目录下的进程是否存在， 这个可以使用 `pgrep` 来判断：

```
# pgrep -f "/usr/jexus"
36
43
```

接下来编写一个 `wait_for_exit` 函数， 每隔一秒钟检查一下是否有位于 `/usr/jexus` 目录下的进程存在， 如果没有， 则退出， 代码如下：

```sh
# a function that spins, stopping every 1s to check if any jexus
# processes are running. the loop terminates when no running jexus 
# processesa are found.
function wait_for_exit {
  while pgrep -f "/usr/jexus" > /dev/null; do
    /bin/sleep 1
  done
  echo "All jexus process have stopped."
}
```

## 处理应用关闭

Jexus 的关闭也很容易， 只要调用 `/usr/jexus/jws stop` ， 如下所示：

```sh
# a function to stop jexus server
function stop_jws {
  /usr/jexus/jws stop
}
```

关键是如何做到让 Docker 停止时自动调用这个 `stop_jws` 函数。 因此需要向主进程发送一个信号通知， 当主进程停止时， 调用 `stop_jws` 函数。

先定义一个 `signal_trap` 函数， 调用 `stop_jws` 函数来关闭 Jexus 服务器：

```sh
# a function that is called whenever a signal is caught requesting that
# the process be terminated. in most cases, this will come from Docker
# as this script will be running as PID 1.
function signal_trap {
  echo "A SIGTERM or SIGINT signal was caught; trying to shut down."
  stop_jws
}
```

向主进程发送一个信号通知， 让主进程知道终止时需要调用 `signal_trap` 函数来关闭 Jexus 服务器。

```sh
# trap termination signals and stop the server processes. this is
# necessary because Docker will send SIGTERM to the container's
# PID 1 when it tries to stop the container. since Bash doesn't
# pass this along, we have to handle it ourselves.
trap signal_trap SIGTERM SIGINT
```

调用 `start_jws` 启动 Jexus 服务器之后， 立即调用 `wait_for_exit` 等待：

```sh
# begin the server startup process.
start_jws
echo "Listening for termination signals..."
# loop until all jexus processes are finished.
wait_for_exit
```

上面写的比较零散， 点击这里查看最终的 
[bootstrap.sh](https://github.com/beginor/docker-jexus-x64/blob/master/bootstrap.sh) 文件， 也可以轻松的修改成其它应用的启动脚本。

> PS: 也可以直接下载我的 [beginor/jexus-x64](https://hub.docker.com/r/beginor/jexus-x64/tags/) 镜像来使用。
