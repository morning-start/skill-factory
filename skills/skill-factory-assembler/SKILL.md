---
name: skill-factory-assembler
version: v2.3.0
author: skill-factory
description: "Use when merging, splitting, combining, integrating, or restructuring multiple AI Agent skills, performing batch validation after assembly operations, or coordinating with Stocktake health scans. Triggers on \"merge skills\", \"split skills\", \"combine skills\", \"integrate skills\", \"restructure skills\", \"skill assembly\", \"batch validate\", \"post-merge check\", or \"stocktake coordination\""
tags: [skill-merging, skill-splitting, skill-restructuring, integration, batch-validation, stocktake-coordination, ci-cd-pipeline, harness-integration, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/"
  pattern: "Assembler Coordinator + Batch Validation"
meta:
  complexity: advanced
  standalone: true
  can_invoke_directly: true
  tdd: deferred
  tdd_waiver_reason: "协调器型技能，核心TDD流程在 creator/references/tdd-guide.md 中。批量验证通过 processor Stocktake 模式协同完成"
  tdd_waiver_date: "2026-05-30"
  batch_validation: true
  stocktake_integration: true
  harness_integration: "v1.0"
---
# 🔗 Skill Factory Assembler — 技能整合器

> **定位**: 多技能合并与拆分的架构重组器 + 批量验证协调器

## 职责

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 合并多个技能为一个 | 从零创建 → `/creator` |
| 拆分复杂技能为多个 | 优化单个 → `/processor` |
| 技能架构重组与调整 | 发布/版本管理 → `/publisher` |
| ⭐ 合并/拆分后批量验证 | 单技能审计 → `/processor` |
| ⭐ Stocktake 健康扫描协同 | 创建测试场景 → `/creator` |

## 🔄 双向操作

```
"合并/整合/组合" → 🔗 Merge Mode
"拆分/分离/解耦" → ✂️ Split Mode

合并: 分析源技能 → 选模式 → 执行 → 验证
拆分: 分析目标技能 → 选维度 → 执行 → 验证
```

## 模式一：合并 (Merge)

| 模式 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **序列** | 有先后依赖 | A→B→C 顺序执行 | 验证→测试→部署 |
| **并行** | 功能独立 | A/B/C 并列子技能 | 格式化+Lint+类型检查 |
| **嵌套** | 子流程嵌入 | B 嵌入 A 作为步骤 | 部署中的健康检查 |

> **详细指南**: [references/merge-patterns.md](references/merge-patterns.md)
> **EvoSkill 多候选评估** (策略模糊时): 生成 2-3 候选方案 → 6 维评分选优 → [references/evoskill-eval.md](references/evoskill-eval.md)

## 模式二：拆分 (Split)

| 维度 | 适用场景 | 特征 | 示例 |
|------|---------|------|------|
| **功能** | 功能模块清晰 | 每个子技能一个功能域 | CRUD→4 个子技能 |
| **场景** | 场景差异大 | 按使用环境划分 | 部署→dev/staging/prod |
| **角色** | 角色关注点不同 | 按目标用户划分 | CI/CD→dev/ops/admin |

> **详细指南**: [references/split-patterns.md](references/split-patterns.md)
> **EvoSkill 多候选评估**: 同上

## 🧪 批量验证

> 合并/拆分操作风险：结构破坏 / 内容丢失 / TDD 失效 / 触发冲突

**标准流程**:
```
① 完成操作 → ② 全量审计(audit.ps1 -Project) → ③ 分析结果(平均≥85%通过)
                                          → ④ 可选: Stocktake 扫描
                                          → ⑤ 验证报告: HTML + 问题清单 + 行动建议
```

**Stocktake 协同触发**:
| 场景 | 必须 Stocktake? |
|------|----------------|
| 大规模合并 (≥3 技能) | ✅ 必须 |
| 核心技能拆分 | ✅ 必须 |
| 小规模调整 (1-2) | 可选 |
| 定期维护 | 推荐 |

> **协同流程**: Assembler 输出操作报告 → Processor Stocktake 扫描 → 分析结果 → 修复/再拆分/退役/观察

### CI/CD 集成

> **完整配置**: `.github/workflows/assembly-validation.yml`

推送 `skills/**/SKILL.md` 变更时自动触发：检测变更 → 全量审计 → 质量门禁 (≥85%) → 上传报告

## 合并 vs 拆分对比

| 维度 | 合并 | 拆分 |
|------|------|------|
| 触发词 | 合并/整合/统一 | 拆分/分离/解耦 |
| 输入 | 2-4 个源技能 | 1 个目标技能 |
| 输出 | 1 个整合技能 | 2-4 个子技能 |
| 耗时 | 30-50min | 30-45min |

## ⚠️ 约束

1. **合并不等于拼接** — 要解决冲突、统一风格
2. **拆分不等于切割** — 保证每个子技能的独立完整性
3. **先评估再行动** — 不是所有技能都适合合并/拆分
4. **保持向后兼容** — 已使用的技能拆分时保留原入口
5. **渐进式重组** — 大型重构可分多步
6. **策略模糊用 EvoSkill** — 多候选 6 维评分选优

## 📂 结构

```
skill-factory-assembler/
├── SKILL.md                              ← 本文件
└── references/
    ├── merge-patterns.md                 ← 序列/并行/嵌套合并详解
    ├── split-patterns.md                 ← 功能/场景/角色拆分详解
    └── evoskill-eval.md                  ← 多候选评估方法论
```

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.3.0** | 2026-05-30 | 批量验证集成：5 步验证+Stocktake 协同+CI/CD 配置 |
| **v2.0.0** | 2026-05-27 | 双向协调器：3 种合并模式 × 3 种拆分维度 |