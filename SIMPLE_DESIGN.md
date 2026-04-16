# GPU Kernel 优化 Agent - 简化实用架构

> 这是一个可以直接编码实现的架构设计，保留核心功能，摒弃过度设计。

## 核心理念

- **3 个 Agent**：分工简单，职责清晰
- **工具即函数**：不要过度抽象
- **流程驱动**：main.py 中清晰可见
- **增量扩展**：先能跑，再优化

---

## 项目结构

```
KernelOptiAgent/
│
├── agents/
│   ├── __init__.py
│   ├── base.py                  # [1] Agent 基类（~50 行）
│   ├── analyzer.py              # [2] 代码分析 Agent
│   ├── profiler.py              # [3] 性能测评 Agent  
│   └── optimizer.py             # [4] 优化执行 Agent
│
├── tools/
│   ├── __init__.py
│   └── kernel_tools.py          # [5] 所有工具函数集合
│
├── core/
│   ├── __init__.py
│   ├── models.py                # [6] 数据模型定义
│   ├── memory.py                # [7] 简单记忆系统
│   └── config.py                # [8] 配置管理
│
├── utils/
│   ├── __init__.py
│   ├── logger.py                # 日志
│   └── errors.py                # 错误处理
│
├── main.py                      # [9] 主程序入口
├── SIMPLE_DESIGN.md             # 本文件
└── requirements.txt
```

## 数据流（简化版）

```
Input Kernel Code
        ↓
  [AnalyzerAgent]
  - 代码解析
  - 识别优化机会
  → AnalysisResult {strategies, bottlenecks}
        ↓
  [ProfilerAgent]
  - 基准测评
  - 性能数据采集
  → ProfileResult {baseline_time, metrics}
        ↓
  [OptimizerAgent]
  ├─ For each strategy:
  │  ├─ 生成优化代码
  │  ├─ 编译 + 验证
  │  ├─ 测评性能
  │  └─ 决策保留/丢弃
  → OptimizationResult {optimized_code, speedup}
        ↓
Output Optimized Kernel + Report
```

---

## 关键特点

| 特性 | 实现方式 |
|------|--------|
| **模块化** | 3 个 Agent + 工具库，职责清晰 |
| **可实现** | 每个文件 < 200 行代码 |
| **可扩展** | 新增 Agent 只需继承 BaseAgent |
| **可测试** | 每个 Agent 独立，容易单测 |
| **可观测** | main.py 中清晰看到全流程 |
| **核心完整** | 有分析、测评、优化三个阶段 |


