# 🏗️ Rebuild RoleRadar from scratch

This is the complete specification needed to **rebuild RoleRadar without the provided JSON** — the data model,
the four workflows' input/output contracts, the LLM prompt→JSON contracts, and the credential model. If you
implemented this on any automation platform (n8n, Make, a few scripts), you'd get the same system.

## 1. Components

| Component | Role |
|-----------|------|
| **n8n** | Orchestration — 4 workflows (Discover, Archive, Score, Generate). |
| **Google Sheets** | The single source of truth / state store. |
| **Google Drive** | Stores generated documents (one folder per application). |
| **OpenRouter** | LLM gateway (one key → many models). |
| **Job source** | Currently LinkedIn's public guest endpoint (scraped). *Recommended for a robust rebuild: an official/licensed jobs API.* |

**Credentials (referenced by name only; never inline a key):**
- Google Sheets OAuth2 · Google Drive OAuth2 · OpenRouter via **HTTP Header Auth** (`Authorization: Bearer sk-or-…`).

## 2. Data model — the Google Sheet

### Tab `Filter` (input to Discover) — one row per search
`Keyword, Location, Experience Level, Remote, Job Type, Easy Apply`
(multi-values comma-separated; blank = no filter).

### Tab `Jobs` (the spine — 38 columns)
```
job_id, title, company, location, remote_type, posted_date, listing_age_days, job_url, apply_url,
source, search_keyword, dedup_key, status, score, recommendation, callback_likelihood, salary_range,
company_size, company_sector, company_summary, matched_skills, missing_skills, green_flags, red_flags,
swot_strengths, swot_weaknesses, swot_opportunities, swot_threats, improvement_notes, interview_prep,
ai_summary, cv_link, cover_letter_link, study_guide_link, date_found, applied_date, notes, cv_template
```

### Tab `Archieve` (Archive index)
`job_id, title, company, location, posted_date, archived_date, drive_link, job_url, score, status`

### `status` — the state machine
```
New ──(Score)──▶ Shortlisted ──(Generate)──▶ Docs Generated
  │                                  └────────▶ Needs Review   (a generation failed → re-run)
  ├──▶ Low Score
  ├──▶ Rejected - Language Requirement   (only on an explicit language requirement)
  └──▶ Needs Review                      (scoring failed → re-run)
```
**Dedup key:** `dedup_key = lower(title)|lower(company)|job_id`. De-dupe each new job against the sheet snapshot
**and** an in-run set, on `job_id`, `job_url`, and `dedup_key`.

## 3. Phase contracts (input → process → output)

### Phase 1 — Discover
- **In:** `Filter` rows. **Out:** new `Jobs` rows, `status=New`.
- For each filter row, build LinkedIn guest search URLs (last 7 days, paginate ≤5 pages × 25 results, ~3s delay
  between requests). Parse listings from the HTML (job id, title, company, location, posted date). De-dupe.
  Append new rows.
- **Termination:** stop at max pages per keyword; advance pages via a page counter carried on the items.

### Phase 1.5 — Archive (optional)
- **In:** `Jobs` not already in `Archieve`. **Out:** a Markdown file in Drive `_archive` + an `Archieve` row.
- Fetch each job page, strip to clean Markdown, upload, upsert the index row (keyed on `job_id`).

### Phase 2 — Score
- **In:** `Jobs` where `status=New`. **Out:** same rows updated with score/skills/SWOT and a new `status`.
- Steps: cheap pre-fetch language check (title/location only) → fetch JD → clean + **language gate** → LLM
  rubric scoring → threshold (default 65). Language gate config: `LANGUAGE_GATE ∈ {off, english_only, exclude}`
  + `EXCLUDE_LANGUAGES`. **Rule:** only an *explicit* language *requirement* (fluent/native/C1/C2/required)
  excludes; foreign boilerplate words apply at most a small score penalty.
- Model: `SCORING_MODEL`.

### Phase 3 — Generate
- **In:** `Jobs` where `status = Shortlisted` (score ≥ `SCORE_THRESHOLD`) and not already done.
  **Out:** a Drive folder + 4 Markdown files; row updated with `*_link`, `cv_template`, `status`.
- Steps: fetch JD → build 4 prompts from the candidate **profile + `SKILLS` skillset + per-job
  matched/missing skills + chosen CV template** → 4 OpenRouter calls → assemble (route any failure to
  `Needs Review`) → create folder → upload CV / cover letter / SWOT / study guide → write links + the template
  name to the sheet.
- Models: `CV_MODEL`, `CL_MODEL`, `SWOT_MODEL`, `STUDY_MODEL`. CV template: `CV_TEMPLATE ∈ {auto, 1–15, name}`.

## 4. LLM contracts

**Scoring (Phase 2)** — input: candidate profile + JD (JD isolated as untrusted data). Output: **strict JSON**
```json
{ "score": 0, "recommendation": "", "callback_likelihood": "", "salary_range": "", "remote_type": "",
  "company_size": "", "company_sector": "", "company_summary": "",
  "matched_skills": [], "missing_skills": [], "green_flags": [], "red_flags": [],
  "swot": { "strengths": [], "weaknesses": [], "opportunities": [], "threats": [] },
  "improvement_notes": [], "interview_prep": [], "summary": "" }
```
Send with `response_format: {type: "json_object"}`. Recommendation mapping: 85–100 *Apply immediately* /
75–84 *Strong apply* / 65–74 *Worth applying* / 50–64 *Stretch role* / <50 *Skip*.

**SWOT (Phase 3)** — **strict JSON**
```json
{ "strengths": [{"point":"","evidence":"","leverage":""}],
  "weaknesses": [{"point":"","impact":"","mitigation":""}],
  "opportunities": [{"point":"","action":""}],
  "threats": [{"point":"","mitigation":""}],
  "top_improvements": [], "interview_prep": [], "application_strategy": "" }
```

**CV / Cover letter / Study guide** — Markdown text, truthful-only, skillset-aware, structured by the chosen
template. The JD is wrapped in `<<<JOB_DESCRIPTION>>> … <<<END_JOB_DESCRIPTION>>>` and labelled untrusted.

**Robust parsing (every JSON boundary):** strip ```` ```json ```` fences and `<think>…</think>`, slice the
outermost `{ … }`, `JSON.parse`; on any failure or an error body with no `choices`, set `status=Needs Review`
(don't silently write a 0 or ship a broken document). Give reasoning-style models enough `max_tokens` (≈4000)
so the JSON isn't truncated.

## 5. Build & sanitization model (how this repo stays publishable)

The repo's workflows are generated from private originals by a transform that: moves API keys into the Header
Auth credential reference, swaps real IDs/PII for `YOUR_*` placeholders and a fictional sample candidate, blanks
instance/credential ids, and applies the RoleRadar canvas branding. **Keep filled-in copies and any generator
script *outside* the published repo** (and gitignored) so a key can never enter git history.

---

See **[ARCHITECTURE.md](ARCHITECTURE.md)** for the runtime diagram and **[LLM_GUIDE.md](LLM_GUIDE.md)** for model
choices and costs.
