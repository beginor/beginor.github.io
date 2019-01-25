#!/bin/bash -e
# jekyll serve --drafts -w
docker run -it --rm -v $(pwd):/site -p 4000:4000 beginor/gh-pages
