<!-- markdownlint-disable MD033 MD041 -->
<p align="center">
  <img src="docs/images/hero.svg" alt="RoleRadar — find, score and auto-draft tailored applications with an AI pipeline in n8n" width="100%">
</p>

<h1 align="center">📡 RoleRadar</h1>

<p align="center">
  <b>Find, score, and auto-draft tailored applications for the right roles.</b><br>
  RoleRadar is an end-to-end job-application pipeline built in <a href="https://n8n.io">n8n</a>: it scrapes
  LinkedIn, scores every role against <i>your</i> profile with an LLM, and auto-generates a tailored CV, cover
  letter, SWOT analysis and interview study guide — for a few cents per application.
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-3ddc97.svg"></a>
  <img alt="Built with n8n" src="https://img.shields.io/badge/built%20with-n8n-22d3ee">
  <img alt="LLM via OpenRouter" src="https://img.shields.io/badge/LLM-OpenRouter-a06bff">
  <img alt="No code" src="https://img.shields.io/badge/no--code-friendly-6b8bff">
</p>

<p align="center">
  <b>⭐ If RoleRadar saves you a weekend of copy-pasting cover letters, give it a star — it really helps.</b>
</p>

---

## 💡 Why

Applying to jobs well is repetitive: find roles, read each description, judge fit, then rewrite your CV and
cover letter for every single one. RoleRadar automates the boring 80% so you spend your time only on the roles
worth applying to — with documents already drafted and tailored.

**RoleRadar works for any field** — software, design, marketing, law, healthcare, finance, hospitality, the
trades. The scoring and the documents adapt to *your* profile and the job, so an architect, a lawyer and a chef
all get a fair score and a tailored CV. The bundled sample happens to be a security engineer; swap in your own
profile and skillset (one config box) and you're set. See [example profiles](docs/EXAMPLE_PROFILES.md).

## 🆚 How RoleRadar is different

Most "automate your job search" templates stop at *search → spreadsheet → one cover letter*. RoleRadar goes
further and is built to actually survive daily use:

- **A real decision pipeline, not a single flow** — 4 composable workflows (discover → archive → score →
  generate) you can run and schedule independently.
- **More than a cover letter** — every strong match gets a tailored **CV**, **cover letter**, a strategic
  **SWOT**, *and* a personalized **interview study guide**.
- **Explainable scoring** — an explicit 0–100 rubric (skills, seniority, location, comp, company type), not a
  vibe check, with the reasoning written back to your sheet.
