# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- **本地预览**: `./start-jekyll.sh` — 使用 Docker 启动 Jekyll 服务，访问 http://localhost:4000
- **创建新文章**: 复制 `_drafts/_template.md` 到 `_posts/`，按 `YYYY-MM-DD-slug.md` 命名
- **草稿预览**: 修改 `start-jekyll.sh` 取消 `--drafts` 注释
- **提交**: 使用简洁的祈使句或 `feat:` 前缀

## 项目结构

基于 Jekyll 的个人博客，托管于 GitHub Pages，使用 Tabler CSS 框架。

### 核心目录

- `_config.yml` — Jekyll 配置（标题、作者、Disqus、分页、Markdown 引擎）
- `_layouts/` — HTML 布局模板：
  - `default.html` — 主页/列表页布局（Tabler UI）
  - `post.html` — 旧版文章布局（Bootstrap + highlight.js）
  - `post2.html` — 新版文章布局（Tabler UI，新文章使用此布局）
- `_includes/` — Liquid 模板片段：header、footer、tags、recent-post、评论（comment/utteranc/gitment）、统计（gtag/flag-counter）
- `_posts/` — 205 篇 Markdown 文章，文件名格式 `YYYY-MM-DD-slug.md`
- `_drafts/` — 草稿文章，含 `_template.md` 模板
- `assets/` — 静态资源（Tabler、Bootstrap、Font Awesome、highlight.js、图片）

### 文章规范

每篇文章以 YAML front matter 开头：

```yaml
---
layout: post2          # 新文章使用 post2，旧文章使用 post
title: 文章标题
description: 文章描述（用于 SEO）
keywords: keyword1, keyword2
tags: [tag1, tag2]
typora-root-url: ../   # Typora 编辑器配置
typora-copy-images-to: ../assets/post-images
---
```

图片存入 `assets/post-images/`，正文使用相对路径引用。

### 技术栈

- **静态生成**: Jekyll + kramdown (GFM) + Rouge 代码高亮
- **CSS 框架**: Tabler (已从 Bootstrap 迁移)
- **评论系统**: Disqus（主配）+ utterances（备选）
- **统计**: Google Analytics (gtag) + flag-counter
- **本地开发**: Docker (`beginor/gh-pages` 镜像)
