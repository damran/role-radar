#!/usr/bin/env bash
# RoleRadar setup wizard (Bash). Collects your profile, scoring prefs, Google resource IDs
# and API keys, then writes a profile.json + .env and (optionally) builds the workflows.
#
#   ./setup.sh            # auto-detect owner vs public
#   ./setup.sh --mode public
#
# Python 3 is required (used for safe JSON writing + applying the profile).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE="$HERE/profile.example.json"

# --- pick a Python 3 interpreter ---
PY=""
for c in py python3 python; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys;exit(0 if sys.version_info[0]>=3 else 1)' >/dev/null 2>&1; then
    PY="$c"; break
  fi
done
[ -n "$PY" ] || { echo "ERROR: Python 3 not found (need it for JSON writing)."; exit 1; }

# --- mode: owner (has the build script) vs public ---
MODE="auto"
[ "${1:-}" = "--mode" ] && MODE="${2:-auto}"
if [ "$MODE" = "auto" ]; then
  if [ -f "$HERE/../_build_workflows.py" ]; then MODE="owner"; else MODE="public"; fi
fi
if [ "$MODE" = "owner" ]; then TARGET="$HERE/../private/profile.json"; else TARGET="$HERE/profile.json"; fi

echo "============================================================"
echo " RoleRadar setup  (mode: $MODE)"
echo " Profile  -> $TARGET"
echo " Defaults come from your existing profile if present, else the example."
echo " Press Enter to keep the shown [default]. For CV/skills/profile, give a file path."
echo "============================================================"

# seed value lookups from the existing target (or example) so [defaults] are meaningful
seed() { "$PY" - "$TARGET" "$EXAMPLE" "$1" <<'PYEOF'
import io, json, os, sys
target, example, path = sys.argv[1], sys.argv[2], sys.argv[3]
src = target if os.path.exists(target) else example
d = json.load(io.open(src, encoding="utf-8"))
cur = d
for k in path.split("."):
    cur = cur.get(k, {}) if isinstance(cur, dict) else ""
print(cur if isinstance(cur, (str, int)) else "")
PYEOF
}

ask() { # ask "Prompt" "default" -> echoes answer
  local prompt="$1" def="$2" ans
  read -r -p "$prompt [${def}]: " ans || true
  echo "${ans:-$def}"
}
ask_secret() { local prompt="$1" ans; read -r -s -p "$prompt (hidden, Enter to skip): " ans || true; echo >&2; echo "$ans"; }
ask_file() { # ask_file "Prompt" -> echoes file contents or "" (keep)
  local prompt="$1" path
  read -r -p "$prompt (file path, Enter to keep current): " path || true
  if [ -n "$path" ]; then
    [ -f "$path" ] || { echo "  ! file not found: $path (keeping current)" >&2; echo ""; return; }
    cat "$path"
  else echo ""; fi
}

echo; echo "--- Contact ---"
RR_NAME="$(ask 'Full name'        "$(seed candidate.name)")"
RR_EMAIL="$(ask 'Email'           "$(seed candidate.email)")"
RR_PHONE="$(ask 'Phone'           "$(seed candidate.phone)")"
RR_LOCATION="$(ask 'Location'     "$(seed candidate.location)")"
RR_LINKEDIN="$(ask 'LinkedIn URL' "$(seed candidate.linkedin)")"
RR_GITHUB="$(ask 'GitHub URL'     "$(seed candidate.github)")"

echo; echo "--- Profile text (give a file path to replace, Enter to keep) ---"
RR_PROFILE="$(ask_file 'Candidate profile (Phase 2 scoring context)')"
RR_CV="$(ask_file 'Full CV text (Phase 3 generation context)')"
RR_SKILLS="$(ask_file 'Skills (source-of-truth skill list)')"

echo; echo "--- Scoring & language ---"
RR_SCORE_THRESHOLD="$(ask 'Score threshold (0-100)' "$(seed scoring.score_threshold)")"
RR_CV_TEMPLATE="$(ask 'CV template (auto, or 1-15)' "$(seed scoring.cv_template)")"
RR_LANGUAGE_GATE="$(ask 'Language gate (off|english_only|exclude)' "$(seed scoring.language_gate)")"
RR_EXCLUDE_LANGUAGES="$(ask 'Exclude languages (comma list)' "$(seed scoring.exclude_languages)")"
RR_FILTER_REC="$(ask 'Phase 3 filter: recommendation (blank=all)' "$(seed scoring.filter_recommendation)")"
RR_FILTER_LOC="$(ask 'Phase 3 filter: location (blank=all)' "$(seed scoring.filter_location)")"

echo; echo "--- Google resource IDs ---"
RR_SHEET_ID="$(ask 'Google Sheet ID' "$(seed resources.google_sheet_id)")"
RR_DRIVE_ROOT="$(ask 'Drive root folder ID' "$(seed resources.drive_root_folder_id)")"
RR_APPS_FOLDER="$(ask 'Applications folder ID' "$(seed resources.applications_folder_id)")"
RR_ARCHIVE_FOLDER="$(ask 'Archive folder ID' "$(seed resources.archive_folder_id)")"

