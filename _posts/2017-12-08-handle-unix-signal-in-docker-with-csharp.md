---
layout: post2
title: C# 程序在 Docker 中响应 Unix 信号
description: 介绍如何用 C# 在 Docker 应用中响应 Unix 信号
keywords: docker, c#, unix signal, sigint, sigterm
tags: [Docker, Xamarin, .NET]
---

在 [Docker Entry Script 详解](https://beginor.github.io/2017/07/01/docker-entry-script.html)中介绍了如何在 shell 脚本中响应 Unix 信号量来实现 Docker 应用优雅的关闭退出， 本文介绍 C# 程序如何在 Docker 中响应 Unix 信号实现优雅的关闭退出。

因为用 Mono 编译出来的程序可以完美的在 Linux/Docker 下运行， 所本文以 Mono 5.4 做为开发环境， 对应的 .Net Framework 版本为 4.6.1 。

假设现在需要运行一个定时任务的程序， 每隔一定时间输出一个 `hello, world!` ，我们使用 Quartz.Net 来完成这个任务， 代码如下所示：

首先来定义一个 `EchoJob` ， 向控制台输出 `hello, world!` ， 代码如下：

```c#
public class EchoJob : IJob {

    public void Execute(IJobExecutionContext context) {
        Console.WriteLine($"{DateTime.Now} Hello, world!");
    }

}
```

接下来使用 `Quartz` 来配置并启动这个任务， 代码如下：

```c#
private static void StartupQuartz() {
    Console.WriteLine("Start Quartz");
    var factory = new StdSchedulerFactory();
    scheduler = factory.GetScheduler();
    scheduler.Start();
    var job = JobBuilder.Create<EchoJob>()
        .WithIdentity("EchoJob", "EchoJob")
        .Build();
    var trigger = TriggerBuilder.Create()
        .WithIdentity("EchoJob-Trigger", "EchoJob")
        .WithSimpleSchedule(
            x => x.WithInterval(TimeSpan.FromSeconds(5))
                    .RepeatForever()
        )
        .StartNow()
        .Build();
    scheduler.ScheduleJob(job, trigger);
}
```

当按 Ctrl + C 结束程序或者使用 `docker stop` 命令停止容器时， 我们希望停止这个任务， 停止任务的代码如下：

```c#
private static void ShutdownQuartz() {
    Console.WriteLine("Shutdown Quartz");
    scheduler.Shutdown();
}
```

接下来， 问题就来了， 我们的程序如何响应这两个时间呢？ 在 Linux 下面， Mono 提供了 `Mono.Unix.UnixSignal` 来解决这中问题， 我们的程序需要监听两个 Unix 信号， 分别是：

- Mono.Unix.Native.Signum.SIGINT ， 按 Ctrl + C 结束程序时发送的信号量；
- Mono.Unix.Native.Signum.SIGTERM ， Docker 容器停止时发送的信号量；

根据 Mono 的文档， 监听 Unix 信号量的代码如下：

```c#
private static void WaitForExit() {
    var signals = new UnixSignal[] {
        new UnixSignal(Signum.SIGINT),
        new UnixSignal(Signum.SIGTERM)
    };
    var index = UnixSignal.WaitAny(signals);
    var signal = signals[index].Signum;
    Console.WriteLine($"Received Signal: {signal}");
}
```

现在， 我们的程序看起来是这样子的：

```c#
class MainClass {

    private static IScheduler scheduler = null;

    public static void Main(string[] args) {
        StartupQuartz();
        WaitForExit();
        ShutdownQuartz();
    }

    private static void StartupQuartz() { ... }

    private static void ShutdownQuartz() { ... }

    private static void WaitForExit() { ... }

}
```

程序在前台运行， 用 `Ctrl + C` 方式来结束程序时， 输出如下：

```
$ mono bin/QuartzDocker.exe
Start Quartz
12/8/2017 11:34:11 AM Hello, world!
12/8/2017 11:34:16 AM Hello, world!
^CReceived Signal: SIGINT
Shutdown Quartz
```

部署到 Docker 容器， 用 `docker stop` 停止容器时， 输出如下：

```
Sending build context to Docker daemon  4.311MB
Step 1/4 : FROM beginor/mono:5.4.1.6
 ---> 7c736fa9d337
Step 2/4 : COPY bin /app
 ---> 80ab98a23b28
Step 3/4 : WORKDIR /app
 ---> bde64015b8b0
Removing intermediate container 299227729a73
Step 4/4 : ENTRYPOINT mono QuartzDocker.exe
 ---> Running in 4c23abe8f903
 ---> b299267db381
Removing intermediate container 4c23abe8f903
Successfully built b299267db381
Successfully tagged quartz-test:latest
Start Quartz
12/08/2017 11:39:00 Hello, world!
12/08/2017 11:39:05 Hello, world!
12/08/2017 11:39:10 Hello, world!
12/08/2017 11:39:15 Hello, world!
12/08/2017 11:39:20 Hello, world!
12/08/2017 11:39:25 Hello, world!
12/08/2017 11:39:30 Hello, world!
Received Signal: SIGTERM
Shutdown Quartz
```

现在， 我们的目的终于达到了。

通常应用程序都会有自己的状态， 在程序结束时， 保存应用程序的状态是非常重要的， 因此应许能够感知结束， 并保存状态是非常重要的。

对于 Docker 来说， 发送 SIGTERM 之后， 默认最多只等待 10 秒钟， 如果 10 秒钟之后还没有退出， 就会被强制关闭。 如果需要修改这个等待时间的话， 则需要在 docker stop 命令添加 `--time` 选项， 设置等待时间， 比如：

```sh
docker stop --time 30 CONTAINER
```

> 如果你的开发环境是 Windows ， 只安装了 .Net Framework, 找不到 `Mono.Posix` 引用怎么办， 不要着急， 可以通过 Nuget 来添加 [Mono.Posix](https://www.nuget.org/packages/Mono.Posix/) 包来解决。
