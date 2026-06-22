---
layout: post2
title: 编译 llama.cpp 以支持张量并行 (tensor split) 并测试多卡性能
description: 介绍如何编译 llama.cpp 以启用试验性的张量并行支持，包括安装 NCCL 库、CMake 构建配置，以及在 8×H20 NVLink 服务器上的多卡推理性能对比。
keywords: llama.cpp, 张量并行, NCCL
tags: [参考, AI]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

最近翻阅 llama.cpp server 文档时，发现它开始试验性支持张量并行，即 `--split-mode tensor`。刚好手头有一台搭载 8 张 H20 + NVLink 的算力服务器，于是决定测试一下开启张量并行后，llama.cpp 在多卡场景下能否有质的提升。

> 多卡并行一直是 vllm 的优势，llama.cpp 根本上不了桌，不在一个层次上。

## llama.cpp 关于张量并行的资料

关于张量并行的资料确实很少，估计有机会用的人就更少了——毕竟一般的游戏显卡（4090/5090）甚至 RTX6000 Pro 都不支持 NVLink。

### Server 文档中稍微提了一下

llama.cpp 对张量并行的支持确实是 **试验性** 的。只有在 server 目录的 [README.md](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) 中通过 `--split-mode` 一带而过，没有更详细的说明：

`-sm, --split-mode` `{none,layer,row,tensor}`

how to split the model across multiple GPUs, one of:

- none: use one GPU only
- layer (default): split layers and KV across GPUs (pipelined)
- row: split weight across GPUs by rows (parallelized)
- tensor: split weights and KV across GPUs (parallelized, EXPERIMENTAL)

(env: LLAMA_ARG_SPLIT_MODE)

> 在 server 目录的 [README.md](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) 中搜索 `split-mode` 只能找到这么多。

### 编译指南中完全没有提

在 llama.cpp 的 CUDA [编译指南](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#cuda) 中，也只有如何启用 CUDA 加速的说明，同样没有提及张量并行。

### 多 GPU 运行文档中有较简单的介绍

在 llama.cpp 的 [多 GPU 运行文档](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md) 中，有关于张量并行的简要介绍，有这些就足够了。详细内容可以参考下面两个链接：

- [4. Tensor parallelism (experimental)](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md#4-tensor-parallelism-experimental)
- [5. With NCCL](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md#5-with-nccl)

## 重新编译 llama.cpp 以支持张量并行

根据文档，编译时需要指定 `-DGGML_CUDA_NCCL=ON` 参数。但依赖的 **NCCL 库**（NVIDIA Collective Communications Library）并非默认安装，需要手工安装 `libnccl2` 和 `libnccl-dev` 包。

### 安装 libnccl2 和 libnccl-dev

安装 `libnccl2` 和 `libnccl-dev` 时要注意，这两个库与系统中安装的 CUDA 版本有较强的依赖关系，因此尽量安装与 CUDA 相匹配的版本。

比如系统中安装的是 CUDA 13.1，就需要在安装时指定 `libnccl2` 和 `libnccl-dev` 的版本，否则很容易编译失败。

先使用 `nvcc --version` 查看 CUDA 版本：

```txt
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Tue_Dec_16_07:23:41_PM_PST_2025
Cuda compilation tools, release 13.1, V13.1.115
Build cuda_13.1.r13.1/compiler.37061995_0
```

确认 CUDA 版本为 13.1 后，安装对应版本的 `libnccl2` 和 `libnccl-dev`：

```sh
sudo apt install libnccl-dev=2.29.3-1+cuda13.1 libnccl2=2.29.3-1+cuda13.1
```

> 这两个库不一定要装最新版本，关键是与系统 CUDA 版本匹配。

在确定 CUDA 版本后，可以用以下命令查询可用的 NCCL 版本：

```sh
apt info libnccl2 -a | grep 13.1
```

输出如下：

```txt
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Version: 2.29.3-1+cuda13.1
Version: 2.29.2-1+cuda13.1
```

### 重新编译 llama.cpp

这一步就比较简单了。按照官方编译指南，拉取源码编译即可，脚本如下：

```bash
#!/bin/bash

cd llama.cpp
git pull
rm -rf build

export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

cmake -B build -DGGML_CUDA=ON -DGGML_CUDA_NCCL=ON
cmake --build build --config Release -j
```

## 开启张量并行

编译完成后，在启动 `llama-server` 时添加 `--split-mode tensor` 参数即可开启张量并行。以 Qwen3.6 27B 为例，示例启动脚本如下：

```sh
# tensor split 需要多张显卡，否则没有意义
export CUDA_VISIBLE_DEVICES=0,1

llama-server \
  --model ./qwen3.6-27b-mtp-gguf/qwen3.6-27b-ud-q6_k_xl.gguf \
  --mmproj ./qwen3.6-27b-mtp-gguf/qwen3.6-27b-mmproj-f16.gguf \
  --flash-attn on \
  --n-gpu-layers 999 --fit off \
  --split-mode tensor --tensor-split 1,1
```

在单用户场景下，确实可以做到类似 vllm 那样——随着显卡数量增加，吐字速度也相应提升。实测数据如下：

- 1 张 H20: ~60 token/s
- 2 张 H20: ~90 token/s
- 4 张 H20: ~120 token/s
- 8 张 H20: 没有机会测试

但在多用户同时请求时（例如同时处理两个请求），4 张 H20 似乎会相互争抢资源，每个请求只有 30～40 token/s 的输出。

看来目前 llama.cpp 确实是试验性地支持张量并行。不过至少单用户场景下速度提升明显，基本和 vllm 处于同一级别了。期待 llama.cpp 也能像 vllm 那样完美地支持张量并行。
