# /log-expert-use — 轻量专家调用记录（Layer 3）

日常单次专家咨询**不必**写 execution log。用本命令只记一行 usage，供 `/hr-review` 当 evidence。

**用中文确认**，数据写入英文/JSON 字段。

## 用法

```
/log-expert-use <slug> <1-5> <一句话 note> [project]
```

示例：`/log-expert-use product-manager 5 "Scoped MVP for extension" my-chrome-app`

## 执行

1. 确认 slug 在 `hr/ROSTER.md` 且存在 `.cursor/skills/<slug>/EVALUATION.md`。
2. 运行：
   ```bash
   ./scripts/log-expert-use.sh <slug> <score> "<note>" [project]
   ```
3. 向用户中文确认：已记入 `ops/usage/index.json` + 该专家 `EVALUATION.md` usage log。

## 规则（GUARDRAILS + OBSERVABILITY）

- **不**写 `ops/executions/`（除非同时提炼了组织知识 → 用 `/distill-to-team`）。
- **不**更新 CHANGELOG（日常咨询级别）。
- 若 note 含可复用方法论且是第二次验证 → 建议用户改跑 `/distill-to-team`。
