# Changelog

All notable changes to the **Skill Factory** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/).

---

## [Unreleased]

### 计划中
- v0.4.0: 工程化基础（自动化测试、数据流验证）
- v0.5.0: 功能增强（CLI 工具、diff 预览）
- v0.7.0: 高级特性（本地技能注册中心）
- v1.0.0: GA 里程碑（生产就绪）

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
