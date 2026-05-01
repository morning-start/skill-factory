---
name: skill-factory-researcher
version: v0.2.0
author: skill-factory
parent: skill-factory-phase-production
layer: 2
phase: production
description: 信息研究员，负责接收用户输入、初步浏览、交互确认需求、网络搜索补充、识别并补充缺失信息，输出完整需求给下游
tags: [skill-factory, researcher, interaction, research]
dependency:
  parent: skill-factory-phase-production
  output_to: skill-factory-analyzer
---

# Skill Factory Researcher - 信息研究员

## 职责边界

**负责**：接收用户输入、初步浏览、交互确认、补充信息、输出完整需求
**不负责**：技术深度分析（analyzer）、类型判定（planner）、文件生成（generator）

**核心价值**：在正式分析前，通过研究和调查确保信息充分、需求明确

---

## 在流程中的位置

```mermaid
flowchart LR
    A[用户输入] --> R[researcher 信息研究]
    
    R -->|需求明确| N[需求文档 输出给 analyzer]
    
    N --> AN[analyzer 技术分析]
    AN --> PL[planner 类型判定]
    PL --> GE[generator 生成文件]
    GE --> PA[packager 结构验证]
    
    subgraph researcher 内部
        direction TB
        R1[浏览内容]
        R2[交互确认]
        R3[搜索补充]
    end
    
    style A fill:#f5f5f5,color:#424242
    style R fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px,color:#1a237e
    style N fill:#c5cae9,stroke:#303f9f,color:#1a237e
```

---

## 核心工作流

### 六步研究流程

```mermaid
flowchart TD
    Start([开始]) --> Step1[Step 1: 接收输入]
    Step1 --> Step2[Step 2: 初步浏览]
    Step2 --> Step3[Step 3: 交互确认]
    Step3 --> Step4[Step 4: 缺失检测]
    Step4 --> Step5{Step 5: 补充信息}
    
    Step5 -->|网络搜索可获取| Search[网络搜索]
    Step5 -->|需要用户确认| Ask[询问用户]
    Step5 -->|信息充足| Skip[跳过]
    
    Search --> Check{足够?}
    Ask --> Check
    Skip --> Check
    
    Check -->|是| Step6[Step 6: 输出需求]
    Check -->|否| Search2[再次尝试或询问]
    Search2 --> Step6
    
    Step6 --> End([输出需求文档])
    
    style Step1 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Step2 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Step3 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Step4 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Step5 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style Step6 fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style End fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style Search fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style Ask fill:#ffe0b2,stroke:#fb8c00,color:#e65100
```

---

## Step 1：接收输入

### 支持的输入类型

```mermaid
flowchart LR
    Input[用户输入] --> Type1[URL 技术文档或官网]
    Input --> Type2[文件夹路径 本地教程]
    Input --> Type3[文件路径 单个文档]
    Input --> Type4[文字描述 用户口述需求]
    
    style Input fill:#f5f5f5,color:#424242
    style Type1 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Type2 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Type3 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Type4 fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
```

### 输入验证

| 输入类型 | 有效条件 | 无效处理 |
|---------|---------|---------|
| URL | HTTP 可访问，返回 HTML/文档 | 提示用户检查链接 |
| 文件夹 | 路径存在，含文档文件 | 提示正确路径 |
| 文件 | 文件存在，可读取 | 提示检查文件 |
| 文字描述 | 长度 > 20 字符 | 引导用户提供更多信息 |

---

## Step 2：初步浏览

### 浏览目标

快速了解内容的**概况**，不需要深入细节：

```mermaid
flowchart TB
    Root[研究目标] --> Cat1[基本信息]
    Root --> Cat2[内容规模]
    Root --> Cat3[内容结构]
    Root --> Cat4[关键特性]
    
    Cat1 --> I1[技术名称]
    Cat1 --> I2[版本号]
    Cat1 --> I3[类型]
    
    Cat2 --> S1[文档页数]
    Cat2 --> S2[示例数量]
    Cat2 --> S3[图表数量]
    
    Cat3 --> St1[主要章节]
    Cat3 --> St2[学习路径]
    Cat3 --> St3[难度评估]
    
    Cat4 --> K1[核心功能列表]
    Cat4 --> K2[适用场景]
    Cat4 --> K3[限制条件]
    
    style Root fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Cat1 fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style Cat2 fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style Cat3 fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style Cat4 fill:#c5cae9,stroke:#303f9f,color:#1a237e
```

### 浏览操作

