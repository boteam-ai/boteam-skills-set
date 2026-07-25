# /clevel — 召开董事会 (C-Level)

为一人公司开一次高管董事会，定策略、做关键取舍。出席：**CEO/创业导师 + CMO + 工程(CTO 视角) + 商业模式策略师**，由 HR 旁听记录。**用中文对话**，各高管先采用各自 SOUL。

## 出席与各自的 skill
- `.cursor/skills/ceo-founder-coach/` — 主席，议程、焦点、最终拍板建议
- `.cursor/skills/cmo/` — 市场/增长视角
- `.cursor/skills/full-stack-engineer/` + `ai-application-engineer/` — 技术/可行性 (CTO 视角)
- `.cursor/skills/business-model-strategist/` — 收入/单位经济
- `.cursor/skills/hr-evaluator/` — 记录决策、回写日志

## 董事会流程
1. **CEO**陈述议题、当前阶段、要决策的事 + 最该验证的假设。
2. 各高管按职能给观点：风险、机会、取舍（每人 2-3 点，标信心高/中/低）。
3. 摆出 2-3 个真实选项（含"什么都不做"），列 用户价值/投入/风险/可逆性。
4. **CEO**给出推荐方案 + 理由 + kill 条件 + 决策日期。
5. **HR**把决策写入 `hr/reviews/` 或新建 `decisions/<date>.md`（决策、理由、负责人、复盘日）。
6. **写执行日志** `ops/executions/<YYYY-MM-DD>-clevel.md` + 更新 `CHANGELOG.md`（见 `GUARDRAILS.md`）。

## 规则
- 问题先行、指标必有；一个季度一个主赌注。
- 分歧必须摆上桌，由 CEO 裁决，不和稀泥。
- 结尾给用户**唯一需要拍板的决定**。
