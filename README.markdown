---
title:  "博文 Markdown 格式说明"
date:   2019-01-16 10:42:06 +0800
author: Bill Kevin
mathjax: true
categories: Blog
img: /images/demo0.jpg
tags:
  - Markdown
---

> 更新博文直接在本 `repo` 中更新就好了, 在 `DCMMC.github.io` 的 submodule `/source/_posts` 中更新的话,
> 要先 git pull origin master 同步一下, 然后再更新, 如果遇到被拒绝的情况, 那就先 `git checkout` 到一个合法
> 的版本的 `hashCode` 去

# Notes 格式说明

记得在每一个Markdown文件开头添加一下模板：

```
---
title:  "博文标题"
date:   2019-01-16 10:42:06 +0800 # 时间
author: Bill Kevin # 作者
mathjax: true # 是否开启 mathjax
categories: Test # 分类
# 现在封面图片可以放在本 `repo` 的 `assets` 中辣
img: /images/demo0.jpg # 封面图片(暂时在 /images 是在 /source/_posts/images 中)
tags: # 标签(多个)
  - Markdown
---
```
