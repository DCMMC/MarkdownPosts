---
layout: post        # 指定模板
title:  "jekyll安装笔记(Cent OS 6.8)"
date:   2017-09-01 12:37:06 +0800
categories: DCMMC   # 分类，首页显示,该项经常用于检测是否为post。请注意，每个文章仅支持一个分类。
image:              # 图像，用于首页，若留空将以NoImage的形式显示, 暂不支持跨域图像。
tags:  CentOS jekyll 安装笔记   # 标签，用于tags页面，允许多个
toc: true           # 确定是否显示toc目录，默认为不显示。
comments: true      # 是否显示评论
author:             # 若指定作者名，请开启多作者功能，否则将以默认作者显示。
---

# CentOS 6.8 jekyll install note

> Current user: `root`

## Ruby安装

1. 删除旧版本

```
runuser -l www -s /bin/bash -c "yum remove ruby ruby-devel -y"
```

2. 下载源码安装

```
runuser -l www -s /bin/bash -c "cd /tmp && wget wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
runuser -l www -s /bin/bash -c "cd /tmp && tar zxvf ruby-2.3.1.tar.gz"
cd /tmp/ruby-2.3.1
runuser -l www -s /bin/bash -c "cd /tmp/ruby-2.3.1 && ./configure --prefix=/usr/local/ruby --with-opessl-dir=/root/soft/openssl-1.0.0l"
runuser -l www -s /bin/bash -c "cd /tmp/ruby-2.3.1 && sudo make && sudo make install"
```

## add `www` to `root` group

```
usermod -a -G root www
```

## add `www`'s `~/.bash_profile`

```
runuser -l www -s /bin/bash -c "vim ~/.bash_profile"
```

add:

```
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=/usr/local/ruby/bin:$PATH:$HOME/bin

export PATH
export

Source:

> Current user: `root`

```
chmod -R 775 /usr/local/ruby/
runuser -l www -s /bin/bash -c "source ~/.bash_profile"
```


## RubyGems安装

```
gem update --system
```

## jekyll安装

```
runuser -l www -s /bin/bash -c "gem install jekyll bundler"
```
If could not find in any of the sources when running jekyll, try `bundle exec jekyll`.

## MarkdownPostsUpdateHook.sh

```
#!/bin/sh

# Jekyll update hook

#GIT_REPO=https://github.com/DCMMC/DCMMC.github.io
GIT_REPO=https://github.com/DCMMC/Notes
TMP_GIT_CLONE=/tmp/blog/
SOURCE=/home/wwwroot/DCMMC.github.io
#user: Root!
PUBLIC_WWW=/home/wwwroot/blog/

git clone $GIT_REPO $TMP_GIT_CLONE

#debug
#whoami

#Clean old post
echo "clean1"
rm -Rf $SOURCE/_posts/*

# move
echo "move"
mv $TMP_GIT_CLONE/* $SOURCE/_posts/

#Clean
echo "clean2"
echo "Clean old htmls"
rm -Rf $PUBLIC_WWW*

echo "build"
/usr/local/ruby/bin/jekyll build --source $SOURCE --destination $PUBLIC_WWW --incremental

#Clean
echo "clean3"

rm -Rf $TMP_GIT_CLONE
exit
```

> `blog` and `DCMMC.github.io/_post` mush set 775
