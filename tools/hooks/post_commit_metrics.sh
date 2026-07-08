#!/usr/bin/env bash
# Claude Code PostToolUse 훅 (matcher: Bash).
# `git commit` 성공 직후 record_commit.py 로 커밋 지표를 sprint-{N}.json 에 append 한다.
# metrics 는 non-blocking — 어떤 실패에도 항상 exit 0.
set -uo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$DIR" ] || exit 0

python3 "$DIR/tools/metrics/record_commit.py" >/dev/null 2>&1 || true
exit 0
