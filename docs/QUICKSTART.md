# ⚡ Quick Start — your first tailored CV in ~30 minutes

New here and not very technical? You're in the right place. This is the **fastest happy path**. It links to the
full [setup guide](SETUP.md) for any step you want explained in more detail.

## Is this for me?
- ✅ You're job hunting and tired of rewriting your CV and cover letter for every role.
- ✅ You can follow clicking instructions and copy-paste. **No coding needed.**
- ✅ You're OK spending a few dollars a month on the AI (pay-as-you-go).

**Honest expectations:** the *hardest part is the one-time setup* — connecting your Google and AI accounts. It
takes about 30 focused minutes. After that, running it is just pressing **Run**.

## The 5 steps

> 🟢 = easy · 🟡 = the fiddly bit (go slow, you've got this)

1. **🟢 Get the three accounts** (all free to start)
   - [n8n](https://n8n.io) — pick the **free Cloud trial** so there's nothing to install.
   - A **Google** account (you already have one).
   - [OpenRouter](https://openrouter.ai) — this is the AI. Add a few dollars of credit.

2. **🟢 Make your Google Sheet**
   Create a new Google Sheet and add the tabs + column headers from
   [the sheet template](GOOGLE_SHEET_TEMPLATE.md) (copy the `Jobs` header row straight from
   [`sheet-template/columns.csv`](../sheet-template/columns.csv)). Make two Google Drive folders too
   (one for documents, one for the archive).

3. **🟡 Connect your accounts in n8n** *(the fiddly bit)*
   Import the four files from [`workflows/`](../workflows), then create three credentials:
   - **Google Sheets** and **Google Drive** — click "Sign in with Google".
   - **OpenRouter** — a "Header Auth" credential: Name = `Authorization`, Value = `Bearer ` + your key.
   Pictures and exact clicks are in [SETUP → step 3](SETUP.md#3-add-credentials-in-n8n).

4. **🟢 Tell it about you**
   Open the first box (`Set` / `Load Config`) in each workflow and paste your Google Sheet ID, your folder IDs,
   and **your own profile and skills** (replace the sample "Alex Mercer"). Add your job searches to the `Filter`
   tab. Not in tech? See [example profiles](EXAMPLE_PROFILES.md) for a lawyer, chef, designer or nurse.

5. **🟢 Press Run**
   Run **Discover**, then **Score**, then **Generate**. Watch jobs, scores and document links appear in your sheet.

## What success looks like
- Your `Jobs` tab fills with roles and a 0–100 score for each.
- Strong matches turn to `Shortlisted`, then `Docs Generated`.
- For each, a Google Drive folder appears with your tailored CV, cover letter, SWOT and study guide.
- To submit a CV: open the `.md` link → **Open with → Google Docs** → **File → Download → PDF/Word**.

## If something looks wrong (top 3)
| You see… | Do this |
|----------|---------|
| Lots of rows say `Needs Review` | The AI model name changed — paste a current one from [openrouter.ai/models](https://openrouter.ai/models) into the config box. |
| `credential not found` after import | Click the node and re-select your credential from the dropdown. |
| Discover finds 0 jobs | LinkedIn may be rate-limiting — wait a bit and run again. |

Stuck on a step? The full [**Setup guide**](SETUP.md) explains every term as it comes up. 🎯
