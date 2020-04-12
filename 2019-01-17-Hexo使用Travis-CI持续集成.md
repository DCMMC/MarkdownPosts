---
title:  "Hexo 使用 Travis-CI 持续集成"
date:   2019-01-17 13:42
author: Bill Kevin
mathjax: false
categories: Blog
img: /images/demo0.jpg
tags:
  - Hexo
  - 持续集成
---

## 使用 `Travis` 自动部署 `Hexo` 到 `Github Page`

我的目标就是:

* 博文用 `Markdown` 语法存储在 `MarkdownPosts` 中 ( `master` 分支)
* `Hexo` 项目存储在 `DCMMC.github.io` 的 `develop` 分支中
* `MarkdownPosts` 在 `DCMMC.github.io` 中作为 `submodule` 存在于 `./source/_posts` 中
* 当 `MarkdownPosts` 更新时自动更新 `DCMMC.github.io` develop 分支中的 submodule
* 当 `DCMMC.github.io` develop 分支更新时自动使用 `hexo` 进行构建和发布到 `DCMMC.github.io` 的 `master` 分支中

### Sketch Steps

* 进入 [https://www.travis-ci.org](https://www.travis-ci.org) 使用 Github 登录, 并将 `MarkdownPosts` 和 `DCMMC.github.io` 绑定上
* 去 [Github Access Token](https://github.com/settings/tokens) 创建一个 `Token`, 权限只开 `repo` 有关的就行
* 将 `Token` 记录在 `Travis` 中的这两个 repo 里面作为环境变量(记得不能公开), 用于在 `git push` 的时候作为 `OAuth`
* 按照目标依次为两个 `repo` 创建 `.travis.yml` 文件(详细请见 `repo` 中有关文件)
* 测试并且调试一下就 **Bingo** 啦

## References

* [掘金博客](https://juejin.im/post/596e39916fb9a06baf2ed273)
