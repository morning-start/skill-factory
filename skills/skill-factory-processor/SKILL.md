---
name: skill-factory-processor
version: v2.5.0
author: skill-factory
description: "Use when optimizing, refining, improving, auditing, validating, checking AI Agent skills for quality and compliance, performing health stocktake scans, or integrating Harness AI Agents for automated quality management. Triggers on \"optimize this skill\", \"improve skill\", \"audit skill\", \"check compliance\", \"skill quality\", \"validate SKILL.md\", \"refactor skill\", \"review skill\", \"stocktake skills\", \"health scan\", \"skill inventory\", \"harness agents\", \"automated review\", \"CI/CD quality gate\""
tags: [skill-optimization, skill-auditing, skill-refactoring, quality-check, harness-agents, automated-review, ci-cd-quality-gate, stocktake-scan, skill-factory]
dependency:
  parent: skill-factory
  structure: "Type 3 (轻+厚): SKILL.md + references/ + scripts/"
  pattern: "Processor Coordinator + Harness AI Hub"
meta:
  complexity: advanced
  standalone: true
  can_invoke_directly: true
  tdd: validation-only
  tdd_waiver_reason: "加工+审计是验证行为本身。审计脚本(scripts/audit.ps1)提供自动化100分评分作为客观验证。Harness Agents 集成通过 harness-agents-guide.md 验证"
  tdd_waiver_date: "2026-05-30"
  harness_agents_ready: true
  automation_level: "full"
---
# ⚙️ Skill Factory Processor — 技能加工器

> **定位**: 三模式协调器 — 加工优化 + 质量审计 + 健康扫描 + Harness AI 对接
> **核心能力**: 4 种加工策略 + 100 分审计评分 + 技能负债检测 + Harness Agents

## 职责

| ✅ 负责 | ❌ 不负责 |
|---------|----------|
| 优化已有技能（精简/丰富/美化/重构） | 从零创建 → `/creator` |
| 审计合规性（100 分制评分） | 发布/版本管理 → `/publisher` |
| 技能质量评估与改进建议 | 合并/拆分 → `/assembler` |
| 运行自动化审计脚本 | 需求分析 → `/creator` |
| ⭐ Harness AI Agents 对接 | 创建测试场景 → `/creator` |

## 🤖 Harness AI Agents

> **完整指南**: [references/harness-agents-guide.md](references/harness-agents-guide.md)

| Agent | 能力 |
|-------|------|
| 🔍 Code Review | 7 维自动审查 + PR 评论集成 |
| 🔧 CI Autofix | 审计问题自动修复 + Fix PR |
| 🚀 DevOps | CI/CD 流水线自动生成 |
| 🧠 Knowledge Graph | 技能关系图谱 + 智能推荐 |

## 🔄 三模式入口

| 用户意图 | 模式 | 流程 |
|----------|------|------|
| 优化/改进/精简/重构 | 📝 加工 | 分析→选策略→执行→验证 |
| 检查/审计/评分/合规 | 🔍 审计 | 运行脚本→评分→改进建议→可选修复 |
| 扫描/盘点/健康检查 | 📊 健康扫描 | 全量审计→交叉分析→生成报告→行动建议 |

---

## 模式一：加工 (Processing)

### 分析现状 (5min)

快速诊断命令: `./scripts/audit.ps1 -Path <SKILL.md路径> -Verbose`

### 选择策略 (5min)

| 策略 | 适用场景 | 核心动作 | 预期效果 |
|------|---------|---------|---------|
| **A: 精简** | >500 行，冗余多 | 删低信号内容，压缩示例 | 减 30-50% |
| **B: 丰富** | <200 行，内容不足 | 补充缺失章节 | 增 50-100% |
| **C: 美化** | 格式混乱 | 统一风格，表格化 | 可读性提升 |
| **D: 重构** | 结构问题 | 重新组织章节，调整类型 | 架构合理 |

> **详细指南**: [references/strategies.md](references/strategies.md)

### 执行与验证

**通用原则**: 每次修改前备份、逐步验证、保持功能不变、记录变更

**验证清单**:
- 功能保留、无死链、引用正确
- 重新审计分数提升、CSO 仍有效
- 行数符合类型预期

