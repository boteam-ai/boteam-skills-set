---
name: lesson
description: >-
  Analyzes the root cause of a bug or error from the current conversation,
  then decides whether to update an existing Cursor rule to prevent recurrence.
  Default is no new rule — only add or change rules when the failure is
  systemic and generalizable. Use when the user invokes /lesson, asks to learn
  from a mistake, or wants to turn a recent error into a durable guardrail.
disable-model-invocation: true
---

# Lesson — 从错误中学习

从**当前对话**里刚出现的 bug / 错误出发，找底层原因，再判断要不要改 Cursor rule。**默认不加 rule**。

## 流程

```
1. 还原事件 → 2. 根因分析 → 3. 准入门槛 → 4. 改 rule（仅当通过）→ 5. 输出摘要
```

### 1. 还原事件

从对话中提取（缺信息就追问，但只问阻塞项）：

- **现象**：什么错了、用户/测试如何发现
- **直接原因**：哪段代码/哪步操作触发的
- **修复**：最终怎么解决的

### 2. 根因分析

用「5 个为什么」压到 **1–3 层**，区分：

| 类型 | 含义 | 典型处置 |
|------|------|----------|
| 偶发 / 上下文缺失 | 一次性误操作、信息不足 | 通常 **不改 rule** |
| 已有 rule 未遵守 | 规范存在但没被应用 | **强化现有 rule**，不新建 |
| 知识/流程缺口 | 会反复踩的系统性盲区 | 候选 **更新或新增 rule** |
| 应用层 bug | 逻辑错误、缺测试 | **优先修代码/加测试**，不是 rule |

输出一段 **根因结论**（2–4 句，说清「为什么会再犯」）。

### 3. 准入门槛（必须全部满足才改 rule）

**以下任一为 true → 停止，不改 rule，在摘要里说明理由：**

- [ ] 一次性事件，无复现路径
- [ ] 现有 rule 已覆盖，只是没执行 → 提醒遵守即可
- [ ] 用代码、类型、lint、测试、脚本能更好解决
- [ ] 规则只能描述极窄场景（< 2 次对话内不会再遇到）
- [ ] 新 rule 与已有 rule 重复或冲突

**仅当全部通过时**，才进入第 4 步。

额外原则：

- **能合并就不新建** — 先搜 `.cursor/rules/*.mdc` 和用户 rules，找可追加的同主题 rule
- **一条 rule 一个关切** — 不把无关教训堆进同一条
- **精简** — 新内容 ≤ 5 条要点或 1 个短示例；整条 rule 建议 < 50 行

### 4. 改 rule（仅当通过门槛）

**放置位置：**

| 范围 | 位置 | 何时用 |
|------|------|--------|
| 本项目 | `.cursor/rules/<name>.mdc` | 栈、目录结构、项目约定相关 |
| 跨项目个人习惯 | 用户 rule（`cursor_dialog`） | 通用编码/沟通习惯；**先征得用户同意** |

**操作顺序：**

1. `Glob` / `Grep` 列出并阅读相关现有 rules
2. **优先** `StrReplace` 更新已有 rule（追加一小节或强化一句）
3. 仅无合适载体时，新建 `.mdc`（含正确 `description`、`globs` 或 `alwaysApply`）
4. 用户 rule 变更：列出拟增删改内容，用户确认后再用 `cursor_dialog`

`.mdc` 格式参考 create-rule skill；示例：

```markdown
---
description: 简短说明何时生效
globs: "**/*.{ts,tsx}"
alwaysApply: false
---

# 标题

- 具体可执行的约束（不要写空话）
```

### 5. 输出摘要

用中文回复，固定结构：

```markdown
## 事件
[1–2 句]

## 根因
[底层原因，非表面现象]

## Rule 决策
**[不改 / 更新 `<path>` / 新建 `<path>` / 建议用户 rule]**

理由：[1–3 句，说明为何够格或为何拒绝]

## 变更（若有）
- 文件：`...`
- 内容：[改了什么，或拟议文案]
```

## 反模式

- ❌ 每个小错都加 rule → 上下文膨胀、互相冲突
- ❌ 把具体 bug 细节写进 rule → 应抽象成可复用约束
- ❌ 重复已有 user rule 或 project rule
- ❌ 未经用户确认就写用户级 rule

## 示例

**场景**：Agent 在未读 schema 的情况下调用了 MCP 工具导致参数错误。

- 根因：流程缺口 — 缺「先读 descriptor 再调用」的硬性步骤
- 门槛：MCP 调用会反复发生 → 通过
- 决策：更新现有 `mcp-usage.mdc`（若有）追加一条；无则新建 scoped rule，**不**写 alwaysApply

**场景**：拼写错误导致变量名 typo。

- 根因：偶发
- 决策：**不改 rule** — linter/IDE 已足够
