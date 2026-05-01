---
name: skill-factory-phase-processing
version: v0.2.0
author: skill-factory
parent: skill-factory
phase: coordination
layer: 1  # 阶段协调器层
description: 加工阶段协调器，负责调度 enricher/simplifier/beautifier/standardizer 四种加工器
tags: [skill-factory, phase-coordinator, processing, strategy]
dependency:
  parent: skill-factory
  children:
    - skill-factory-enricher
    - skill-factory-simplifier
    - skill-factory-beautifier
    - skill-factory-standardizer
  input_from: skill-factory-phase-production
  output_to: skill-factory-phase-publishing
---

# Phase Processing - 加工阶段协调器

## 职责边界

**负责**: 协调加工阶段的 4 个子技能，根据策略模式选择执行顺序
**不负责**: 生产阶段（production）、发布阶段（publishing）

---

## 在三层架构中的位置

```mermaid
flowchart TB
    L0["Layer 0: skill-factory"] --> L1["Layer 1: phase-processing<br/>⭐ 本协调器"]
    
    L1 --> E["enricher 丰富"]
    L1 --> S["simplifier 简化"]
    L1 --> B["beautifier 美化"]
    L1 --> ST["standardizer 规范"]
    
    PrevPhase["← phase-production"] --> L1
    L1 --> NextPhase["→ phase-publishing"]
    
    style L0 fill:#f3e5f5,stroke:#9c27b0,color:#4a148c
    style L1 fill:#fff3e0,stroke:#ff9800,color:#e65100,stroke-width:2px
    style E fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style S fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style B fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style ST fill:#ffe0b2,stroke:#fb8c00,color:#e65100
```

---

## 核心职责

```mermaid
mindmap
  root((加工阶段))
    策略选择
      精简优先 (>500行)
      丰富优先 (<200行)
      均衡模式 (200-500行)
      快速路径跳过 (Type1)
    循环保护
      最大轮次限制 (3)
      循环模式检测
      效率下降预警
    质量门禁
      加工后质量评分 ≥80
      格式规范通过
    与其他阶段接口
      上游: phase-production
      下游: phase-publishing
```

---

## 三种策略模式编排

### 策略一：精简优先 (Simplify-First)

**触发条件**: 初稿 >500 行

```mermaid
flowchart LR
    Input[输入: 冗长初稿] --> S1["simplifier<br/>轻量去重<br/>0.5h"]
    S1 --> S2["enricher<br/>选择性补充<br/>1h"]
    S2 --> S3["standardizer<br/>最终校验<br/>0.5h"]
    S3 --> Output[精炼后技能]
    
    style Input fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
    style Output fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
```

### 策略二：丰富优先 (Enrich-First)

**触发条件**: 初稿 <200 行

```mermaid
flowchart LR
    Input[输入: 简陋初稿] --> E1["enricher<br/>完整丰富<br/>1.5h"]
    E1 --> B1["beautifier<br/>可视化增强<br/>0.5h"]
    B1 --> S3["standardizer<br/>规范化<br/>0.5h"]
    S3 --> Output[丰富后技能]
    
    style Input fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
    style Output fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
```

### 策略三：均衡模式 (Balanced) ⭐ 推荐

**触发条件**: 200-500 行（默认）

```mermaid
flowchart LR
    Input[输入: 中等初稿] --> S1["simplifier<br/>轻量去重<br/>0.5h"]
    S1 --> E2["enricher<br/>按需补充<br/>1-2h"]
    E2 --> B2["beautifier<br/>关键图表<br/>0.5h"]
    B2 --> ST["standardizer<br/>最终校验<br/>0.5h"]
    ST --> Output[均衡优化后技能]
    
    style Input fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Output fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
```

---

## 策略选择决策树

