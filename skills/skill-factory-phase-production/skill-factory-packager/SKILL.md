---
name: skill-factory-packager
version: v0.2.0
author: skill-factory
parent: skill-factory-phase-production
layer: 2
phase: production
description: 技能打包器，基于"轻/重/薄/厚"四维分类验证技能结构完整性，支持四种验证模式和快速验证模式
tags: [skill-factory, packager, validation]
dependency:
  parent: skill-factory-phase-production
  requires: skill-factory-generator
---

# Skill Factory Packager - 技能打包器

## 职责边界

**负责**：识别技能类型 → 验证对应结构 → 输出报告
**不负责**：分析内容（analyzer）、判定类型（planner）、生成文件（generator）

---

## 四种验证模式

```mermaid
flowchart LR
    A[📁 技能目录] --> B{识别类型}
    
    B -->|"轻+薄"| T1["🟢 类型1<br/>单文件验证"]
    B -->|"重+薄"| T2["🔵 类型2<br/>技能族-薄验证"]
    B -->|"轻+厚"| T3["🟠 类型3<br/>复杂单技能验证"]
    B -->|"重+厚"| T4["🟣 类型4<br/>混合模式验证"]
    
    T1 --> V1[✅ 结构检查]
    T2 --> V2[✅ 结构检查]
    T3 --> V3[✅ 结构检查]
    T4 --> V4[✅ 结构检查]
    
    V1 & V2 & V3 & V4 --> Score[📊 质量评分]
    Score --> Report[📋 输出报告]
    
    style T1 fill:#e8f5e9,stroke:#4caf50
    style T2 fill:#e3f2fd,stroke:#2196f3
    style T3 fill:#fff3e0,stroke:#ff9800
    style T4 fill:#f3e5f5,stroke:#9c27b0
```

---

## 类型 1：轻+薄（简单技能）验证

### 必须存在的结构

```mermaid
graph LR
    A["📁 {name}/"] --> B["📄 SKILL.md ✅<br/><br/>唯一文件<br/><300行"]
    
    style A fill:#e8f5e9,stroke:#4caf50,stroke-width:2px
    style B fill:#c8e6c9,stroke:#388e3c
```

### 验证项

```mermaid
flowchart TD
    Check["类型1 验证"]
    
    Check --> C1["✅ SKILL.md 存在"]
    Check --> C2["❌ 无 skills/ 目录"]
    Check --> C3["❌ 无 references/ 目录"]
    Check --> C4["✅ 正文行数 < 300 行"]
    Check --> C5["✅ 前言区完整"]
    
    C1 & C2 & C3 & C4 & C5 --> Pass([✅ 通过])
    
    style Check fill:#e8f5e9,stroke:#4caf50
    style C1 fill:#c8e6c9,stroke:#388e3c
    style C2 fill:#ffcdd2,stroke:#d32f2f
    style C3 fill:#ffcdd2,stroke:#d32f2f
    style C4 fill:#c8e6c9,stroke:#388e3c
    style C5 fill:#c8e6c9,stroke:#388e3c
    style Pass fill:#a5d6a7,stroke:#2e7d32
```

| 检查项 | 标准 |
|--------|------|
| SKILL.md 存在 | ✅ 必需 |
| 无 skills/ 目录 | ✅ 不应有 |
| 无 references/ 目录 | ✅ 不应有 |
| 正文行数 | < 300 行 |
| 前言区完整 | name/version/description/tags |

---

## 类型 2：重+薄（技能族-薄）验证

### 必须存在的结构

```mermaid
graph TD
    A["📁 {name}-family/"] --> B["📄 SKILL.md 🎯<br/>母技能（含 children）"]
    A --> C["📁 skills/"]
    C --> D["📁 {子技能}/SKILL.md ×N"]
    
    style A fill:#e3f2fd,stroke:#2196f3,stroke-width:2px
    style B fill:#bbdefb,stroke:#1976d2
    style C fill:#90caf9,stroke:#1565c0
```

### 验证项

