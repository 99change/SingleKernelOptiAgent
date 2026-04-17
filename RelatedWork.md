# 一、核心高质量工作（优先级最高，建议逐篇读）

## 1. KernelBench（及其后续）

* 类型：benchmark + framework
* 作用：定义 evaluation protocol
* 方法：LLM iterative optimization loop
* 可信度：★★★★★（基石）

👉 说明：
几乎所有后续工作都默认这个范式（甚至直接用它的 benchmark）。

---

## 2. GPU Kernel Scientist

* 类型：iterative refinement（强化版）
* 方法：

  * 多轮 self-improve
  * 引入 execution feedback + reasoning
* 特点：

  * 比 KernelBench 更强调“analysis → rewrite”
* 可信度：★★★★☆

👉 本质：
是 KernelBench loop 的“做深版本”，不是范式突破。

---

## 3. Astra（multi-agent kernel optimization）

* 类型：multi-agent
* 方法：

  * planner / coder / evaluator 分工
* 特点：

  * 引入 agent 协作，而不是单 LLM loop
* 可信度：★★★★☆

👉 关键问题：
multi-agent 是否真的优于单 agent（很多证据并不强）。

---

## 4. AutoKernel（agent + profiling loop）

* 类型：agent system
* 方法：

  * 自动 compile + profile + refine
* 特点：

  * 更工程化（接近真实系统）
* 可信度：★★★★☆

---

## 5. KernelFoundry

* 类型：LLM + evolutionary search
* 方法：

  * LLM 生成候选
  * evolutionary 筛选
* 特点：

  * 引入“population-based search”
* 可信度：★★★★☆

👉 这是少数**认真在解决 search problem 的**。

---

## 6. Kevin（RL for CUDA kernel optimization）

* 类型：RL + LLM hybrid
* 方法：

  * RL 学习优化策略
  * LLM 辅助生成
* 特点：

  * 尝试解决 credit assignment
* 可信度：★★★★☆

---

# 二、第二梯队（有价值，但创新有限）

## 7. KernelCoder / LLM4CUDA 类工作

* 类型：code generation + optimization
* 方法：

  * prompt engineering + few-shot
* 问题：

  * 很多优化来自 prompt，而不是算法
* 可信度：★★★☆☆

---

## 8. Triton-LLM optimization 系列

* 类型：LLM → Triton kernel
* 方法：

  * 利用 Triton 降低搜索空间
* 优点：

  * 更稳定（比 raw CUDA 好）
* 缺点：

  * 上限受 Triton 限制
* 可信度：★★★☆☆

---

## 9. LLM autotuning 替代 cost model

* 类型：LLM as cost model
* 方法：

  * 预测 kernel performance
* 问题：

  * 精度通常不稳定
* 可信度：★★★☆☆


# 四、一个更严格的“去重结论”

如果你**去掉所有水分，只保留真正推进问题的工作**：

👉 你可以认为：

**真正值得深读的 ≈ 6–10 篇**

就是：

* KernelBench（及变体）
* GPU Kernel Scientist
* Astra
* AutoKernel
* KernelFoundry
* Kevin

---

# 五、一个非常关键的现实判断

这 6–10 篇里，大多数工作的本质改动是：

* 改 loop（multi-agent / iterative）
* 改 search（evolution / RL）
* 改 representation（少数）

但**几乎没有人真正解决这三个核心问题：**

1. search space explosion
2. expensive feedback
3. hardware-aware reasoning
