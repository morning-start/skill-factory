---
name: skill-factory-generator
version: v0.2.0
author: skill-factory
parent: skill-factory-phase-production
layer: 2
phase: production
description: 技能生成器，基于"轻/重/薄/厚"四维分类生成对应结构的技能文件，支持四种输出模式
tags: [skill-factory, generator, skill-classification]
dependency:
  parent: skill-factory-phase-production
  requires: skill-factory-planner
---

# Skill Factory Generator - 技能生成器

## 职责边界

**负责**：根据拆分计划的类型（轻/重/薄/厚），生成对应目录结构和文件
**不负责**：分析内容（analyzer）、判定类型（planner）、验证打包（packager）

---

## 四种输出模式

```mermaid
flowchart LR
    A[📋 拆分计划] --> B{识别类型}
    
    B -->|"轻+薄"| T1["🟢 类型1<br/>单文件"]
    B -->|"重+薄"| T2["🔵 类型2<br/>子技能族"]
    B -->|"轻+厚"| T3["🟠 类型3<br/>单技能+refs"]
    B -->|"重+厚"| T4["🟣 类型4<br/>混合模式"]
    
    T1 --> G1[生成文件]
    T2 --> G2[生成文件]
    T3 --> G3[生成文件]
    T4 --> G4[生成文件]
    
    G1 --> Check[✅ 自检]
    G2 --> Check
    G3 --> Check
    G4 --> Check
    
    Check --> Output[📦 输出]
    
    style T1 fill:#e8f5e9,stroke:#4caf50
    style T2 fill:#e3f2fd,stroke:#2196f3
    style T3 fill:#fff3e0,stroke:#ff9800
    style T4 fill:#f3e5f5,stroke:#9c27b0
```

---

## 类型 1：轻+薄（简单技能）

**适用**：单一功能 + 内容精简 (<300行)

### 输出结构

```mermaid
graph LR
    A["📁 {name}/"] --> B["📄 SKILL.md ✅<br/><br/>全部内容 <300行<br/>无子目录"]
    
    style A fill:#e8f5e9,stroke:#4caf50,stroke-width:2px
    style B fill:#c8e6c9,stroke:#388e3c
```

### SKILL.md 模板

```markdown
---
name: {name}
version: v0.1.0
author: {author}
description: {100-150字符}
tags: [{tag1}, {tag2}, {tag3}]
---

# {标题}

## 任务目标
- 本 Skill 用于: <一句话>
- 核心能力: <能力列表>
- 触发条件: <何时使用>

## 操作步骤
1. <步骤1>
2. <步骤2>
3. ...

## 使用示例
<完整示例>

## 注意事项
<注意点>
```

### 生成规则

```mermaid
graph TD
    R1["✅ 文件数量: 仅 1 个 SKILL.md"] 
    R2["✅ 正文行数: < 300 行"]
    R3["✅ 无子目录: 不创建 skills/、references/ 等"]
    
    style R1 fill:#c8e6c9,stroke:#388e3c
    style R2 fill:#c8e6c9,stroke:#388e3c
    style R3 fill:#c8e6c9,stroke:#388e3c
```

---

## 类型 2：重+薄（技能族-薄）

**适用**：多模块可独立 + 每个模块都精简

### 输出结构

```mermaid
graph TD
    A["📁 {name}-family/"] --> B["📄 SKILL.md 🎯<br/>母技能（编排器）"]
    A --> C["📁 skills/"]
    C --> D["📁 {子技能1}/SKILL.md"]
    C --> E["📁 {子技能2}/SKILL.md"]
    C --> F["📁 {子技能N}/SKILL.md"]
    
    style A fill:#e3f2fd,stroke:#2196f3,stroke-width:2px
    style B fill:#bbdefb,stroke:#1976d2
    style C fill:#90caf9,stroke:#1565c0
```

### 模板关系

```mermaid
flowchart TB
    subgraph 母技能 SKILL.md
        M1["---<br/>name: {name}-family<br/>dependency:<br/>  children: [子1, 子2]<br/>---"]
        M2["# {名称} Family"]
        M3["| 子技能 | 职责 |"]
    end
    
    subgraph 子技能 SKILL.md
        S1["---<br/>name: {子技能}<br/>parent: {母技能}<br/>requires: {依赖}<br/>---"]
        S2["# {子技能名}"]
        S3["## 职责<br/>**负责**: ..."]
    end
    
    M1 -.-> S1
    
    style M1 fill:#bbdefb,stroke:#1976d2
    style S1 fill:#90caf9,stroke:#1565c0
```

### 生成规则

```mermaid
graph TD
    R1["✅ 母技能必须有 children 列表"]
    R2["✅ 每个子技能 <200 行（薄）"]
    R3["❌ 无 references/"]
    R4["❌ 无 scripts/ (除非特别需要)"]
    
    style R1 fill:#bbdefb,stroke:#1976d2
    style R2 fill:#90caf9,stroke:#1565c0
    style R3 fill:#ffcdd2,stroke:#d32f2f
    style R4 fill:#ffcdd2,stroke:#d32f2f
```

---

## 类型 3：轻+厚（复杂单技能）

**适用**：单一功能 + 内容丰富 (>300行)

### 输出结构

```mermaid
graph TD
    A["📁 {name}/"] --> B["📄 SKILL.md 📋<br/>概览+索引 ~150行"]
    A --> C["📁 references/ 📚"]
    A --> D["📁 scripts/ 🔧 可选"]
    A --> E["📁 templates/ 📄 可选"]
    
    C --> C1["implementation.md"]
    C --> C2["api-reference.md"]
    C --> C3["examples.md"]
    C --> C4["..."]
    
    style A fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    style B fill:#ffe0b2,stroke:#f57c00
    style C fill:#ffcc80,stroke:#ef6c00
```

