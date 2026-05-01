---
name: skill-factory-enricher
version: v0.1.0
author: skill-factory
parent: skill-factory
phase: processing
description: 技能丰富器，补充技能内容使其更完整，包括补充示例、添加 references、扩展能力、添加可视化图表
tags: [skill-factory, processing, enricher, content-enhancement]
---

# Skill Factory Enricher - 技能丰富器

## 职责边界

**负责**: 补充技能内容，使技能更完整、更有价值
**不负责**: 类型判定（planner）、格式美化（beautifier）、规范检查（standardizer）

---

## 加工流程

```mermaid
flowchart TD
    Input[输入已有技能] --> A[分析当前状态]
    A --> B{丰富方向?}
    
    B -->|补充示例| O1[示例增强]
    B -->|添加详情| O2[references 拆分]
    B -->|扩展功能| O3[能力扩展]
    B -->|添加图表| O4[Mermaid 增强]
    
    O1 --> E[评估类型变化]
    O2 --> E
    O3 --> E
    O4 --> E
    
    E --> Output[输出丰富后的技能]

    style Input fill:#fff3e0,stroke:#ff9800,color:#e65100
    style O1 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style O2 fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style O3 fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style O4 fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style Output fill:#fff3e0,stroke:#ff9800,color:#e65100
```

---

## 操作一：示例增强

### 判定条件

- 示例数量 < 2 个
- 现有示例不完整（缺少输入/输出）
- 未覆盖主要使用场景

### 操作步骤

1. **识别缺失场景**
   - 列出技能的所有使用场景
   - 标注已有示例覆盖的场景
   - 找出未覆盖的场景

2. **生成新示例**
   - 每个缺失场景至少 1 个示例
   - 示例格式：输入 → 操作 → 输出
   - 确保示例可复制执行

3. **插入位置**
   - 放在"## 使用示例"章节
   - 或在对应操作步骤后紧跟

### 效果评估

| 变化 | 影响 |
|------|------|
| 新增 < 2 个简单示例 | 行数微增，类型不变 |
| 新增 >= 2 个或复杂示例 | 可能 薄→厚 |

---

## 操作二：References 拆分

### 判定条件

- 正文行数 > 300 行且为单文件
- 有大量代码块或详细说明混在主文件
- 内容层次不明显

### 操作步骤

1. **分析内容结构**
   - 识别可独立成章的内容块
   - 评估每个块的规模

2. **创建 references 目录**
   ```
   {name}/
   ├── SKILL.md          # 精简为概览 ~150行
   └── references/
       ├── implementation.md
       ├── examples.md
       ├── api-reference.md
       └── troubleshooting.md
   ```

3. **迁移内容**
   - 详细实现 → implementation.md
   - 完整示例 → examples.md
   - 接口文档 → api-reference.md
   - FAQ → troubleshooting.md

4. **重写主文件**
   - 保留任务目标、快速开始、内容索引
   - 添加指向 references 的链接

### 效果

**薄 → 厚** (确定升级)

---

## 操作三：能力扩展

### 判定条件

- 用户要求添加新功能
- 发现相关但缺失的能力
- 原技能范围过窄

### 操作步骤

1. **评估影响**
   - 新能力是否与核心功能内聚？
   - 是否应该拆分为独立子技能？

2. **决策**

```mermaid
flowchart TD
    NewCap[新增能力] --> Q{与核心功能关系?}
    Q -->|高度内聚| Keep[直接添加到原技能]
    Q -->|可独立使用| Split{当前类型?}
    Split -->|轻| ToHeavy[升级为重+薄]
    Split -->|重| AddSub[添加子技能]

    style Keep fill:#ffe0b2,stroke:#fb8c00,color:#e65100
    style ToHeavy fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style AddSub fill:#ffcc80,stroke:#ef6c00,color:#e65100
```

3. **执行**
   - 内聚添加: 在操作步骤中增加新步骤
   - 升级为重: 创建 skills/ 子目录
   - 添加子技能: 在 children 中注册

### 效果

可能 **轻 → 重** (如果需要子技能)

---

## 操作四：Mermaid 增强

### 判定条件

- 流程描述文字化，缺乏直观性
- 有决策分支但没有决策图
- 多组件协作没有架构图

### 可用图表类型

| 图表类型 | 适用场景 | Mermaid 语法 |
|---------|---------|-------------|
| flowchart LR/TD/TB | 流程、步骤、决策 | `flowchart` |
| sequenceDiagram | 交互时序 | `sequenceDiagram` |
| pie | 占比分布 | `pie` |

### 配色规范

```mermaid
flowchart LR
    S1["成功/通过<br/>fill:#e8f5e9<br/>stroke:#4caf50"]
    S2["信息/处理中<br/>fill:#e3f2fd<br/>stroke:#2196f3"]
    S3["警告/注意<br/>fill:#fff3e0<br/>stroke:#ff9800"]
    S4["错误/失败<br/>fill:#fce4ec<br/>stroke:#e91e63"]

    style S1 fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style S2 fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style S3 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style S4 fill:#fce4ec,stroke:#e91e63,color:#880e4f
```

### 规则

- 节点文本不使用 `< > { }` 特殊字符
- 不使用 emoji 在节点文本内
- 每个 style 必须包含 `color:` 属性
- 优先使用 flowchart，避免 quadrantChart 和 mindmap

---

## 操作五：多技能整合（Assembly）

将多个相关技能合并为一个统一的能力集合。

### 整合模式选择

