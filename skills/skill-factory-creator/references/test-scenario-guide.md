# Test Scenario 设计与 Acceptance Criteria 完整指南

> **来源**: skill-factory-creator → Test Harness 集成
> **版本**: v1.0.0
> **用途**: 为新创建的技能设计完整的测试场景和验收标准

---

## 🧪 Test Scenario 设计 (Harness 集成)

> **来源**: [harness-integration-guide.md](../skill-factory-processor/references/harness-integration-guide.md)
> **目的**: 为新创建的技能设计完整的测试场景，确保 CI/CD 自动化验证

### 为什么需要 Scenario 设计

```
技能质量 = 内容正确性(TDD) × 触发准确率(CSO) × 场景覆盖率(Scenario)
                ↑ 已有完整流程      ↑ 已有 CSO Eval     ↑ 📌 本章节新增
```

### Scenario 设计时机

| 时机 | 说明 | 必要性 |
|------|------|--------|
| **创建完成后** | 技能编写完毕，进入验证阶段前 | ✅ 必须 |
| **优化后** | processor 加工完成后重新设计 | 推荐 |
| **发布前** | publisher 发布前的最终验证 | ✅ 必须 |

---

## 📝 Scenarios YAML 格式规范

#### 文件位置: `tests/scenarios/{skill-name}/scenarios.yaml`

