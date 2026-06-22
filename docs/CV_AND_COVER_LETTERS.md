# 🧬 Skills, CVs & Cover Letters

How RoleRadar turns *your* background into a **tailored, ATS-friendly** application for each job — never a
generic one — and how to steer it.

> **The honest rule:** RoleRadar makes you look as strong as the truth allows. It reframes and emphasizes your
> real experience to match each job; it **never invents** skills, titles, dates or results.

---

## 1. Your skillset — the source of truth

Your **skillset** is a short, grouped list of what you can actually do. RoleRadar uses it as the single source
of truth so your CV and cover letter highlight the *right* real skills for each job.

It lives in one place: the **`SKILLS`** field in the Phase 3 config node (**`Set Job ID`**).

### What it looks like
Group skills by category, most job-relevant first:

```
Security Operations: Multi-cloud SOC, Detection Engineering, Incident Response, Threat Hunting
Cloud & Automation: AWS, Azure, GCP, Terraform, GitHub CI/CD, Python, Bash
SIEM & EDR: Splunk, Sumo Logic, SentinelOne, ELK Stack
Certifications: AWS Solutions Architect Associate, Terraform Associate, CEH
Soft skills: cross-team leadership, mentoring, technical writing
```

### How to generate it (5 minutes)
1. Open your current CV (or just think through your last 2–3 roles).
2. List every tool, platform, method and certification you've genuinely used.
3. **Group** them into 4–8 categories (e.g. *Cloud*, *Tools*, *Certifications*, *Soft skills*).
4. Put the categories **most relevant to the jobs you want first**.
5. Paste it into the `SKILLS` field. Done.

> Tip: an AI assistant can draft this from your CV in seconds — just **fact-check every line**. If you didn't do
> it, delete it.

### How to choose which skills to include
- ✅ **Include:** skills you can talk about confidently in an interview, anything that shows up in your target
  job postings, and your strongest certifications.
- 🚫 **Leave out:** things you touched once and forgot, or buzzwords you can't back up. A focused, true skillset
  beats a long, padded one — and it keeps the AI honest.

---

## 2. How matching works (this is what makes it non-generic)

```
Your SKILLS + profile ──▶ Phase 2 compares them to each job ──▶ matched_skills / missing_skills (saved to sheet)
                                                                          │
                                          Phase 3 reads those + the job text + your SKILLS ──▶ tailored CV & cover letter
```

For **every** job, RoleRadar:
1. **Scores the fit** (Phase 2) and records which of your skills the job wants (`matched_skills`) and which it
   asks for that you don't list (`missing_skills`).
2. **Writes the documents** (Phase 3) using those results + the full job description + your skillset, so the CV:
   - **surfaces the real skills the job is asking for**, mirroring the posting's wording where it's truthful
     (e.g. the job says "SIEM", you have Splunk → it names both),
   - **handles gaps honestly** — instead of claiming a missing skill, it foregrounds your closest real,
     transferable experience,
   - **weaves keywords in naturally** — no stuffing, no fake tools.

That's why two jobs produce two different CVs from the same you.

---

## 3. ATS & HR — what actually gets you through

Most applications are first read by an **ATS** (Applicant Tracking System) and a busy human skimming for ~10
seconds. RoleRadar is built for both:

- **ATS-safe formatting by design.** Single column, standard section headings, real dates, plain text — **no
  tables, columns, text boxes, icons or graphics**, because those are exactly what confuse ATS parsers. (This is
  why the "templates" below are *content structures*, not fancy designs.)
- **Keyword alignment, truthfully.** It mirrors the job's real terminology that you genuinely match — the single
  biggest factor in ATS keyword scoring.
- **Quantified achievements** (the "X-Y-Z" pattern: *accomplished X, measured by Y, by doing Z*) — what HR
  reviewers look for.
- **Human tone.** Banned AI clichés and varied sentence length, so it doesn't read as machine-written.