```mermaid
flowchart TD
    Start[接收技能初稿] --> Q{行数?}
    
    Q -->|> 500| Strategy1["📉 精简优先<br/>Simplify-First"]
    Q -->|< 200| Strategy2["📈 丰富优先<br/>Enrich-First"]
    Q -->|200-500| Strategy3["⚖️ 均衡模式<br/>Balanced ⭐推荐"]
    
    Strategy1 & Strategy2 & Strategy3 --> Check{Type 1?}
    
    Check -->|是| Skip["⏭️ 跳过加工<br/>(快速路径)"]
    Check -->|否| Execute["执行选定策略"]
    
    Execute --> Protect{循环检测}
    Protect -->|正常| Process[继续加工]
    Protect -->|检测到循环| Warn["⚠️ 发出警告"]
    Warn --> Decide{用户决定?}
    Decide -->|终止| Done[进入发布阶段]
    Decide -->|继续| Process
    
    style Start fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style Strategy1 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style Strategy2 fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Strategy3 fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style Skip fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style Warn fill:#fce4ec,stroke:#e91e63,color:#880e4f
```

---

## 循环保护机制

### 配置

```yaml
processing_protection:
  max_rounds: 3                    # 最大加工轮次
  circular_detection: true         # 启用循环检测
  efficiency_threshold: 0.05       # 行数变化 <5% 认为无实质改进
  
  circular_patterns:
    - pattern: "enrich→simplify"
      max_consecutive: 2           # 连续2次触发警告
    - pattern: "net_change < 5%"
      trigger: always              # 总是检测
```

### 保护流程

当检测到循环时：
1. ✅ 记录历史（每轮操作和净变化）
2. ⚠️ 发出警告（含效率分析）
3. ❓ 询问用户：终止 or 继续最后一轮？
4. 终止 → 直接进入发布阶段
5. 继续 → 最多再执行 1 轮

---

## 与上下游的关系

```mermaid
sequenceDiagram
    participant PP as phase-production
    participant PROC as phase-processing (本阶段)
    participant PUB as phase-publishing
    
    PP->>PROC: 交付技能包 (质量≥60分)
    
    Note over PROC: 策略选择 (精简/丰富/均衡)
    PROC->>PROC: 执行加工流程 (可选跳过)
    
    alt 正常加工
        PROC-->>PUB: 交付加工后技能 (质量≥80分)
    else 快速路径 (Type1)
        PP-->>PUB: 直接交付 (跳过本阶段)
    end
    
    PUB->>PUB: 接收并开始版本管理
```

---

## 配置参数

```yaml
phase_config:
  name: processing
  layer: 1
  coordinator_type: strategy_selector
  
  strategies:
    simplify_first:
      trigger: "line_count > 500"
      order: [simplifier, enricher, standardizer]
      estimated_time: "2-3h"
      
    enrich_first:
      trigger: "line_count < 200"
      order: [enricher, beautifier, standardizer]
      estimated_time: "3-4h"
      
    balanced:
      trigger: "default"
      order: [simplifier, enricher, beautifier, standardizer]
      estimated_time: "2.5-3.5h"
  
  fast_path:
    enabled: true
    trigger: "type == Type1 (light-thin)"
    action: "完全跳过本阶段"
  
  protection:
    max_rounds: 3
    cooldown_between_rounds: 0
    auto_warn_on_circular: true
```

---

## 参考

- [skill-factory](../SKILL.md) - 工厂根 (Layer 0)
- [skill-factory-phase-production](../skill-factory-phase-production/SKILL.md) - 上游阶段 (Layer 1)
- [skill-factory-phase-publishing](../skill-factory-phase-publishing/SKILL.md) - 下游阶段 (Layer 1)
- [docs/processing-strategies.md](../../docs/processing-strategies.md) - 详细策略定义
- [enricher](../skill-factory-enricher/SKILL.md) - 子技能 (Layer 2)
- [simplifier](../skill-factory-simplifier/SKILL.md) - 子技能 (Layer 2)
- [beautifier](../skill-factory-beautifier/SKILL.md) - 子技能 (Layer 2)
- [standardizer](../skill-factory-standardizer/SKILL.md) - 子技能 (Layer 2)