```mermaid
flowchart TD
    Check["类型2 验证"]
    
    Check --> C1["✅ 母技能 SKILL.md 存在"]
    Check --> C2["✅ 含 children 列表"]
    Check --> C3["✅ skills/ 目录存在"]
    Check --> C4["✅ 子技能数 ≥ 1"]
    Check --> C5["✅ 每个子技能有 SKILL.md"]
    Check --> C6["❌ 子技能无 references/"]
    Check --> C7["✅ children 与实际匹配"]
    Check --> C8["✅ parent 指向正确"]
    
    C1 & C2 & C3 & C4 & C5 & C6 & C7 & C8 --> Pass([✅ 通过])
    
    style Check fill:#e3f2fd,stroke:#2196f3
    style Pass fill:#90caf9,stroke:#1565c0
```

| 检查项 | 标准 |
|--------|------|
| 母技能 SKILL.md | 存在，含 children 列表 |
| skills/ 目录 | 存在 |
| 子技能数量 | ≥ 1 个 |
| 每个子技能有 SKILL.md | ✅ |
| 子技能无 references/ | ✅ （薄=单文件） |
| children 一致 | 与实际子技能匹配 |
| parent 指向 | 子技能 → 母技能 |

---

## 类型 3：轻+厚（复杂单技能）验证

### 必须存在的结构

```mermaid
graph TD
    A["📁 {name}/"] --> B["📄 SKILL.md 📋<br/>概览+索引 ~150行"]
    A --> C["📁 references/ 📚 (≥2个)"]
    A --> D["📁 scripts/ 🔧 可选"]
    A --> E["📁 templates/ 📄 可选"]
    
    C --> C1["implementation.md"]
    C --> C2["api-reference.md"]
    C --> C3["examples.md"]
    
    style A fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    style B fill:#ffe0b2,stroke:#f57c00
    style C fill:#ffcc80,stroke:#ef6c00
```

### 验证项

```mermaid
flowchart TD
    Check["类型3 验证"]
    
    subgraph 必需检查
        C1["✅ SKILL.md 存在"]
        C2["✅ 含索引表 → references/"]
        C3["✅ references/ 目录存在"]
        C4["✅ references 文件数 ≥ 2"]
        C5["✅ 索引链接有效"]
        C6["✅ 内容充实度 >500字符"]
        C7["❌ skills/ 不存在"]
    end
    
    subgraph 可选检查
        O1["⚠️ scripts/ 如存在则有效"]
        O2["⚠️ templates/ 如存在则正确"]
        O3["⚠️ assets/ 如存在则有效"]
    end
    
    C1 & C2 & C3 & C4 & C5 & C6 & C7 & O1 & O2 & O3 --> Pass([✅ 通过])
    
    style Check fill:#fff3e0,stroke:#ff9800
    style Pass fill:#ffcc80,stroke:#ef6c00
```

| 检查项 | 标准 |
|--------|------|
| SKILL.md 存在 | ✅ 必需 |
| SKILL.md 含索引表 | ✅ （指向 references/） |
| references/ 目录 | 存在 |
| references 文件数 | ≥ 2 个 .md |
| 索引链接有效 | 所有链接指向存在的文件 |
| 内容充实度 | references 总量 > 500 字符 |
| skills/ 不存在 | ✅ （轻=不拆分） |

---

## 类型 4：重+厚（技能族-厚）验证 ⭐

### 必须存在的结构

```mermaid
graph TD
    A["📁 {name}-family/"] --> B["📄 SKILL.md 🎯<br/>母技能"]
    A --> C["📄 metadata.json 推荐"]
    A --> D["📁 templates/ 可选"]
    A --> E["📁 skills/"]
    
    E --> F["📁 {薄子技能}/ 📝"]
    E --> G["📁 {厚子技能}/ 📚"]
    
    F --> F1["📄 SKILL.md 单文件"]
    
    G --> G1["📄 SKILL.md 概览"]
    G --> G2["📁 references/ 详细文档"]
    G --> G3["📁 scripts/ 可选"]
    G --> G4["📁 templates/ 可选"]
    
    style A fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px
    style B fill:#e1bee7,stroke:#7b1fa2
    style F fill:#f3e5f5,stroke:#9c27b0
    style G fill:#ce93d8,stroke:#8e24aa
```

