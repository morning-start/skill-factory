# 社区元技能调研报告

> **项目**: skill-factory v2.0.1
> **日期**: 2026-05-27
> **调研范围**: agentskills.io 官方生态 / GitHub 开源社区 / 中英文技术博客
> **目的**: 发现社区中其他元技能/技能工具的设计模式，识别可借鉴的改进方向

---

## 一、执行摘要

本次调研覆盖了 **6 大信息源**，发现了 **1 个直接竞品**（官方 `skill-creator`）和 **多个可借鉴的创新模式**。核心结论：

| 维度 | 我们的 skill-factory | 官方 skill-creator | 差距评估 |
|------|---------------------|-------------------|---------|
| **功能广度** | ⭐⭐⭐⭐⭐ 创建+加工+发布+整合+审计 | ⭐⭐ 仅创建 | ✅ 显著领先 |
| **CSO 自动化** | ⭐⭐ 手动规则 | ⭐⭐⭐⭐⭐ 自动触发率评估+优化循环 | 🚨 **最大短板** |
| **TDD 方法论** | ⭐⭐⭐⭐⭐ RED/GREEN/REFACTOR 完整体系 | ⭐⭐⭐ eval 驱动迭代 | ✅ 领先 |
| **类型分类** | ⭐⭐⭐⭐⭐ 四维分类(Type 1-4) | ❌ 无 | ✅ 独有优势 |
| **模板系统** | ⭐⭐⭐⭐⭐ Type 1-4 模板库 | ❌ 无 | ✅ 独有优势 |
| **自动化验证** | ⭐⭐⭐⭐ audit.ps1 (100分制) | ⭐⭐⭐⭐ quick_validate + run_eval | ⚠️ 各有侧重 |

**战略建议**: 借鉴官方的 **CSO 触发率自动化评估** 能力补齐最大短板，同时保持我们在全流程覆盖和 TDD/类型体系上的差异化优势。

---

## 二、调研资源清单

### 2.1 核心发现（按价值排序）

