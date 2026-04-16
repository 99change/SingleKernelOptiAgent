## 1. 基础 Agent 类

所有 Agent 都继承自 BaseAgent，具有以下结构：

```
BaseAgent
├── Attributes (属性)
│   ├── name: str                    # Agent 名称
│   ├── tools: List[Tool]            # 工具集合
│   ├── memory: AgentMemory          # 记忆模块
│   ├── config: AgentConfig          # 配置对象
│   └── state: AgentState            # 当前状态
│
├── Core Methods (核心方法)
│   ├── execute(task)                # 执行任务（主入口）
│   ├── think(context)               # 思考/推理
│   ├── plan(goal)                   # 制定计划
│   ├── act(action)                  # 执行动作
│   ├── observe(result)              # 观察结果
│   └── reflect(outcome)             # 反思/学习
│
└── Internal State (内部状态)
    ├── current_task                 # 当前任务
    ├── execution_history            # 执行历史
    └── performance_metrics          # 性能指标
```

---

## 2. Agent 生命周期架构

Agent 的每次执行都遵循以下循环模式：

```
Agent Reasoning Loop
│
├─ INIT PHASE (初始化)
│   ├── Load Tools                   # 加载工具
│   ├── Initialize Memory            # 初始化记忆
│   └── Load Prompts/Instructions    # 加载提示词
│
├─ PERCEIVE PHASE (感知)
│   ├── Read Input                   # 读取输入
│   ├── Parse Context                # 解析上下文
│   └── Update State                 # 更新状态
│
├─ THINK PHASE (思考)
│   ├── Analyze Situation            # 分析情況
│   ├── Generate Options             # 生成选项
│   └── Deliberate (LLM reasoning)   # 深思熟虑
│
├─ PLAN PHASE (计划)
│   ├── Select Action                # 选择动作
│   ├── Prepare Tool Calls           # 准备工具调用
│   └── Organize Subtasks            # 组织子任务
│
├─ ACT PHASE (执行)
│   ├── Execute Tools                # 执行工具
│   ├── Handle Errors                # 处理错误
│   └── Collect Results              # 收集结果
│
├─ OBSERVE PHASE (观察)
│   ├── Process Outcomes             # 处理输出
│   ├── Update Memory                # 更新记忆
│   └── Check Goal Progress          # 检查目标进度
│
├─ REFLECT PHASE (反思)
│   ├── Evaluate Performance         # 评估表现
│   ├── Adjust Strategy              # 调整策略
│   └── Learn from Results           # 从结果学习
│
└─ LOOP or RETURN (循环或返回)
    ├── Continue to next iteration   # 继续下一轮
    └── Return final result          # 返回最终结果
```

---

## 3. 核心组件架构

项目的目录结构和各模块职责：

```
KernelOptiAgent/
│
├── agents/                          # Agent 实现模块
│   ├── __init__.py
│   ├── base_agent.py                # [Base] 所有 Agent 的基类
│   ├── master_agent.py              # [Master] 主协调 Agent
│   ├── analyzer_agent.py            # [Analyzer] 代码分析 Agent
│   ├── profiler_agent.py            # [Profiler] 性能测评 Agent
│   ├── optimizer_agent.py           # [Optimizer] 优化执行 Agent
│   └── comparator_agent.py          # [Comparator] 方案对比 Agent
│
├── tools/                           # 工具库
│   ├── __init__.py
│   ├── base_tool.py                 # [Base] 工具基类
│   ├── kernel_tools.py              # Kernel 解析、验证工具
│   ├── compile_tools.py             # 编译相关工具（nvcc）
│   ├── profile_tools.py             # 性能测评工具（nsys, ncu）
│   └── optimize_tools.py            # 优化转换工具
│
├── memory/                          # 记忆管理模块
│   ├── __init__.py
│   ├── agent_memory.py              # Agent 个体记忆
│   ├── knowledge_base.py            # 全局知识库
│   └── optimization_history.py      # 优化历史库
│
├── models/                          # 数据类型定义
│   ├── __init__.py
│   ├── input_models.py              # 输入数据模型
│   ├── output_models.py             # 输出数据模型
│   ├── internal_models.py           # 内部数据模型
│   └── domain_models.py             # 领域特定模型
│
├── config/                          # 配置管理
│   ├── __init__.py
│   ├── agent_config.py              # Agent 配置
│   ├── tool_config.py               # 工具配置
│   └── constants.py                 # 常量定义
│
├── interfaces/                      # 接口规范
│   ├── __init__.py
│   ├── agent_interface.py           # Agent 接口
│   ├── tool_interface.py            # Tool 接口
│   └── memory_interface.py          # Memory 接口
│
├── utils/                           # 工具函数
│   ├── __init__.py
│   ├── logger.py                    # 日志管理
│   ├── error_handler.py             # 错误处理
│   └── validators.py                # 数据验证
│
├── ARCHITECTURE.md                  # 本文件
├── main.py                          # 入口脚本
├── requirements.txt                 # 依赖
└── README.md                        # 项目说明
```

