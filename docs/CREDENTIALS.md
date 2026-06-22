# 🔑 Credentials & Google access

How RoleRadar handles your keys and accounts — and exactly how to connect Google (Sheets + Drive) and
OpenRouter. Links go to n8n's own documentation so you can follow the canonical steps.

## What's a "credential" vs. "config" here (and why)

RoleRadar follows n8n's recommended split:

| Thing | Where it lives | Why |
|-------|----------------|-----|
| **OpenRouter API key** | n8n **credential** (HTTP *Header Auth*) | It's a secret → encrypted in n8n's credential store, **never** written into the workflow file you share. |
| **Google account** (Sheets + Drive) | n8n **credential** (OAuth2) | Auth tokens are secrets → managed by n8n, never in the workflow file. |
| **Sheet ID, Drive folder IDs, model names, score threshold, your profile/skills** | the first **`Set` / config node** of each workflow | These are **not secrets** (a Sheet ID isn't a password; your profile is content that must go *into* your documents). A visible config box is the standard, easy-to-edit n8n pattern for shareable templates. |

So the answer to *"why not put everything in the credential store?"* — the **keys already are** in the
credential store (that's why the exported `.json` files contain no secrets). n8n credentials are specifically
for **authentication secrets**; everyday settings like a spreadsheet ID belong in a config node (or, if you
prefer 12-factor, environment variables via `{{ $env.NAME }}`). See n8n's docs:
[Credentials overview](https://docs.n8n.io/integrations/builtin/credentials/) ·
[Manage credentials](https://docs.n8n.io/credentials/).

> 💡 The config node is the **"START HERE"** box — open it first and fill in your details. Nothing else needs
> editing to get running.

---

## 1. Connect Google (Sheets + Drive)

You need two Google credentials in n8n: **Google Sheets OAuth2** and **Google Drive OAuth2**. How you create them
depends on where n8n runs.

### 🟢 On n8n Cloud — the easy path (recommended for most people)
n8n Cloud ships with Google OAuth **pre-configured**. In the node, choose to create a Google credential and just
click **"Sign in with Google"** — no Google Cloud project, no setup. Done in under a minute.

### 🟡 On self-hosted n8n — you create your own Google OAuth app
Self-hosted n8n needs its own Google OAuth client. The one-time steps (per n8n's guide):
1. In the **[Google Cloud Console](https://console.cloud.google.com/)**, create (or pick) a project.
2. **Enable the APIs** you use: *Google Sheets API* and *Google Drive API*.
3. Configure the **OAuth consent screen** (external or internal), and add yourself as a test user.
4. Create an **OAuth client ID** (type: *Web application*) and add n8n's **OAuth Redirect URL** (n8n shows it on
   the credential screen) to the client's *Authorized redirect URIs*.
5. Copy the **Client ID + Client Secret** into the n8n Google credential, then **Sign in with Google**.

Follow n8n's step-by-step, which has the current screenshots:
- **[Google credentials overview](https://docs.n8n.io/integrations/builtin/credentials/google/)**
- **[OAuth2 (single service)](https://docs.n8n.io/integrations/builtin/credentials/google/oauth-single-service/)** — the method above
- **[OAuth2 (generic)](https://docs.n8n.io/integrations/builtin/credentials/google/oauth-generic/)** — one Google app for several services

### 🏢 Google Workspace notes
- If your Google account is part of a **Workspace** (company domain), an **admin may need to approve** the OAuth
  app or the requested scopes before you can sign in. With an *internal* consent screen, only users in your
  domain can authorize it.
- For unattended/server use (or to avoid per-user consent), n8n also supports a **Service Account**:
  **[Service Account auth](https://docs.n8n.io/integrations/builtin/credentials/google/service-account/)**.
  If you use one with Workspace, you may need domain-wide delegation and to **share the Sheet/Drive folders with
  the service account's email**.

Node references: [Google Sheets node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/)
· [Google Drive node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googledrive/).

---

## 2. Connect OpenRouter (the AI)

Create **one** n8n credential of type **HTTP *Header Auth***:
- **Name:** `Authorization`
- **Value:** `Bearer ` + your key (e.g. `Bearer sk-or-v1-…`) — get the key at <https://openrouter.ai/keys>.

The HTTP Request nodes reference this credential, so your key never appears in the workflow file.
Reference: [HTTP Request credentials / Header Auth](https://docs.n8n.io/integrations/builtin/credentials/httprequest/).

---

## 3. After importing — re-select credentials
When you import the workflows, n8n may show **"credential not found"** on the Google/OpenRouter nodes (the shared
files reference credentials by *name*, with no IDs). Just open each such node and pick your credential from the
dropdown once. See **[SECURITY.md](../SECURITY.md)** for safe key handling.