| 操作 | 说明 |
|------|------|
| **URL 输入** | 访问页面，提取标题、目录、关键概念 |
| **文件夹** | 列出文件结构，读取 README 或入口文档 |
| **单文件** | 扫描头部、章节标题、代码块数量 |
| **文字描述** | 提取关键词，判断是否需要更多上下文 |

### 浏览结果输出

```yaml
研究报告:
  来源: URL 或文件夹或文件
  技术名称: 名称
  类型: 框架或库或工具
  版本: 版本号
  内容规模:
    章节: N 个
    示例: N 个
  初步印象:
    复杂度: 简单或中等或复杂
    可能的类型判定: 轻加薄 或 重加薄 或 轻加厚 或 重加厚
```

---

## Step 3：交互确认

### 必须确认的信息

```mermaid
flowchart TD
    Q1{技能用途} 
    Q1 --> A1[学习该技术?]
    Q1 --> A2[使用该技术开发?]
    Q1 --> A3[教学培训他人?]
    
    Q2{目标用户?}
    Q2 --> B1[初学者?]
    Q2 --> B2[有经验的开发者?]
    Q2 --> B3[团队协作使用?]
    
    Q3{期望的技能形式?}
    Q3 --> C1[快速上手指南?]
    Q3 --> C2[完整参考手册?]
    Q3 --> C3[实战项目模板?]
    Q3 --> C4[按需组合?]
    
    Q4{有特殊要求?}
    Q4 --> D1[需要中文为主?]
    Q4 --> D2[需要代码示例?]
    Q4 --> D3[需要配置模板?]
    Q4 --> D4[有特定场景限制?]
    
    style Q1 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Q2 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Q3 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Q4 fill:#fff3e0,stroke:#ff9800,color:#e65100
```

### 交互原则

| 原则 | 说明 |
|------|------|
| **渐进式** | 从宽泛到具体，不要一次性问太多 |
| **提供选项** | 给出选项让用户选择，而非开放式问题 |
| **智能推断** | 能从上下文推断的不用问 |
| **记录决策** | 记录用户的每个选择，用于后续步骤 |

### 交互示例

**推荐方式**（提供选项）：
> 这个技能的主要用途是什么？
> - A) 学习理解该技术
> - B) 使用该技术开发项目
> - C) 教授/培训他人
> - D) 其他（请说明）

**避免方式**（开放式）：
> ❌ 请详细描述你的需求...

---

## Step 4：缺失检测

### 检查清单

```mermaid
flowchart TD
    Check[缺失信息检测]
    
    Check --> Cat1{基础信息}
    Cat1 --> I1[技术名称?]
    Cat1 --> I2[官方文档链接?]
    Cat1 --> I3[最新版本?]
    
    Check --> Cat2{内容信息}
    Cat2 --> I4[API接口文档?]
    Cat2 --> I5[配置示例?]
    Cat2 --> I6[常见问题FAQ?]
    
    Check --> Cat3{上下文信息}
    Cat3 --> I7[依赖环境?]
    Cat3 --> I8[兼容性要求?]
    Cat3 --> I9[最佳实践?]
    
    I1 & I2 & I3 & I4 & I5 & I6 & I7 & I8 & I9 --> Result{汇总缺失项}
    
    Result --> HasMissing[有缺失项]
    Result --> Complete[信息完整]
    
    HasMissing --> NextStep[进入 Step 5 补充]
    Complete --> Output[直接输出需求]
    
    style Check fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style HasMissing fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Complete fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
```

### 常见缺失项及优先级

| 缺失项 | 优先级 | 获取难度 | 推荐来源 |
|--------|--------|---------|---------|
| 技术名称 | 高 | 低 | 页面标题/用户确认 |
| 官方文档 | 高 | 低 | URL 本身/搜索 |
| API 文档 | 中 | 中 | 官网/API 文档站 |
| 配置示例 | 中 | 中 | 文档/GitHub |
| 最佳实践 | 低 | 高 | 博客/社区/询问用户 |

---

## Step 5：补充信息

### 补充策略优先级

```mermaid
flowchart LR
    Missing[发现缺失信息] --> P1[① 自动推断 从已有内容推导]
    P1 --> P2[② 网络搜索 Google或官方文档]
    P2 --> P3[③ 询问用户 直接沟通确认]
    
    style Missing fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
    style P1 fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style P2 fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style P3 fill:#fff3e0,stroke:#ff9800,color:#e65100
```

### 网络搜索策略

| 搜索目标 | 搜索关键词模板 | 预期结果 |
|---------|---------------|---------|
| 技术概述 | `{技术名} introduction tutorial` | 入门教程链接 |
| API 文档 | `{技术名} API reference` | 官方 API 文档 |
| 配置示例 | `{技术名} config example` | 配置文件模板 |
| 最佳实践 | `{技术名} best practices` | 经验文章 |
| 更新日志 | `{技术名} changelog release notes` | 版本信息 |