---

## 4. 单个 Agent 内部架构

每个 Agent 的内部结构与数据流：

```
AgentClass (extends BaseAgent)
│
├── Class Attributes (类属性)
│   ├── agent_id: str
│   ├── agent_type: str              # e.g., "analyzer", "optimizer"
│   ├── role_description: str
│   └── capabilities: List[str]
│
├── Initialization (初始化)
│   ├── __init__(config: AgentConfig)
│   ├── setup_tools()                # 设置工具
│   ├── load_prompts()               # 加载 prompt
│   └── initialize_memory()          # 初始化记忆
│
├── Public Interface (公共接口)
│   ├── run(task: Task) -> Result    # 主入口
│   ├── execute(objective) -> Result # 执行任务
│   └── get_result() -> Result       # 获取结果
│
├── Internal Processing (内部处理)
│   ├── _receive_context()           # 接收上下文
│   ├── _analyze()                   # 分析
│   ├── _decide()                    # 决策
│   ├── _process()                   # 处理
│   └── _validate_output()           # 验证输出
│
├── Tool Management (工具管理)
│   ├── _get_tool(name: str)         # 获取工具
│   ├── _call_tool(tool_name, ...)   # 调用工具
│   ├── _validate_result()           # 验证结果
│   └── _handle_tool_error()         # 处理工具错误
│
├── Memory Management (记忆管理)
│   ├── _save_to_memory(key, value)  # 存储信息
│   ├── _retrieve_from_memory(key)   # 检索信息
│   ├── _update_context()            # 更新上下文
│   └── _clear_cache()               # 清理缓存
│
└── Output (输出)
    ├── result: dict                 # 结果数据
    ├── reasoning: str               # 推理过程
    └── metadata: dict               # 元数据（耗时、资源等）
```

---

## 5. Tool 的架构

每个工具遵循统一的接口规范：

```
ToolClass (extends BaseTool)
│
├── Metadata (元数据)
│   ├── name: str                    # 工具名称
│   ├── description: str             # 功能描述
│   ├── category: str                # 分类（compile, profile, optimize）
│   └── version: str                 # 版本号
│
├── Definition (定义)
│   ├── input_schema: Dict           # 输入结构定义
│   ├── output_schema: Dict          # 输出结构定义
│   └── parameters: List[Parameter]  # 参数列表
│
├── Implementation (实现)
│   ├── execute(input: Input) -> Output
│   │   # 主执行方法，协调整个流程
│   ├── validate_input(input)        # 输入验证
│   ├── process(validated_input)     # 核心逻辑
│   └── format_output(output)        # 输出格式化
│
├── Error Handling (错误处理)
│   ├── handle_error(error)          # 错误处理
│   ├── retry_logic(max_retries)     # 重试逻辑
│   └── graceful_fallback()          # 优雅降级
│
└── Monitoring (监控)
    ├── log_execution(input, output) # 执行日志
    ├── collect_metrics()            # 收集指标
    └── send_telemetry()             # 发送遥测
```

---

## 6. Master Agent 协调架构

Master Agent 的职责是编排整个优化流程：