### 验证项

#### A. 通用验证

```mermaid
flowchart TD
    A["通用验证"]
    A --> A1["✅ 母技能 SKILL.md 存在"]
    A --> A2["✅ skills/ 目录存在"]
    A --> A3["✅ 子技能总数 ≥ 1"]
    A --> A4["✅ 每个子技能有 SKILL.md"]
    A --> A5["✅ children 列表一致"]
    
    A1 & A2 & A3 & A4 & A5 --> APass([通用通过])
    
    style A fill:#f3e5f5,stroke:#9c27b0
    style APass fill:#e1bee7,stroke:#7b1fa2
```

#### B. 子技能分类验证

```mermaid
flowchart TD
    B["子技能分类验证"]
    
    B --> B1{"子技能类型?"}
    
    B1 -->|"薄子技能"| ThinCheck
    B1 -->|"厚子技能"| ThickCheck
    
    subgraph ThinCheck["薄子技能检查"]
        T1["✅ 只有 SKILL.md"]
        T2["❌ 无 references/"]
    end
    
    subgraph ThickCheck["厚子技能检查"]
        TH1["✅ 有 SKILL.md + references/"]
        TH2["✅ references/ 有 ≥1 个 .md"]
        TH3["✅ 含内容索引表"]
    end
    
    T1 & T2 & TH1 & TH2 & TH3 --> BPass([分类通过])
    
    style B fill:#ce93d8,stroke:#8e24aa
    style BPass fill:#e1bee7,stroke:#7b1fa2
```

| 检查项 | 标准 |
|--------|------|
| **薄子技能** | 只有 SKILL.md，无 references/ |
| **厚子技能** | 有 SKILL.md + references/ + ≥1 个 .md |
| **厚子技能索引** | SKILL.md 内含内容索引表 |

#### C. 混合模式专项检查

```mermaid
flowchart TD
    C["混合模式专项检查"]
    
    C --> C1["✅ 分类合理性<br/>应拆的已拆，应分层的已分层"]
    C --> C2["✅ 索引完整性<br/>所有厚子技能链接有效"]
    C --> C3["✅ 无冗余<br/>无错误拆分的 references"]
    C -> C4["✅ 共享资源位置合理"]
    
    C1 & C2 & C3 & C4 --> CPass([专项通过])
    
    style C fill:#ba68c8,stroke:#7b1fa2
    style CPass fill:#e1bee7,stroke:#7b1fa2
```

| 检查项 | 标准 |
|--------|------|
| 分类合理性 | 应拆的已拆为子技能（重），应分层已在 references（厚） |
| 索引完整性 | 所有厚子技能的索引链接全部有效 |
| 无冗余 | 不存在本应是 references 的内容被错误拆成子技能 |
| 共享资源 | templates/ 在母级或各子技能内位置合理 |

---

## 通用验证：前言区检查

### 标准字段（所有类型）

```mermaid
flowchart LR
    subgraph 前言区必填字段
        F1["name ✅<br/>kebab-case"]
        F2["version ✅<br/>vX.X.X"]
        F3["author ✅<br/>非空"]
        F4["description ✅<br/>100-150字符"]
        F5["tags ✅<br/>≥3个标签"]
        F6["dependency ⚠️<br/>类型2/4需要"]
    end
    
    style F1 fill:#c8e6c9,stroke:#388e3c
    style F2 fill:#c8e6c9,stroke:#388e3c
    style F3 fill:#c8e6c9,stroke:#388e3c
    style F4 fill:#c8e6c9,stroke:#388e3c
    style F5 fill:#c8e6c9,stroke:#388e3c
    style F6 fill:#fff9c4,stroke:#fbc02d
```

