<#
  RoleRadar setup wizard (PowerShell). Collects your profile, scoring prefs, Google
  resource IDs and API keys, then writes a profile.json + .env and (optionally) builds
  the workflows.

      ./setup.ps1                 # auto-detect owner vs public
      ./setup.ps1 -Mode public

  Python 3 is required (used for safe JSON writing + applying the profile).
#>
param([string]$Mode = "auto")
$ErrorActionPreference = "Stop"

$HERE = $PSScriptRoot
$EXAMPLE = Join-Path $HERE "profile.example.json"

# --- pick a Python 3 interpreter ---
$PY = $null
foreach ($c in @("py", "python3", "python")) {
  $cmd = Get-Command $c -ErrorAction SilentlyContinue
  if ($cmd) {
    try { & $c -c "import sys;exit(0 if sys.version_info[0]>=3 else 1)" 2>$null; if ($LASTEXITCODE -eq 0) { $PY = $c; break } } catch {}
  }
}
if (-not $PY) { Write-Error "Python 3 not found (need it for JSON writing)."; exit 1 }

# --- mode: owner (has the build script) vs public ---
if ($Mode -eq "auto") {
  if (Test-Path (Join-Path $HERE "..\_build_workflows.py")) { $Mode = "owner" } else { $Mode = "public" }
}
$TARGET = if ($Mode -eq "owner") { Join-Path $HERE "..\private\profile.json" } else { Join-Path $HERE "profile.json" }

Write-Host "============================================================"
Write-Host " RoleRadar setup  (mode: $Mode)"
Write-Host " Profile  -> $TARGET"
Write-Host " Defaults come from your existing profile if present, else the example."
Write-Host " Press Enter to keep the shown [default]. For CV/skills/profile, give a file path."
Write-Host "============================================================"

$seedCode = @'
import io, json, os, sys
target, example, path = sys.argv[1], sys.argv[2], sys.argv[3]
src = target if os.path.exists(target) else example
d = json.load(io.open(src, encoding="utf-8"))
cur = d
for k in path.split("."):
    cur = cur.get(k, {}) if isinstance(cur, dict) else ""
print(cur if isinstance(cur, (str, int)) else "")
'@
function Seed($path) { return ($seedCode | & $PY - $TARGET $EXAMPLE $path) }