```
MasterAgent (extends BaseAgent)
│
├── Main Orchestration (主编排)
│   ├── orchestrate(kernel_code: str) -> OptimizationResult
│   │   ├── Parse Input              # 解析输入
│   │   ├── Create Task List         # 创建任务列表
│   │   │
│   │   ├── Phase 1: Parallel Analysis
│   │   │   ├─ spawn(AnalyzerAgent)   → analyze_kernel()
│   │   │   ├─ spawn(ProfilerAgent)   → profile_kernel()
│   │   │   └─ spawn(HistoryAgent)    → query_experience()
│   │   │   └─ wait_all()             # 等待全部完成
│   │   │
│   │   ├── Phase 2: Aggregate
│   │   │   ├─ merge_results()        # 合并结果
│   │   │   ├─ identify_bottlenecks() # 识别瓶颈
│   │   │   └─ generate_strategies()  # 生成策略
│   │   │
│   │   ├── Phase 3: Sequential Optimization
│   │   │   ├─ for each strategy:
│   │   │   │   ├─ spawn(OptimizerAgent)
│   │   │   │   └─ track_improvements()
│   │   │   └─ finalize_best()        # 确定最优
│   │   │
│   │   └── Return Optimized Result   # 返回结果
│   │
│   └── generate_report()             # 生成报告
│
├── State Management (状态管理)
│   ├── current_phase: Phase          # 当前阶段
│   ├── active_subtasks: Dict         # 活跃子任务
│   ├── results_cache: Dict           # 结果缓存
│   └── execution_log: List           # 执行日志
│
├── Decision Making (决策制定)
│   ├── decide_strategy()             # 决策策略
│   ├── handle_conflicts()            # 处理冲突
│   ├── prioritize_actions()          # 优先级排序
│   └── adapt_plan()                  # 调整计划
│
└── Feedback Loop (反馈循环)
    ├── monitor_progress()            # 监测进度
    ├── adjust_strategy()             # 调整策略
    ├── handle_failures()             # 处理失败
    └── optimize_next_round()         # 优化下一轮
```

---

## 7. 数据流架构

端到端的数据流转过程：

```
Input Layer (输入层)
│
├─ GPU Kernel Code (GPU Kernel 代码)
├─ Configuration (配置参数)
└─ Hardware Profile (硬件信息)
         │
         ↓
    [Message Queue / Event Bus]
         │
         ↓
Master Agent (THINK 阶段)
│
├─ Decompose Task           # 分解任务
├─ Decide Strategy          # 决定策略
└─ Assign Sub-Agents       # 分配子 Agent
         │
         ↓
Parallel Execution Layer (并行执行)
│
├─ Analyzer Agent ──────────────────────┐
│   ├─ Parse Kernel Syntax              │
│   ├─ Detect Memory Patterns           │
│   ├─ Identify Compute Hotspots        │
│   └─ Output: AnalysisResult           │
│                                       │
├─ Profiler Agent ─────────────────────→ [Aggregation Point]
│   ├─ Compile Kernel                   │
│   ├─ Run with Profiler                │
│   ├─ Extract Metrics                  │
│   └─ Output: PerformanceMetrics       │
│                                       │
└─ History Agent ──────────────────────→
    ├─ Query Similar Kernels
    ├─ Retrieve Optimization Patterns
    └─ Output: KnowledgeBase
         │
         ↓
Results Aggregator (结果聚合)
│
├─ Merge All Results        # 合并所有结果
├─ Resolve Conflicts        # 解决冲突
└─ Create Unified Context   # 创建统一上下文
         │
         ↓
Iterative Optimization Layer (迭代优化)
│
├─ Round 1: Strategy 1
│   ├─ Optimizer Agent
│   │   ├─ Transform Code           → Candidate 1
│   │   ├─ Validate Correctness     → ✓/✗
│   │   ├─ Compile & Profile        → Metrics
│   │   └─ Store in Memory
│   └─ Measure: Speedup 1.5x
│
├─ Round 2: Strategy 2
│   ├─ Optimizer Agent
│   │   ├─ Transform Code           → Candidate 2
│   │   ├─ Validate Correctness     → ✓/✗
│   │   ├─ Compile & Profile        → Metrics
│   │   └─ Store in Memory
│   └─ Measure: Speedup 1.2x
│
├─ Round 3: Strategy 3
│   └─ ... similar process
│
└─ ... Continue until no improvement
         │
         ↓
Comparator Agent (对比器)
│
├─ Compare All Candidates   # 比较所有候选
├─ Select Pareto Optimal    # 选择帕累托最优
└─ Output: Best Solution    # 输出最优方案
         │
         ↓
Output Layer (输出层)
│
├─ Optimized Kernel Code
├─ Performance Improvement Report
├─ Optimization History
└─ Recommendations for Future
```

