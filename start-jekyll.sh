#!/bin/bash -e

# 1. 构建 Tailwind CSS
pnpm build:css

# 2. 启动 Jekyll 服务
# 如果需要预览草稿，添加 --drafts 参数
docker run -it --rm \
  -v $(pwd):/site \
  -p 4000:4000 \
  beginor/gh-pages