```yaml
version: 1.0
skill: {your-skill-name}
created_date: "2026-05-30"
author: skill-factory-creator

metadata:
  total_scenarios: 20
  should_trigger_count: 10
  should_not_trigger_count: 10
  coverage_dimensions:
    - 措辞变化
    - 明确度变化
    - 细节程度
    - 复杂度变化

scenarios:
  # ========== Should-trigger (正例) ==========
  should_trigger:
    # 维度 1: 措辞变化 (3个)
    - id: st-01
      type: should-trigger
      dimension: 措辞变化
      variant: 正式
      prompt: "请帮我创建一个新的 AI Agent Skill"
      expected_trigger: true
      notes: "最标准的触发方式，必须通过"
      
    - id: st-02
      type: should-trigger
      dimension: 措辞变化
      variant: 随意
      prompt: "建个skill试试"
      expected_trigger: true
      notes: "随意措辞应也能触发"
      
    - id: st-03
      type: should-trigger
      dimension: 措辞变化
      variant: 错别字
      prompt: "新建一个skiil文件"
      expected_trigger: true
      notes: "容忍常见错别字"

    # 维度 2: 明确度变化 (3个)
    - id: st-04
      type: should-trigger
      dimension: 明确度变化
      variant: 直接命名
      prompt: "用 creator 创建一个 Type 1 技能"
      expected_trigger: true
      
    - id: st-05
      type: should-trigger
      dimension: 明确度变化
      variant: 间接描述
      prompt: "我需要一个能帮 Claude 学新能力的工具"
      expected_trigger: true
      
    - id: st-06
      type: should-trigger
      dimension: 明确度变化
      variant: 需求描述
      prompt: "基于这个需求文档，帮我构建对应的 Agent Skill"
      expected_trigger: true

    # 维度 3: 细节程度 (2个)
    - id: st-07
      type: should-trigger
      dimension: 细节程度
      variant: 简短
      prompt: "建个技能"
      expected_trigger: true
      
    - id: st-08
      type: should-trigger
      dimension: 细节程度
      variant: 详细上下文
      prompt: |
        我正在开发一个 DevOps 自动化工具集，
        需要为其中的 CI/CD 模块创建一个独立的技能，
        要求支持 GitHub Actions 和 Harness.io 双平台
      expected_trigger: true

    # 维度 4: 复杂度变化 (2个)
    - id: st-09
      type: should-trigger
      dimension: 复杂度变化
      variant: 单步请求
      prompt: "创建技能"
      expected_trigger: true
      
    - id: st-10
      type: should-trigger
      dimension: 复杂度变化
      variant: 多步嵌入链
      prompt: "先分析这个工具能不能做成 skill，然后创建它，最后运行 TDD 测试"
      expected_trigger: true

  # ========== Should-not-trigger (负例) ==========
  should_not_trigger:
    # 近误类型: 同域不同操作 (3个)
    - id: snt-01
      type: should-not-trigger
      dimension: 近误: 同域不同操作
      variant: 加工请求
      prompt: "帮我优化一下现有的 skill-factory-processor"
      expected_trigger: false
      target_skill: processor
      notes: "包含 'skill' 但动作是'优化'非'创建'"
      
    - id: snt-02
      type: should-not-trigger
      dimension: 近误: 同域不同操作
      variant: 审计请求
      prompt: "检查这个 SKILL.md 是否符合规范"
      expected_trigger: false
      target_skill: processor
      notes: "'检查' 应触发审计非创建"
      
    - id: snt-03
      type: should-not-trigger
      dimension: 近误: 同域不同操作
      variant: 发布请求
      prompt: "发布 creator 的新版本"
      expected_trigger: false
      target_skill: publisher
      notes: "'发布' 应触发生成器非创建器"

    # 近误类型: 同词不同义 (2个)
    - id: snt-04
      type: should-not-trigger
      dimension: 近误: 同词不同义
      variant: 脚本请求
      prompt: "写个 Python 脚本来自动化测试"
      expected_trigger: false
      target_skill: null
      notes: "'skill' 在此指技术技能非 Agent Skill"
      
    - id: snt-05
      type: should-not-trigger
      dimension: 近误: 同词不同义
      variant: 软件技能
      prompt: "提升我的 Git 使用技能"
      expected_trigger: false
      target_skill: null
      notes: "通用技能非 Agent Skill 创建"

    # 近误类型: 泛化请求 (2个)
    - id: snt-06
      type: should-not-trigger
      dimension: 近误: 泛化请求
      variant: 宽泛优化
      prompt: "优化我的开发流程"
      expected_trigger: false
      target_skill: null
      notes: "太宽泛，不特指创建新技能"
      
    - id: snt-07
      type: should-not-trigger
      dimension: 近误: 泛化请求
      variant: 工具链整合
      prompt: "把这些功能封装成可复用的模块"
      expected_trigger: false
      target_skill: assembler
      notes: "可能是 assembler 的任务"

    # 近误类型: 跨技能边界 (2个)
    - id: snt-08
      type: should-not-trigger
      dimension: 近误: 跨技能边界
      variant: 合并意图
      prompt: "把 creator 和 processor 合并成一个技能"
      expected_trigger: false
      target_skill: assembler
      notes: "合并/拆分是 assembler 的职责"
      
    - id: snt-09
      type: should-not-trigger
      dimension: 近误: 跨技能边界
      variant: 文档生成
      prompt: "为现有技能生成使用文档"
      expected_trigger: false
      target_skill: null
      notes: "文档生成不是创建新技能"

    # 边缘情况 (1个)
    - id: snt-10
      type: should-not-trigger
      dimension: 边缘情况
      variant: 空请求
      prompt: ""
      expected_trigger: false
      target_skill: null
      notes: "空输入不应触发任何技能"
```

---

## ✅ Acceptance Criteria 格式规范

#### 文件位置: `tests/scenarios/{skill-name}/acceptance-criteria.md`

```markdown
# Acceptance Criteria — {skill-name}

> **版本**: 1.0.0
> **创建日期**: 2026-05-30
> **基于**: [harness-integration-guide.md](../../references/harness-integration-guide.md)

---

## ✅ 正确模式 (Pass Criteria)

### 1. Front Matter 完整性
✅ 包含所有必填字段：`name`, `version`, `description`, `tags`
✅ `description` 以 "Use when..." 开头
✅ `description` 长度在 50-1024 字符之间
✅ 无 XML 角括号 `< >`

### 2. CSO Description 质量
✅ 只包含触发条件，不含功能描述
✅ 覆盖主要触发词变体（正式/随意/错别字）
✅ 不包含工作流步骤说明

### 3. TDD 验证记录
✅ 包含压力场景描述（≥ 3 个）
✅ 或包含明确的 TDD 豁免说明及原因
✅ 压力场景覆盖时间/权威/疲劳/模糊维度

### 4. 必备章节完整性
✅ 包含明确的目标/定位说明
✅ 包含可执行的操作步骤
✅ 包含至少 1 个端到端示例
✅ 包含具体的注意事项/Gotchas

### 5. 层级合规
✅ 目录深度 ≤ 3 层（references/ 不计入）
✅ 命名符合 kebab-case 规范

---

## ❌ 错误模式 (Fail Criteria)

### 1. Front Matter 缺失或错误
❌ 缺少 `name` 或 `version` 字段
❌ `description` 不以 "Use when" 开头
❌ `description` 长度 < 50 或 > 1024 字符
❌ 包含 XML 角括号

**示例**:
```yaml
# ❌ 错误: 功能描述而非触发条件
description: "Skill Factory Creator - helps you create new AI Agent Skills..."

