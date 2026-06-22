# Contributing

Thanks for wanting to improve **RoleRadar**! 🎉

## Ways to help

- 🐛 **Bug reports** — open an issue with the workflow name, the failing node, and the n8n error text.
- 🌍 **New job sources** — add a Phase-1-style sub-flow for another board (company career pages, RSS, etc.).
- 🧠 **Better prompts** — sharper scoring rubric, stronger humanization, more languages.
- 📄 **Docs** — clearer setup steps, a Loom walkthrough, screenshots in `docs/images/`.

## Workflow PR checklist

Because these are exported n8n JSON files, please follow a few rules so the repo stays safe and clean:

1. **No secrets.** Before committing, confirm the export contains no API keys, real `GOOGLE_SHEET_ID`,
   Drive folder IDs, or personal data. Keys must use the `OpenRouter API` Header Auth credential reference.
   Quick check:
   ```bash
   grep -REn "sk-or-v1-|AIza|/spreadsheets/d/[A-Za-z0-9_-]{30,}" workflows/ || echo "clean"
   ```
2. **Keep the sample profile fictional** — use *Alex Mercer* placeholders, never a real person.
3. **Blank instance-specific IDs** — credential `id`s, `meta.instanceId`, workflow `id`/`versionId` should be
   empty so the file imports cleanly on any instance.
4. **Re-export tidily** — name nodes clearly and keep the sticky-note documentation up to date.
5. **Describe the change** — what you changed and how you tested it (which phase you ran, on how many jobs).

## Local testing

Import into a throwaway n8n instance, point the config nodes at a test Google Sheet, and run the affected
phase on 1–2 jobs. Confirm there are no `Parse Error` / `Needs Review` rows that shouldn't be there.

By contributing you agree your work is licensed under the repo's [MIT License](LICENSE).
