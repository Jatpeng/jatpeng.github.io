---
title: LeetCode 50 - Pow(x, n)
cover: https://picsum.photos/seed/20250204-leetcode50-pow/1200/675
comments: true
copyright: true
typora-root-url: ..
date: 2025-02-04 23:38:28
tags:
categories:
description:
---

## 题目

实现 `pow(x, n)`，即计算 `x` 的 `n` 次幂。

## 解题思路

使用快速幂（分治）：

- 若 `n` 为偶数：`x^n = (x^(n/2))^2`
- 若 `n` 为奇数：`x^n = x * x^(n-1)`

为了处理负指数，把 `x` 取倒数并将 `n` 取相反数。

## 代码实现（Python）

```python
class Solution:
    def myPow(self, x: float, n: int) -> float:
        if n == 0:
            return 1.0
        if n < 0:
            x = 1 / x
            n = -n

        result = 1.0
        while n > 0:
            if n & 1:
                result *= x
            x *= x
            n >>= 1
        return result
```

## 复杂度分析

- 时间复杂度：`O(log n)`
- 空间复杂度：`O(1)`
