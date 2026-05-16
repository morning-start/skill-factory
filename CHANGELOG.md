# Changelog

All notable changes to the **Skill Factory** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/).

---

## [v0.5.1] - 2026-05-16

### 🔧 回溯审计全面修复

基于 v0.3.1→v0.5.0 变更链的回溯审计，修复过度删除、价值流失、跨文件不一致等 16 项问题。

#### 高优先级修复
- ✨ **D1**: creator 加工操作表从名称列表升级为含技巧要点的操作指南（4 列：操作/用途/何时用/关键技巧）
- ✨ **D3**: design-principles 新增"超三层处理 SOP"章节（检测→分析→方案→确认→标记 5 阶段 + 用户确认话术模板）
- ✨ **U1**: 根 SKILL.md "这是什么？"升级为完整定位页（痛点表格 + 适用场景 + 不适用场景）
- ✨ **I2**: publisher/assembler 补充 writing-rules 引用（跨文件引用对称完成）

#### 中优先级修复
- ✨ **U2**: 快速开始表 creator/assembler 行增加描述（结构对称）
- ✨ **U3/U4**: creator 生产流水线新增入口分流（新建/优化/检查规范 三路分流）
- ✨ **I3**: design-principles 版本判定表补充 refactor + 类型升级行（与 publisher 对齐）
- ✨ **I1**: assembler 合并后生成内容可回引 creator
- ✨ **U5**: publisher 注意事项版本号例子更新为 v0.5.x 系列
- ✨ **U6**: assembler 拆分维度扩展（新增 design-system/api-docs 非编程领域示例）

### 📊 版本统计

| 维度 | v0.5.0 | v0.5.1 | 变化 |
|------|--------|--------|------|
| 文件数 | 7 | 7 | 不变 |
| 总行数 | ~1050 | **~1400** | +33% |
| 设计模式 | 11 | 11 | 不变 |
| 跨文件引用 | 不对称 | **全对称** | publisher/assembler 各 3 引用 |

---

## [v0.5.0] - 2026-05-16

### ✍️ 写作高级规则模块（执行层补充）

基于第二轮外部搜索（agentskills.io / hiddentao.com 28 条规则 / agent-almanac / CSDN 技能教程）发现的 7 项高价值缺失内容。

#### 🆕 新增核心文件
- **`references/writing-rules.md`** (~173 行)：技能写作高级规则，7 个章节：
  - R1: **Gotchas 坑点清单** — 6 个环境级陷阱（查询条件遗漏/API 版本不匹配/字段歧义/时区陷阱/编码问题/权限默认值）
  - R2: **反模式命名 + 失败模式** — 4 个反模式（泛泛指令/选项菜单/隐含假设/禁令无替代方案），每个配失败原因和正确做法
  - R3: **Happy Path First** — 排序原则：90% 场景前置、Quickstart 覆盖端到端、边缘情况后置
  - R4: **错误处理矩阵** — 5 类异常（输入/工具/数据/权限/超时）各有触发条件→处理方式→反馈信息→是否重试
  - R5: **Plan→Validate→Execute 验证循环** — 二进制验证标准（拒绝"代码整洁"，要求"`eslint` exit code = 0"）
  - R6: **复杂度分级** — basic(<5步)/intermediate(5-10步)/advanced(>10步) 三级定义
  - R7: **默认值优于选项菜单** — Agent 选择弱点分析 + 3 组对比示例

#### 升级现有文件
- ✨ `skill-standards.md`: 新增"写作质量检查"章节（注意事项升级要求表 + 反模式速查表），常见问题 9→13 条
- ✨ `skill-factory-creator/SKILL.md`: 新增"写作规则速查"章节（排序原则/规则配对公式/反模式三段式/验证清单规范/复杂度自检）
- ✨ 根 SKILL.md: 设计模式表 7→11 个（新增 Happy Path First / 反模式命名 / 验证循环 / 错误处理矩阵）

