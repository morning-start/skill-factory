# 工厂架构详细说明

> **来源**: [../SKILL.md](../SKILL.md) → 工厂全景架构 / 四维分类 / 发布路径  
> **版本**: v0.3.0

---

## 三层架构优势与实践收益

```mermaid
mindmap
  root((三层架构优势))
    层次清晰
      目录即层次
      自解释架构
      新用户易理解
    职责分离
      publisher三件套归属明确
      阶段内依赖局部化
      跨阶段接口清晰
    可扩展性强
      每阶段独立扩展
      新增子技能归位清晰
      支持50+子技能规模
    便于维护
      阶段级配置集中
      错误处理分层
      测试按层组织
```

> **💡 与"为什么是三层？"的关系**：[铁律说明](./three-layer-iron-rule.md) 阐述理论基础（认知科学+软件工程），本节聚焦**工程实践收益**。两者互补：理论指导设计，实践验证价值。

---

## 四阶段定位

| 阶段 | 类比现实工厂 | 输入 | 输出 | 核心问题 |
|------|------------|------|------|---------|
| **① 生产** | 原料→成品 | 文档/URL/需求 | SKILL.md 技能包 | 怎么造？ |
| **② 加工** | 成品→精加工 | 已有技能 | 升级后的技能 | 怎么改？ |
| **③ 发布** | 质检→出厂 | 加工后技能 | 版本发布记录 | 怎么发？ |
| **④ 销毁** | 退役→回收 | 过时技能 | deprecated 标记 | 怎么废？ |

---

## 四维分类体系详细

```mermaid
flowchart TB
    subgraph 四维分类法
        direction LR
        L1["功能维度<br/>━━━━━━━━<br/>轻 单一功能<br/>重 多模块"]
        L2["内容维度<br/>━━━━━━━━<br/>厚 内容丰富<br/>薄 内容精简"]
    end
    
    Q1["轻+薄 简单技能<br/>单文件 SKILL.md"]
    Q2["重+薄 技能族-薄<br/>skills 子目录"]
    Q3["轻+厚 复杂单技能<br/>SKILL.md + refs"]
    Q4["重+厚 技能族-厚<br/>混合模式"]

    style Q1 fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style Q2 fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style Q3 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style Q4 fill:#f3e5f5,stroke:#9c27b0,color:#4a148c
```

| 维度 | 定义 | 判断标准 | 输出结构 |
|------|------|---------|---------|
| **轻** | 功能单一 | 1 个核心能力 | 单个 SKILL.md |
| **重** | 功能复杂 | 多个模块，可独立使用 | `skills/{子}/SKILL.md` |
| **薄** | 内容精简 | <300 行能描述清楚 | 无需额外文件 |
| **厚** | 内容丰富 | 需要详细说明/示例/代码 | `references/` + 可选 `scripts/` |

---

## 发布路径选择详细

### 路径矩阵

| 技能类型 | 推荐路径 | 流程步骤 | 预计耗时 | 效率提升 |
|---------|---------|---------|---------|---------|
| **Type 1 (轻+薄)** | 🚀 **快速路径** | 生产→发布 | **30-40min** | **+85%** |
| Type 2 (重+薄) | 📋 标准路径 | 生产→选择性加工→发布 | 2h | - |
| Type 3 (轻+厚) | 📋 标准路径 | 生产→加工→发布 | 3h | - |
| Type 4 (重+厚) | 🔄 完整路径 | 生产→全量加工→发布+监控 | 5h+ | - |

---

### 快速路径详细流程 (Type 1 专用)

```mermaid
flowchart LR
    subgraph 快速路径 ["🚀 Type 1 快速路径 (~35min)"]
        direction TB
        S1["Step 1: Researcher<br/>输入收集 (10min)"]
        S2["Step 2: Analyzer<br/>技术分析 (5min)"]
        S3["Step 3: Planner<br/>类型判定=Type 1 (5min)"]
        S4["Step 4: Generator<br/>生成单文件 (5min)"]
        S5["Step 5: Packager<br/>快速验证 (3min)"]

        S1 --> S2 --> S3 --> S4 --> S5

        S5 -->|跳过加工| SKIP["⏭️ 跳过阶段二"]

        SKIP --> S6["Step 6: Publisher-Version<br/>v0.1.0 → v0.1.1 (2min)"]
        S6 --> S7["Step 7: Publisher-Metadata<br/>更新描述/标签 (2min)"]
        S7 --> S8["Step 8: Publisher-Release<br/>git commit (3min)"]
        S8 --> Done["✅ 完成!"]
    end

    style S1 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style S2 fill:#c5cae9,stroke:#303f9f,color:#1a237e
    style S3 fill:#bbdefb,stroke:#1976d2,color:#0d47a1
    style S4 fill:#90caf9,stroke:#1565c0,color:#ffffff
    style S5 fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style SKIP fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style S6 fill:#64b5f6,stroke:#1976d2,color:#ffffff
    style S7 fill:#42a5f5,stroke:#1976d2,color:#ffffff
    style S8 fill:#2196f3,stroke:#1565c0,color:#ffffff
    style Done fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
```

---

### 路径选择决策树

```mermaid
flowchart TD
    Start[创建新技能] --> Planner{Planner 判定类型}

    Planner -->|"Type 1<br/>轻+薄"| FastPath["🚀 快速路径<br/>跳过加工阶段"]
    Planner -->|"Type 2/3/4"| StandardPath["📋 标准路径<br/>完整流程"]

    FastPath --> QuickCheck["Packager 快速验证<br/>阈值: ≥80分"]
    QuickCheck --> Pass{通过?}
    Pass -->|是| DirectPublish["直接进入发布阶段"]
    Pass -->|否| Fallback["降级为标准路径"]

    StandardPath --> Process["执行加工策略<br/>精简/丰富/均衡"]
    Process --> FullCheck["Packager 完整验证"]
    FullCheck --> Publish["进入发布阶段"]

    style FastPath fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style StandardPath fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style DirectPublish fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
```

---

### Type 1 判定标准（快速路径准入）

```yaml
type_1_criteria:
  功能维度: "轻"  # 单一核心能力
  内容维度: "薄"  # <300行可描述清楚
  输出结构: "单个 SKILL.md 文件"
  复杂度评估:
    示例数量: "<= 3 个"
    决策分支: "<= 2 个"
    外部依赖: "无或极少"

fast_path_requirements:
  - ✅ 前言区完整（name/version/description/tags）
  - ✅ 单文件 SKILL.md（无 skills/ 或 references/）
  - ✅ 正文 < 300 行
  - ✅ Packager 快速验证 ≥ 80 分
  - ⏭️ 跳过 Enricher/Simplifier/Beautifier/Standardizer
```

---

## 物理目录结构

```
skills/
├── phase-production/     ← Layer 1 + Layer 2 (5 workers)
├── phase-processing/     ← Layer 1 + Layer 2 (4 workers)
├── phase-publishing/     ← Layer 1 + Layer 2 (3 workers)
└── phase-destruction/    ← Layer 1 + Layer 2 (1 worker)
```

---

## 相关链接

- [skill-factory 主文件](../SKILL.md)
- [三层架构铁律详情](./three-layer-iron-rule.md)
- [超三层处理 SOP](./over-three-layer-sop.md)