RR_CRED_ID=""
if [ "$MODE" = "owner" ]; then
  echo; echo "--- n8n (owner) ---"
  RR_CRED_ID="$(ask 'n8n OpenRouter credential ID' "$(seed credentials.openrouter_cred_id)")"
fi

echo; echo "--- API keys (optional; recommended path is n8n credentials) ---"
RR_OPENROUTER_KEY="$(ask_secret 'OpenRouter API key')"
RR_GEMINI_KEY="$(ask_secret 'Gemini API key')"

export RR_NAME RR_EMAIL RR_PHONE RR_LOCATION RR_LINKEDIN RR_GITHUB \
       RR_PROFILE RR_CV RR_SKILLS RR_SCORE_THRESHOLD RR_CV_TEMPLATE RR_LANGUAGE_GATE \
       RR_EXCLUDE_LANGUAGES RR_FILTER_REC RR_FILTER_LOC RR_SHEET_ID RR_DRIVE_ROOT \
       RR_APPS_FOLDER RR_ARCHIVE_FOLDER RR_CRED_ID

mkdir -p "$(dirname "$TARGET")"
"$PY" - "$TARGET" "$EXAMPLE" <<'PYEOF'
import io, json, os, sys
target, example = sys.argv[1], sys.argv[2]
base = json.load(io.open(target if os.path.exists(target) else example, encoding="utf-8"))
E = os.environ.get
def setv(path, val):
    if not val: return
    cur = base
    keys = path.split(".")
    for k in keys[:-1]:
        cur = cur.setdefault(k, {})
    cur[keys[-1]] = val
setv("candidate.name", E("RR_NAME"));        setv("candidate.email", E("RR_EMAIL"))
setv("candidate.phone", E("RR_PHONE"));       setv("candidate.location", E("RR_LOCATION"))
setv("candidate.linkedin", E("RR_LINKEDIN")); setv("candidate.github", E("RR_GITHUB"))
setv("candidate_profile", E("RR_PROFILE"));   setv("full_cv", E("RR_CV")); setv("skills", E("RR_SKILLS"))
st = E("RR_SCORE_THRESHOLD")
if st:
    try: base.setdefault("scoring", {})["score_threshold"] = int(st)
    except ValueError: pass
setv("scoring.cv_template", E("RR_CV_TEMPLATE"))
setv("scoring.language_gate", E("RR_LANGUAGE_GATE"))
setv("scoring.exclude_languages", E("RR_EXCLUDE_LANGUAGES"))
setv("scoring.filter_recommendation", E("RR_FILTER_REC"))
setv("scoring.filter_location", E("RR_FILTER_LOC"))
setv("resources.google_sheet_id", E("RR_SHEET_ID"))
setv("resources.drive_root_folder_id", E("RR_DRIVE_ROOT"))
setv("resources.applications_folder_id", E("RR_APPS_FOLDER"))
setv("resources.archive_folder_id", E("RR_ARCHIVE_FOLDER"))
setv("credentials.openrouter_cred_id", E("RR_CRED_ID"))
with io.open(target, "w", encoding="utf-8") as f:
    json.dump(base, f, ensure_ascii=False, indent=2); f.write("\n")
print("  wrote " + target)
PYEOF

# --- .env (only if a key was provided) ---
if [ -n "$RR_OPENROUTER_KEY" ] || [ -n "$RR_GEMINI_KEY" ]; then
  ENV_FILE="$HERE/.env"
  {
    echo "# Generated by setup.sh — NEVER commit this file."
    [ -n "$RR_OPENROUTER_KEY" ] && echo "OPENROUTER_API_KEY=$RR_OPENROUTER_KEY"
    [ -n "$RR_GEMINI_KEY" ] && echo "GEMINI_API_KEY=$RR_GEMINI_KEY"
    echo "GOOGLE_SHEET_ID=$RR_SHEET_ID"
    echo "DRIVE_ROOT_FOLDER_ID=$RR_DRIVE_ROOT"
    echo "APPLICATIONS_FOLDER_ID=$RR_APPS_FOLDER"
    echo "ARCHIVE_FOLDER_ID=$RR_ARCHIVE_FOLDER"
  } > "$ENV_FILE"
  echo "  wrote $ENV_FILE"
else
  echo "  (no API key entered — store keys in n8n credentials, see docs/CREDENTIALS.md)"
fi

# --- build / apply ---
echo
if [ "$MODE" = "owner" ]; then
  read -r -p "Rebuild workflows now (py ../_build_workflows.py)? [y/N]: " go || true
  if [ "${go,,}" = "y" ]; then ( cd "$HERE/.." && "$PY" _build_workflows.py ); fi
else
  read -r -p "Generate personalized workflows now (py apply_profile.py)? [y/N]: " go || true
  if [ "${go,,}" = "y" ]; then ( cd "$HERE" && "$PY" apply_profile.py ); fi
fi
echo "Done."