---

## 8. 配置架构

所有可配置的参数统一管理：

```
config/

├── agent_config.py
│   └── AgentConfig (BaseSettings)
│       ├── name: str                 # Agent 名称
│       ├── role: str                 # 角色
│       ├── model: str                # 使用的 LLM 模型
│       ├── temperature: float        # 回复温度
│       ├── max_iterations: int       # 最大迭代次数
│       ├── timeout: int              # 超时时间（秒）
│       ├── max_retries: int          # 最大重试次数
│       ├── tools: List[str]          # 可用工具清单
│       └── prompts: Dict             # 提示词字典
│
├── tool_config.py
│   └── ToolConfig (BaseSettings)
│       ├── tool_name: str            # 工具名称
│       ├── enabled: bool             # 是否启用
│       ├── timeout: int              # 超时设置
│       ├── retry_count: int          # 重试次数
│       ├── max_parallel: int         # 最大并行数
│       └── resource_limits: Dict     # 资源限制
│
├── system_config.py
│   └── SystemConfig
│       ├── timeout_global: int       # 全局超时
│       ├── max_parallel_agents: int  # 最大并行 Agent 数
│       ├── logging_level: str        # 日志级别
│       ├── output_dir: Path          # 输出目录
│       ├── cache_size: int           # 缓存大小
│       ├── enable_telemetry: bool    # 是否启用遥测
│       └── gpu_devices: List[int]    # GPU 设备 ID
│
└── env.yaml / .env                   # 环境变量配置文件
    ├── OPENAI_API_KEY
    ├── CUDA_VISIBLE_DEVICES
    ├── OPTIMIZATION_TIMEOUT
    └── ...
```

---

## 9. 类型定义架构

使用 Pydantic 或 dataclass 定义数据结构：

```
models/

├── input_models.py
│   ├── KernelInput(BaseModel)
│   │   ├── code: str                # kernel 源代码
│   │   ├── hardware_target: str      # 目标硬件
│   │   ├── optimization_goal: str    # 优化目标（speed/memory/power）
│   │   └── constraints: Dict        # 约束条件
│   │
│   ├── AnalysisRequest(BaseModel)
│   ├── OptimizationRequest(BaseModel)
│   └── ValidationRequest(BaseModel)
│
├── output_models.py
│   ├── AgentResult(BaseModel)
│   │   ├── agent_id: str
│   │   ├── status: str              # success/error/timeout
│   │   ├── result: Any
│   │   ├── reasoning: str           # 推理过程描述
│   │   └── metadata: Dict           # 执行元数据
│   │
│   ├── AnalysisResult(BaseModel)
│   │   ├── complexity: float
│   │   ├── memory_patterns: List
│   │   ├── bottlenecks: List
│   │   └── opportunities: List
│   │
│   ├── OptimizationResult(BaseModel)
│   │   ├── optimized_code: str
│   │   ├── speedup: float
│   │   ├── improvement_history: List
│   │   └── applied_strategies: List
│   │
│   └── Report(BaseModel)
│       ├── summary: str
│       ├── details: Dict
│       └── recommendations: List
│
├── internal_models.py
│   ├── Task(BaseModel)
│   │   ├── task_id: str
│   │   ├── agent_id: str
│   │   ├── objective: str
│   │   └── priority: int
│   │
│   ├── ActionPlan(BaseModel)
│   │   ├── steps: List[Action]
│   │   └── estimated_cost: Dict
│   │
│   ├── ToolCall(BaseModel)
│   │   ├── tool_name: str
│   │   ├── parameters: Dict
│   │   ├── timeout: int
│   │   └── retry_config: Dict
│   │
│   └── ExecutionTrace(BaseModel)
│       ├── timestamp: datetime
│       ├── agent_id: str
│       ├── action: str
│       ├── result: Any
│       └── duration: float
│
└── domain_models.py
    ├── KernelMetrics(BaseModel)
    │   ├── execution_time: float
    │   ├── memory_bandwidth: float
    │   ├── register_usage: int
    │   ├── thread_efficiency: float
    │   └── occupancy: float
    │
    ├── OptimizationStrategy(BaseModel)
    │   ├── name: str
    │   ├── description: str
    │   ├── expected_improvement: float
    │   ├── risk_level: str          # low/medium/high
    │   └── prerequisites: List
    │
    └── PerformanceComparison(BaseModel)
        ├── before: KernelMetrics
        ├── after: KernelMetrics
        ├── speedup: float
        └── trade_offs: Dict
```

