## Dockerfile 的 ENTRYPOINT 与 CMD

Dockerfile 有两个启动配置， `CMD` 和 `ENTRYPOINT` ， 可以在 Dockerfile 中来配置容器启动时自动执行的命令， 但是这二者有什么区别呢， 接下来总结如下：

首先来看一下 `CMD` ， 有三种格式的配置， 分别是：

- `CMD ["executable","param1","param2"]` (exec 格式, 推荐的格式)
- `CMD ["param1","param2"]` (作为 ENTRYPOINT 的默认参数)
- `CMD command param1 param2` (shell 格式)

在使用时， 要注意一下问题：

1. 包含可执行文件时， 为容器指定默认执行命令， 这个是主要用途；
2. 不包含可执行文件时， 必须提供 `ENTRYPOINT` 配置， `CMD` 作为默认参数；
3. Dockerfile 中只能有一个 `CMD` 起效， 如果出现了多个， 则最后一个起效；

而 `ENTRYPOINT` ， 有两种格式的配置， 分别是：

- ENTRYPOINT ["executable", "param1", "param2"] (exec 格式, 推荐)
- ENTRYPOINT command param1 param2 (shell 格式)

`CMD` 和 `ENTRYPOINT` 两种配置格式的区别是：

- `exec 格式` 推荐这种格式， 使用这种模式时， 可以不需要 shell 进程， 让 Docker 应用的可执行程序成为容器的 `PID 1` 进程， 可以接收 Unix 信号， 比如执行 `docker stop <container>` 时能够接收到 `SIGTERM`。
- `shell 格式` 会始终调用一个 shell 进程， 成为 `/bin/sh -c` 的子命令， 可执行程序不能响应 Unix 信号。

> 注意： `ENTRYPOINT` 使用 `shell 格式` 时， 会忽略 `CMD` 和 `run` 传入的参数， 如果要替换默认的 `ENTRYPOINT` 命令， 则需要在执行 docker run 的时候指定 `--entrypoint` 参数。

当 `CMD` 和 `ENTRYPOINT` 的使用总结如下：

- 在 Dockerfile 中， 应该至少指定一个 `CMD` 和 `ENTRYPOINT`；
- 将 Docker 当作可执行程序时， 应该使用 `ENTRYPOINT` 进行配置；
- `CMD` 可以用作 `ENTRYPOINT` 默认参数， 或者用作 Docker 的默认命令；
- `CMD` 可以被 docker run 传入的参数覆盖；
- docker run 传入的参数会附加到 `ENTRYPOINT` 之后， 前提是使用了 `exec 格式` 。

