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

假定训练集中对某一个应用共有 $K$ 个 flow，每一个 flow 的前 $n$ (e.g. 20) bits 就表示其签名，所以签名集 $A_{sig} = \{ \{f_{i,j} | 1 \le j \le n \} | 1 \le i \le K \}$. e.g. $\{11101, 11011, 11001\}$ 就是 3 个 flow 的签名集合。

> Tips: 原来 mathjax 里面连续两个 `\{` 要用空格隔开, 除了 `这种` 之外的地方星号都要转义

应用的签名表示为 `s = [(1 if sum(A_sig[:, i] == K else 0 if sum(A_sig[:, i] == 0 else '*') for j in range(n)]` (类 Python 语法).

* Run-length Encoding

上述应用签名长度为 $n$ 位三进制，使用 RLE 这种 naive 的无损压缩方式，具体地说，$n$ 个连续的 $1, 0, \*$ 分别表示为 $nW, nZ, n\*$.

* State Transition Machine Creation

RLE 进一步转化为一个受限的有限计数自动机（Transition Constrained Counting Automata, abbr., TCCA)。

其实就是一种魔改版的 DFA。。或者说是一种 regexp 子集。

> `8W8Z3*3W` 其实就是 regexp `1{8,8}0{6,6}[01]{3,3}1{3,3}`

形式化表示为：$\mathcal{M} = (Q, \Sigma, C, \sigma, q_0, F),$ w.r.t. $Q$ is finite set of input symbols, $\Sigma$ is finite set of input symbols, $C$ is finite set of counters, $q_0 \in Q$ is initial state, $F \subseteq Q$ is final state set, $\sigma$ is the set of transitions, 并且 $\sigma_i \in \sigma, \sigma_i = <q_i, q_j, c, \phi(c_i), Inc(c_j)>$, w.r.t. $q_i$ is current state, $q_j$ is next state, $c_i$ is current count, $\phi(c_i)$ is the (invariant) constraint on counter value $c_i$, $Inc(c_j)$ is a function that assign the $c_j$ to a new value.

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