### 文档层次关系

```mermaid
flowchart TB
    subgraph "SKILL.md (~150行)"
        M1["## 任务目标"]
        M2["## 快速开始"]
        M3["## 内容索引 → references/"]
    end
    
    subgraph "references/"
        R1["implementation.md<br/>实现细节"]
        R2["api-reference.md<br/>API 参数"]
        R3["examples.md<br/>使用示例"]
    end
    
    M3 --> R1
    M3 --> R2
    M3 --> R3
    
    style M1 fill:#ffe0b2,stroke:#f57c00
    style R1 fill:#ffcc80,stroke:#ef6c00
```

### 生成规则

```mermaid
graph TD
    R1["✅ SKILL.md ~150行（仅概览+索引）"]
    R2["✅ references/ 至少 2 个 .md 文件"]
    R3["✅ 索引完整性：所有链接指向存在的文件"]
    R4["⚠️ scripts/ 仅当有自动化操作时"]
    R5["⚠️ templates/ 仅当有初始化模板时"]
    
    style R1 fill:#ffe0b2,stroke:#f57c00
    style R2 fill:#ffe0b2,stroke:#f57c00
    style R3 fill:#ffe0b2,stroke:#f57c00
    style R4 fill:#fff9c4,stroke:#fbc02d
    style R5 fill:#fff9c4,stroke:#fbc02d
```

---

## 类型 4：重+厚（技能族-厚）⭐

**适用**：多模块可独立 + 部分模块内容丰富

### 输出结构

```mermaid
graph TD
    A["📁 {name}-family/"] --> B["📄 SKILL.md 🎯<br/>母技能"]
    A --> C["📄 metadata.json"]
    A --> D["📁 templates/ 可选"]
    A --> E["📁 skills/"]
    
    E --> F["📁 {薄子技能}/ 📝"]
    E --> G["📁 {厚子技能}/ 📚"]
    
    F --> F1["📄 SKILL.md 单文件"]
    
    G --> G1["📄 SKILL.md 概览"]
    G --> G2["📁 references/ 详细文档"]
    G --> G3["📁 scripts/ 可选"]
    G --> G4["📁 templates/ 可选"]
    
    G2 --> G2a["topic1.md"]
    G2 --> G2b["topic2.md"]
    
    style A fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px
    style B fill:#e1bee7,stroke:#7b1fa2
    style F fill:#e1bee7,stroke:#7b1fa2
    style G fill:#ce93d8,stroke:#8e24aa
```

### 混合模式说明

```mermaid
flowchart TB
    subgraph "母技能"
        P["SKILL.md 🎯<br/>children 列表<br/>含 thin/thick 标注"]
    end
    
    subgraph "薄子技能 (thin)"
        Thin["SKILL.md only<br/>简单直接"]
    end
    
    subgraph "厚子技能 (thick)"
        Thick["SKILL.md + references/<br/>内容分层"]
    end
    
    P --> Thin
    P --> Thick
    
    style P fill:#e1bee7,stroke:#7b1fa2
    style Thin fill:#f3e5f5,stroke:#9c27b0
    style Thick fill:#ce93d8,stroke:#8e24aa
```

### 生成规则

```mermaid
graph TD
    R1["✅ 分类明确：每个子技能标注 thin 或 thick"]
    R2["✅ 薄子技能：单文件，无额外目录"]
    R3["✅ 厚子技能：有 SKILL.md + references/"]
    R4["✅ 共享资源：templates/ 放在母级或各子技能内"]
    
    style R1 fill:#e1bee7,stroke:#7b1fa2
    style R2 fill:#f3e5f5,stroke:#9c27b0
    style R3 fill:#ce93d8,stroke:#8e24aa
    style R4 fill:#f3e5f5,stroke:#9c27b0
```

---

## 通用自检清单

```mermaid
flowchart TD
    Start([生成完成]) --> Check{自检}
    
    Check --> All["检查项"]
    
    All --> A1["✅ 前言区字段完整<br/>(name/version/description/tags)"]
    All --> A2["✅ 文件数量与计划一致"]
    All --> A3["✅ parent/requires 指向正确"]
    
    Check --> Type2or4{"类型2或4？"}
    Type2or4 -->|Yes| B1["✅ children 列表匹配"]
    Type2or4 -->|No| Skip1[跳过]
    
    Check --> Type3or4{"类型3或4？"}
    Type3or4 -->|Yes| C1["✅ 索引链接有效"]
    Type3or4 -->|No| Skip2[跳过]
    
    Type3or4 --> D1["✅ references/ 存在且非空"]
    
    A1 & A2 & A3 & B1 & C1 & D1 & Skip1 & Skip2 --> Pass([✅ 通过])
    
    style All fill:#e3f2fd,stroke:#2196f3
    style Pass fill:#e8f5e9,stroke:#4caf50
```

| 类型 | 必检项 |
|------|--------|
| **全部** | 前言区字段完整 (name/version/description/tags) |
| **全部** | 文件数量与计划一致 |
| **全部** | parent/requires 指向正确 |
| **类型2/4** | children 列表与实际匹配 |
| **类型3/4** | 索引链接有效 |
| **类型3/4** | references/ 文件存在且非空 |

---

## 参考

- [skill-factory](../../SKILL.md) - 母技能（四维分类说明）
- [skill-factory-packager](../skills/skill-factory-packager/SKILL.md) - 下游验证
