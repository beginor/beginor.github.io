# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- **本地预览**: `./start-jekyll.sh` — 自动构建 Tailwind CSS 后启动 Docker Jekyll
- **单独构建 CSS**: `pnpm build:css`
- **watch CSS 开发**: `pnpm dev:css`（配合 Jekyll 在另一个终端同时运行）
- **创建新文章**: 复制 `_drafts/_template.md` 到 `_posts/`，按 `YYYY-MM-DD-slug.md` 命名
- **草稿预览**: 修改 `start-jekyll.sh` 取消 `--drafts` 注释
- **提交**: 使用简洁的祈使句或 `feat:` 前缀

## 项目结构

基于 Jekyll 的个人博客，托管于 GitHub Pages，使用 Tailwind CSS（逐步替换 Tabler）框架。

### 核心目录

- `_config.yml` — Jekyll 配置（标题、作者、Disqus、分页、Markdown 引擎）
- `_layouts/` — HTML 布局模板：
  - `default.html` — 主页/列表页布局（Tabler UI，待迁移 Tailwind）
  - `post.html` — 旧版文章布局（Bootstrap）
  - `post2.html` — 新版文章布局（Tabler UI，待迁移 Tailwind）
- `_includes/` — Liquid 模板片段：header、footer、tags、recent-post、评论（comment/utteranc/gitment）、统计（gtag/flag-counter）
- `_posts/` — 205 篇 Markdown 文章，文件名格式 `YYYY-MM-DD-slug.md`
- `_drafts/` — 草稿文章，含 `_template.md` 模板
- `assets/` — 静态资源（Tabler、Bootstrap、Font Awesome、highlight.js、图片）

### CSS 构建

- **入口**: `assets/styles/tailwind-input.css` — Tailwind CSS v4 配置，不含 base 层（避免覆盖 Tabler）
- **输出**: `assets/styles/tailwind.css`（gitignored，构建生成）
- **只引入 utilities 层**: Tailwind 的 utility class 与 Tabler 共存，可逐步迁移
- **Dark mode**: 通过 `@custom-variant dark` 映射 Tabler 的 `theme-dark` class
- **Typography**: `@tailwindcss/typography` 插件用于 Markdown 内容排版（`prose` class）

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
- **CSS 框架**: Tailwind CSS v4 + `tabler-shim.css`（极简兼容层，含 `.page`/`.icon` 等必需类）
- **设计系统**: Geist（Vercel 设计系统），定义在 `design.md`（浅色）和 `design.drak.md`（深色）
- **字体**: Inter（Geist Sans 的后备方案，自托管于 `assets/inter/`）
- **图标**: Tabler Icons（`ti ti-*`，字体文件约 11MB）
- **旧版**: `_layouts/post.html` 仍使用 Bootstrap + Font Awesome（兼容旧文章）
- **评论系统**: Disqus（主配）+ utterances（备选）
- **统计**: Google Analytics (gtag) + flag-counter
- **本地开发**: Docker (`beginor/gh-pages` 镜像)
- **CI/CD**: GitHub Actions (`pnpm build:css` → `jekyll build` → deploy to Pages)