# ✅ 正确: 纯触发条件
description: "Use when creating new AI Agent skills from scratch..."
```

### 2. TDD 验证缺失
❌ 未提及 TDD 或压力测试
❌ 无豁免说明

**示例**:
```yaml
# ❌ 错误: 无 TDD 相关内容
meta:
  complexity: intermediate

# ✅ 正确: 有完整 TDD 或明确豁免
meta:
  tdd: full
  # 或
  tdd: validation-only
  tdd_waiver_reason: "路由器型技能..."
```

### 3. 结构违规
❌ 目录深度 > 3 层
❌ 文件名不符合 kebab-case
❌ 缺少必备章节（目标/步骤/示例/注意事项）

### 4. 内容质量问题
❌ 示例过于简单或缺失
❌ 注意事项泛泛而谈无具体 Gotchas
❌ 步骤不可执行或模糊

---

## 📊 评分标准

| 维度 | 权重 | 通过标准 | 分值 |
|------|------|---------|------|
| Front Matter | 20% | 字段完整 + 格式正确 | 20/20 |
| CSO Description | 25% | Use when + 触发词覆盖 | 25/25 |
| TDD Validation | 20% | 记录/豁免完整 | 20/20 |
| Essential Sections | 20% | 4 项必备齐全 | 20/20 |
| Structure Compliance | 15% | 层级+命名正确 | 15/15 |
| **总计** | **100%** | | **100/100** |

**等级标准**:
- ⭐ **A (优秀)**: ≥ 90 分 — 可直接发布
- ⭐ **B (良好)**: 75-89 分 — 小修后发布
- ⭐ **C (合格)**: 60-74 分 — 需要优化
- ❌ **D (不合格)**: < 60 分 — 必须重写
```

---

## 🚀 快速开始

### Step 1: 创建 Scenario 文件结构

```bash
mkdir -p tests/scenarios/{your-skill-name}
```

### Step 2: 编写 scenarios.yaml

复制上面的 YAML 模板，根据你的技能特点调整：
- 修改 `skill` 字段为你的技能名
- 调整 `prompt` 示例以匹配你的触发条件
- 保持 10 正例 + 10 负例的平衡

### Step 3: 编写 acceptance-criteria.md

复制上面的 Markdown 模板，根据你的技能标准调整：
- 补充具体的 Pass/Fail 示例
- 调整评分权重（如需要）

### Step 4: 本地测试

```bash
# 使用 mock 模式快速验证
npx harness your-skill-name --mock --scenarios tests/scenarios/{your-skill-name}/scenarios.yaml
```

---

## 📚 相关资源

| 资源 | 链接 | 用途 |
|------|------|------|
| Harness 集成指南 | [harness-integration-guide.md](../skill-factory-processor/references/harness-integration-guide.md) | CI/CD 对接完整参考 |
| Processor 审计脚本 | [audit.ps1](../skill-factory-processor/scripts/audit.ps1) | 100 分制审计工具 |
| TDD 指南 | [tdd-guide.md](./tdd-guide.md) | RED→GREEN→REFACTOR 流程 |
| 示例 Scenario | [tests/scenarios/skill-factory-processor/](../../../tests/scenarios/skill-factory-processor/) | 参考实现 |

---

> 💡 **提示**: 此文档从 Creator SKILL.md 中提取，目的是保持主文件精简（<500行）。详细内容请查阅本文件。
