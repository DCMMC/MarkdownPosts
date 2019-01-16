---
title:  "博文 Markdown 格式说明"
date:   2019-01-16 10:42:06 +0800
author: Bill Kevin 
mathjax: true 
categories: Test
img: /images/demo0.jpg
tags:
  - Markdown
---

# Notes 格式说明

记得在每一个Markdown文件开头添加一下模板：

```
---
layout: post        # 指定模板
title:  "Test by DCMMC"
date:   2017-08-31 10:42:06 +0800
categories: DCMMC   # 分类，首页显示,该项经常用于检测是否为post。请注意，每个文章仅支持一个分类。
image:              # 图像，用于首页，若留空将以NoImage的形式显示, 暂不支持跨域图像。
tags: DCMMC Test    # 标签，用于tags页面，允许多个
toc: true           # 确定是否显示toc目录，默认为不显示。
comments: true      # 是否显示评论
author:             # 若指定作者名，请开启多作者功能，否则将以默认作者显示。
---
```