```mermaid
flowchart TD
    Start[整合多个技能] --> M{执行模式?}
    
    M -->|数据依次传递| SEQ[顺序模式]
    M -->|多任务同时| PAR[并行模式]
    M -->|外层控制内层| NEST[嵌套模式]
    
    SEQ --> T{结果类型?}
    PAR --> T
    NEST --> T
    
    T -->|子技能都简单| RT[重+薄]
    T -->|部分子需详细说明| RH[重+厚]

    style SEQ fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style PAR fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style NEST fill:#fff3e0,stroke:#ff9800,color:#e65100
```

### 模式对比

| 模式 | 执行方式 | 适用场景 | 数据流 |
|------|---------|---------|--------|
| **顺序** | 技能按序执行 | 流水线处理 | A → B → C |
| **并行** | 技能同时执行 | 独立任务 | 分支→汇聚 |
| **嵌套** | 外层调用内层 | 分层控制 | 外层→内层 |

### 整合五步流程

#### Step 1：分析源技能

```yaml
源技能分析:
  skill-a:
    capabilities: [能力1, 能力2]
    type: <当前四维类型>
  skill-b:
    capabilities: [能力3, 能力4]
    type: <当前四维类型>
```

**兼容性检查**:
- [ ] 命名无冲突
- [ ] 接口可统一
- [ ] 数据格式可转换

#### Step 2：设计整合架构

```yaml
整合设计:
  名称: <整合技能名>
  模式: <顺序/并行/嵌套>
  预期类型: <重+薄 或 重+厚>
  组件:
    - <skill-a>: <角色>
    - <skill-b>: <角色>
```

**数据流设计**:
```
# 顺序模式
输入 → [skill-a] → 中间数据 → [skill-b] → 输出

# 并行模式
输入 → ├─ [skill-a] →─┐
       └─ [skill-b] →─┘ → 汇聚 → 输出

# 嵌套模式
输入 → [协调器] → 内部调用 [skill-a] → [skill-b] → 输出
```

**输出类型判定**:
```
整合后的技能一定是"重"（多模块）
是否需要"厚"？ → 任一子技能需要详细说明？
  是 → 重+厚
  否 → 重+薄
```

#### Step 3：生成协调器 SKILL.md

```markdown
---
name: <整合名>-family
version: v0.1.0
description: <100-150字符>
tags: [<标签>]
---

## 任务目标
- 本 Skill 用于: <一句话>
- 包含子技能:
  - <skill-a>: <用途>
  - <skill-b>: <用途>
- 整合模式: <顺序/并行/嵌套>

## 子技能索引
- [<skill-a>](skills/<skill-a>/SKILL.md): <简述>
- [<skill-b>](skills/<skill-b>/SKILL.md): <简述>

## 执行流程
<根据模式的流程说明>
```

#### Step 4：测试验证

- [ ] 整合模式选择合理
- [ ] 数据流设计清晰
- [ ] 接口契约明确
- [ ] 对应类型的结构验证通过
  - 重+薄: 子技能均可独立运行
  - 重+厚: references/ 链接有效

#### Step 5：发布验收

- [ ] 整合模式选择合理
- [ ] 数据流设计清晰
- [ ] 接口契约明确
- [ ] 依赖声明完整
- [ ] 四维类型判定正确
- [ ] 目录结构符合规范

### 效果

多个独立技能 → **重+薄** 或 **重+厚**

---

## 操作六：优化策略诊断与加工（Optimization）

基于问题诊断选择对应的加工策略。

### 问题诊断决策树

```mermaid
flowchart TD
    Start[技能质量问题] --> D{问题维度?}
    
    D -->|职责过多 >5个| S1[原子化拆分<br/>→ simplifier 操作四]
    D -->|内容臃肿 >300行| S2[薄到厚升级<br/>→ enricher 操作二]
    D -->|描述不规范| S3[描述优化<br/>→ standardizer 检查一]
    D -->|示例不足 <2个| S4[示例补充<br/>→ enricher 操作一]
    D -->|接口不清晰| S5[标准化接口<br/>→ standardizer 检查二]

    style S1 fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style S2 fill:#fff3e0,stroke:#ff9800,color:#e65100
    style S3 fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style S4 fill:#f3e5f5,stroke:#9c27b0,color:#4a148c
    style S5 fill:#fce4ec,stroke:#e91e63,color:#880e4f
```

### 策略速查表

| 问题症状 | 策略 | 执行者 | 类型影响 |
|---------|------|--------|---------|
| 能力 >5 个 | 原子化拆分 | simplifier | 轻→重 |
| 正文 >300 行混杂 | 薄→厚升级 | enricher | 薄→厚 |
| description 不符规范 | 描述优化 | standardizer | 无 |
| 示例 <2 个 | 示例补充 | enricher | 可能 薄→厚 |
| 输入输出不清晰 | 标准化接口 | standardizer | 无 |

---

## 输出报告

```markdown
## 丰富操作报告

### 操作摘要
- 操作类型: <enrich/split/extend/diagram>
- 原类型: <轻+薄 / ...>
- 新类型: <更新后类型>

### 变更清单
| 操作 | 内容 | 行数变化 |
|------|------|---------|

### 类型变化
- 轻→重: 是/否
- 薄→厚: 是/否

### 后续建议
- 需要发布新版本: 是/否
- 推荐版本变更: minor +1
```

---

## 参考

- [skill-factory](../SKILL.md) - 工厂主文件
- [skill-factory-standardizer](../skills/skill-factory-standardizer/SKILL.md) - 规范化（丰富后建议执行）
- [skill-factory-publisher-version](../skills/skill-factory-publisher-version/SKILL.md) - 版本管理