| # | 资源 | 来源 | 类型 | 关键产出 |
|---|------|------|------|---------|
| 1 | **official skill-creator** | [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | 官方元技能 | CSO自动优化、eval驱动、HTML报告 |
| 2 | **agentskills.io 规范文档** | [agentskills.io](https://agentskills.io) | 官方标准 | 最佳实践、Progressive Disclosure、CSO优化指南 |
| 3 | **skills-ref CLI** | agentskills.io 推荐 | 官方验证工具 | `npx skills-ref validate` |
| 4 | **Agent Skills 深度解析 (日文)** | Qiita @nogataka | 社区经验 | 技能负债悖论、30+平台兼容、标准迁移 |
| 5 | **Agent Skills 完整指南 (中文)** | jishuzhan.net | 中文生态 | 四层架构详解、EvoSkill模式、安全设计 |
| 6 | **Strapi 英文实践指南** | strapi.io/blog | 英文博客 | 三层披露、MCP协同、可组合性 |

### 2.2 未找到的资源

- GitHub 上除官方外，**无其他成熟的元技能/技能工厂项目**
- 无开源的 "skill generator" 或 "SKILL.md scaffolding" 工具
- 这意味着 **skill-factory 在社区中是独一无二的**（除了官方 skill-creator）

---

## 三、官方 skill-creator 深度分析

### 3.1 基本信息

```
仓库: anthropics/skills → skills/skill-creator/
最后更新: 2026-03-07 (improve_description.py)
许可: Apache-2.0
定位: "帮助用户从意图捕获到 eval 驱动的完整技能创建"
```

### 3.2 目录结构

```
skill-creator/
├── SKILL.md                    (~200行? 协调器)
├── scripts/
│   ├── improve_description.py   ← 🌟 核心: CSO 自动优化
│   ├── run_loop.py             ← Eval 循环引擎
│   └── quick_validate.py       ← Front Matter 验证
├── references/                 (参考文档)
├── assets/                     (模板/静态资源)
├── agents/                     (子代理配置)
└── eval-viewer/               ← 🌟 HTML 实时报告
```

### 3.3 核心工作流（6 Phase）

#### Phase 1: 捕获意图 — 4 问框架

| 问题 | 目的 | 我们的对等 |
|------|------|----------|
| 技能让 Claude 做什么？ | 定义 SKILL.md body 范围 | ✅ 需求分析(第一步) |
| 何时触发？ | 驱动 description 字段 | ✅ CSO 编写规则(R9) |
| 期望的输出格式？ | 塑造示例和断言 | ❌ **缺失** |
| 是否需要测试用例？ | 决定是否值得做 eval | ⚠️ TDD 豁免判断 |

**差距**: 我们缺少"输出格式"维度的显式捕获。

#### Phase 2: 访谈与研究

- 边缘情况、I/O 格式、示例文件、成功标准、依赖项
- 如有 MCP 可用，并行调用子代理研究文档
- **目标**: 带着足够上下文开始写 SKILL.md，减少来回

#### Phase 3: 编写 SKILL.md

关键设计决策:
- **description 用祈使句**: `"Use whenever the user mentions dashboards..."` 而非 `"Use when the user wants to build a dashboard"`
- **倾向 pushy 措辞**: 对抗 Claude 的 undertriggering 倾向
- **body <500 行**: 超过则拆到 references/

#### Phase 4: 编写测试用例 (Eval Queries)

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": [],
      "expectations": []
    }
  ]
}
```

- 2-3 个真实测试 prompt
- **assertions 先留空**，下一阶段运行时填写

#### Phase 5: 运行与评分

- 每个 query 跑 3 次（应对非确定性）
- 计算触发率 (trigger_rate = triggers/runs)
- 通过阈值: should-trigger > 0.5, should-not-trigger < 0.5

#### Phase 6: 迭代优化

- 训练集(60%)指导修改 + 验证集(40%)防过拟合
- 通常 5 轮迭代收敛
- 输出 **HTML 实时报告** (eval-viewer)

### 3.4 `improve_description.py` 核心逻辑

这是官方 skill-creator 最有价值的差异化能力：

```python
# 伪代码逻辑:

def optimize_description(skill_path):
    current_desc = read_description(skill_path)
    eval_queries = load_eval_queries()  # 20个: 10正 + 10负
    
    for iteration in range(5):
        # 1. 在训练集上评估
        train_results = run_eval(eval_queries.train, current_desc)
        
        # 2. 识别失败案例
        failures = identify_failures(train_results)
        #    - should_trigger 但未触发 → description 太窄
        #    - should_not_trigger 但触发了 → description 太宽
        
        # 3. 用 Claude API 提出改进方案
        improved = ask_claude_to_improve(current_desc, failures)
        
        # 4. 检查长度限制 (<1024 chars)
        if len(improved) > 1024:
            improved = retry_single_turn_compress(improved)
        
        # 5. 在验证集上检查泛化性
        val_results = run_eval(eval_queries.validation, improved)
        
        # 6. 选择最佳版本（不一定是最后一个）
        if is_better(val_results, best_so_far):
            best_desc = improved
    
    return best_desc, html_report
