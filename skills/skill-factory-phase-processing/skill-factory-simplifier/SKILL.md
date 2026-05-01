---
name: skill-factory-simplifier
version: v0.2.0
author: skill-factory
parent: skill-factory-phase-processing
layer: 2
phase: processing
description: 技能简化器，合并去重、语言精炼、摘要提取、原子拆分
tags: [skill-factory, simplifier, refinement]
dependency:
  parent: skill-factory-phase-processing
---

# Skill Factory Simplifier - 技能简化器

## 职责边界

**负责**: 精简冗余内容，使技能更精炼高效
**不负责**: 内容丰富（enricher）、类型判定（planner）、删除有用信息

---

## 加工流程

```mermaid
flowchart TD
    Input[输入已有技能] --> A[分析冗余度]
    A --> B{简化策略?}
    
    B -->|重复内容多| O1[合并去重]
    B -->|表述冗余| O2[语言精炼]
    B -->|单文件过长| O3[摘要提取]
    B -->|职责过多| O4[原子拆分]
    
    O1 --> E[评估结果]
    O2 --> E
    O3 --> E
    O4 --> E
    
    E --> Output[输出简化后的技能]

    style Input fill:#fff3e0,stroke:#ff9800,color:#e65100
    style O1 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style O2 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style O3 fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style O4 fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style Output fill:#fff3e0,stroke:#ff9800,color:#e65100
```

---

## 操作一：合并去重

### 冗余检测

| 冗余类型 | 检测方法 | 处理方式 |
|---------|---------|---------|
| 重复描述 | 同一概念多次说明 | 保留最完整的版本 |
| 重复示例 | 相似示例多个 | 合并为一个通用示例 |
| 重复章节 | 内容重叠的章节 | 合并到同一章节下 |
| 循环引用 | A 引用 B，B 又引用 A | 打破循环，单向引用 |

### 操作原则

1. **保留信息量最大的版本**
2. **合并时标注来源**（如需要追溯）
3. **验证合并后逻辑一致性**

---

## 操作二：语言精炼

### 冗余模式识别

| 冗余模式 | 示例 | 精炼后 |
|---------|------|--------|
| 同义反复 | "用户输入的用户名" | "用户名" |
| 过度限定 | "首先第一步先做的是" | "第一步：" |
| 空话套话 | "值得注意的是我们需要注意" | "注意：" |
| 重复连接词 | "并且和以及" | "和" |

### 精炼规则

1. 删除无信息的修饰语
2. 用短句替代长句
3. 用表格替代列表式描述
4. 用 Mermaid 图替代纯文字流程描述

### 目标

```
精炼后行数减少 >= 20%
语义完整性保持不变
```

---

## 操作三：摘要提取（薄化）

### 适用条件

- 当前类型为轻+厚 或 重+厚
- 主文件超过 200 行
- references 已存在或可以创建

### 操作步骤

```mermaid
flowchart LR
    A[原文 SKILL.md] --> B[识别核心内容]
    B --> C[提取概要 ~150行]
    C --> D[创建 references/]
    D --> E[移入详细内容]
    E --> F[重写索引链接]

    style A fill:#fff3e0,stroke:#ff9800,color:#e65100
    style F fill:#ffe0b2,stroke:#fb8c00,color:#e65100
```

1. **保留在主文件的内容**:
   - 任务目标（精简版）
   - 快速开始（3-5 步）
   - 内容索引表

2. **移入 references 的内容**:
   - 详细操作步骤
   - 完整使用示例
   - API 参数说明
   - 边缘情况处理

### 效果

**厚 → 薄** (主文件从厚变薄)

---

## 操作四：原子拆分（轻量化）

### 适用条件

- 核心能力 > 5 个
- 不同能力面向不同用户
- 部分能力可独立复用

### 与 enricher 的区别

| 维度 | simplifier 拆分 | enricher 扩展 |
|------|----------------|-------------|
| 方向 | 从复杂→简单 | 从简单→复杂 |
| 目标 | 每个子更轻 | 能力更全 |
| 结果 | 重→多个轻 | 轻→重 |

### 操作步骤

1. **能力盘点**
   ```yaml
   原技能:
     capabilities:
       - name: 能力A
         users: [用户群X]
         can_standalone: true
       - name: 能力B
         users: [用户群Y]
         can_standalone: true
   ```

2. **设计拆分方案**
   - 每个子技能单一职责
   - 子技能间松耦合
   - 公共部分放入协调器

3. **执行拆分**
   - 创建 skills/ 子目录
   - 编写各子技能（目标: 轻+薄）
   - 原文件改为协调器

### 效果

**重 → 多个轻** (确定类型变化)

---

## 操作四扩展：拆分方案详细设计流程

当原子拆分的复杂度较高时，使用以下完整设计流程：

### 拆分触发条件检查

| 条件 | 说明 | 建议 |
|------|------|------|
| 能力 >5 个 | 职责过多 | 强烈建议拆分 |
| 不同用户群体 | 面向不同场景 | 建议拆分 |
| 部分可独立复用 | 有复用价值 | 建议拆分 |
| 单子技能 >300 行 | 内容臃肿 | 考虑对该子薄→厚 |