---

## 10. 接口规范架构

所有模块遵循统一的接口约定：

```
interfaces/

├── agent_interface.py
│   └── IAgent (ABC)
│       ├── execute(task: Task) -> Result
│       │   """执行任务，返回结果"""
│       │
│       ├── plan(goal: Goal) -> ActionPlan
│       │   """根据目标制定行动计划"""
│       │
│       ├── think(context: Context) -> Thought
│       │   """思考并返回推理过程"""
│       │
│       ├── get_tools() -> List[Tool]
│       │   """获取该 Agent 可用的工具"""
│       │
│       └── save_state() -> State
│           """保存当前 Agent 状态"""
│
├── tool_interface.py
│   └── ITool (ABC)
│       ├── get_schema() -> Schema
│       │   """获取工具的输入/输出模式"""
│       │
│       ├── validate(input: Input) -> bool
│       │   """验证输入是否合法"""
│       │
│       ├── execute(input: Input) -> Output
│       │   """执行工具"""
│       │
│       └── describe() -> str
│           """返回工具的描述信息"""
│
└── memory_interface.py
    └── IMemory (ABC)
        ├── save(key: str, value: Any) -> bool
        │   """保存信息"""
        │
        ├── retrieve(key: str) -> Any
        │   """检索信息"""
        │
        ├── search(query: str) -> List[Any]
        │   """搜索匹配的信息"""
        │
        ├── delete(key: str) -> bool
        │   """删除信息"""
        │
        └── clear() -> bool
            """清空所有信息"""
```

---

## 架构特性总结

| 特性 | 实现方式 |
|------|--------|
| **模块化** | 基类 + 继承，明确的职责分工 |
| **可扩展** | 接口 + 工厂模式，易于添加新 Agent/Tool |
| **可维护** | 统一的生命周期模式，清晰的数据流 |
| **可观测** | 完整的执行追踪和日志记录 |
| **可协作** | 明确的 Agent 协调和通信机制 |
| **容错性** | 重试、降级、错误处理机制 |
| **性能** | 并行执行、缓存、资源管理 |

---

## 关键设计原则

1. **单一职责**：每个 Agent/Tool 只做一件事，做好做专
2. **开放封闭**：对扩展开放，对修改封闭
3. **依赖倒置**：依赖抽象接口，而不是具体实现
4. **DRY 原则**：避免重复，复用公共逻辑
5. **KISS 原则**：保持简单，避免过度设计
6. **可测试性**：各模块应当便于单元测试
7. **可观测性**：提供完整的日志和监控

---

## 开发建议

### MVP 阶段（2-3 周）
- [ ] 实现 BaseAgent 和 BaseMemory
- [ ] 实现 Analyzer Agent
- [ ] 实现 Profiler Agent
- [ ] 简单 Optimizer（单策略）

### 迭代阶段（后续）
- [ ] Multi-Strategy Comparator
- [ ] Advanced Memory (学习能力)
- [ ] Hardware-specific Tuning
- [ ] Distributed Execution

---

**最后更新**：2026-04-16