| 字段 | 必须 | 格式要求 |
|------|------|----------|
| name | ✅ | kebab-case |
| version | ✅ | vX.X.X |
| author | ✅ | 非空 |
| description | ✅ | 100-150 字符 |
| tags | ✅ | ≥ 3 个标签 |
| dependency | 类型2/4 需要 | 含 parent + children/requires |

### 版本号格式

- ✅ `v1.0.0`、`v2.1.3`
- ❌ `v1.0`、`v1`、`1.0.0`

---

## 质量评分

### 评分维度

```mermaid
pie title 评分维度权重分布
    "结构完整性" : 25
    "前言区完整性" : 25
    "关系正确性" : 25
    "内容充实度" : 25
```

| 维度 | 权重 | 说明 |
|------|------|------|
| 结构完整性 | 25% | 对应类型的必需文件/目录是否齐全 |
| 前言区完整性 | 25% | 标准字段是否齐全且格式正确 |
| 关系正确性 | 25% | parent/requires/children/索引链接是否正确 |
| 内容充实度 | 25% | 文件内容是否有实质内容（>200字符） |

### 评分等级

```mermaid
flowchart LR
    S1["🥇 优秀<br/>90-100分"] --> R1["✅ 直接通过"]
    S2["🥈 良好<br/>70-89分"] --> R2["✅ 通过 + 建议"]
    S3["🥉 合格<br/>60-69分"] --> R3["✅ 通过 + 必须修复"]
    S4["❌ 不合格<br/><60分"] --> R4["返回 generator"]
    
    style S1 fill:#a5d6a7,stroke:#2e7d32
    style S2 fill:#fff9c4,stroke:#fbc02d
    style S3 fill:#ffcc80,stroke:#ef6c00
    style S4 fill:#ffcdd2,stroke:#d32f2f
```

| 总分 | 等级 | 处理方式 |
|------|------|----------|
| 90-100 | 🥇 优秀 | 通过 |
| 70-89 | 🥈 良好 | 通过 + 改进建议 |
| 60-69 | 🥉 合格 | 通过 + 必须修复项 |
| <60 | ❌ 不合格 | 返回 generator 修复 |

---

## 输出格式

```markdown
## 技能打包验证报告

### 基本信息
- **技能名称**: {名称}
- **判定类型**: light-thin / heavy-thin / light-thick / **heavy-thick**
- **验证时间**: {时间}

### 结构验证结果

#### 类型 {N} 专项检查
| 检查项 | 标准 | 实际 | 状态 |
|--------|------|------|------|
| {项目} | {标准} | {实际} | ✅ / ❌ |

{如为类型4，显示子技能分类}
#### 子技能分类（仅类型4）
| 子技能 | 判定类型 | 结构 | references数 | 状态 |
|--------|----------|------|--------------|------|
| {子技能A} | thin | 单文件 | 0 | ✅ |
| {子技能B} | thick | 多文件 | 3 | ✅ |

### 关系验证
| 验证项 | 状态 |
|--------|------|
| parent 指向 | ✅ |
| requires 依赖 | ✅ |
| children 列表一致性 | ✅ |
| 索引链接有效性 | ✅ |

### 质量评分
| 维度 | 得分 | 加权分 |
|------|------|--------|
| 结构完整性 | XX | XX |
| 前言区完整性 | XX | XX |
| 关系正确性 | XX | XX |
| 内容充实度 | XX | XX |
| **总分** | | **XX** |

**等级**: 🥇/🥈/🥉/❌

### 结论
✅ 通过 / ❌ 需修复: {问题列表}
```

---

## 失败处理流程

