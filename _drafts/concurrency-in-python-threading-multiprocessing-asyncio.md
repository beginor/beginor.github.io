---
layout: post2
title: Python 中的并发：多线程、多进程和Asyncio
description: 讨论 Python 中的多线程、多进程和Asyncio并发模型，提供了清晰的示例和详细说明，以帮助您了解何时以及如何有效地使用它们。
keywords: python, threading, multi processing, asyncio
tags: [Python, 教程]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## TL;DR

```python
if io_bound:
    if io_very_slow:
        print("Use Asyncio")
    else:
        print("Use Threads")
else:
    print("Multi Processing")
```

## 介绍

并发是编程中的一个基本概念，它允许应用程序同时执行多个任务。Python 提供了多种用于管理并发的工具：多线程、多进程和异步编程（Python 中的 asyncio 模块）。每个都有独特的优势，适合不同类型的任务。本文深入探讨了这些并发模型，提供了清晰的示例和详细说明，以帮助您了解何时以及如何有效地使用它们。

## 进程与线程

### 进程

进程是正在执行的程序的独立实例。每个进程都在自己的内存空间中运行，其自己的资源由作系统分配。进程不与其他进程共享内存，除非明确设计为通过进程间通信 （IPC） 共享内存。

### 线程

线程是进程中的最小执行单位。同一进程中的多个线程共享相同的内存空间，使它们能够比单独的进程更高效地进行通信。但是，此共享内存可能会导致同步问题。

### 示例：在 Python 中创建线程

```py
import threading
import time


def print_numbers():
    # This function will run in a separate thread
    for i in range(5):
        print(f"Thread: {i}")
        time.sleep(1)  # Simulate some work with sleep


# Create a new thread object to run print_numbers()
thread = threading.Thread(target=print_numbers)
# Start the thread
thread.start()
# Wait for the thread to finish before exiting the main program
thread.join()
print("Main thread: Execution finished")
```

解释：

- `threading.Thread(target=print_numbers)`: 创建将运行 `print_numbers()` 函数的线程；
- `thread.start()`：开始执行线程。
- `thread.join（）`：确保主线程等待新线程完成，然后再继续。

## 多线程与多进程

### 多线程

多线程允许多个线程在同一进程中并发运行。在 Python 中，多线程中的真正并行性受到全局解释器锁 （GIL） 的限制，该锁一次只允许一个线程执行 Python 字节码。但是，多线程处理对于 I/O 密集型任务仍然很有用，其中线程可以等待外部资源（如文件 I/O 或网络作），而其他线程可以继续执行。

### 示例：Python 中的多线程

```py
import threading
import time


def worker(name):
    print(f"Worker {name} starting")
    time.sleep(2)  # Simulating I/O-bound work
    print(f"Worker {name} finished")


threads = []


for i in range(5):
    t = threading.Thread(target=worker, args=(i,))
    threads.append(t)
    t.start()

for t in threads:
    t.join()  # Wait for all threads to complete
```

解释：

- 每个线程通过休眠 2 秒来模拟一些 I/O 绑定工作。
- `thread.join()` 确保主线程等待所有工作线程完成。

### 多进程

多进程涉及运行多个进程，每个进程都有自己的 Python 解释器和内存空间。这允许真正的并行性，使多进程成为 CPU 密集型任务的理想选择。

### 示例：Python 中的多进程

```py
import multiprocessing
import time


def worker(name):
    print(f"Worker {name} starting")
    time.sleep(2)  # Simulate some work
    print(f"Worker {name} finished")


if __name__ == '__main__':
    processes = []

    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(i,))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()  # Wait for all processes to finish
```

解释：

- 每个工作进程独立运行，从而实现跨 CPU 内核的真正并行性。
- 多进程避免了 GIL，使其适合 CPU 密集型任务。

## Asyncio

Asyncio 是一个 Python 库，用于使用 `async/await` 语法编写并发代码。它专为 I/O 密集型任务而设计，并使用事件循环来管理和计划任务。

### Asyncio 中的关键概念

1. `协程 (Coroutines)`: 使用 `async def` 定义的函数。这些是 asyncio 的构建块，表示可以暂停和恢复的任务;
2. `事件循环 (Event Loop)` ：asyncio 的核心，用于管理任务的执行;
3. `Tasks`：围绕在事件循环上调度的协程的包装器。
4. `await`：暂停协程的执行，将控制权交还给事件循环。

### 示例：Asyncio 基础

```py
import asyncio


async def task(name):
    print(f"Task {name} starting")
    await asyncio.sleep(2)  # Simulate an I/O-bound operation
    print(f"Task {name} finished")


async def main():
    await asyncio.gather(task("A"), task("B"), task("C"))


asyncio.run(main())
```

解释：

- `await asyncio.sleep(2)`: 暂停协程，允许事件循环运行其他任务;
- `asyncio.gather()`: 并发运行多个协程。

### 在 Asyncio 中处理 CPU 密集型的任务

Asyncio 不太适合 CPU 密集型任务，因为它们会阻塞事件循环。但是，您可以使用 `asyncio.to_thread()` 或 `asyncio.run_in_executor()` 将 CPU 密集型任务卸载到单独的线程或进程。

#### 示例：卸载 CPU 密集型任务

