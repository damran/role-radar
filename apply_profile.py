#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RoleRadar — personalize the workflows from your profile.

Reads a profile config (default: profile.json, or profile.example.json as a fallback)
and writes ready-to-import copies of the four workflows into ./configured/ with your
details, models, scoring knobs and Google resource IDs filled in.

This does NOT touch API keys — keep those in your n8n credentials (recommended) or .env.

Usage:
    python apply_profile.py                 # uses ./profile.json (or profile.example.json)
    python apply_profile.py my-profile.json # use a specific profile

Run the interactive wizard (setup.ps1 / setup.sh) first if you'd rather be prompted.
"""
import io, json, os, sys

BASE = os.path.dirname(os.path.abspath(__file__))
WF_DIR = os.path.join(BASE, "workflows")
OUT_DIR = os.path.join(BASE, "configured")
WORKFLOWS = ["1-job-search.json", "1.5-job-archive.json",
             "2-ai-scoring.json", "3-cv-coverletter-generator.json"]


def load_json(path):
    with io.open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def node_by_name(data, name):
    for n in data.get("nodes", []):
        if n.get("name") == name:
            return n
    return None


def set_field(node, name, value):
    """Update a classic Set node field (parameters.fields.values) in place if present."""
    if node is None:
        return
    vals = node.get("parameters", {}).get("fields", {}).get("values")
    if vals is None:
        return
    for v in vals:
        if v.get("name") == name:
            v["stringValue"] = value
            return
    vals.append({"name": name, "stringValue": value})


def set_assignment(node):
    """Return the assignment dict of a Set v3 node (parameters.assignments.assignments[0])."""
    if node is None:
        return None
    a = node.get("parameters", {}).get("assignments", {}).get("assignments")
    return a[0] if a else None


def personalize(key, data, profile):
    c = profile.get("candidate", {})
    sc = profile.get("scoring", {})
    md = profile.get("models", {})
    if key == "2-ai-scoring.json":
        a = set_assignment(node_by_name(data, "Set Candidate Profile"))
        if a is not None:
            a["value"] = profile.get("candidate_profile", a.get("value", ""))
        cfg = node_by_name(data, "P2: Load Config")
        set_field(cfg, "SCORE_THRESHOLD", str(sc.get("score_threshold", 65)))
        set_field(cfg, "SCORING_MODEL", md.get("scoring", "deepseek/deepseek-v4-flash"))
        set_field(cfg, "LANGUAGE_GATE", sc.get("language_gate", "english_only"))
        set_field(cfg, "EXCLUDE_LANGUAGES", sc.get("exclude_languages", ""))
    if key == "3-cv-coverletter-generator.json":
        cfg = node_by_name(data, "P3: Set Job ID")
        set_field(cfg, "FULL_CV_CONTEXT", profile.get("full_cv", ""))
        set_field(cfg, "SKILLS", profile.get("skills", ""))
        set_field(cfg, "CV_MODEL", md.get("cv", "anthropic/claude-sonnet-4.6"))
        set_field(cfg, "CL_MODEL", md.get("cl", "anthropic/claude-sonnet-4.6"))
        set_field(cfg, "SWOT_MODEL", md.get("swot", "deepseek/deepseek-v4-flash"))
        set_field(cfg, "STUDY_MODEL", md.get("study", "deepseek/deepseek-v4-flash"))
        set_field(cfg, "CV_TEMPLATE", sc.get("cv_template", "auto"))
        set_field(cfg, "FILTER_RECOMMENDATION", sc.get("filter_recommendation", ""))
        set_field(cfg, "FILTER_LOCATION", sc.get("filter_location", ""))
        for fname, ckey in [("CANDIDATE_NAME", "name"), ("CANDIDATE_EMAIL", "email"),
                            ("CANDIDATE_PHONE", "phone"), ("CANDIDATE_LINKEDIN", "linkedin"),
                            ("CANDIDATE_LOCATION", "location"), ("CANDIDATE_GITHUB", "github")]:
            set_field(cfg, fname, c.get(ckey, ""))


def fill_resource_ids(text, resources):
    """Replace the YOUR_* resource placeholders everywhere with real IDs (when provided)."""
    mapping = {
        "YOUR_GOOGLE_SHEET_ID": resources.get("google_sheet_id", ""),
        "YOUR_DRIVE_ROOT_FOLDER_ID": resources.get("drive_root_folder_id", ""),
        "YOUR_APPLICATIONS_FOLDER_ID": resources.get("applications_folder_id", ""),
        "YOUR_ARCHIVE_FOLDER_ID": resources.get("archive_folder_id", ""),
    }
    for placeholder, real in mapping.items():
        if real and real != placeholder:
            text = text.replace(placeholder, real)
    return text


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else None
    if arg:
        profile_path = arg if os.path.isabs(arg) else os.path.join(BASE, arg)
    else:
        cand = os.path.join(BASE, "profile.json")
        profile_path = cand if os.path.exists(cand) else os.path.join(BASE, "profile.example.json")

    if not os.path.exists(profile_path):
        sys.exit("Profile not found: %s\nCopy profile.example.json to profile.json (or run setup)." % profile_path)

    profile = load_json(profile_path)
    resources = profile.get("resources", {})
    os.makedirs(OUT_DIR, exist_ok=True)

    print("Using profile: %s" % os.path.relpath(profile_path, BASE))
    for key in WORKFLOWS:
        src = os.path.join(WF_DIR, key)
        if not os.path.exists(src):
            print("  skip (missing): %s" % key)
            continue
        data = load_json(src)
        personalize(key, data, profile)
        text = fill_resource_ids(json.dumps(data, ensure_ascii=False, indent=2) + "\n", resources)
        with io.open(os.path.join(OUT_DIR, key), "w", encoding="utf-8") as f:
            f.write(text)
        print("  wrote configured/%s" % key)

    left = [p for p in ("YOUR_GOOGLE_SHEET_ID", "YOUR_DRIVE_ROOT_FOLDER_ID",
                        "YOUR_APPLICATIONS_FOLDER_ID", "YOUR_ARCHIVE_FOLDER_ID")
            if not resources.get({"YOUR_GOOGLE_SHEET_ID": "google_sheet_id",
                                  "YOUR_DRIVE_ROOT_FOLDER_ID": "drive_root_folder_id",
                                  "YOUR_APPLICATIONS_FOLDER_ID": "applications_folder_id",
                                  "YOUR_ARCHIVE_FOLDER_ID": "archive_folder_id"}[p])]
    print("\nDone. Import the files in configured/ into n8n.")
    if left:
        print("Note: these resource IDs were left as placeholders (set them in the profile or in n8n): "
              + ", ".join(left))
    print("Remember to attach your Google + OpenRouter credentials after import (see docs/CREDENTIALS.md).")


if __name__ == "__main__":
    main()