### 搜索结果处理

```mermaid
flowchart TD
    Search[搜索完成] --> Evaluate{结果质量}
    
    Evaluate -->|高质量官方权威源| Use[直接使用]
    Evaluate -->|质量一般需要筛选| Filter[筛选后使用]
    Evaluate -->|无结果或低质量| Fallback[询问用户]
    
    Use --> Record[记录来源URL]
    Filter --> Record
    Fallback --> Record
    
    Record --> Next[继续下一步]
    
    style Search fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style Use fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style Filter fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Fallback fill:#fff3e0,stroke:#ff9800,color:#e65100
```

### 询问用户时机

以下情况应该**主动询问用户**：

| 场景 | 询问内容 | 示例 |
|------|---------|------|
| 多个版本 | 使用哪个版本？ | "Vue2 还是 Vue3？" |
| 多种用法 | 主要用于什么？ | "主要用于 SPA 还是 SSR？" |
| 特殊环境 | 有特殊限制吗？ | "需要在 Node 还是浏览器运行？" |
| 搜索失败 | 你有相关资料吗？ | "找不到 XXX 的文档，你有吗？" |
| 歧义需求 | 具体指什么？ | "你说高效是指性能还是开发效率？" |

### 询问技巧

```mermaid
flowchart TD
    Ask[需要询问用户]
    
    Ask --> Rule1[规则1: 提供上下文 说明为什么需要知道]
    Ask --> Rule2[规则2: 给出选项 降低回答门槛]
    Ask --> Rule3[规则3: 说明影响 不同选择的结果]
    Ask --> Rule4[规则4: 允许跳过 可以使用默认值]
    
    Rule1 & Rule2 & Rule3 & Rule4 --> GoodAsk[好的问题]
    
    style Ask fill:#fff3e0,stroke:#ff9800,color:#e65100
    style GoodAsk fill:#ffe0b2,stroke:#f57c00,color:#e65100
```

---

## Step 6：输出需求文档

### 输出格式

```markdown
# 技能需求文档

## 基本信息
- 来源: 原始输入
- 技术名称: 确认后的名称
- 版本: 版本号
- 类型: 框架或库或工具

## 用户需求
- 主要用途: 学习或开发或教学或其他
- 目标用户: 初学者或有经验或团队
- 期望形式: 快速上手或完整参考或项目模板
- 特殊要求: 列出各项

## 内容资源
- 主文档: URL 或路径
- API 文档: URL 或路径
- 配置示例: 有或无加来源
- 最佳实践: 有或无加来源
- 补充资料: 搜索获得的额外资源

## 研究结论
- 复杂度预估: 简单或中等或复杂
- 可能类型: 轻加薄 或 重加薄 或 轻加厚 或 重加厚
- 建议方向: 基于用户需求的建议

## 交互记录
- 时间: 问题 到 用户回答
- 时间: 搜索 到 结果
```

### 传递给下游

```mermaid
flowchart LR
    Researcher[researcher 输出需求文档] --> Analyzer[analyzer 接收并分析]
    
    Researcher -->|包含| Info1[明确的用户意图]
    Researcher -->|包含| Info2[确认的技术信息]
    Researcher -->|包含| Info3[补充的资源链接]
    Researcher -->|包含| Info4[交互决策记录]
    
    style Researcher fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Analyzer fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
```

---

## 全程回调机制

在后续阶段（analyzer/planner/generator/packager）中如果发现信息不足，可以**回调** researcher：

### 回调配置 (v0.2.0 新增)

```yaml
callback_config:
  max_callbacks: 3              # 最大回调次数（硬限制）
  cooldown_seconds: 60          # 回调间隔冷却时间（秒）
  auto_escalate_threshold: 2    # 超过N次自动升级为人工介入
  callback_history_log: true    # 是否记录回调历史
```

### 回调行为规则

- 每次回调前检查 `callback_count < max_callbacks`
- 超过限制时：停止回调 → 标记 warning → 建议人工 review
- 记录每次回调的：时间戳、触发者、请求内容、补充结果
- 冷却期内重复请求返回"请等待冷却"

### 回调保护流程（v0.2.0 更新）