```py
import asyncio
import time


def cpu_bound_task(n):
    time.sleep(n)  # Simulating a CPU-bound task
    return n * n


async def main():
    result = await asyncio.to_thread(cpu_bound_task, 2)
    print(f"Result: {result}")


asyncio.run(main())
```

解释：

- `asyncio.to_thread()`: 将 CPU 绑定的任务卸载到单独的线程，从而允许事件循环保持响应。

### 常见的误解和错误

#### 混合同步和异步代码

不是需要所有内容都是异步的。可以使用 `asyncio.to_thread()` 或类似方法在异步代码中调用同步函数。

示例：

```py
import asyncio
import time


def sync_task():
    time.sleep(2)
    return "Completed"


async def main():
    result = await asyncio.to_thread(sync_task)
    print(result)


asyncio.run(main())
```

#### 直接等待 CPU 密集型任务

直接等待 CPU 绑定的任务可能会阻止事件循环，始终将此类任务卸载到单独的线程或进程。

`create_task()` 与 `await`

- `await coroutine`: 运行协程并等待其完成；
- `asyncio.create_task(coroutine)`： 安排协程与其他任务并发运行并立即返回。然后，您可以稍后等待该任务。

示例：

```py
import asyncio


async def my_coroutine():
    await asyncio.sleep(2)
    return "Done"


async def main():
    task = asyncio.create_task(my_coroutine())
    print("Doing something else while waiting...")
    result = await task
    print(f"Task result: {result}")


asyncio.run(main())
```

解释：

- `asyncio.create_task()`：当您想要启动协程并同时执行其他工作时，此功能非常有用。

## 何时使用哪种方法

1. 多线程：
   - 最适合 I/O 密集型任务，如网络作或文件 I/O；
   - 当您需要在线程之间共享状态时使用；
   - 由于 Python 中的 GIL，因此不适合 CPU 密集型任务。
2. 多进程：
   - 非常适合需要真正并行性的 CPU 密集型任务；
   - 当您需要绕过 GIL 时使用；
   - 最适合繁重的计算工作负载。
3. asyncio:
   - 非常适合具有许多并发作的 I/O 密集型任务。
   - 非常适合构建高性能网络服务器或具有大量 I/O 密集型任务的应用程序。
   - 不适合没有卸载的 CPU 密集型任务。

## 示例：FastAPI 中的异步编程

FastAPI 是一个现代 Web 框架，它利用 asyncio 来有效地处理并发请求。它使用 async/await 语法来管理 I/O 绑定作，而不会阻塞服务器。

### 为什么 FastAPI 使用 Async

1. 可扩展性 ：异步代码允许 FastAPI 以最小的开销处理许多并发连接;
2. 性能 ：对于 I/O 密集型任务，异步可以胜过传统线程;
3. 简单性：与线程代码相比，异步代码通常更易于编写和推理。

### 在 FastAPI 中卸载 CPU 密集型任务

FastAPI 可以通过将 CPU 密集型任务卸载到线程或进程池来处理这些任务。

```py
from fastapi import FastAPI
from concurrent.futures import ProcessPoolExecutor
import asyncio


app = FastAPI()
process_pool = ProcessPoolExecutor()


def cpu_bound_task(n):
    # Simulate a CPU-bound task
    total = 0
    for i in range(n):
        total += i * i
    return total


@app.get("/compute/{n}")
async def compute(n: int):
    # Offload the CPU-bound task to a separate process
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(process_pool, cpu_bound_task, n)
    return {"result": result}
```

解释：

- `ProcessPoolExecutor`: 创建一个 ProcessPoolExecutor 来将 CPU 绑定的任务卸载到单独的进程，这确保了主 FastAPI 事件循环保持响应，它的实现由 Uvicorn 内部处理;
- `loop.run_in_executor()`: 此方法将 `cpu_bound_task` 卸载给 `executor`（在本例中为 `ProcessPoolExecutor）`，允许 FastAPI 服务器在并行处理 CPU 密集型任务的同时处理其他请求;
- `await`: 通过使用 `await` 确保 FastAPI 处理程序在返回结果之前等待 CPU 绑定的任务完成。

## 为什么卸载很重要

在 Web 应用程序中，响应能力是关键。如果你直接在 FastAPI 事件循环中运行 CPU 密集型任务，它会阻止服务器处理其他请求，直到任务完成。通过卸载到单独的进程或线程，服务器可以继续并发处理传入请求，从而获得更好的可扩展性和用户体验。

## 结论

Python 中的并发是一个强大的工具，允许您编写高效且可扩展的应用程序。无论您是处理 I/O 密集型任务、CPU 密集型计算，还是两者兼而有之，Python 都提供了各种并发模型（多线程、多进程和 asyncio）来满足您的需求:

- `多线程`： 最适合共享内存有用的 I/O 密集型任务，但由于 GIL 的原因，它不适合 CPU 密集型任务;
- `多进程`：非常适合需要真正并行性的 CPU 密集型任务，避免了 GIL 的限制;
- `Asyncio`：非常适合涉及大量并发作的 I/O 绑定任务，提供非阻塞并发。

参考资料：

- [Concurrency in Python: Understanding Threading, Multiprocessing, and Asyncio](https://medium.com/@ark.iitkgp/concurrency-in-python-understanding-threading-multiprocessing-and-asyncio-03bd92ca298b)
- [stackoverflow](https://stackoverflow.com/a/52498068)
