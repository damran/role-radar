# Models & Cost

All model choices are **centralized** in the config (`Set`) node of each workflow. Changing a model is a
one-line edit — you never have to touch the HTTP nodes or hunt through JSON.

## Where each model is set

| Config variable | Workflow | Used by | Default | Purpose |
|-----------------|----------|---------|---------|---------|
| `SCORING_MODEL` | Phase 2 | `P2: DeepSeek AI Scoring` | `deepseek/deepseek-v4-flash` | Score + analyze each job (cheap, fast, JSON). |
| `CV_MODEL` | Phase 3 | `P3: OpenRouter Generate CV` | `anthropic/claude-sonnet-4.5` | Highest-quality tailored CV. |
| `CL_MODEL` | Phase 3 | `P3: OpenRouter Generate Cover Letter` | `anthropic/claude-sonnet-4.5` | Human-sounding cover letter. |
| `SWOT_MODEL` | Phase 3 | `P3: OpenRouter Generate SWOT` | `deepseek/deepseek-v4-flash` | Structured SWOT JSON. |
| `STUDY_MODEL` | Phase 3 | `P3: OpenRouter Generate Study Guide` | `deepseek/deepseek-v4-flash` | Interview study guide (Markdown). |

> ⚠️ **Model slugs change over time.** Before your first run, open <https://openrouter.ai/models>, copy the
> exact slug you want, and paste it into the config node. A wrong/retired slug is the #1 cause of
> `Needs Review` rows (the API returns an error body with no `choices`, which can't be parsed).

## How to swap a model

1. Open the workflow → the first **config / `Set`** node.
2. Edit the relevant `*_MODEL` value (e.g. set `SCORING_MODEL` to a different OpenRouter slug).
3. Save and re-run. That's it — the request body reads the value from config.

## Cost (rough, order-of-magnitude)

Costs depend entirely on the models you pick and on prompt/response length. With the cheap DeepSeek default for
scoring and a premium Claude model for the final documents, a typical run looks like:

| Step | Model class | Tokens (≈) | Indicative cost |
|------|-------------|-----------|-----------------|
| Score one job (Phase 2) | budget (DeepSeek) | ~2–4k | fractions of a cent |
| CV + cover letter (Phase 3) | premium (Claude Sonnet) | ~6–8k | a few cents |
| SWOT + study guide (Phase 3) | budget (DeepSeek) | ~6–8k | ~a cent |

**Net:** scoring hundreds of jobs costs cents; generating a full application pack costs a few cents each. Check
live per-model pricing on the OpenRouter model page — it's printed next to every slug.

## Cost-saving presets

Phase 3 ships with **disabled** alternative nodes (`… - Quality First`, `… - Hybrid Smart`) showing cheaper
model setups. To use one, enable the alternative node and disable the premium one with the same role. Update its
hardcoded slug to a current one first.

| Preset | CV / CL model | Relative cost |
|--------|---------------|---------------|
| Full Premium (default) | Claude Sonnet | 1× |
| Quality-First | Claude Haiku | ~0.4× |
| Hybrid Smart | DeepSeek | ~0.2× |

## Why JSON-returning calls are hardened

Phase 2 (scoring) and Phase 3 (SWOT) ask the model for JSON. The parser nodes now:

- strip ```` ```json ```` fences **and** `<think>…</think>` reasoning blocks,
- extract the outermost `{ … }` before `JSON.parse`,
- raise `max_tokens` so reasoning models don't truncate the JSON,
- send `response_format: {type: "json_object"}`,
- and on any failure write `status = Needs Review` (with the raw error) instead of silently scoring 0 or
  shipping a broken document.
