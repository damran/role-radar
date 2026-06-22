# 🐳 Self-hosting n8n with Docker (free, runs on your machine)

Prefer not to use n8n Cloud? You can run n8n **locally with Docker** for free — your data and API keys
never leave your machine. This takes ~10 minutes and works on Windows, macOS, and Linux.

> **Cloud vs. self-hosted — quick decision**
> - **n8n Cloud** (the [Quick Start](QUICKSTART.md) path): nothing to install, Google sign-in is one click. Easiest.
> - **Docker self-hosting** (this guide): free forever, fully private, but **you create your own Google OAuth app**
>   (see [CREDENTIALS.md](CREDENTIALS.md)) and you keep the container running when you want RoleRadar to work.

## 1. Install Docker

Install **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (Windows/macOS) or Docker Engine
(Linux). Confirm it works:

```bash
docker --version
```

## 2. Start n8n

### Option A — one command (quickest)

```bash
docker volume create n8n_data

docker run -d --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e GENERIC_TIMEZONE="Europe/Berlin" \
  -e N8N_SECURE_COOKIE=false \
  docker.n8n.io/n8nio/n8n
```

Then open **<http://localhost:5678>** and create your owner account.

- `-d` runs it in the background; `--name n8n` lets you `docker stop n8n` / `docker start n8n` later.
- `-v n8n_data:/home/node/.n8n` **persists your workflows, credentials, and encryption key** so nothing is
  lost when the container restarts. Don't skip this.
- Set `GENERIC_TIMEZONE` to yours (used by any scheduled triggers).

### Option B — docker-compose (recommended if you'll keep it around)

Create `docker-compose.yml`:

```yaml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - GENERIC_TIMEZONE=Europe/Berlin
      - N8N_SECURE_COOKIE=false
      # Optional: persist a fixed encryption key so credentials survive a volume reset.
      # Generate one with:  openssl rand -hex 16
      # - N8N_ENCRYPTION_KEY=replace-with-your-own-32-char-hex
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

Start it:

```bash
docker compose up -d
```

Open **<http://localhost:5678>**. To update later: `docker compose pull && docker compose up -d`.

> 💡 The bundled [`.env.example`](../.env.example) is **optional** and only relevant if you wire env vars into
> the container via `env_file: .env`. RoleRadar's keys live in n8n **credentials**, not in `.env` — so for a
> normal setup you can ignore it.

## 3. Connect your accounts (one-time)

Once n8n is open at `localhost:5678`:

1. **Google (Sheets + Drive)** — on self-hosted n8n you must create your **own Google OAuth app**. Full steps
   are in **[CREDENTIALS.md → self-hosted](CREDENTIALS.md#-on-self-hosted-n8n--you-create-your-own-google-oauth-app)**.
   When Google asks for the **Authorized redirect URI**, paste the one n8n shows on the credential screen
   (it will look like `http://localhost:5678/rest/oauth2-credential/callback`).
2. **OpenRouter** — create an **HTTP Header Auth** credential (`Name` = `Authorization`, `Value` = `Bearer sk-or-…`).
   See [CREDENTIALS.md → OpenRouter](CREDENTIALS.md#2-connect-openrouter-the-ai).

> ⚠️ **Google OAuth on `localhost`** works for personal use. If your browser blocks the callback, either keep
> the redirect URI exactly as n8n shows it, or expose n8n over HTTPS with a tunnel (e.g. `cloudflared`,
> `ngrok`) and set `-e WEBHOOK_URL=https://your-tunnel-url/` so the redirect resolves.

## 4. Import the workflows and run

Import the four files from [`workflows/`](../workflows) and continue with the
**[Setup guide → step 4](SETUP.md#4-import-the-workflows)**. Everything after this point is identical to the
Cloud path.

## Handy Docker commands

| Task | Command |
|------|---------|
| Stop n8n | `docker stop n8n` |
| Start it again | `docker start n8n` |
| View logs | `docker logs -f n8n` |
| Update to latest | `docker pull docker.n8n.io/n8nio/n8n` then recreate the container |
| Back up everything | copy the `n8n_data` volume (workflows + credentials live there) |

> 🔐 Your credentials are encrypted inside the `n8n_data` volume using n8n's encryption key. If you ever move to
> a new machine, keep the **same** `N8N_ENCRYPTION_KEY` (Option B) or you'll have to re-enter credentials.
