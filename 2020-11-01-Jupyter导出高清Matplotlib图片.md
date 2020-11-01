---
title:  "Jupyter 导出高清 Matplotlib 图片"
date:   2020-11-01 15:00
author: Bill Kevin
mathjax: false
categories: 杂谈
img: /images/demo0.jpg
tags:
  - Jupyter
  - Matplotlib
---

## Jupyter 导出高清 Matplotlib 图片

Jupyter notebook 中如果使用 `%matplotlib inline` 来显示 Matplotlib 输出的话，效果很差很模糊。

如果用 `%matplotlib notebook` 的方式的话，Matplotlib 输出会以 Widget 的形式呈现，效果会好很多。

不过问题是当我们导出到 PDF 或 html 时，这些 Widget 竟然没有了，查阅了大量 Issue 后发现要保存 Widget state 或者关闭所有 widget 才行，总之一顿操作后，依然没成功...

最后终于在一个博客[1] 中找到了一个靠谱的答案：

```python
import matplotlib as mpl
%matplotlib inline

mpl.rcParams['figure.dpi'] = 300
from IPython.display import set_matplotlib_formats
set_matplotlib_formats('png', 'pdf')
```

原理很简单，就是告诉 Jupyter 同时保存 png 和 pdf 格式的 Matplotlib 输出。

这样在 Jupyter notebook 中就用 png 格式的内容显示，然后导出到 PDF (by LaTeX) 的时候就直接用矢量图的 pdf 图。

同时，inline 模式下，Matplotlib 输出的 png 图像实在时模糊，所以我们需要简单修改下  dpi 为 300，不过这样保存到文件的时候会占用更加大的空间（都 2020 年了，也不用在乎这点空间吧）。



最后，Jupyter notebook 通过 LaTeX 导出到 PDF 需要 Pandoc 和 TeX (推荐 MikTeX) 依赖。

不过在带有中文的 Jupyter notebook 导出成 PDF 时，中文字符都会出问题，这是因为 Jupyter notebook 的 LaTeX 模板默认不支持中文。

所以我们只需要简单的修改下模板文件 `../nbconvert/templates/latex/base.tex.j2` (不同 Jupyter 版本可能在不同文件哦），加入 `ctex` 包 （`\usepackage{ctex}`) 就好啦。



> 啊，就这样水了一篇博客~

## References

* [1] [Robin's Blog](http://blog.rtwilson.com/how-to-get-nice-vector-graphics-in-your-exported-pdf-ipython-notebooks/)