### Step 1：提取能力清单并标注类型

```yaml
原技能分析:
  name: <原技能名>
  current_type: <重+厚 / 重+薄 / 轻+厚>
  capabilities:
    - name: <能力1>
      can_standalone: <是/否>
      content_size: <大约行数>
      needs_detail: <是/否>
    - name: <能力2>
      can_standalone: <是/否>
      content_size: <大约行数>
      needs_detail: <是/否>
```

### Step 2：识别拆分点

| 拆分维度 | 说明 | 示例 |
|---------|------|------|
| 功能 | 按功能模块拆分 | 读取/清洗/分析/导出 |
| 场景 | 按使用场景拆分 | 实时处理/批处理 |
| 复杂度 | 按复杂度拆分 | 简单任务/复杂任务 |

### Step 3：预判每个子技能的类型

```
对每个待拆分的子技能问：
1. 能否独立使用？ → 能=轻, 不能=需归入父技能
2. 内容能否在300行内说清楚？ → 能=薄, 不能=厚
```

### Step 4：设计协作关系

```mermaid
flowchart LR
    subgraph 拆分前
        O["原技能<br/>重+厚<br/>所有能力集中"]
    end
    
    subgraph 拆分后
        A["技能A<br/>轻+薄"]
        B["技能B<br/>轻+厚"]
        C["技能C<br/>轻+薄"]
    end
    
    O --> A
    O --> B
    O --> C
    
    A -->|可选调用| B

    style O fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style A fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style B fill:#fff3e0,stroke:#ff9800,color:#e65100
    style C fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
```

### Step 5：制定迁移策略

```yaml
迁移策略:
  阶段1: 创建新技能（并行维护）
  阶段2: 标记原技能为 deprecated
  阶段3: 提供迁移期（建议30天）
  阶段4: 退役原技能（调用 destroyer）
```

### 原技能 deprecated 模板

```yaml
---
name: <原技能>
version: v0.1.0
description: "[已拆分] 请使用以下独立技能:"
tags: [deprecated]
---

## 迁移指引

本技能已拆分为:
- [<skill-1>](../<skill-1>/SKILL.md): <用途>
- [<skill-2>](../<skill-2>/SKILL.md): <用途>
```

### 拆分目标类型映射

| 原类型 | 拆分目标 | 典型操作 |
|--------|---------|---------|
| **重+厚** | 多个 **轻+薄** 或 **轻+厚** | 模块拆分 + 内容重组 |
| **重+薄** | 更细的 **重+薄** 或多个 **轻+薄** | 子技能再拆分 |
| **轻+厚** | 保持 **轻+厚** 但 refs 更清晰 | references 重组 |

---

## 简化效果评估

### 量化对比表

| 指标 | 简化前 | 简化后 | 变化率 |
|------|-------|-------|--------|
| 总行数 | _ | _ | _% ↓ |
| 核心能力数 | _ | _ | _ |
| 文件/目录数 | _ | _ | _ |
| 类型判定 | _ | _ | _ |

### 类型变化追踪

| 变化方向 | 触发条件 | 版本影响 |
|---------|---------|---------|
| 厚→薄 | 主文件从 >200行 降至 <200行 | minor +1 |
| 重→多轻 | 从单技能变为技能族 | minor +1 |
| 无变化 | 仅精炼语言或去重 | patch +1 |

### 质量保证

简化操作必须满足：

- [ ] 信息无丢失（只是重新组织）
- [ ] 核心能力保持不变（除非主动拆分）
- [ ] 链接和引用有效
- [ ] 用户仍能找到所有信息

---

## 输出报告

```markdown
## 简化操作报告

### 操作摘要
- 操作类型: <dedup/refine/extract/split>
- 原类型: <轻+厚 / 重+厚 / ...>
- 新类型: <更新后类型>

### 量化结果
- 行数变化: -XX 行 (-XX%)
- 文件数变化: X → Y

### 类型变化
- 厚→薄: 是/否
- 重→轻: 是/否

### 后续建议
- 需要发布新版本: 是/否
- 推荐版本变更: minor +1 (类型变化时)
```

---

## 推荐使用策略 (v0.2.0 新增)

本加工器在以下策略中使用：
- ✅ **精简优先 (Simplify-First)**: 第1步（核心操作）
- ✅ **丰富优先 (Enrich-First)**: 不使用
- ✅ **均衡模式 (Balanced)**: 第1步（轻量去重）
- ❌ **快速路径**: 不使用（跳过加工）

**与其他加工器的协作关系**:
| 关系 | 加工器 | 说明 |
|------|--------|------|
| 前置依赖 | 无 | 通常作为第一步 |
| 后续触发 | Enricher | 均衡模式下按需补充 |
| 对立操作 | Enricher | 方向相反（简化 vs 丰富） |

**详细策略定义**: [docs/processing-strategies.md](../../docs/processing-strategies.md)

---

## 参考

- [skill-factory](../../SKILL.md) - 工厂主文件
- [skill-factory-enricher](../skills/skill-factory-enricher/SKILL.md) - 丰富器（反向操作）
- [skill-factory-standardizer](../skills/skill-factory-standardizer/SKILL.md) - 规范化（简化后建议执行）