#### 来源引用
| 来源 | 贡献内容 |
|------|---------|
| [agentskills.io](https://agentskills.io/skill-creation/best-practices) | Gotchas 概念、默认值原则 |
| [hiddentao.com](https://hiddentao.com/archives/2026/04/26/the-definitive-guide-to-writing-great-skill-files-for-ai-agents/) | 28 条写作规则、反模式命名、Happy Path First |
| [agent-almanac](https://github.com/pjt222/agent-almanac/blob/main/guides/creating-skills.md) | Plan→Validate→Execute、复杂度分级 |
| [CSDN 技能教程](https://blog.csdn.net/weixin_44673517/article/details/158839657) | 错误处理矩阵 |

### 📊 版本统计

| 维度 | v0.4.1 | v0.5.0 | 变化 |
|------|--------|--------|------|
| 文件数 | 6 | **7** | +1 (writing-rules.md) |
| 总行数 | ~888 | **~1050** | +18% |
| 设计模式 | 7 | **11** | +4 |
| references | 2 | **3** | +1 |

---

## [v0.4.1] - 2026-05-16

### 📚 质量审计与外部最佳实践补充

基于 repo-analyzer 审计报告（13 个问题）+ 外部搜索（agentskills.io / Anthropic 官方）的优化。

#### P0 修复（影响正确性）
- ✅ 层级模板与实际结构矛盾 → 统一为"轻量工坊 + 完整工厂"双模式
- ✅ 旧版命名残留（researcher/standardizer/coordinator/worker）→ 全部替换为中文描述
- ✅ design-principles 嵌套模式描述错误（B→C 应为 B 嵌入 A）

#### P1 修复（影响用户体验）
- ✅ 版本历史行数 1,500→800 修正
- ✅ publisher "四级" vs "五项"矛盾修复
- ✅ "协调器" vs "阶段指南"术语统一
- ✅ 三个子技能补全"任务目标"+"注意事项"必备章节
- ✅ 根 SKILL.md 补充示例章节 + 注意事项

#### P2 优化（提升规范合规性）
- ✅ creator/assembler 拆分内容去重（creator 引用 assembler）
- ✅ skill-standards 补充轻量工坊 + 完整工厂双套命名规范

#### 🆕 新增内容（来自外部最佳实践）
- ✨ **Progressive Disclosure**：Skills 三阶段加载机制（Discovery→Activation→Execution）
- ✨ **Token 效率原则**：最小高信号 token 集原则 + 5 条实操建议
- ✨ **description 编写 4 条规则**：触发信号、关键词、单行、防歧义
- ✨ **scripts/ + assets/ 目录约定**：完整技能目录结构模板
- ✨ 设计模式表扩展至 7 个（新增渐进加载、Token 效率）
- ✨ skill-standards 常见问题表扩展至 9 条
- ✨ metadata.json 同步更新（行数、新概念、加工策略术语）

---

## [v0.4.0] - 2026-05-16

### 🔧 工坊模式重构（重大变更）

基于 [ANALYSIS_REPORT.md](ANALYSIS_REPORT.md) 的架构分析结果，将工厂模式重构为工坊模式。

#### 精简结构：18 文件 → 6 文件
- 📦 从 6,000 行精简至 ~1,000 行（减少 83%）
- 🗂️ 从 18 个 SKILL.md 文件精简为 4 个
- 📊 从 107 个 Mermaid 图表精简至 ~15 个
- 🏷️ 从 Type 4（重+厚）降至 Type 2（重+薄）

#### 核心变更
- ✨ 重写根 **SKILL.md** 为工坊模式入口 (~216 行)
- ✨ 新建 **references/design-principles.md**：合并旧的三层铁律 + SOP + 工厂架构 + 发布路径等 4 个参考文档 (~138 行)
- ✨ 新建 **references/skill-standards.md**：合并旧的 packager + standardizer + beautifier 规范职责 (~110 行)
- ✨ 新建 **skills/skill-factory-creator/SKILL.md**：合并生产 5 步流水线 + 加工 4 种策略 (~177 行)
- ✨ 新建 **skills/skill-factory-publisher/SKILL.md**：合并发布 3 步 + 销毁流程 (~168 行)
- ✨ 新建 **skills/skill-factory-assembler/SKILL.md**：从 Enricher 独立出的整合器 (~184 行)

#### P0 修复
- ✅ 统一版本号：所有文件统一为 v0.4.0
- ✅ 职责分离：Standardizer 与 Packager 合并为统一的 skill-standards.md 评分体系
- ✅ 层级修正：layers 从 3 修正为 2（旧版协调器→执行者的两层已合并）

#### P1 修复
- ✅ 合并 Phase-destruction 协调器至 destroyer（发布器统一处理）
- ✅ Assembly 从 Enricher 独立为 skill-factory-assembler

#### P2 修复
- ✅ 13 执行者 → 3 个阶段指南（creator/publisher/assembler）
- ✅ SOP 182 行 → design-principles.md 中的超三层处理章节（~20 行）
- ✅ 废弃旧文件：4 个协调器 + 13 个执行者 SKILL.md
- ✅ 废弃旧 references：three-layer-iron-rule.md / over-three-layer-sop.md / factory-architecture.md

#### 设计哲学变更
- 🏭→🔧 从"工厂操作系统"转变为"工坊设计指南"
- 📖 从"需要学习元系统"转变为"可随时查阅的模式目录"
- ⚡ 从"每个概念必有独立文件"转变为"内容驱动而非架构驱动"

### 📊 版本统计

| 维度 | 旧版 (v0.3.1) | 新版 (v0.4.0) | 变化 |
|------|-------------|-------------|------|
| 文件数 | 18 | 6 | -67% |
| 总行数 | ~6,000 | ~1,000 | -83% |
| Mermaid 图表 | 107 | ~15 | -86% |
| 架构层级 | 3 | 2 | 简化 |
| 技能类型 | Type 4 | Type 2 | 降级 |

---

## [v0.3.0] - 2026-05-01

### ⚖️ 核心理念升级（重大变更）

#### 三层架构铁律内化
- 🏛️ **新增核心章节**：「⚖️ 三层架构铁律（Core Principle）」作为独立一级章节
  - 铁律定义与可视化（Mermaid 流程图）
  - 三层结构标准模板（命名规范、职责特征）
  - **为什么是三层？** 理论基础（认知科学 + 软件工程 + 实践验证）
  - 层级深度计算方法（含正误示例对比）
  - **强制执行机制**（自动检测流程图）
  - 违规处理策略表（1-3层/4层/≥5层的处置方式）
  - 常见"假性超三层"场景及解决方案
- 📝 **前言区强化**：
  - `description`: 明确标注"**严格遵循三层架构铁律**"和"**层级深度≤3层**"
  - `tags`: 新增 `max-three-layers`, `layer-constraint` 标签
  - `dependency.architecture`: 新增 `max_layers_allowed: 3` 字段
  - `dependency.core_principle`: 新增核心理念定义段（name/definition/enforcement）

#### 超三层处理标准程序（SOP）
- 🚨 **新增完整 SOP 章节**：「🚨 超三层处理流程（SOP v0.3.0）」
  - 触发条件定义（4 种场景 + 自动检测机制）
  - **标准处理流程图**（4 步：暂停→分析→拆分→确认）
  - **详细步骤说明**：
    - Step 1-2: 暂停与分析（根因识别）
    - Step 3: 拆分方案设计（技能族模式推荐 + 目录结构对比）
    - **拆分决策树**（功能/场景/角色三维拆分策略）
    - Step 4: 用户确认流程（备选方案）
      - 超三层架构申请模板（标准化格式）
      - 用户同意时的特殊标记规范（YAML 元数据）
      - 用户不同意时的回退机制
  - 处理结果记录规范（4 个必填字段）

### 🔧 生产阶段增强

#### 层级检查嵌入
- ⚠️ 生产阶段新增 **三层铁律检查点** 说明
- 🔄 **生产流程图更新**：
  - planner 节点：添加"🛑 层级深度预检"
  - generator 节点：添加"⚠️ 层级合规验证"
  - packager 节点：添加"✅ 最终层级确认"
- 📋 **执行者职责更新**：
  - planner: 新增"层级深度预检"职责 + "层级合规性评估"
  - generator: 新增"层级结构生成"职责 + "确保输出≤3层"
  - packager: 新增"最终层级确认"职责 + "层级深度校验"

### ⚙️ 加工阶段优化

#### 层级合规维护
- ⚠️ 加工阶段新增 **三层铁律优化点** 说明
- 🔄 **加工流程图更新**：拆分模式节点添加"🛑 确保拆分后≤3层"
- 📋 **simplifier 操作表更新**：原子拆分效果增加"确保每个子技能≤3层"
- 📋 **拆分模式说明增强**：
  - 输出示意图增加层级警示注释
  - 新增"**三层铁律约束**"条目

### 🎨 架构可视化增强

#### 工厂全景架构图
- 🖼️ 架构图新增 **MAX_DEPTH 警示节点**
  - 显示文本："🛑 最大深度: 3层 / ⚠️ 严禁超过!"
  - 样式：红色背景 (#ffcdd2) + 粗边框 (3px)
- 📝 架构图下方新增 **层级警示说明**
  - 强调 Layer 2 为最深层级
  - 明确禁止在执行者下再创建子层级

### 📊 版本统计

| 维度 | 数量 |
|------|------|
| 新增章节数 | 2 个（铁律 + SOP） |
| 更新章节数 | 4 个（前言区 + 生产 + 加工 + 架构图） |
| 新增 Mermaid 图 | 5 个 |
| 新增表格 | 6 个 |
| 代码行数变化 | ~+450 行 |

---

## [v0.2.0] - 2026-05-01

### 🏗️ 架构重构（重大变更）

#### 三层架构体系
- ✨ 新增 **Layer 1: 阶段协调器 (Phase Coordinator)** 层
- 📁 创建 4 个阶段协调器目录和 SKILL.md：
  - `skill-factory-phase-production` - 生产阶段协调器（5步流水线调度 + 快速路径判断）
  - `skill-factory-phase-processing` - 加工阶段协调器（策略选择 3种 + 循环保护机制）
  - `skill-factory-phase-publishing` - 发布阶段协调器（强顺序 version→metadata→release）
  - `skill-factory-phase-destruction` - 销毁阶段协调器（退役流程管理）
- 🔧 **物理目录重组**：13 个 worker 移入对应的 phase 子目录
- 📝 新增架构设计文档：[docs/three-layer-architecture.md](docs/three-layer-architecture.md)（9章节完整记录）

#### 元数据结构升级
- 🔄 `metadata.json` 从扁平 children 数组改为**嵌套 phases 结构**
- ➕ 新增字段：`architecture`, `phases[].coordinator`, `callback_mechanism`, `processing_strategies`, `versioning_rules`
- 📊 统计信息：`total_sub_skills: 13`, `phase_coordinators: 4`, `architecture_layers: 3`

### 🔒 稳定性修复 (T2.1)

#### 回调机制保护措施
- 🛡️ 新增 `callback_config` 配置段：
  - `max_callbacks: 3` （硬限制最大回调次数）
  - `cooldown_seconds: 60` （回调间隔冷却时间）
  - `auto_escalate_threshold: 2` （超过 N 次自动升级为人工介入）
  - `callback_history_log: true` （记录回调历史）
- 🔄 更新回调流程图，增加**保护逻辑**分支：
  - 次数检查 → 冷却期检测 → 自动升级触发
- 📊 增强时序示例，展示多次回调场景（含警告状态）
- 🧪 创建测试用例：`tests/researcher/test_callback_protection.yaml`（8个测试场景）

### ⚙️ 功能标准化 (T2.2)

#### 加工策略模式定义
- 📋 定义**三种标准加工策略**：
  - **精简优先 (Simplify-First)**: 初稿 >500 行时使用，S→E→ST 顺序
  - **丰富优先 (Enrich-First)**: 初稿 <200 行时使用，E→B→ST 顺序
  - **均衡模式 (Balanced)** ⭐ 推荐: 200-500 行默认选择，S→E→B→ST 完整流程
- 🎯 新增**策略选择决策树**（基于行数自动判定）
- 🛡️ 实现**循环保护机制**：
  - `max_processing_rounds: 3` （同技能最多加工 3 轮）
  - 循环模式检测（enrich→simplify 往复识别）
  - 效率下降预警（净变化 <5% 时警告）
- 📄 创建详细文档：[docs/processing-strategies.md](docs/processing-strategies.md)
- 🔗 更新 4 个加工器 SKILL.md 添加**策略引用**：
  - enricher/simplifier/beautifier/standardizer 各自标注在哪些策略中使用

### 🚀 性能优化 (T2.3)

#### 快速发布路径实现
- ⚡ 为 **Type 1（轻+薄）** 技能实现快速路径：
  - 跳过整个**加工阶段**（enricher/simplifier/beautifier/standardizer）
  - 预计耗时从 5h+ 缩减至 **30-40min**
  - **效率提升 85%+**
- 📐 在主 SKILL.md 添加**发布路径选择**章节：
  - 路径矩阵表（4 种类型 × 推荐路径 × 预计耗时）
  - 快速路径详细流程图（10 步 Mermaid 图）
  - 路径选择决策树（Planner 判定 → 路径分配）
- 🔧 更新 6 个子技能支持**快速模式**：
  - Researcher: 快速研究模式（10min vs 标准 20min，-50%）
  - Packager: 快速验证模式（3min vs 标准 15min，-80%）
  - Publisher-Version/Metadata/Release: 各自的简化流程
- 🧪 创建集成测试：`tests/fast-path/test_type1_release.yaml`（10 步端到端场景）

### 📏 规范完善 (T2.4)

#### 版本判定规则明确化
- 📖 创建完整规则文档：[docs/versioning-rules.md](docs/versioning-rules.md)
  - **9 大章节**覆盖所有判定场景
  - 4 种变更类型详解：Fix / Feature / Type Upgrade / Breaking
  - 类型转换矩阵（T1→T2/T3/T4 及反向）
  - 边缘场景速查表（12 种常见情况）
  - **快速 5 步判断法**（Breaking → Type Upgrade → Feature → Fix）
  - 常见误区纠正（4 个典型错误认知）
- 🔗 更新 Publisher-Version 引用新规则并添加速查表

### 🧪 测试套件建设 (T2.5)

#### 基础测试框架搭建
- 📁 创建测试框架指南：`tests/README.md`
  - 项目结构说明
  - 覆盖目标定义
  - 测试分类规范（Unit / Integration）
  - 用例编写规范

#### 单元测试（超额完成 🎉）
| 模块 | 用例数 | 目标 | 达成率 |
|------|--------|------|--------|
| researcher (callback) | 9 | - | ✅ |
| planner (type decision) | 5 | - | ✅ |
| packager (validation) | 5 | - | ✅ |
| publisher-version (versioning) | 4 | - | ✅ |
| analyzer (analysis) | 3 | - | ✅ |
| processing-strategies (strategy selection) | 5 | - | ✅ |
| **合计** | **31** | **≥25** | **124%** ✅ |

#### 集成测试（超额完成 🎉）
| 场景 | 用例数 | 目标 |
|------|--------|------|
| 生产流程端到端 | 3 | - |
| 加工流程端到端 | 3 | - |
| 快速路径集成 | 1 | - |
| 回调场景测试 | 3 | - |
| 循环检测中断 | 3 | - |
| Type1 跳过加工验证 | 3 | - |
| **合计** | **16** | **≥5** |

---

### 📝 文档与配置更新

#### 全局版本升级
- 📌 所有文件版本号从 `v0.1.0` 统一升级至 **`v0.2.0`**
  - metadata.json
  - 主 SKILL.md
  - 4 个阶段协调器 SKILL.md
  - 13 个执行者 SKILL.md

#### 路径引用修正
- 🔗 更新所有相对路径以匹配新的三层物理目录结构
- Worker 文件：`../SKILL.md` → `../../SKILL.md`（12 个文件批量修复）
- 主 SKILL.md 子技能索引：添加完整的 phase 路径前缀

#### Parent 引用重构
- 🔗 13 个 worker 的 `parent` 字段从 `skill-factory` 改为对应的 `phase-xxx`
- ➕ 新增 `layer: 2` 和 `phase: xxx` 标识字段

---

### 🗑️ 废弃与移除

#### 清理旧结构
- 🗑️ 删除 13 个旧的扁平空目录（worker 原位置）

---

## [v0.1.0] - 2026-04-XX

### 🎉 初始版本

#### 项目建立
- ✨ 从 skill-lifecycle 项目独立为单独项目
- 📋 定义四维分类体系（轻/重 × 薄/厚 = 4 种类型）
- 🏭 建立工厂隐喻的四阶段流水线模型：
  - ① 生产 (Production): researcher → analyzer → planner → generator → packager
  - ② 加工 (Processing): enricher / simplifier / beautifier / standardizer
  - ③ 发布 (Publishing): version → metadata → release
  - ④ 销毁 (Destruction): destroyer

#### 核心功能
- 📦 创建 13 个子技能的初始 SKILL.md
- 🔄 实现全程回调机制（researcher 可被后续阶段回调补充信息）
- 📐 定义四种输出结构模式（Type A/B/C/D 对应 Type 1/2/3/4）
- 🎯 实现场景快速路由（根据用户需求自动分发到对应阶段）

#### 文档
- 📖 创建主 SKILL.md 工厂入口文件
- 📊 创建 metadata.json 项目元数据
- 📘 初始版本无分析报告和计划文档（后续版本补充）

---

## 版本说明

### 版本号格式
```
v主版本.次版本.修订版本 (vX.Y.Z)
```

### 版本类型定义
| 类型 | 说明 | 示例 |
|------|------|------|
| **Major (主版本)** | 破坏性变更、接口修改、能力删除 | v0.1.0 → v1.0.0 (GA) |
| **Minor (次版本)** | 新功能、类型升级、内容扩展 | v0.1.0 → v0.2.0 (三层架构) |
| **Patch (修订版)** | Bug 修复、文字优化、小改进 | v0.2.0 → v0.2.1 |

### 变更类别图例
| 图标 | 类别 | 说明 |
|------|------|------|
| ✨ | 新功能 (Added) | 新增的功能或文件 |
- 🔄 | 变更 (Changed) | 现有功能的改动
- 🛡️ | 安全/保护 (Security) | 安全性增强或保护机制
- ⚡ | 性能 (Performance) | 性能优化或速度提升
- 🐛 | 修复 (Fixed) | Bug 修复
- 🗑️ | 移除 (Removed) | 删除的功能或文件
- 📋 | 文档 (Docs) | 文档相关变更

---

## 相关链接

- **代码仓库**: [skill-factory](./)
- **问题追踪**: [Issues](https://github.com/your-repo/skill-factory/issues)
- **架构设计**: [three-layer-architecture.md](docs/three-layer-architecture.md)
- **加工策略**: [processing-strategies.md](docs/processing-strategies.md)
- **版本规则**: [versioning-rules.md](docs/versioning-rules.md)
- **实施计划**: [plan/ROADMAP.md](docs/plan/ROADMAP.md)

---

> **维护者**: Skill Factory Core Team  
> **最后更新**: 2026-05-01  
> **下次发布**: v0.3.0 (预计 2026-06)
