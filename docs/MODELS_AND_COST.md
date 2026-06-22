# Models — technical reference

All model choices are **centralized** in the config (`Set`) node of each workflow. Changing a model is a
one-line edit — you never have to touch the HTTP nodes or hunt through JSON.

> 🤖 **New here, or want to pick the right model and see costs per job?** Read the friendly
> **[Choosing Your AI Models guide](LLM_GUIDE.md)** — model options, pros/cons, and cost analysis per
> application. This page is the quick technical reference.

## Where each model is set

| Config variable | Workflow | Used by | Default | Purpose |
|-----------------|----------|---------|---------|---------|
| `SCORING_MODEL` | Phase 2 | `P2: DeepSeek AI Scoring` | `deepseek/deepseek-v4-flash` | Score + analyze each job (cheap, fast, JSON). |
| `CV_MODEL` | Phase 3 | `P3: OpenRouter Generate CV` | `anthropic/claude-sonnet-latest` | Highest-quality tailored CV. |
| `CL_MODEL` | Phase 3 | `P3: OpenRouter Generate Cover Letter` | `anthropic/claude-sonnet-latest` | Human-sounding cover letter. |
| `SWOT_MODEL` | Phase 3 | `P3: OpenRouter Generate SWOT` | `deepseek/deepseek-v4-flash` | Structured SWOT JSON. |
| `STUDY_MODEL` | Phase 3 | `P3: OpenRouter Generate Study Guide` | `deepseek/deepseek-v4-flash` | Interview study guide (Markdown). |

> ⚠️ **Model slugs change over time.** Before your first run, open <https://openrouter.ai/models>, copy the
> exact slug you want, and paste it into the config node. A wrong/retired slug is the #1 cause of
> `Needs Review` rows (the API returns an error body with no `choices`, which can't be parsed).

## How to swap a model

1. Open the workflow → the first **config / `Set`** node.
2. Edit the relevant `*_MODEL` value (e.g. set `SCORING_MODEL` to a different OpenRouter slug).
3. Save and re-run. That's it — the request body reads the value from config.

## Cost & cost-saving presets

Full cost analysis (per job and per application, with three ready presets) lives in the
**[Choosing Your AI Models guide →](LLM_GUIDE.md#cost-per-application)**.

Quick version: Phases 1 & 1.5 use no AI (free). Scoring costs a fraction of a cent per job; a full application
pack (CV + cover letter + SWOT + study guide) costs roughly **1–15¢** depending on whether you use budget or
premium writers. Phase 3 also ships **disabled** "Quality First" / "Hybrid" example nodes for cheaper setups —
enable one, disable the matching premium node, and update its slug.

## Why JSON-returning calls are hardened

Phase 2 (scoring) and Phase 3 (SWOT) ask the model for JSON. The parser nodes now:

- strip ```` ```json ```` fences **and** `<think>…</think>` reasoning blocks,
- extract the outermost `{ … }` before `JSON.parse`,
- raise `max_tokens` so reasoning models don't truncate the JSON,
- send `response_format: {type: "json_object"}`,
- and on any failure write `status = Needs Review` (with the raw error) instead of silently scoring 0 or
  shipping a broken document.
