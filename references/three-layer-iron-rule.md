# 三层架构铁律详细说明

> **来源**: [../SKILL.md](../SKILL.md) → 三层架构铁律章节  
> **版本**: v0.3.0

---

## 铁律定义

```mermaid
flowchart LR
    subgraph 铁律 ["⚖️ 三层架构铁律"]
        direction TB
        L0["Layer 0: 工厂根<br/>（入口/编排）"]
        L1["Layer 1: 协调器<br/>（调度/管控）"]
        L2["Layer 2: 执行者<br/>（操作/实现）"]
        
        L0 --> L1 --> L2
        
        MAX["🛑 层级深度 ≤ 3"]
    end
    
    style MAX fill:#ffcdd2,stroke:#d32f2f,color:#b71c1c,stroke-width:3px
    style 铁律 fill:#fff9c4,stroke:#fbc02d,color:#f57f17,stroke-width:2px
```

---

## 三层结构标准模板

| 层级 | 命名规范 | 职责特征 | 典型数量 |
|------|---------|---------|---------|
| **Layer 0** | `{skill-name}` | 全局入口、跨层编排 | 1 个 |
| **Layer 1** | `phase-{name}` 或 `{domain}-coordinator` | 阶段调度、质量门禁 | 2-6 个 |
| **Layer 2** | `{specific-worker}` | 单一职责操作 | 5-20+ 个 |

---

## 为什么是三层？

```mermaid
mindmap
  root((为什么最多三层?))
    认知科学
      米勒定律 7±2
      三层最佳平衡点
      降低认知负担
    软件工程
      模块化原则
      单一职责
      高内聚低耦合
    实践验证
      50+技能可扩展性
      维护成本可控
      新用户易上手
    架构美学
      目录即文档
      自解释结构
      符合直觉
```

---

## 层级深度计算方法

```
计算规则：
- 从技能根目录（SKILL.md）开始计数
- 每深入一级子目录 +1
- references/ 和 scripts/ 不算层级（辅助资源）

示例：
✅ skill-factory/SKILL.md                              = Layer 0 (1层)
✅ skills/phase-production/SKILL.md                     = Layer 1 (2层)
✅ skills/phase-production/researcher/SKILL.md          = Layer 2 (3层) ✓
❌ skills/phase-production/researcher/sub-worker/SKILL.md = Layer 3 (4层) ✗ 违规！
```

---

## 强制执行机制

```mermaid
flowchart TD
    A[开始创建技能] --> B{层级深度检测}
    
    B -->|≤3层| C[✅ 继续创建]
    B -->|4层| D[🛑 触发超层机制]
    B -->|≥5层| E[🚨 严重警告]
    
    D --> F{是否真的需要?}
    
    F -->|可以拆分| G["方案A: 拆为多个<br/>3层内的独立技能"]
    F -->|确实需要| H["方案B: 征求用户同意<br/>+ 记录特殊原因"]
    
    H --> I{用户同意?}
    I -->|是| J[⚠️ 创建并标记]
    I -->|否| K[重新设计]
    
    style C fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style G fill:#a5d6a7,stroke:#2e7d32,color:#ffffff
    style J fill:#fff9c4,stroke:#fbc02d,color:#f57f17
    style K fill:#ffcc80,stroke:#ef6c00,color:#e65100
    style D fill:#ef9a9a,stroke:#c62828,color:#b71c1c
    style E fill:#ef5350,stroke:#d32f2f,color:#ffffff
```

---

## 违规处理策略

| 层级深度 | 处置方式 | 是否需要确认 |
|---------|---------|------------|
| **1-3层** | ✅ 正常流程 | 否 |
| **4层** | ⚠️ 先尝试拆分，若无法拆分则征求用户同意 | **是** |
| **≥5层** | 🚨 必须重新设计，强制拆分为多个技能 | **必须** |

---

## 常见的"假性超三层"场景

| 场景 | 实际情况 | 正确做法 |
|------|---------|---------|
| 技能有多个子功能 | 功能复杂但可拆分 | 使用 **重+薄** 技能族模式（仍在3层内） |
| 需要引用外部文档 | 内容丰富 | 放入 `references/` （**不算层级**） |
| 有配置文件/脚本 | 辅助资源 | 同级目录存放（**不算层级**） |
| 动态加载模块 | 运行时行为 | 在 SKILL.md 内描述逻辑（不增加物理层级） |

---

## 相关链接

- [skill-factory 主文件](../SKILL.md)
- [超三层处理 SOP](./over-three-layer-sop.md)
- [工厂架构详情](./factory-architecture.md)