function Ask($prompt, $def) {
  $a = Read-Host "$prompt [$def]"
  if ([string]::IsNullOrEmpty($a)) { return $def } else { return $a }
}
function AskFile($prompt) {
  $p = Read-Host "$prompt (file path, Enter to keep current)"
  if ([string]::IsNullOrEmpty($p)) { return "" }
  if (-not (Test-Path $p)) { Write-Host "  ! file not found: $p (keeping current)"; return "" }
  return (Get-Content -Raw -Path $p)
}
function AskSecret($prompt) {
  $s = Read-Host "$prompt (hidden, Enter to skip)" -AsSecureString
  if ($s.Length -eq 0) { return "" }
  $b = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
  try { return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($b) }
  finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

Write-Host "`n--- Contact ---"
$env:RR_NAME     = Ask "Full name"        (Seed "candidate.name")
$env:RR_EMAIL    = Ask "Email"            (Seed "candidate.email")
$env:RR_PHONE    = Ask "Phone"            (Seed "candidate.phone")
$env:RR_LOCATION = Ask "Location"         (Seed "candidate.location")
$env:RR_LINKEDIN = Ask "LinkedIn URL"     (Seed "candidate.linkedin")
$env:RR_GITHUB   = Ask "GitHub URL"       (Seed "candidate.github")

Write-Host "`n--- Profile text (give a file path to replace, Enter to keep) ---"
$env:RR_PROFILE = AskFile "Candidate profile (Phase 2 scoring context)"
$env:RR_CV      = AskFile "Full CV text (Phase 3 generation context)"
$env:RR_SKILLS  = AskFile "Skills (source-of-truth skill list)"

Write-Host "`n--- Scoring & language ---"
$env:RR_SCORE_THRESHOLD   = Ask "Score threshold (0-100)" (Seed "scoring.score_threshold")
$env:RR_CV_TEMPLATE       = Ask "CV template (auto, or 1-15)" (Seed "scoring.cv_template")
$env:RR_LANGUAGE_GATE     = Ask "Language gate (off|english_only|exclude)" (Seed "scoring.language_gate")
$env:RR_EXCLUDE_LANGUAGES = Ask "Exclude languages (comma list)" (Seed "scoring.exclude_languages")
$env:RR_FILTER_REC        = Ask "Phase 3 filter: recommendation (blank=all)" (Seed "scoring.filter_recommendation")
$env:RR_FILTER_LOC        = Ask "Phase 3 filter: location (blank=all)" (Seed "scoring.filter_location")

Write-Host "`n--- Google resource IDs ---"
$env:RR_SHEET_ID       = Ask "Google Sheet ID" (Seed "resources.google_sheet_id")
$env:RR_DRIVE_ROOT     = Ask "Drive root folder ID" (Seed "resources.drive_root_folder_id")
$env:RR_APPS_FOLDER    = Ask "Applications folder ID" (Seed "resources.applications_folder_id")
$env:RR_ARCHIVE_FOLDER = Ask "Archive folder ID" (Seed "resources.archive_folder_id")

$env:RR_CRED_ID = ""
if ($Mode -eq "owner") {
  Write-Host "`n--- n8n (owner) ---"
  $env:RR_CRED_ID = Ask "n8n OpenRouter credential ID" (Seed "credentials.openrouter_cred_id")
}

Write-Host "`n--- API keys (optional; recommended path is n8n credentials) ---"
$RR_OPENROUTER_KEY = AskSecret "OpenRouter API key"
$RR_GEMINI_KEY     = AskSecret "Gemini API key"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TARGET) | Out-Null

$writer = @'
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
'@
$writer | & $PY - $TARGET $EXAMPLE

# --- .env (only if a key was provided) ---
if ($RR_OPENROUTER_KEY -or $RR_GEMINI_KEY) {
  $envFile = Join-Path $HERE ".env"
  $lines = @("# Generated by setup.ps1 - NEVER commit this file.")
  if ($RR_OPENROUTER_KEY) { $lines += "OPENROUTER_API_KEY=$RR_OPENROUTER_KEY" }
  if ($RR_GEMINI_KEY)     { $lines += "GEMINI_API_KEY=$RR_GEMINI_KEY" }
  $lines += "GOOGLE_SHEET_ID=$($env:RR_SHEET_ID)"
  $lines += "DRIVE_ROOT_FOLDER_ID=$($env:RR_DRIVE_ROOT)"
  $lines += "APPLICATIONS_FOLDER_ID=$($env:RR_APPS_FOLDER)"
  $lines += "ARCHIVE_FOLDER_ID=$($env:RR_ARCHIVE_FOLDER)"
  Set-Content -Path $envFile -Value $lines -Encoding utf8
  Write-Host "  wrote $envFile"
} else {
  Write-Host "  (no API key entered - store keys in n8n credentials, see docs/CREDENTIALS.md)"
}

# --- build / apply ---
Write-Host ""
if ($Mode -eq "owner") {
  if ((Read-Host "Rebuild workflows now (py ../_build_workflows.py)? [y/N]") -match '^(y|Y)') {
    Push-Location (Join-Path $HERE ".."); try { & $PY _build_workflows.py } finally { Pop-Location }
  }
} else {
  if ((Read-Host "Generate personalized workflows now (py apply_profile.py)? [y/N]") -match '^(y|Y)') {
    Push-Location $HERE; try { & $PY apply_profile.py } finally { Pop-Location }
  }
}
Write-Host "Done."
