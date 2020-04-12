---
title:  "BitCoding流量分类笔记"
date:   2019-10-05 21:00:00
author: Bill Kevin
mathjax: true
categories: 论文
tags:
  - 论文
  - 网络流量分类
---


## Traffic Classification

### BitCoding

Ref: [BitCoding: Network Traffic Classification
Through Encoded Bit Level Signatures](http://doi.org/10.1109/TNET.2018.2868816)

> CCF A，TON

#### Main Idea

DPI 依靠专家经验来使用 payload 部分的字节级签名（byte-level signatures）作为应用层的分类规则，
然而现在越来越多的应用开始使用二进制位级信息（bit-level information）来编码其应用协议。
作为 DPI 的改进，BitCoding 使用基于 DPI 的二进制位签名（bit-level DPI-based signature）来作为分类依据。
BitCoding 只取 payload 的前面一小部分比特位作为签名，并且将签名压缩编码并转换为受限的计数自动机。

> BitCoding 是 flow-based 的而不是 packet-based 的方法。

主要分为以下几个步骤：

* Bi-directional flow reconstruction

按照 `(SrcIP, DstIP, SrcPort, DstPort, Protocol)` 这个 5-tuple 和 TCP/UDP 的一些特征提取特定应用的数据流（traffic flow）用于训练和测试。

* Bit signature generation

> 公式跟原文表示有点出入

假定训练集中对某一个应用共有 $K$ 个 flow，每一个 flow 的前 $n$ (e.g. 20) bits 就表示其签名，所以签名集 $A\_{sig} = \\{ \\{f\_{i,j} | 1 \le j \le n \\} | 1 \le i \le K \\}$. e.g. $\\{11101, 11011, 11001\\}$ 就是 3 个 flow 的签名集合。

> Tips: 原来 mathjax 里面连续两个 `\\{` 要用空格隔开并且要两边斜杠来转义, 除了 `这种` 之外的地方星号都要转义, `_` 要一遍斜杠转义

应用的签名表示为 `s = [(1 if sum(A_sig[:, i] == K else 0 if sum(A_sig[:, i] == 0 else '*') for j in range(n)]` (类 Python 语法).

* Run-length Encoding

上述应用签名长度为 $n$ 位三进制，使用 RLE 这种 naive 的无损压缩方式，具体地说，$n$ 个连续的 $1, 0, \*$ 分别表示为 $nW, nZ, n\*$.

* State Transition Machine Creation

RLE 进一步转化为一个受限的有限计数自动机（Transition Constrained Counting Automata, abbr., TCCA)。

其实就是一种魔改版的 DFA。。或者说是一种 regexp 子集。

> `8W8Z3*3W` 其实就是 regexp `1{8,8}0{6,6}[01]{3,3}1{3,3}`

形式化表示为：$\mathcal{M} = (Q, \Sigma, C, \sigma, q_0, F),$ w.r.t. $Q$ is finite set of input symbols, $\Sigma$ is finite set of input symbols, $C$ is finite set of counters, $q\_0 \in Q$ is initial state, $F \subseteq Q$ is final state set, $\sigma$ is the set of transitions, 并且 $\sigma\_i \in \sigma, \sigma\_i = (q\_i, q\_j, c, \phi(c\_i), Inc(c\_j))$, w.r.t. $q\_i$ is current state, $q\_j$ is next state, $c\_i$ is current count, $\phi(c\_i)$ is the (invariant) constraint on counter value $c\_i$, $Inc(c\_j)$ is a function that assign the $c\_j$ to a new value.

> 形式化表示看起来复杂，结合原文的 Fig. 4 很好理解，并且原文 Fig. 4 有一些错误。

#### 解决签名重叠（冲突）

虽然很短的签名能够减少计算的 overhead，但是这会带来不用应用的签名相同的问题（类似哈希冲突）。
这可以通过增加 $n$ 的大小减少冲突（naive 的思路），原作者采用修改版的 Hamming Distance 来衡量两个签名之间的距离（Relaxed Hamming Distance)。

> Hamming Distance 计算相同长度的字符串中不同的位数，而 $\*$ 表示为 0 或 1，所以 Relaxed Hamming Distance 位于含有 $\*$ 的位不算作不同。

所以只需要对 Hamming distance 太小的应用的签名长度增加便可以提高分类精度。

#### Q&A

1. 包头这个方法考虑过吗：

> 原文只是利用 header 来讲应用的 traffic flow 提取出来，i.e. Bi-directional flow reconstruction 部分。而 TCCA 的创建不使用 header，而且其实 header （Ethernet/IP层) 部分大部分都是协议版本，Port，IP，MAC 之类的固定信息，这些信息在应用层要么都是一样的要么我们的论文预处理的时候会屏蔽掉它们。

2. K 越大，相同位置得到 $\*$ 的概率也有越大，导致 TCCA 自由一个节点，那么所有流都会走到终止状态？

> 作者采用 **Relaxed** Hamming Distance 并且增长签名长度来避免这种情况。

3. RHD 具体如何解决冲突问题？

> 前面有讲解。


### Feature Fusion