```mermaid
flowchart TD
    Fail(["验证失败"]) --> Reason{失败原因?}
    
    Reason -->|"结构缺失"| R1["→ 返回 generator 补充"]
    Reason -->|"前言区缺失"| R2["→ 返回 generator 修复"]
    Reason -->|"循环依赖"| R3["→ 返回 planner 重新设计"]
    Reason -->|"索引链接断裂"| R4["→ 返回 generator 修复"]
    Reason -->|"类型判定错误"| R5["→ 返回 planner 重新判定"]
    Reason -->|"评分 <60"| R6["→ 返回 generator 修复"]
    
    style Fail fill:#ffcdd2,stroke:#d32f2f
    style R1 fill:#bbdefb,stroke:#1976d2
    style R2 fill:#bbdefb,stroke:#1976d2
    style R3 fill:#fff9c4,stroke:#fbc02d
    style R4 fill:#bbdefb,stroke:#1976d2
    style R5 fill:#fff9c4,stroke:#fbc02d
    style R6 fill:#bbdefb,stroke:#1976d2
```

| 场景 | 处理 |
|------|------|
| 结构缺失 | 返回 generator 补充 |
| 前言区缺失 | 返回 generator 修复 |
| 循环依赖 | 返回 planner 重新设计 |
| 索引链接断裂 | 返回 generator 修复 |
| 类型判定错误 | 返回 planner 重新判定（如：薄子技能有 references） |
| 评分 <60 | 返回 generator 修复 |

---

## 参考

- [skill-factory](../../SKILL.md) - 母技能（四维分类说明）

---

## 快速验证模式 (Type 1 专用) - v0.2.0 新增

当技能被判定为 **Type 1（轻+薄）** 时，使用快速验证模式：

```yaml
type_1_quick_check:
  适用条件:
    - 判定类型: 轻+薄
    - 输出结构: 单个 SKILL.md 文件
    - 预期行数: < 300 行

  检查项:
    must_have:
      - frontmatter_exists: "前言区存在且格式正确"
      - single_file_valid: "仅有 SKILL.md，无 skills/ 或 references/"
      - description_length_ok: "100-150字符"
      - at_least_2_examples: "至少包含2个使用示例"

  验证阈值:
    quality_score_threshold: 80  # 保持与标准模式一致
    estimated_time: "3min"       # vs 标准模式的15min (-80%)

  失败处理:
    score_60_79: "通过 + 建议后续优化（可进入发布）"
    score_below_60: "返回 generator 修复（或降级为标准路径）"
```

### 快速验证 vs 标准验证对比

| 维度 | 标准验证 | 快速验证 (Type 1) |
|------|---------|-------------------|
| **检查项数量** | 15-20 项 | **5 项**（核心必填） |
| **验证范围** | 全量结构检查 | **最小必要集** |
| **预计耗时** | 10-15 min | **3 min** |
| **详细程度** | 详细报告 | **简化报告** |
| **失败处理** | 返回修复 | **修复 or 降级** |

### 快速验证流程图

```mermaid
flowchart TD
    Input["Type 1 技能"] --> Quick{"快速验证<br/>(5项核心)"}

    Quick -->|≥80分| Pass["✅ 通过<br/>直接发布"]
    Quick -->|60-79分| Warn["⚠️ 通过+建议<br/>可发布"]
    Quick -->|<60分| Fail{"选择?"}

    Fail --> Fix["返回 generator 修复"]
    Fail --> Fallback["降级为标准路径"]

    style Input fill:#c8e6c9,stroke:#388e3c,color:#1b5e20
    style Quick fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Pass fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style Warn fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style Fail fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c
    style Fix fill:#bbdefb,stroke:#1976d2,color:#0d47a1
    style Fallback fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
```

### 快速验证输出报告（简化版）

```markdown
## Type 1 快速验证报告

### 基本信息
- **技能名称**: {name}
- **判定类型**: light-thin
- **验证时间**: {time}
- **验证模式**: 🚀 快速验证 (3min)

### 核心检查结果
| 检查项 | 状态 | 备注 |
|--------|------|------|
| 前言区完整 | ✅ / ❌ | |
| 单文件结构 | ✅ / ❌ | 无 skills/references |
| description 长度 | ✅ / ❌ | XX字符 |
| 示例数量 | ✅ / ❌ | X 个 |

### 质量评分
- **总分**: XX / 100
- **等级**: 🥇🥈🥉❌

### 结论
✅ 可直接发布 / ⚠️ 建议优化后发布 / ❌ 需修复
```
