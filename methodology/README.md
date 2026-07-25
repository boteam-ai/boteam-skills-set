# Methodology — 跨项目可复用方法论

存放 **第二次仍被验证**、可跨 App/SaaS 复用的做法（提炼后），不是某产品的 PRD 或一次性笔记。

## 什么放这里 ✅

- 经过 2+ 项目验证的流程（如「扩展上架 checklist」「solo SaaS 定价实验 SOP」）
- 从专家对话中提炼、且已写入某 expert `references/` 的摘要版
- 与 GUARDRAILS 一致：有来源、可链接到 `/source-skill`

## 什么不放这里 ❌

- 单个产品的 PRD、wireframe、用户访谈原文 → 产品仓库 / Notion
- 只用一次的技巧 → 不写；第二次再用再 `/distill-to-team`
- 无来源的临时 prompt

## 文件命名

`methodology/<topic-slug>.md` — 英文 slug，正文可中英混合。

## 创建方式

1. 对话中：`/distill-to-team <topic> — <一句话摘要>`
2. 或手动从 [templates/METHODOLOGY.template.md](../templates/METHODOLOGY.template.md) 创建
3. 必须：execution log + CHANGELOG 一行
