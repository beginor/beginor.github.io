---
layout: post
title: 使用 C 创建 Windows 服务
description: 使用 C 创建 Windows 服务
tags: [参考, C]
keywords: C, Windows Service
---

最近需要将一些命令行程序包装成后台服务， 本来可以用 .NET 完成， 不过又想尝试一下用 C 语言实
现 Windows 服务， 发现用 C 语言做 Windows 服务也是很容易的， 步骤如下：

1 包含必要的头文件， 并定义一些常量， 代码如下：

```c
#include <windows.h>
#include <stdio.h>

// 服务线程暂停时间；
#define SLEEP_TIME 5000
// 日志文件输入路径
#define LOGFILE "C:\\memstatus.txt"
```

2 写日志文件， 几乎所有的服务都有日志输出， 即使是最简单的服务， 可以说： “无日志不服务！“ 
作为一个简单的例子， 仅仅简单的向日志文件输出字符串。

```c
int WriteToLog(char* str) {
    FILE* log;
    log = fopen(LOGFILE, "a+");
    if (log == NULL)
        return -1;
    fprintf(log, "%s\n", str);
    fclose(log);
    return 0;
}
```

3 全局服务状态和服务控制处理变量， 这写变量会在多个函数中用到， 所以定义成全局变量。

```c
// 当前服务状态
SERVICE_STATUS ServiceStatus;
// 服务控制处理函数
SERVICE_STATUS_HANDLE ServiceStatusHandle;
```

4 初始化服务， 作为示例， 仅简单向输出日志。

```c
int InitService() {
    int result;
    result = WriteToLog("Monitoring started.");
    return(result);
}
```

5 服务控制处理函数， 响应在服务管理器中对服务的操作（停止、重新启动）。

```c
void ServiceControlHandler(DWORD request) {
    switch (request) {
    case SERVICE_CONTROL_STOP:
    case SERVICE_CONTROL_SHUTDOWN:
        // 服务停止
        WriteToLog("Monitoring stopped.");
        ServiceStatus.dwWin32ExitCode = 0;
        ServiceStatus.dwCurrentState = SERVICE_STOPPED;
        break;
    default:
        break;
    }

    // 向服务管理器汇报服务状态
    SetServiceStatus(ServiceStatusHandle, &ServiceStatus);

    return;
}
```

6 服务入口函数， 运行在后台服务线程中， 服务的逻辑主要在这个函数中实现。

```c
void ServiceMain(int argc, char** argv) {
    // 初始化服务类型、 状态、 接受的控制方法以及期待的返回值
    ServiceStatus.dwServiceType = SERVICE_WIN32;
    ServiceStatus.dwCurrentState = SERVICE_START_PENDING;
    ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
    ServiceStatus.dwWin32ExitCode = 0;
    ServiceStatus.dwServiceSpecificExitCode = 0;
    ServiceStatus.dwCheckPoint = 0;
    ServiceStatus.dwWaitHint = 0;

    // 注册服务控制处理函数
    ServiceStatusHandle = RegisterServiceCtrlHandler(
        L"MemoryStatus", // 服务名称必须与安装服务时的名称一致；
        (LPHANDLER_FUNCTION)ServiceControlHandler
        );
    if (ServiceStatusHandle == NULL) {
        // 服务注册失败
        return;
    }
    // 初始化服务
    int error = InitService();
    if (error) {
        // 初始化服务失败， 设置服务状态为 STOPPED 并返回
        ServiceStatus.dwCurrentState = SERVICE_STOPPED;
        ServiceStatus.dwWin32ExitCode = -1;
        SetServiceStatus(ServiceStatusHandle, &ServiceStatus);
        return;
    }
    // 现在服务已经成功运行起来了， 向服务管理器汇报状态。
    ServiceStatus.dwCurrentState = SERVICE_RUNNING;
    SetServiceStatus(ServiceStatusHandle, &ServiceStatus);

    MEMORYSTATUS memory;
    // 服务线程主循环， 每隔 5 秒钟读取系统内存状态， 输出到日志文件
    while (ServiceStatus.dwCurrentState == SERVICE_RUNNING) {
        char buffer[16];
        GlobalMemoryStatus(&memory);
        sprintf(buffer, "%d", memory.dwAvailPhys);
        int result = WriteToLog(buffer);
        if (result) {
            ServiceStatus.dwCurrentState = SERVICE_STOPPED;
            ServiceStatus.dwWin32ExitCode = -1;
            SetServiceStatus(ServiceStatusHandle, &ServiceStatus);
            return;
        }

        Sleep(SLEEP_TIME);
    }
    return;
}
```

7 最后， 程序入口函数， 只是简单的注册服务入口函数， 然后就退出了。 因为已经想系统注册了服务
入口函数， 系统会继续保留这个进程以运行服务线程， 服务进程不会退出。

```c
int main(int argc, char** argv) {
    SERVICE_TABLE_ENTRY entry;
    entry.lpServiceName = L"MemoryStatus";
    entry.lpServiceProc = (LPSERVICE_MAIN_FUNCTION)ServiceMain;

    // Start the control dispatcher thread for our service
    StartServiceCtrlDispatcher(&entry);
    return 0;
}
```

8 服务安装以及测试， 使用 `sc create` 命令可以安装服务：

```
REM 服务名称必须与代码中的服务名称保持一致
SC CREATE MemoryStatus binPath= %PROJECT_OUTPUT_DIR%\MemoryStatus.exe
```

<div class="alert alert-warning">
注意： 服务名称必须与代码中的服务名称保持一致， binPath= 之后必须保留一个空格！
</div>

服务的启动与关闭可以使用 `NET` 命令：

```
NET START MemoryStatus
```

过几秒钟之后在关闭服务：

```
NET STOP MemoryStatus
```

最后， 打开日志文件， 可以看到类似下面的输出：

```text
Monitoring started.
-1446236160
-1438883840
-1437360128
Monitoring stopped.
```

[点击查看完整的程序](https://gist.github.com/beginor/6f8a6f46489bfd8e6dce)