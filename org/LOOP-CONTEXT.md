# Loop Context — 组织 loop 启动清单

**任何组织级 run 开始前**，agent 必须先读完以下上下文（约 2 分钟），再执行命令本身。

适用：`/hr-review` · weekly cron · `/hire-expert` · `/clevel` · `/distill-to-team`

## Checklist

```
Loop pre-read:
- [ ] GUARDRAILS.md — 确认本次变更属于 team ✅ 而非产品 ❌
- [ ] CHANGELOG.md — [Unreleased] + 最近 1 个 dated section
- [ ] org/examples/ — review example execution log format if needed
- [ ] hr/ROSTER.md — 当前 active/probation/retired 数量
- [ ] (若改来源) source-skill/references/SOURCES-CATALOG.md
```

## 执行后（同一 turn 内完成）

```
Loop close-out:
- [ ] 若属「必须写 execution」事件 → ops/executions/<date>-<trigger>.md
- [ ] 更新 ops/executions/index.json（运行 scripts/update-execution-index.sh）
- [ ] 更新 CHANGELOG.md
- [ ] 若 touch 专家 → EVALUATION.md / ROSTER / catalog 同步
- [ ] 若提炼方法论 → methodology/<topic>.md
```

## 日常专家咨询（非组织 loop）

- **不要**写 execution log
- **可选**：`./scripts/log-expert-use.sh` 或 `/log-expert-use` → 仅 Layer 3

详见 [OBSERVABILITY.md](OBSERVABILITY.md)