**循环保护**: 同一技能最多加工 3 轮；连续 2 轮行数变化 <5% 时停止

---

## 模式二：审计 (Auditing)

### 双重验证工具链

1. **官方规范**: `skills-ref validate ./target-skill/` (格式合规)
2. **质量评分**: `./scripts/audit.ps1 -Path ./target-skill/SKILL.md` (100 分制)

**推荐顺序**: 先格式 → 再评分

### 评分维度 (7 项)

| # | 维度 | 满分 | 关键 |
|---|------|------|------|
| 1 | Front Matter 完整 | 10 | 基本信息 |
| 2 | **CSO Description** | **15** | **最关键** |
| 3 | **TDD 验证** | **15** | **最关键** |
| 4 | 必备章节 | 10 | 结构完整 |
| 5 | 层级合规 | 10 | ≤3 层 |
| 6 | 命名规范 | 5 | kebab-case |
| 7 | 链接有效 | 5 | 无死链 |

**等级**: ≥90 ⭐A 优秀 / ≥75 ⭐B 良好 / ≥60 C 合格 / <60 ❌D 不合格

### 生成改进建议 + 修复

输出结构化改进报告（优先级排序：P0 阻塞 > P1 建议），用户确认后执行修复 → 重新审计 → 对比分数

> **完整审计标准**: [references/audit-criteria.md](references/audit-criteria.md)

---

## 模式三：健康扫描 (Stocktake)

发现**技能负债** — 四类问题：

| 负债类型 | 定义 | 检测方法 |
|---------|------|---------|
| 冗余 | 功能重叠 | description 语义相似度+触发词重叠 >60% |
| 退化 | 质量下降 | 历史审计分数对比，下降 >10 分 |
| 孤岛 | 从未被使用 | 引用分析，零入度节点 |
| 过期 | 长期未更新 | last_modified >90天，依赖失效 |

### 执行步骤

```
① 全量审计(5min): ./scripts/audit.ps1 -Project -OutputFormat JSON > baseline.json
② 交叉分析(10min): 冗余/退化/孤岛/过期四维检测
③ 健康报告(15min): 总览仪表盘 + 状态矩阵(🟢/🟡/🔴)
④ 行动建议(5min):  合并/退役/升级/归档
```

**建议频率**: <20 技能→月度 / 20-50→双周 / >50→周度 / 发布前→必须

---

## 三模式对比

| 维度 | 加工 | 审计 | 健康扫描 |
|------|------|------|---------|
| 触发词 | 优化/重构 | 检查/合规 | 扫描/盘点 |
| 输入 | 单个技能 | 单技能或项目 | 全项目 |
| 输出 | 改进后技能 | 评分+建议 | 健康报告+行动 |
| 改文件 | 是(有备份) | 否 | 否 |
| 耗时 | 20-40min | 10-20min | 30-45min |

## 🛠️ 自动化工具

| 工具 | 用途 | 命令 |
|------|------|------|
| `skills-ref` (官方) | 格式合规验证 | `skills-ref validate <path>` |
| `audit.ps1` (自建) | 100 分质量评分 | `audit.ps1 -Path <file>` / `-Project` |

## ⚠️ 约束

1. **加工前必审计** — 先了解现状再优化
2. **最小变更** — 优化不是重写，每步有明确目的
3. **审计客观** — 100 分制基于明确标准
4. **最多 3 轮** — 避免过度优化
5. **备份原文件** — 任何加工前创建备份
6. **TDD+CSO 最高权重** — 各 15 分

## 📂 结构

```
skill-factory-processor/
├── SKILL.md                              ← 本文件
├── references/
│   ├── strategies.md                     ← 4种加工策略详解
│   ├── audit-criteria.md                 ← 审计标准与评分细则
│   ├── harness-integration-guide.md      ← Test Harness CI/CD 集成
│   └── harness-agents-guide.md           ← Harness AI Agents 对接
└── scripts/
    └── audit.ps1                           ← 自动化审计脚本
```

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v2.5.0** | 2026-05-30 | 提取 Harness Agents 至 references/，936→~600 行 |
| **v2.0.0** | 2026-05-27 | 双模式协调器重构，4 种加工策略 |