---
title: 20250714-线程池和jobSystem
cover: https://picsum.photos/800/600?random=<%= titleHash('20250714-线程池和jobSystem) %>
comments: true
copyright: true
typora-root-url: ..
date: 2025-07-14 17:16:30
tags:
categories:
description:
---

## C++ 最小线程池实现

下面是一个简洁易懂的 C++11 线程池最小实现示例，并附详细注释：

```cpp
#include <vector>                // 用于存储线程对象
#include <queue>                 // 任务队列
#include <thread>                // std::thread
#include <mutex>                 // std::mutex
#include <condition_variable>    // 条件变量用于线程同步
#include <functional>            // std::function 封装任务
#include <future>                // std::future 获取任务结果
#include <atomic>                // std::atomic<bool> 控制线程池关闭

class ThreadPool {
public:
    ThreadPool(size_t n) : stop(false) { // 构造函数，初始化线程池并启动 n 个线程
        for (size_t i = 0; i < n; ++i) {
            workers.emplace_back([this] { // 每个线程执行一个循环任务
                while (true) {
                    std::function<void()> task; // 当前要执行的任务
                    {
                        std::unique_lock<std::mutex> lock(this->mtx); // 加锁保护任务队列
                        this->cv.wait(lock, [this] { return stop || !tasks.empty(); }); // 等待任务或关闭信号
                        if (stop && tasks.empty()) return; // 如果关闭且无任务，退出线程
                        task = std::move(tasks.front()); // 取出队首任务
                        tasks.pop(); // 移除队首任务
                    }
                    task(); // 执行任务
                }
            });
        }
    }
    ~ThreadPool() { // 析构函数，关闭线程池
        {
            std::unique_lock<std::mutex> lock(mtx); // 加锁
            stop = true; // 设置关闭标志
        }
        cv.notify_all(); // 唤醒所有线程
        for (auto &t : workers) t.join(); // 等待所有线程结束
    }
    template<class F, class... Args>
    auto enqueue(F&& f, Args&&... args) -> std::future<typename std::result_of<F(Args...)>::type> {
        using ret_type = typename std::result_of<F(Args...)>::type; // 推导返回类型
        auto task = std::make_shared<std::packaged_task<ret_type()>>(
            std::bind(std::forward<F>(f), std::forward<Args>(args)...) // 绑定参数
        );
        std::future<ret_type> res = task->get_future(); // 获取 future
        {
            std::unique_lock<std::mutex> lock(mtx); // 加锁
            if (stop) throw std::runtime_error("enqueue on stopped ThreadPool"); // 已关闭则抛异常
            tasks.emplace([task]() { (*task)(); }); // 将任务加入队列
        }
        cv.notify_one(); // 唤醒一个线程
        return res; // 返回 future
    }
private:
    std::vector<std::thread> workers; // 工作线程数组
    std::queue<std::function<void()>> tasks; // 任务队列
    std::mutex mtx; // 互斥锁
    std::condition_variable cv; // 条件变量
    std::atomic<bool> stop; // 关闭标志
};
```

### 使用方法

```cpp
ThreadPool pool(4);
auto fut = pool.enqueue([] { return 42; });
int result = fut.get(); // result == 42
```

### 讲解
- 构造函数创建 n 个工作线程，每个线程不断从任务队列取任务执行。
- enqueue 方法支持任意可调用对象入队，并返回 future 以获取结果。
- 析构函数安全关闭线程池。

该实现适合学习和小型项目，生产环境建议使用更健壮的线程池库。