```

**关键技术细节**:
- 使用 `claude -p` 子进程调用（无需 ANTHROPIC_API_KEY）
- 过长描述的重试是**全新单轮调用**（内联过长版本而非多轮跟进）
- 支持**嵌套在 Claude Code 会话内**运行（剥离 CLAUDECODE 环境变量）

---

## 四、agentskills.io 官方最佳实践对标

### 4.1 规范要求 vs 我们的实现

| 官方规范 | 要求 | 我们的实现 | 状态 |
|---------|------|-----------|------|
| **SKILL.md <500 行** | 强烈推荐 | 全部 <280 行 | ✅ |
| **description 50-1024 字符** | 硬限制 | 全部合规 | ✅ |
| **name: kebab-case, 1-64字符** | 必须 | 全部合规 | ✅ |
| **Progressive Disclosure L1/L2/L3** | 架构原则 | 三级加载系统 | ✅ |
| **references/ 文件小而聚焦** | 效率优化 | 按需引用指针 | ✅ |
| **Gotchas 具体陷阱章节** | 高价值内容 | R1 + 各子技能 | ✅ |
| **脆弱度匹配具体性** | 校准原则 | R11 已写入 | ✅ |
| **默认值优于菜单** | 减少认知负担 | R12 已写入 | ✅ |
| **PVE (Plan-Validate-Execute)** | 流程模式 | R13 已写入 | ✅ |
| **`npx skills-ref validate`** | 推荐工具 | 自建 audit.ps1 | ⚠️ 可补充 |

### 4.2 官方 CSO 优化指南（我们缺失的核心能力）

来源: [agentskills.io/skill-creation/optimizing-descriptions.md](https://agentskills.io/skill-creation/optimizing-descriptions.md)

#### 编写有效 description 的原则

1. **使用祈使句**: "Use this skill when..." 而非 "This skill does..."
2. **聚焦用户意图**: 描述用户想达成什么，非内部机制
3. **倾向 pushy**: 明确列出适用场景，包括用户未直接提及的情况
4. **保持简洁**: 几句话到短段落，硬限制 1024 字符

#### Eval Query 设计方法

**Should-trigger queries (8-10 个)**:
- **措辞变化**: 正式/随意/错别字/缩写
- **明确度变化**: 直接命名域 vs 描述需求而不命名
- **细节程度**: 简短 prompt + 重 context prompt
- **复杂度变化**: 单步 vs 多步骤嵌入链

**Should-not-trigger queries (8-10 个)**:
- 最有价值的是**近误 (near-miss)**: 共享关键词但实际需要不同技能

**优化循环**:
1. 在训练集+验证集上评估当前 description
2. 识别训练集失败案例（仅用训练集指导修改）
3. 修订 description（泛化而非添加特定关键词）
4. 检查 <1024 字符限制
5. 重复直到训练集全部通过或无显著提升
6. **选择验证集通过率最高的版本**（不一定是最后版本）

---

## 五、社区创新模式

### 5.1 EvoSkill 三Agent 协作 (中文社区)

来源: jishuzhan.net Agent Skills 内部原理完全解析

```
┌──────────────┐  生成候选    ┌──────────────┐
│  Creator     │ ──────────→ │  Evaluator  │
│  Agent       │              │  Agent       │
└──────────────┘              └──────┬───────┘
     ↑                            │ 评分
     │      选择最佳变体           ↓
     └──────────────────────────────┘
                  Refiner
                   Agent
