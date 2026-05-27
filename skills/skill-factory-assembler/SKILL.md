---
name: skill-factory-assembler
version: v2.0.1
author: skill-factory
description: Use when merging, splitting, combining, integrating, or restructuring multiple AI Agent skills. Triggers on "merge skills", "split skills", "combine skills", "integrate skills", "restructure skills", or "skill assembly"
tags: [skill-merging, skill-splitting, skill-restructuring, integration, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Assembler Coordinator"
meta:
  complexity: intermediate
  standalone: true
  can_invoke_directly: true
  tdd: deferred
  tdd_waiver_reason: "协调器型技能，核心TDD流程在 creator/references/tdd-guide.md 中。当前为 v2.0.1 稳定版，待后续补充完整压力测试记录"
  tdd_waiver_date: "2026-05-27"
---
# 🔗 Skill Factory Assembler — 技能整合器 v2.0.1

> **定位**: 多技能合并与拆分的架构重组器
> **架构**: 自含型子技能 + references/ 详细参考

---

## 🎯 职责范围

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 合并多个技能为一个 | 从零创建 → `/creator` |
| 拆分复杂技能为多个 | 优化单个 → `/processor` |
| 技能架构重组与调整 | 发布/版本管理 → `/publisher` |

---

## 🔄 双向操作

```
"合并/整合/组合" → 🔗 Merge Mode (合并)
"拆分/分离/解耦" → ✂️ Split Mode (拆分)

合并模式: 分析源技能 → 选模式 → 执行合并 → 验证
拆分模式: 分析目标技能 → 选维度 → 执行拆分 → 验证
```

---

## 模式一：合并（Merge）

### 三种合并模式速查

| 模式 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **序列 (Sequential)** | 有先后依赖 | A→B→C 顺序执行 | 验证→测试→部署 |
| **并行 (Parallel)** | 功能独立 | A/B/C 并列子技能 | 格式化+Lint+类型检查 |
| **嵌套 (Nested)** | 子流程嵌入 | B 嵌入 A 作为步骤 | 部署中的健康检查 |

### 模式选择

```
有先后顺序? → 序列合并
功能独立无依赖? → 并行合并
一个是另一个的子流程? → 嵌套合并
复杂混合? → 组合模式
```

> 📖 **详细操作步骤 + 示例**: [references/merge-patterns.md](references/merge-patterns.md)

---

## 模式二：拆分（Split）

### 三种拆分维度速查

| 维度 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **功能 (Function)** | 功能模块清晰可辨 | 每个子技能一个功能域 | CRUD→4个子技能 |
| **场景 (Scene)** | 场景差异大 | 按使用环境划分 | 部署→dev/staging/prod |
| **角色 (Role)** | 角色关注点不同 | 按目标用户划分 | CI/CD→dev/ops/admin |

### 维度选择

```
功能边界清晰? → 按功能拆分
使用场景差异大? → 按场景拆分
用户角色不同? → 按角色拆分
多种因素混合? → 主维度 + 辅助维度
```

> 📖 **详细操作步骤 + 示例**: [references/split-patterns.md](references/split-patterns.md)

---

## 📊 合并 vs 拆分对比

| 维度 | 合并 | 拆分 |
|------|------|------|
| **触发词** | 合并/整合/组合/统一 | 拆分/分离/解耦/精简 |
| **输入** | 2-4 个源技能 | 1 个目标技能 |
| **输出** | 1 个整合技能 | 2-4 个子技能 |
| **核心挑战** | 解决冲突 | 保持完整性 |
| **耗时** | 30-50 min | 30-45 min |

---

## ⚠️ 注意事项

1. **合并不等于拼接**: 要解决冲突、重新组织、统一风格
2. **拆分不等于切割**: 保证每个子技能的独立性和完整性
3. **先评估再行动**: 不是所有技能都适合合并或拆分
4. **保持向后兼容**: 已使用的技能拆分时保留原入口
5. **渐进式重组**: 大型重构可分多步完成

---

## 📂 本子技能结构

```
skills/skill-factory-assembler/
├── SKILL.md                      ← 本文件（协调器 ~200行）
└── references/
    ├── merge-patterns.md         ← 序列/并行/嵌套合并详解
    └── split-patterns.md         ← 功能/场景/角色拆分详解
```

## 🔗 相关资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 设计原则 | [../references/design-principles.md](../references/design-principles.md) | 整合模式选择 |
| 写作规则 | [../references/writing-rules.md](../references/writing-rules.md) | R1-R14 完整规则 |
| 最佳实践 | [../references/best-practices.md](../references/best-practices.md) | 项目知识枢纽 |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.0.1** | 2026-05-27 | **优化**: 拆分 references/(2文件)；修复死链(subskill-design已删)；添加 TDD 豁免；行数 549→~200 |
| **v2.0.0** | 2026-05-27 | 初始版本：单文件双向协调器；3种合并模式 × 3种拆分维度 |
