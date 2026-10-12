#!/usr/bin/env bash
# video-edit health check. Safe to re-run; changes nothing except what the skill's own setup.py
# already repairs (its Python venv). Exit 0 only when everything the skill needs is ready.
#
#   1. Runs the skill's setup.py (ffmpeg, Node 22+, Python venv, sound effects).
#   2. Probes every network host the skill downloads from (a cloud environment's network policy
#      can block these; the skill then fails mid-run instead of at setup).
#   3. Reports whether the one-time onboarding answers (config.json) were restored.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SK="$ROOT/.claude/skills/video-edit"
fail=0
ok()  { echo "  OK       $*"; }
bad() { echo "  PROBLEM  $*"; fail=1; }

if [[ ! -f "$SK/SKILL.md" ]]; then
  echo "video-edit skill not found at $SK. Run ./scripts/sync-skill.sh first." >&2
  exit 1
fi

echo "1. Skill environment (the skill's own setup.py)"
PYBIN="$(command -v python3 || command -v python || true)"
if [[ -z "$PYBIN" ]]; then
  bad "no python3 on PATH"
else
  if out="$("$PYBIN" "$SK/scripts/setup.py" 2>&1)"; then ok "setup.py reports READY"; else bad "setup.py reports NOT READY"; fi
  printf '%s\n' "$out" | sed 's/^/           /'
fi

echo "2. Network hosts the skill downloads from"
# probe "<what it is for>" <curl args...>  (200 and 206 both count: 206 is a 1-byte range request)
probe() {
  local what="$1"; shift
  local code
  code="$(curl -sS -L -o /dev/null -m 30 -w '%{http_code}' "$@" 2>/dev/null || true)"
  if [[ "$code" == "200" || "$code" == "206" ]]; then ok "$what"; else bad "$what (HTTP ${code:-none}; blocked or unreachable)"; fi
}
probe "registry.npmjs.org: HyperFrames renderer (npx)" "https://registry.npmjs.org/hyperframes"
probe "pypi.org: Python packages"                      "https://pypi.org/simple/faster-whisper/"
probe "raw.githubusercontent.com: sound effects"       "https://raw.githubusercontent.com/heygen-com/hyperframes/main/README.md"
probe "cdn.jsdelivr.net: GSAP animation library (every render)" "https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"
probe "huggingface.co + its file CDN: Whisper models (transcription)" -r 0-0 "https://huggingface.co/Systran/faster-whisper-small.en/resolve/main/model.bin"

echo "3. One-time onboarding answers"
if [[ -f "$SK/config.json" ]]; then
  ok "config.json present, so /video-edit will not re-ask the setup questions"
else
  echo "  NOTE     no config.json, so /video-edit will ask the setup questions again"
fi

echo
if [[ "$fail" == "0" ]]; then
  echo "video-edit: ready."
else
  echo "video-edit: NOT ready. Fix the PROBLEM lines above."
  echo "In a Claude Code cloud environment, a blocked host is added under Network access > Allowed domains:"
  echo "  https://code.claude.com/docs/en/cloud-environments#network-access"
fi
exit "$fail"