```

**流程**:
1. **Creator Agent**: 从需求生成多个技能版本变体
2. **Evaluator Agent**: 用 eval queries 对每个版本打分
3. **Refiner Agent**: 选最优版本微调

**借鉴价值**: assembler 合并时可生成多个候选合并方案，自动评估选最优。

### 5.2 技能负债管理 (@nogataka, 20+ 技能运营者)

> *"Skills を50個運用して気づいた — 増やすほど生産性が下がるパラドックス"*  
> （运营 50 个技能后发现的悖论：技能越多生产力越低）

**关键洞察**:

| 问题 | 表现 | 根因 | 解法 |
|------|------|------|------|
| **发现成本** | 随数量指数增长 | 技能多 → 选择困难 | Progressive Disclosure + 好的 CSO |
| **维护成本** | 线性增长 | 每个技能需持续更新 | 标准化格式降低维护成本 |
| **质量退化** | 随时间增长 | 技能与实际需求漂移 | 定期 stocktake + 审计 |
| **冗余累积** | 团队规模增大 | 不同人创建重叠技能 | 统一注册表 + 去重 |

**借鉴价值**: processor 应增加"全项目健康扫描"模式。

### 5.3 四层信息架构 (AQUA 日本)

来源: aquallc.jp Agent Skills 完全ガイド

| 层级 | 组件 | 内容类型 | Token消耗 | 加载策略 |
|------|------|---------|----------|---------|
| **L1** | Metadata | name/description/version | ~100 tokens | Always-On (常驻) |
| **L2** | Instruction | SKILL.md 正文规则 | <5000 tokens | On-Demand (命中后加载) |
| **L3** | Reference | 外部文档/手册/规范 | 可变 | Context-Triggered (条件触发) |
| **L4** | Script | Python/Shell/JS 脚本 | **零** | Execution-Only (仅执行不读) |

**注意**: 这个模型比我们的三级(L1/L2/L3)多了 **L4 Script 层**，强调脚本执行时不占用上下文窗口。我们可以采纳这个区分。

### 5.4 双引擎架构 (Strapi)

来源: strapi.io/blog "What Are Agent Skills And How To Use Them"

```
┌─────────────────────────────────────────────────┐
│                  AI Agent                        │
│                                                   │
│  ┌──────────┐    Skills流入    ┌─────────────┐  │
│  │ Knowledge│ ─────────────→ │   Agent    │  │
│  │ (Skills) │                │             │  │
│  └──────────┘                └──────┬──────┘  │
│                                     ↑         │
│  ┌──────────┐    数据管道      ┌──────┴──────┐  │
│  │Connectivity│ ←──双向协作── │    Tools    │  │
│  │   (MCP)   │                │  (MCP Server)│  │
│  └──────────┘                └─────────────┘  │
│                                                   │
└─────────────────────────────────────────────────┘
```

**核心理念**: MCP = "给 Agent 手"，Skills = "给 Agent 脑"

**借鉴价值**: 未来可支持 "skill-factory + MCP" 组合模式——skill 定义工作流，MCP 提供工具连接。

---

## 六、对比矩阵：我们 vs 官方 vs 理想态

| 能力维度 | 官方 skill-creator | 我们的 v2.0.1 | 理想态 (v3.0?) |
|---------|:-:|:-:|:-:|
| **创建技能** | ✅ 意图捕获→访谈→编写→eval | ✅ 需求→类型→TDD→模板→构建 | ✅ 两者融合 |
| **CSO 编写** | ✅ 手动规则 | ✅ R9 规则 | ✅ 规则 + 自动优化 |
| **CSO 评估** | ✅ **自动触发率 eval** | ❌ **手动** | ✅ **自动化** |
| **CSO 迭代优化** | ✅ **Claude API 自动** | ❌ 无 | ✅ **半自动** |
| **加工/优化** | ❌ 无 | ✅ 4种策略 | ✅ 策略 + AI 建议 |
| **质量审计** | ✅ quick_validate + run_eval | ✅ audit.ps1 (100分) | ✅ 两者结合 |
| **发布管理** | ❌ 无 | ✅ semver + git + 退役 | ✅ 自动 changelog |
| **合并/拆分** | ❌ 无 | ✅ 3模式 × 3维度 | ✅ + EvoSkill 评估 |
| **TDD 方法** | ⚠️ eval 驱动 | ✅ **RED/GREEN/REFACTOR** | ✅ **两者互补** |
| **类型分类** | ❌ 无 | ✅ **四维 Type 1-4** | ✅ **保留** |
| **模板库** | ❌ 无 | ✅ **Type 1-4 模板** | ✅ **保留** |
| **HTML 报告** | ✅ eval-viewer | ❌ 纯文本 | ✅ **可视化** |
| **技能负债检测** | ❌ 无 | ❌ 无 | ✅ stocktake 扫描 |
| **跨平台路径** | ✅ .agents/skills/ | ⚠️ 自定义路径 | ✅ 标准路径 |

---

## 七、改进路线图建议

### Phase 1: 快速补齐（1-2 天工作量）

| # | 改进项 | 来源 | 做法 | 预期收益 |
|---|--------|------|------|---------|
| 1.1 | **集成 skills-ref CLI** | 官方工具 | processor 新增 `npx skills-ref validate` 步骤 | 与国际标准对齐 |
| 1.2 | **CSO Eval Query 设计方法** | 官方优化指南 | creator/references/tdd-guide.md 新增章节 | 用户可自行评估 CSO 质量 |
| 1.3 | **意图捕获升级为 4 维** | 官方 Phase 1 | creator 第一步增加"输出格式"维度 | 更完整的技能定义 |
| 1.4 | **L4 Script 层概念** | AQUA 四层架构 | design-principles.md 更新三级→四级 | 概念清晰度提升 |

### Phase 2: 核心差异化（3-5 天工作量）

| # | 改进项 | 来源 | 做法 | 预期收益 |
|---|--------|------|------|---------|
| 2.1 | **CSO 优化脚本** | 官方 improve_description.py | 新增 scripts/optimize-description.sh | **最大短板补齐** |
| 2.2 | **审计 HTML 报告** | 官方 eval-viewer | audit.ps1 输出改为 HTML | 可视化审计结果 |
| 2.3 | **技能健康扫描** | @nogataka 经验 | processor 新增"stocktake 模式" | 项目级质量管理 |
| 2.4 | **EvoSkill 评估模式** | 中文社区 | assembler 合并时生成多候选+自动选优 | 合并质量保障 |

### Phase 3: 生态对齐（1-2 周工作量）

| # | 改进项 | 来源 | 做法 | 预期收益 |
|---|--------|------|------|---------|
| 3.1 | **标准路径 .agents/skills/** | 官方规范 | 生成的技能输出到标准路径 | 30+ 平台可直接使用 |
| 3.2 | **allowed-tools 字段** | 官方 spec | Front Matter 增加 allowed-tools 声明 | 安全性增强 |
| 3.3 | **MCP 集成模式** | Strapi 双引擎 | 支持 Skill + MCP 组合 | 企业级场景 |
| 3.4 | **license/compatibility 字段** | 官方 spec | Front Matter 补全 | 发布就绪度提升 |

---

## 八、结论与下一步

### 8.1 核心发现

1. **我们是独特的**: 除官方 skill-creator 外，社区中**没有其他元技能/技能工厂项目**
2. **我们更全面**: 功能覆盖范围远超官方（6 个维度 vs 1 个），在加工/发布/整合/TDD/类型体系上有独特优势
3. **最大短板是 CSO 自动化**: 官方的 `improve_description.py` + 触发率 eval 是我们最急需借鉴的能力
4. **社区趋势明朗**: Progressive Disclosure 是共识，技能负债是真实问题，标准化是解药

### 8.2 战略定位建议

```
                    专业化深度
                       ↑
    官方 skill-creator ●━━━━━━●  (创建专家)
                        ╲       ║
                         ╲ CSO  ║ 加工 ║ 发布 ║ 整合
                          ╚═════╝═════╝═════╝
    我们的 skill-factory ●━━━━━━●━━━━━●━━━━━●━━━━━● (全能工厂)
                       ↑
                   全流程覆盖广度
```

**定位语**: "skill-factory = 官方 skill-creator 的超集 —— 不仅帮你创建技能，还帮你加工、审计、发布和管理整个技能生命周期"

### 8.3 建议的下一步行动

1. **短期**: 实施 Phase 1 的 4 项快速补齐（集成 skills-ref + CSO eval 方法 + 意图4维 + L4概念）
2. **中期**: 开发 CSO 优化脚本（Phase 2.1），这是最高 ROI 的单项改进
3. **长期**: 逐步向 Phase 3 生态对齐靠拢

---

*报告完成于 2026-05-27，基于对 agentskills.io 官方文档、GitHub anthropics/skills 仓库、以及中日英技术社区的广泛调研。*