Ref: [Encrypted Traffic Classification of Decentralized Applications on Ethereum using Feature Fusion](https://doi.org/10.1145/3326285.3329053) (IWQoS, CCF B)

#### Main idea

对以太坊上的分布式应用的加密流量进行分类，本文主要是提出了一种新的急于 **特征融合的特征提取方法**，并且在一个自己收集的真实数据集（该数据集已开源）上实验。

因为以太坊中的分布式应用使用统一的区块链平台，所以其加密流量的 SSL/TLS 实现是一模一样的，之前使用实现上的差异作为特征的方法已经不适用。

> 参考 [1] 使用 TLS Handshake Metadata 作为特征，这些特征包括 client 支持的 cipher set （e.g. encryption algorithm and pseudorandom function）和 TLS extensions set。 不同平台（mobile or desktop）和不同实现 （e.g., chrome Boring SSL, firefox NSS，病毒使用的标准库 OpenSSL）的上述 SSL fingerprint 差异很大。

#### Dataset

Network flow 导出为 CSV 格式，每一行为 packet 的信息，包括：时间戳，src/dst IP, ports, protocols, 包长度和 TCP/IP flags.
总共 15 种分布式应用, 收集时间为 50 天, 总共 18242 条 flow (包含百万级数量的包).

> 本文定义 flow 为 (src/dst ip, src/dst ports) 相同的 packets.

#### 相关工作

* 基于 SSL/TLS 消息类型的 Markov Model.

使用 compact notation 来表示 SSL/TLS 会话的消息类型 (e.g., 22:2 represents `Server Hello` ), 一个状态可以是 SSL/TLS 消息类型, 或者同一个 TCP segment 传输的 SSL/TLS 消息类型序列, 据此构造一个 Markov Model.

> 因为以太坊平台中所有分布式应用的 SSL/TLS 消息类型行为都一致, 所以上述方法难以区分不同应用.

* 基于包长度的统计特征

三种方向(income, outcome, bi-direction) 的包的 18 种统计信息 (minimum, maximum, mean, median absolute deviation, standard deviation, variance, skew, kurtosis, percentiles (from 10% to 90%) and the number of elements in the series).

> 在以太坊分布式应用加密流量中此类信息的判别性能 (discrimination) 不是很好.

* Merging features

除了上述两种特征之外, 还可以使用 time series 和 packets bursts 这样的 (变长) 多维特征.

burst 是 TCP flow 中传输连续的多个相同方向 (src -> dst or dst -> src) 的包.

bursts 的统计特征包括 burst size (包数量) 和 burst length (burst 中所有包的 payload 长度之和).

bursts 统计特征 和  time series 同样也可以使用类似 packets lengths 的统计信息, 包含两个方向: ingress, egress, bi-direction. ( burst 只用了前两种方向: $2 \times 2 \times 18 = 72$, time 包含三个方向: $3 \times 18 = 54$ )

> merging features 中 packet length 还包括三个方向的包的总数作为 feature

> 实验结果: packet length: 79%, burst: 82%, time series: 78%, 三者简单合并 (merge): 85%.

* Select important features of merging features

使用随机森林中的 Gini importance metric, 筛除掉分数低于 0.15% 的, 183 个 features 减少为 166, RF 实验结果只提高 0.54%.

#### overview of feature fusion

$f = [Plen, Ptime, Brust]$

Kernel function:

$K(x, x^{\top}) = \phi(x) \phi(x^{\top})$

> $x \subset \mathcal{R}^{n \times 1}$

* polynomial kernel function:

$K(x, x^{\top}) = (x \* x^{\top} + 1)^d$

> $d \in \mathcal{N}^{+}$

* radial basis function

$K(x, x^{\top}) = \exp(- \frac{\lVert x - x^\top \rVert^2}{2 \sigma^2})$

> $\sigma \in (0, 1)$

对 Plen, Ptime 和 Burst 分别使用核函数之后把原来各有 $i, j, k$ 个元素变为 $i\*i, j\*j, k\*k$ 个元素 (并且会展平为一维).

> $i, j, k$ 在本文中为 $57, 54, 72$

特征选择:

暴力枚举 2 到 183 种特征来确定最重要的特征数 $n$ 的选择计算复杂度过高, 论文使用 random forest 中的 Gini index 作为特征重要性测量方法.

$VIM^{gini}\_{jm} = GI\_m - GI\_l - GI\_r$

> $GI_i = 1 - \sum\_{k=1}^{K} p\_{mk}^2$, $p\_{mk}$ 表示应用 $k$ 在结点 $m$ 中的百分比, $l$ 和 $r$ 表示 $m$ 的左右子节点.

> $VIM\_j$ 为特征 $j$ 的重要性, 共 $K$ 个 特征 $X\_1, \cdots, X\_C$

当 $X\_j$ 出现在树 $i$ 的结点中 (这些结点集为 $M$), $X\_j$ 对树 $i$ 的重要性为:

$VIM\_{ij}^{gini} = \sum\_{m \in M} VIM\_{jm}^{gini}$

随机森林中共 $n$ 棵决策树:

$VIM\_{j}^{gini} = \sum\_{i=1}^n VIM\_{ij}^{gini}$

归一化一下:

$VIM\_j = \frac{VIM\_j}{\sum\_{i=1}^c VIM\_i}$

排序这些特征重要性之后, $n$ 个特征的贡献衡量为:

$CFC\_n = \sum\_{i=1}^n VIM\_j \times \frac{1}{n}$

> CFC 在我看来毫无意义, VIM 高的特征的共享当然高, 但是 CFC 的值跟分类结果无关

#### 实验结果

具体看论文, Random Forest 对比其他两种 (kNN, SVM) 效果好很多, 感觉 classifer 的选择甚至比 feature 的选择效果更加明显

#### Refs

[1] Machine Learning for Encrypted Malware Traffic Classification: Accounting for Noisy Labels and Non-Stationarity
