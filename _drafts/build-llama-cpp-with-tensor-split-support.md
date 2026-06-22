---
layout: post2
title: 编译
description: post description
keywords: keyword1, keyword2, keyword3
tags: [参考, AI]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

最近在查看 llama.cpp 的 server 的文档的时候发现开始试验性支持张量并行，即 `--split-mode tensor`， 刚好有一台算力服务器是8张 H20 + NVLink， 因此决定测试一下开启张量并行之后， llama.cpp 在多卡并行时会不会有质的提升。

> 多卡并行一直是 vllm 的优势， llama.cpp 根本上不了桌，不在一个层次上。

## llama.cpp 关于张量并行的资料

关于张量并行的资料确实很少，估计有机会用的人就更少了， 因为一般的游戏显卡 (4090/5090) 甚至 RTX6000 Pro 都不支持 NVLink。

### Server 文档中稍微提了一下

llama.cpp 对张量并行的支持确实是 **试验性** 的， 只有在 server 目录的 [README.md](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) 中在 `--split-mode` 提到了一下， 其它没有任何更详细的说明。

`-sm, --split-mode` `{none,layer,row,tensor}`

how to split the model across multiple GPUs, one of:

- none: use one GPU only
- layer (default): split layers and KV across GPUs (pipelined)
- row: split weight across GPUs by rows (parallelized)
- tensor: split weights and KV across GPUs (parallelized, EXPERIMENTAL)

(env: LLAMA_ARG_SPLIT_MODE)

> 在 在 server 目录的 [README.md](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) 中搜索 `split-mode` 只能找到这么多。

### 编译指南中完全没有提

同样在 llama.cpp 的 CUDA [编译指南](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#cuda) 中也只有如何启用 CUDA 加速的说明， 也没有关于张量并行的说明。

### 在多 GPU 运行的文档中有较简单介绍

在 llama.cpp 的 [多 GPU 运行文档](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md) 中有关于张量并行的简单介绍， 有这些就足够了。 详细内容可以参考下面这两个链接：

- [4. Tensor parallelism (experimental)](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md#4-tensor-parallelism-experimental)
- [5. With NCCL](https://github.com/ggml-org/llama.cpp/blob/master/docs/multi-gpu.md#5-with-nccl)

## 重新编译 llama.cpp 以支持张量并行

根据上面的文档， 需要在编译时指定 `-DGGML_CUDA_NCCL=ON` 参数， 但是依赖的 **NCCL 库** (NVIDIA Collective Communications Library) 却不是默认安装的，需要手工安装 `libnccl2` 和 `libnccl-dev` 包。

### 安装 libnccl2` 和 libnccl-dev

在安装 `libnccl2` 和 `libnccl-dev` 是要注意， 这两个库是和系统中安装的 CUDA 版本有比较强的依赖关系， 因此尽量安装和系统中的 CUDA 向匹配的版本。

比如系统中安装的 CUDA 是 13.1 ，就需要在安装时指定 `libnccl2` 和 `libnccl-dev` 的版本， 否则很容易编译失败：

先使用 `nvcc --version` 查看系统中 CUDA 的版本：

```txt
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Tue_Dec_16_07:23:41_PM_PST_2025
Cuda compilation tools, release 13.1, V13.1.115
Build cuda_13.1.r13.1/compiler.37061995_0
```

确认系统中的 CUDA 版本是 13.1 ，然后再安装对应版本的 `libnccl2` 和 `libnccl-dev` ：

```sh
sudo apt install libnccl-dev=2.29.3-1+cuda13.1 libnccl2=2.29.3-1+cuda13.1
```

> 这两个库不一定要安装最新版本，而是要安装和系统 CUDA 版本匹配的版本。

在知道了 CUDA 版本之后， 可以使用下面的命令来查询：

```sh
apt info libnccl2 -a | grep 13.1
```

然后看输出就知道要安装什么版本了

```txt
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Version: 2.29.3-1+cuda13.1
Version: 2.29.2-1+cuda13.1
```

## 重新编译 llama.cpp

这一步就很容易了， 根据官方的编译指南， 拉源代码编辑即可， 编译脚本如下：

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

编译好了之后， 在 `llama-server` 启动时添加 `--split-mode tensor` 参数，即可开启张量并行， 以 Qwen3.6 27B 为例， 示例启动脚本如下：

```sh
# tensor split 必须多个显卡，否则没有意义
export CUDA_VISIBLE_DEVICES=0,1

llama-server \
  --model ./qwen3.6-27b-mtp-gguf/qwen3.6-27b-ud-q6_k_xl.gguf \
  --mmproj ./qwen3.6-27b-mtp-gguf/qwen3.6-27b-mmproj-f16.gguf \
  --flash-attn on \
  --n-gpu-layers 999 --fit off \
  --split-mode tensor --tensor-split 1,1
```

在单用户使用的情况下，确实可以做到类似 vllm 那样， 随着显卡的增加， 吐字数度也响应增加， 比如 1 张 H20 显卡时 60token/秒， 2 张 H20 显卡时约 90token/秒， 4 张 H20 显卡时约 120token/秒， 8 张 H20 显卡， 没有机会测试了。

但是在多用户同时请求时，比如 2 个同时处理两个请求时， 4 张 H20 似乎会相互冲突， 每个请求只有 30～40 token/秒的输出。

看来目前 llama.cpp 确实是试验性的支持张量并行， 但是至少单用户速度上去了，基本上和 vllm 一个级别了，期待 llama.cpp 也可以像 vllm 那样完美的支持张量并行。
