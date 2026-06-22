# 🤖 Choosing Your AI Models (and what they cost)

RoleRadar uses AI ("LLMs" — large language models) to read job posts, score them, and write your documents.
This page explains **which models it uses, what else you can use, and roughly what each costs per job** — in
plain language. If you just want it to work, the defaults are sensible; skim the [presets](#cost-per-application)
and move on.

> **One key idea:** RoleRadar talks to every model through **[OpenRouter](https://openrouter.ai)** — a single
> account and API key that gives you access to hundreds of models from OpenAI, Anthropic, Google, DeepSeek and
> more. **To change a model, you just change a short text name (a "slug") in one config box.** No new accounts,
> no code.

---

## Where the AI is actually used

Phases 1 and 1.5 use **no AI** (just LinkedIn + Google) — they're free. All AI cost comes from Phase 2 and 3:

| AI job | Phase | Config setting | Default model | What "good" looks like |
|--------|-------|----------------|---------------|------------------------|
| Score & analyze a job | 2 | `SCORING_MODEL` | DeepSeek (budget) | Reliable JSON, cheap, fast — it runs on *every* job |
| Write your CV | 3 | `CV_MODEL` | Claude Sonnet (premium) | Natural, human-sounding, keyword-smart |
| Write your cover letter | 3 | `CL_MODEL` | Claude Sonnet (premium) | Warm, specific, not robotic |
| SWOT analysis | 3 | `SWOT_MODEL` | DeepSeek (budget) | Structured JSON, clear reasoning |
| Interview study guide | 3 | `STUDY_MODEL` | DeepSeek (budget) | Long, organized, practical |

**Why mix cheap and premium?** Scoring and analysis just need clean structured output, so a cheap model is
perfect. Your **CV and cover letter are what a recruiter actually reads**, so those get the best writer. This
"hybrid" split is the default — great results for a few cents.

---

## What each job needs (so you can choose well)

- **Scoring & SWOT** → must return tidy **JSON**, run often, and stay cheap. *Reliability and price matter more
  than eloquence.* → a budget model is ideal.
- **CV & cover letter** → must read like a **real person** wrote them and follow detailed instructions. *Writing
  quality matters most.* → a premium model pays for itself.
- **Study guide** → long, helpful, well-organized. *A budget model is fine.*

---

## Model options & trade-offs

All of these work by pasting their OpenRouter slug into the matching config box. Exact slugs and live prices are
on **<https://openrouter.ai/models>** (model names change over time — always copy the current one).

| Model family | Good at | Watch out for | Best used for | Price tier |
|--------------|---------|---------------|---------------|-----------|
| **DeepSeek** (e.g. `deepseek/…`) | Very cheap, solid reasoning & JSON | Writing can feel slightly less natural | Scoring, SWOT, study guide | 💲 Budget |
| **Anthropic Claude Sonnet** | Best-in-class natural writing, follows instructions closely | Most expensive | CV, cover letter | 💲💲💲 Premium |
| **Anthropic Claude Haiku** | Cheaper Claude, still writes well | A step below Sonnet on nuance | Budget CV/cover letter | 💲💲 Mid |
| **OpenAI GPT (4-class & "mini")** | Strong all-rounder, great JSON | "mini" less eloquent for CVs | Anything; mini for scoring | 💲–💲💲💲 |
| **Google Gemini (Flash / Pro)** | Flash is cheap & fast, huge context, strong multilingual | Flash less polished for prose | Scoring, non-English job posts | 💲–💲💲 |
| **Open models (Llama, Qwen, Mistral)** | Cheapest (sometimes free), private if self-hosted | Quality varies; weaker instruction-following | Experiments, max privacy/budget | 💲 / free |

**Rule of thumb:** keep a **budget** model for scoring/SWOT/study, and spend on a **premium** model only for the
CV and cover letter.

---

## Cost per **job** — the simple math

You're only ever charged for the text in and out. The formula:

```
cost = (input tokens × input price) + (output tokens × output price)
```

A "token" is roughly ¾ of a word. Typical amounts RoleRadar sends/receives per AI call:

| AI call | Input tokens (≈) | Output tokens (≈) |
|---------|------------------|-------------------|
| Score a job | 2,500 | 900 |
| CV | 2,800 | 3,000 |
| Cover letter | 2,500 | 600 |
| SWOT | 2,500 | 1,500 |
| Study guide | 2,500 | 2,500 |

Because you control the model, **any price works** — just multiply by the per-million-token price shown on the
model's OpenRouter page.

---

<a id="cost-per-application"></a>
## Cost per **application** — three ready presets

The numbers below are **illustrative** (real prices change — check OpenRouter). They assume these example
prices per **1M tokens** (input / output): **Budget** $0.30 / $1.20 · **Premium** $3.00 / $15.00.

| Preset | CV + cover letter | SWOT + study guide | ≈ Cost per full application | Best for |
|--------|-------------------|--------------------|-----------------------------|----------|
| **All-Budget** | DeepSeek | DeepSeek | **~$0.012** (about 1¢) | High volume, tight budget |
| **Hybrid** *(default)* | Claude Sonnet | DeepSeek | **~$0.08** (about 8¢) | Best value — recruiter-ready docs, cheap analysis |
| **All-Premium** | Claude Sonnet | Claude Sonnet | **~$0.15** (about 15¢) | When you want the very best of everything |

**Scoring (Phase 2)** is separate and tiny: on a budget model it's **~$0.002 per job** — so screening **200
jobs costs roughly $0.40**. (Avoid a premium model for scoring; it'd cost ~10× more for no benefit.)

> 💡 Real-world monthly cost for most people is **a few dollars**, dominated by how many CVs you actually
> generate — not by scoring.

---

## How to change a model (about 1 minute)

1. Open the workflow (Phase 2 or Phase 3) in n8n.
2. Click the first box — **`Load Config`** (Phase 2) or **`Set Job ID`** (Phase 3).
3. Find the setting (e.g. `CV_MODEL`) and paste a current slug from <https://openrouter.ai/models>.
4. **Save.** Done — the next run uses the new model.

There's also a **cheaper preset built in**: Phase 3 contains disabled "Quality First" / "Hybrid" example nodes.
To use one, enable it and disable the matching premium node. (Update its slug to a current one first.)

---

## Privacy note

Whichever model you choose **sees the job description and your profile**. Use a provider you're comfortable with
and check its data-retention policy on OpenRouter. For maximum privacy, you can run an **open model** (Llama,
Qwen, Mistral) — either via OpenRouter or self-hosted.

## A reliability tip

The scoring and SWOT steps ask the model for **JSON**. If you switch to a model that "thinks out loud" or has a
small output limit, JSON can get cut off. RoleRadar already guards against this (it cleans and repairs the
output and retries), but if you see lots of `Needs Review` rows, it usually means a **wrong/retired model
slug** — re-check the name on OpenRouter. See [SETUP → Troubleshooting](SETUP.md#troubleshooting).