```mermaid
flowchart TD
    A[收到回调请求] --> B{callback_count < 3?}

    B -->|是| C{冷却期已过?}
    C -->|是| D[执行回调]
    C -->|否| E[返回: 请等待60秒]

    D --> F[递增 callback_count]
    F --> G[记录到 callback_history]
    G --> H{count >= 2?}
    H -->|是| I[🔔 自动升级为人工介入建议]
    H -->|否| J[返回补充结果]

    B -->|否| K[⚠️ 达到上限]
    K --> L[标记 warning 并继续]
    L --> M[建议人工 review]

    style A fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style B fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style C fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style D fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style E fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
    style F fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style G fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style H fill:#fff3e0,stroke:#ff9800,color:#e65100
    style I fill:#fff3e0,stroke:#ff9800,color:#e65100
    style J fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style K fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style L fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style M fill:#fff3e0,stroke:#ff9800,color:#e65100
```

### 回调时序示例

```mermaid
sequenceDiagram
    participant R as researcher
    participant A as analyzer
    participant U as 用户
    participant Web as 网络

    R->>A: 需求文档
    A->>A: 分析中...
    A-->>R: 缺少 API 签名信息 (callback #1)

    R->>Web: 搜索 API 文档
    Web-->>R: 找到文档

    R->>U: 确认使用 REST 还是 GraphQL?
    U-->>R: REST

    R->>A: 补充 REST API 文档
    A->>A: 继续分析...

    Note over R: callback_count = 1/3 ✅

    A-->>R: 缺少边界条件说明 (callback #2)
    R->>U: 询问边界条件
    U-->>R: 提供边界值列表
    R->>A: 补充边界条件

    Note over R: callback_count = 2/3 ⚠️ 接近阈值

    A-->>R: 再次缺少信息 (callback #3)
    R->>R: 检查 count=3 == max=3
    R-->>A: ⚠️ 已达回调上限，建议人工 review
```

### 回调触发条件

| 触发阶段 | 触发条件 | 回调动作 |
|---------|---------|---------|
| analyzer | 技术细节不清楚 | 搜索或询问 |
| planner | 无法判断轻重薄厚 | 询问用户期望 |
| generator | 缺少具体示例 | 搜索示例或询问 |
| packager | 格式规范有歧义 | 查询最新规范 |

---

## 注意事项

| 原则 | 说明 |
|------|------|
| **不过度研究** | 信息够用即可，无需完美 |
| **尊重用户时间** | 问题精简，每次最多 3 个 |
| **保留决策依据** | 记录为什么做某个决定 |
| **允许迭代** | 后续可以回来补充信息 |
| **超时机制** | 单次交互等待不超过合理时间 |

---

## 快速路径优化 (Type 1) - v0.2.0 新增

当检测到可能是 **Type 1（轻+薄）** 技能时，启用快速研究模式：

```yaml
fast_research_mode:
  触发条件:
    - 用户明确表示"简单技能"
    - 输入内容 < 500 字符
    - 预计输出 < 300 行

  简化措施:
    缺失检测清单:
      - 仅检查必填项（技术名称、官方文档）
      - 跳过可选信息（最佳实践、FAQ等）
    交互确认:
      - 减少为 1-2 个关键问题
      - 使用默认值填充非关键项
    目标耗时:
      - 标准: 20min → 快速: 10min (-50%)
```

### 快速模式 vs 标准模式对比

| 维度 | 标准模式 | 快速模式 (Type 1) |
|------|---------|-------------------|
| **输入收集** | 完整浏览+深度分析 | 快速扫描关键信息 |
| **缺失检测** | 9 项全检 | 仅检必填 3 项 |
| **交互确认** | 4 组问题（12个） | 1 组问题（2-3个） |
| **补充策略** | 自动→搜索→询问 | 自动→默认值 |
| **预计耗时** | 20min | 10min |
| **适用场景** | Type 2/3/4 | **Type 1** |

### 快速模式流程图

```mermaid
flowchart TD
    Start[检测到可能Type 1] --> QuickScan[快速扫描<br/>提取核心信息]
    QuickScan --> BasicCheck{必填项完整?}

    BasicCheck -->|是| FastConfirm["快速确认<br/>1-2个关键问题"]
    BasicCheck -->|否| MinSupplement["最小化补充<br/>仅填必填项"]

    FastConfirm --> Output[输出简化需求文档]
    MinSupplement --> Output

    Output --> Note["⏱️ 总耗时: ~10min<br/>(vs 标准20min)"]

    style Start fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style QuickScan fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style BasicCheck fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style FastConfirm fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style MinSupplement fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Output fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style Note fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
```

---

## 参考

- [skill-factory](../../SKILL.md) - 母技能
- [skill-factory-analyzer](../skill-factory-analyzer/SKILL.md) - 下游技能