### 📄 From Markdown to a submittable PDF/DOCX (about 2 minutes)

RoleRadar saves each CV/cover letter as a **Markdown (`.md`)** file — clean, single-column, ATS-friendly
*content*. ATS systems accept **PDF or DOCX**, so convert before submitting:

1. In your Google Sheet, click the **`cv_link`** (or `cover_letter_link`) — the `.md` file opens in Google Drive.
2. At the top of the preview, click **Open with → Google Docs**. Google renders the Markdown as a formatted document.
3. In Google Docs: **File → Download → PDF Document (.pdf)** or **Microsoft Word (.docx)**.
4. Submit the PDF/DOCX. Keep it single-column with standard fonts — don't add tables, columns or graphics
   (those break ATS parsing).

*(The menu labels above are the English Google UI: **Open with**, **Google Docs**, **File**, **Download**. If your
Google interface is in another language they're in the same positions — e.g. Turkish: "Birlikte aç → Google
Dokümanlar", then "Dosya → İndir → PDF Belgesi (.pdf) / Microsoft Word (.docx)".)*

---

## 4. CV templates — pick a structure

RoleRadar ships **15 ATS-safe CV structures**. They change the *section order and emphasis*, not the visual
design (keeping them ATS-parseable). Set your choice in the Phase 3 config field **`CV_TEMPLATE`** —
use `auto`, a number, or the template name.

| # | Template | Best for |
|---|----------|----------|
| 1 | Classic Reverse-Chronological | The safe default; steady career history |
| 2 | Skills-Forward Hybrid | You're a close skills match — lead with them |
| 3 | Technical / Engineering | Engineers/IT — tools, systems, projects |
| 4 | Senior Individual Contributor | Deep specialist, two pages of depth |
| 5 | Leadership / Management | Team size, budget, business outcomes |
| 6 | Executive (one-page) | Director/VP/C-level brevity |
| 7 | Career-Changer / Transferable | Switching field or industry |
| 8 | Achievement-Focused (X-Y-Z) | Metrics on every line |
| 9 | ATS Keyword-Max | Maximize keyword match (truthfully) |
| 10 | Minimalist One-Page | Referrals, concise markets |
| 11 | Consultant / Contractor | Engagement/client-outcome framing |
| 12 | Academic → Industry | Moving from research to industry |
| 13 | Startup / Generalist | Breadth, ownership, shipping |
| 14 | Domain Specialist | Certifications/frameworks up front |
| 15 | Early-Career / Graduate | Education + projects first |

**How to choose:**
- **`auto`** *(default)* — RoleRadar picks based on the job title (e.g. senior/lead → Leadership, engineer →
  Technical, graduate → Early-Career). Great if you're applying broadly.
- **A number or name** — e.g. set `CV_TEMPLATE` to `3` or `Technical / Engineering` to force one style for
  every application.

The CV file contains **only the finished CV** — ready to convert and submit. Fit analysis and ways to strengthen
the application live separately in the **SWOT** document and the `improvement_notes` / `interview_prep` columns,
so nothing extra has to be trimmed out of the CV before you send it.

---

## 5. Cover letters

The cover letter uses the same skillset and matched skills, plus what's appealing about the company. It's:
280–380 words, specific (a real hook about the company, two real achievements with numbers), conversational, and
free of AI clichés — and, like the CV, it never claims a skill you don't have.

---

### Where to set everything (Phase 3 → `Set Job ID` config)

| Field | What it does |
|-------|--------------|
| `SKILLS` | Your master skillset (source of truth) |
| `CV_TEMPLATE` | `auto`, a number `1`–`15`, or a template name |
| `FULL_CV_CONTEXT` | Your full background/experience |
| `CANDIDATE_*` | Name, email, phone, LinkedIn, location |

See model/quality choices in the **[Choosing AI Models guide](LLM_GUIDE.md)**.
