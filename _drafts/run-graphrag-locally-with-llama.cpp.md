---
layout: post2
title: 使用 llama.cpp 本地运行 GraphRAG
description: 本文介绍如何使用 llama.cpp 在本地运行微软开源的 GraphRAG
keywords: ai, llama.cpp, graphrag, llm
tags: [AI, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

## 环境准备

GraphRAG 需要的 Python 环境为 3.10 ， 如果本地没有 Python 3.10 的话， 需要先安装 Python 3.10 ， 以 Mac 为例， 用 homebrew 安装 Python 3.10:

```sh
brew install python@3.10
```

单独为 GraphRAG 创建一个 Python 虚拟环境， 因为它的依赖项很多：

```sh
# 使用 Python 内置的 venv 模块创建一个 .venv 虚拟环境
python3 -m venv .venv
# 激活虚拟环境
source .venv/bin/activate
```

## 选择运行方式

GraphRAG 是开源的，

### 下载源代码运行

```sh
git clone https://github.com/microsoft/graphrag.git
```

```sh
pip3 install poetry
poetry install
```

### 安装 pip 包运行

```sh
pip3 install graphrag
```

## 准备工作区

### 下载输入文件