- **Configurable language gate** — keep only roles you can actually do (English-only by default; exclude any
  language you don't speak — fully config-driven).
- **Built to not break** — hardened JSON parsing, retries, centralized model config, and a visible
  `Needs Review` status instead of silent failures or junk documents.
- **Secrets done right** — API keys live in n8n credentials, never in the workflow JSON.

## 🧭 How it works

![How RoleRadar works — Discover, Score, Generate](docs/images/how-it-works.svg)

<details>
<summary><b>See the detailed pipeline diagram</b></summary>

```mermaid
flowchart LR
  subgraph Sheet["🗒️ Google Sheet (single source of truth)"]
    JOBS[(Jobs tab)]
    FILTER[(Filter tab — your search keywords)]
    ARCH[(Archieve)]
  end

  FILTER --> P1
  P1["**1 · Discover**<br/>LinkedIn guest search<br/>+ dedupe"] -->|new jobs| JOBS
  JOBS --> P2["**2 · Score**<br/>AI scoring 0–100<br/>+ SWOT + language gate"]
  P2 -->|score ≥ threshold| JOBS
  JOBS -->|shortlisted| P3["**3 · Generate**<br/>CV · Cover letter<br/>SWOT · Study guide"]
  P3 --> DRIVE[(📁 Google Drive<br/>one folder per application)]
  JOBS -.optional.-> P15["**1.5 · Archive**<br/>JD → Markdown"]
  P15 --> DRIVE
```

</details>

| Phase | Workflow file | What it does |
|------:|---------------|--------------|
| **1 · Discover** | [`1-job-search.json`](workflows/1-job-search.json) | Searches LinkedIn (free guest endpoint) across your keyword clusters, dedupes, writes new jobs to the sheet. |
| **1.5 · Archive** | [`1.5-job-archive.json`](workflows/1.5-job-archive.json) | Fetches full job descriptions, converts to Markdown, archives them to Drive. |
| **2 · Score** | [`2-ai-scoring.json`](workflows/2-ai-scoring.json) | Scores each job 0–100 against your profile, extracts skills/SWOT/salary, runs the language gate, shortlists. |
| **3 · Generate** | [`3-cv-coverletter-generator.json`](workflows/3-cv-coverletter-generator.json) | For strong matches, generates an ATS-structured CV, cover letter, SWOT and interview study guide as Markdown files in Drive. |

## ✨ Features

- 🔎 **LinkedIn search with no API key** — uses the public guest endpoint, paginates, and rate-limits politely.
- 🧠 **LLM scoring with an explicit rubric** — skills, seniority, location, comp, company type — not vibes.
- 🌍 **Configurable language gate** — English-only out of the box; exclude any language you don't speak.
- 🧾 **ATS-structured CV + cover letter** (Markdown you export to PDF/DOCX) with anti-cliché writing rules.
- 🧬 **Skillset matching + 15 ATS CV templates** — truthful, keyword-aligned documents tailored to each job.
- 🗂️ **Everything in one Google Sheet** — auditable, filterable, no database to run.
- 💸 **Cheap** — default models cost roughly a few cents per full application. See [cost table](docs/MODELS_AND_COST.md).
- 🔐 **Secrets done right** — API keys live in n8n credentials, never in the workflow JSON.
- 🩹 **Resilient** — hardened JSON parsing, retries, and a visible `Needs Review` status instead of silent failures.

## 🧰 What you'll need (about 30 minutes, one-time)

**No coding required.** You'll need three accounts that are free to start:

- **[n8n](https://n8n.io)** — runs the workflows. The free **Cloud trial is easiest** (nothing to install).
- **Google** — RoleRadar saves jobs to a Google Sheet and documents to Google Drive.
- **[OpenRouter](https://openrouter.ai)** — provides the AI (pay-as-you-go, usually a few dollars a month).

New to automation tools? Follow the **[step-by-step setup guide](docs/SETUP.md)** — it explains each term as it
comes up, with no assumed background.

## 🚀 Quick start (the short version)

1. **Import** the four files in [`workflows/`](workflows) into your n8n instance.
2. **Create credentials** (see [SETUP](docs/SETUP.md)):
   - `Google Sheets account` (OAuth2) and `Google Drive account` (OAuth2)
   - `OpenRouter API` → **HTTP Header Auth**: name `Authorization`, value `Bearer sk-or-…`
3. **Copy the Google Sheet template** — create the tabs/columns from [GOOGLE_SHEET_TEMPLATE](docs/GOOGLE_SHEET_TEMPLATE.md).
4. **Configure** the `Load Config` / `Set` node at the start of each workflow: paste your `GOOGLE_SHEET_ID`,
   Drive folder IDs, your real profile, model slugs, and the language gate.
5. **Run** Discover → Score → Generate (manual trigger). Watch the rows light up in the sheet.

Full walkthrough: **[docs/SETUP.md](docs/SETUP.md)**.

## ⚙️ Configuration at a glance

Everything you tune lives in the first **config node** of each workflow (an n8n `Set` node):

| Setting | Where | Notes |
|---------|-------|-------|
| `GOOGLE_SHEET_ID`, `*_FOLDER_ID` | every config node | Your sheet + Drive folders |
| Search keywords / location / filters | `Filter` tab in the Sheet | One row = one search |
| `SCORE_THRESHOLD` | Phase 2 config | Default `65` → `Shortlisted` |
| `LANGUAGE_GATE` + `EXCLUDE_LANGUAGES` | Phase 2 config | `off` \| `english_only` (default) \| `exclude`. See [language gate](docs/SETUP.md#-language-gate). |
| `SCORING_MODEL` / `CV_MODEL` / `CL_MODEL` / `SWOT_MODEL` / `STUDY_MODEL` | Phase 2 & 3 config | One place to swap models — see [choosing AI models & costs](docs/LLM_GUIDE.md) |
| `SKILLS` + `CV_TEMPLATE` | Phase 3 config | Your skillset + which of 15 ATS CV templates — see [CVs & cover letters](docs/CV_AND_COVER_LETTERS.md) |
| Candidate profile / CV context | Phase 2 `Set Candidate Profile`, Phase 3 config | Replace the fictional **Alex Mercer** with you |

## 🗂️ Repository structure

```
role-radar/
├── workflows/          # the 4 importable n8n workflows (sanitized + branded)
├── docs/               # setup, architecture, sheet template, models & cost
├── sheet-template/     # column headers for the Google Sheet
├── .env.example        # placeholder secrets (optional env-var path)
└── README.md
```

## 📚 Documentation

- **[Setup guide](docs/SETUP.md)** — beginner-friendly, step by step
- **[Choosing AI models & costs](docs/LLM_GUIDE.md)** — which model to use, pros/cons, price per job
- **[Skills, CVs & cover letters](docs/CV_AND_COVER_LETTERS.md)** — skillset, matching & 15 ATS CV templates
- **[Example profiles](docs/EXAMPLE_PROFILES.md)** — ready-to-adapt profiles for any field (lawyer, chef, …)
- **[Architecture](docs/ARCHITECTURE.md)** — how the pieces fit together
- **[Rebuild from scratch](docs/REBUILD.md)** — full spec: data model, contracts, LLM JSON shapes
- **[Google Sheet template](docs/GOOGLE_SHEET_TEMPLATE.md)** — tabs & columns
- **[Model technical reference](docs/MODELS_AND_COST.md)** — where each model is set

## ⚖️ Legal & responsible use

RoleRadar reads LinkedIn's **public** guest job pages. **Scraping may conflict with LinkedIn's Terms of
Service** — use it for personal, low-volume job searching at your own risk, keep the built-in rate-limit delays,
and stop if asked. Job descriptions can contain other people's personal data; when you run RoleRadar **you** are
the data controller (GDPR and similar laws may apply), and the job text plus your profile are sent to your chosen
LLM provider — review its data-retention policy and prefer a provider/model you trust. RoleRadar **does not apply
to any job for you** — it drafts documents that you review and submit yourself. None of this is legal advice.

## ⚠️ Known limitations

- **LinkedIn parsing is best-effort.** It relies on LinkedIn's public HTML; if LinkedIn changes its markup or
  rate-limits you, Discover may return few/zero jobs until the parser is updated.
- **Model slugs drift.** Defaults are valid at time of writing; if you see many `Needs Review` rows, verify the
  model names at [openrouter.ai/models](https://openrouter.ai/models) — it's one edit in the config node.
- **Documents are Markdown.** Open them in Google Docs/Word and **export to PDF/DOCX before submitting** to an ATS.
- **A failed AI generation** still creates the job's Drive folder; the row is marked `Needs Review` so you re-run it.

## 🔐 Security

API keys are **never** stored in these workflow files — they live in n8n's encrypted credential store and the
exported JSON only references them by name. Please read **[SECURITY.md](SECURITY.md)** before publishing your
own fork, and **rotate any key you've ever pasted into a workflow node**.

## 💬 Feedback

Shared as-is, as a personal project — there's no active roadmap. Found a bug or have an idea? Open an
**issue** on GitHub and I may pick it up.

## 📄 License

[MIT](LICENSE) — do whatever you want, no warranty. Built with [n8n](https://n8n.io) and
[OpenRouter](https://openrouter.ai).

---

<p align="center"><sub>Not affiliated with LinkedIn. Respect each site's Terms of Service and rate limits, and use responsibly.</sub></p>
