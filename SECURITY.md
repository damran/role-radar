# Security Policy & Best Practices

This project moves data between LinkedIn, an LLM provider, and your Google account. Treat the credentials
seriously.

## 🔑 Golden rules

1. **Never commit API keys.** The workflows in `workflows/` store **no** keys — they reference an n8n
   credential by name only. Keep it that way in your fork.
2. **Rotate any key that has ever been pasted into a workflow node**, shared in a screenshot, or committed to
   git history. Once a secret touches a public surface, consider it burned and issue a new one:
   - OpenRouter: <https://openrouter.ai/keys>
   - Google: handled via OAuth credentials, not raw keys.
3. **Keep your filled-in copies private.** Real `GOOGLE_SHEET_ID`, Drive folder IDs and your CV/profile are
   personal data — keep them in the gitignored `private/` copy, never in the public repo.

## How secrets are stored here (recommended setup)

API keys live in **n8n's encrypted credential store**, not in the workflow JSON:

- **OpenRouter** → an `HTTP Header Auth` credential named **`OpenRouter API`**
  (`Name = Authorization`, `Value = Bearer sk-or-…`). The HTTP Request nodes reference it via
  *Generic Credential Type → Header Auth*, so the exported JSON contains only `{ "httpHeaderAuth": { "name": "OpenRouter API" } }`.
- **Google Sheets / Drive** → standard n8n OAuth2 credentials.

This means you can safely export and share any workflow from this repo without leaking a key.

## Responsible use

- Respect LinkedIn's Terms of Service and rate limits — the workflows add deliberate delays; don't remove them.
  Scraping may conflict with those ToS; use it for personal, low-volume searching at your own risk.
- The LLM sees the job descriptions and your profile. Use a provider you trust and review its data-retention policy.
- Job descriptions may contain **other people's personal data** (recruiter names, etc.). When you run RoleRadar
  **you are the data controller** (GDPR/CCPA may apply) — keep volumes low, don't redistribute scraped data,
  and minimize what you store.
- RoleRadar **does not submit applications for you**; it drafts documents you review and send yourself.

## Reporting

Found a security issue in this template? Open a GitHub issue (no secrets in the report, please) or contact the
maintainer privately.
