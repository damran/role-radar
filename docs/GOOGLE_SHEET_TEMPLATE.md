# Google Sheet Template

Create one Google Sheet with the four tabs below. Put each column list in **row 1** (the header row). Column
order is not strict, but the **names must match exactly** (they map to the n8n nodes).

The `Jobs` header row is also provided as [`sheet-template/columns.csv`](../sheet-template/columns.csv) — open
it and paste row 1 straight into your sheet.

---

## Tab: `Jobs` (main table)

```
job_id, title, company, location, remote_type, posted_date, listing_age_days,
job_url, apply_url, source, search_keyword, dedup_key, status, score,
recommendation, callback_likelihood, salary_range, company_size, company_sector,
company_summary, matched_skills, missing_skills, green_flags, red_flags,
swot_strengths, swot_weaknesses, swot_opportunities, swot_threats,
improvement_notes, interview_prep, ai_summary, cv_link, cover_letter_link,
study_guide_link, date_found, applied_date, notes, cv_template
```

`cv_template` records which of the 15 ATS CV templates was used for that application
(see [CVs & cover letters](CV_AND_COVER_LETTERS.md)).

Phase 1 fills the first dozen columns; Phase 2 fills score/recommendation/SWOT/etc.; Phase 3 fills the
`*_link` columns and sets `status = Docs Generated`.

`status` values you'll see: `New`, `Shortlisted`, `Low Score`, `Rejected - Language Requirement`,
`Docs Generated`, `Needs Review`.

---

## Tab: `Filter` (your searches — Phase 1 input)

One row per search. Multiple values are comma-separated; blank means "no filter".

| Keyword | Location | Experience Level | Remote | Job Type | Easy Apply |
|---------|----------|------------------|--------|----------|------------|
| Detection Engineer | Berlin | Mid-Senior level | Remote | Full-time | |
| SOC Analyst | Germany | Associate,Mid-Senior level | Hybrid | Full-time | |
| Cloud Security Engineer | Remote, EU | | Remote | | |

Accepted values:
- **Experience Level:** `Internship`, `Entry level`, `Associate`, `Mid-Senior level`, `Director`, `Executive`
- **Remote:** `On-Site`, `Remote`, `Hybrid`
- **Job Type:** `Full-time`, `Part-time`, `Contract`, … (first letter is used)
- **Easy Apply:** `true` or blank

---

## Tab: `Shortlist` (Phase 3 input)

Either:
- repoint Phase 3 to read the `Jobs` tab (simplest), **or**
- make this tab a live view with, in cell `A1`:
  ```
  =QUERY(Jobs!A:AK, "select * where M = 'Shortlisted'", 1)
  ```
  (`M` is the `status` column with the layout above.)

See [SETUP → Shortlist tab](SETUP.md#shortlist-tab).

---

## Tab: `Archieve` (Phase 1.5 index)

> Spelled `Archieve` on purpose — it matches the node configuration. Rename both if it bothers you.

```
job_id, title, company, location, posted_date, archived_date, drive_link, job_url, score, status
```
