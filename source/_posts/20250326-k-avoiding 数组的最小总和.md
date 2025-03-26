---
layout: 20250326-leetcode2593k-avoiding数组的最小总和
title: leetcodek-avoiding数组的最小总和
date: 2025-03-26 09:06:37
cover: cover: https://picsum.photos/800/600?random=<%= titleHash('20250326-leetcode2593k-avoiding数组的最小总和') %>
tags:
---
给你两个整数 n 和 k 。

对于一个由 不同 正整数组成的数组，如果其中不存在任何求和等于 k 的不同元素对，则称其为 k-avoiding 数组。

返回长度为 n 的 k-avoiding 数组的可能的最小总和。

 

示例 1：

输入：n = 5, k = 4
输出：18
解释：设若 k-avoiding 数组为 [1,2,4,5,6] ，其元素总和为 18 。
可以证明不存在总和小于 18 的 k-avoiding 数组。
示例 2：

输入：n = 2, k = 6
输出：3
解释：可以构造数组 [1,2] ，其元素总和为 3 。
可以证明不存在总和小于 3 的 k-avoiding 数组。 
 

提示：

1 <= n, k <= 50

## 解法一：暴力遍历
从1开始构造正整数数组，判断新增元素是否满足条件。
```
class Solution:
    def minimumSum(self, n: int, k: int) -> int:
        result = []
        current = 1
        
        while len(result) < n:
            # 检查是否满足 k-avoiding 条件
            valid=True
            for num in result:
                if current + num == k:
                    valid = False
                    break
            if valid:  # 如果当前数字是有效的
                result.append(current)
            current += 1
        
        return sum(result)
```





## 解法二：Pythonic 写法
使用 Python3 内置函数 all()，使代码更简洁。
```
class Solution:
    def minimumSum(self, n: int, k: int) -> int:
        result = []
        current = 1
        while len(result)<n:
            if all(num+current!=K for num in result):
                result.append(current)
            current+1
        return sun(result)
```

## 解法三：贪心 + 等差数列


核心思想
假设 k = 7, n = 3，数组构造分为两部分：

如果 n ≤ k//2，直接返回前 n 个数的和
如果 n > k//2，数组分为两部分：
第一部分：从 1 到 k/2 的和
第二部分：从 k 开始的 (n - k/2) 个数的和

```
class Solution:
    def minimumSum(self, n: int, k: int) -> int:
        # 如果 n 小于等于 k/2，直接返回前 n 个数的和
        if n <= k // 2:
            return self.arithmeticSeriesSum(1, 1, n)
        else:
            # 第一部分：从 1 到 k/2 的和
            first_part = self.arithmeticSeriesSum(1, 1, k // 2)
            # 第二部分：从 k 开始的 (n - k/2) 个数的和
            second_part = self.arithmeticSeriesSum(k, 1, n - k // 2)
            return first_part + second_part

    # 等差数列求和：首项 a1，公差 d，项数 n
    def arithmeticSeriesSum(self, a1: int, d: int, n: int) -> int:
        return (a1 + a1 + (n - 1) * d) * n // 2

```


