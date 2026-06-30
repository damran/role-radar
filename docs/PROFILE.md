# Your profile (`profile.json`) + the setup wizard

RoleRadar can read everything personal — your contact details, CV, skills, model choices, scoring
preferences and Google resource IDs — from **one file**, so you don't have to hand-edit the config node in
every workflow.

- **`profile.example.json`** — a committed template, pre-filled with the fictional *Jordan Avery* sample.
- **`profile.json`** — *your* copy (gitignored, never committed). Create it with the wizard, or by copying
  the example.

> 🔑 **API keys never go in `profile.json`.** Keep them in your n8n **credentials** (recommended) or in a
> gitignored `.env`. The wizard can write `.env` for you.

## Fastest path — the wizard

```bash
# macOS / Linux
./setup.sh
```
```powershell
# Windows
./setup.ps1
```

It prompts for each field (press **Enter** to keep the shown default), then:

- writes your **`profile.json`**,
- optionally writes **`.env`** (only if you enter an API key),
- and offers to generate your personalized workflows.

**Python 3 is required** (the wizard uses it to write JSON safely). It auto-detects two modes:

| Mode | When | Output |
|------|------|--------|
| **public** *(default for most users)* | no `_build_workflows.py` present | writes `profile.json` here, then `apply_profile.py` produces `configured/*.json` to import |
| **owner** | the maintainer's build script is present | writes `../private/profile.json`, then runs the full build |

Force a mode with `./setup.sh --mode public` or `./setup.ps1 -Mode public`.

## Apply a profile without the wizard

If you already have a `profile.json` (e.g. you copied and edited the example):

```bash
python apply_profile.py                  # uses ./profile.json (falls back to profile.example.json)
python apply_profile.py my-profile.json  # use a specific file
```

This writes personalized, ready-to-import copies of all four workflows into **`configured/`**, with your
contact fields, CV, skills, models, scoring knobs and Google resource IDs filled in. Import those into n8n,
then attach your Google + OpenRouter credentials (see [CREDENTIALS.md](CREDENTIALS.md)).

## Schema

```jsonc
{
  "candidate": {
    "name": "...", "email": "...", "phone": "...",
    "location": "...", "linkedin": "...",
    "github": "github.com/your-handle"   // optional — added to the CV header + cover-letter contact line; blank to omit
  },
  "candidate_profile": "...",   // Phase 2 scoring context (who you are, used to rate fit)
  "full_cv": "...",             // Phase 3 generation context (the source of truth for your CV)
  "skills": "...",              // your skill list (mirrored truthfully against each job)
  "scoring": {
    "score_threshold": 65,            // 0-100; jobs at/above are shortlisted
    "cv_template": "auto",            // "auto" or 1-15 (see CV_AND_COVER_LETTERS.md)
    "language_gate": "english_only",  // off | english_only | exclude
    "exclude_languages": "German",    // comma list, used when language_gate = exclude
    "filter_recommendation": "",      // Phase 3: only generate for this tier (blank = all shortlisted)
    "filter_location": ""             // Phase 3: only generate for this location (blank = all)
  },
  "models": {                         // OpenRouter slugs — confirm against openrouter.ai/models
    "scoring": "deepseek/deepseek-v4-flash",
    "cv": "anthropic/claude-sonnet-4.6",
    "cl": "anthropic/claude-sonnet-4.6",
    "swot": "deepseek/deepseek-v4-flash",
    "study": "deepseek/deepseek-v4-flash"
  },
  "resources": {                      // copy each ID from the URL of your Sheet / Drive folders
    "google_sheet_id": "YOUR_GOOGLE_SHEET_ID",
    "drive_root_folder_id": "YOUR_DRIVE_ROOT_FOLDER_ID",
    "applications_folder_id": "YOUR_APPLICATIONS_FOLDER_ID",
    "archive_folder_id": "YOUR_ARCHIVE_FOLDER_ID"
  },
  "credentials": {
    "openrouter_cred_id": ""          // owner-only: the n8n credential *reference* id (not a key)
  }
}
```

`candidate_profile`, `full_cv` and `skills` are plain text — paste a multi-line block. With the wizard, give
a **file path** when prompted and it reads the file in for you.
