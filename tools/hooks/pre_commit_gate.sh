#!/usr/bin/env bash
# Claude Code PreToolUse 훅 (matcher: Bash).
# `git commit` 호출을 가로채 flutter analyze warning/error 가 있으면 커밋을 차단한다.
# 차단은 exit 2 (Claude Code가 tool 호출을 막고 stderr 를 모델에 노출).
# 그 외 Bash 호출은 no-op.
set -uo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

# git commit 이 아닌 명령은 통과
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# 비대화형 셸이라 PATH 미보장 → flutter 경로를 견고하게 해석
FLUTTER="$(command -v flutter || true)"
if [ -z "$FLUTTER" ] && [ -x "$HOME/fvm/default/bin/flutter" ]; then
  FLUTTER="$HOME/fvm/default/bin/flutter"
fi
if [ -z "$FLUTTER" ]; then
  # 환경 문제(flutter 부재)로 커밋 자체를 막지는 않는다
  echo "[pre_commit_gate] flutter 미발견 — analyze 게이트 skip" >&2
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

# P0 리스크(부록 C, 2026-05-30 발견): lib/main.dart의 AppConfig.setDev()가
# 주석 해제된 채 커밋되면 prod 빌드가 Sentry OFF + Mock 데이터 ON 상태로 나간다.
# 스테이지된 main.dart 기준으로 검사(작업 트리가 아니라 실제 커밋될 내용).
if git diff --cached --name-only | grep -qx "lib/main.dart"; then
  if git show :lib/main.dart 2>/dev/null | grep -qE '^[[:space:]]*AppConfig\.setDev\(\);'; then
    echo "❌ lib/main.dart: AppConfig.setDev()가 활성 상태로 커밋 시도됨 — 커밋 차단" >&2
    echo "→ prod 빌드에 Sentry 비활성 + Mock 데이터 생성이 그대로 들어갑니다. AppConfig.setProd()로 되돌리세요." >&2
    exit 2
  fi
fi

out="$("$FLUTTER" analyze --no-pub 2>&1 || true)"
warn="$(printf '%s\n' "$out" | grep -cE '(warning|error) •' || true)"
warn="${warn:-0}"

if [ "$warn" -gt 0 ]; then
  echo "❌ flutter analyze: warning/error ${warn}건 — 커밋 차단 (Sprint 0 게이트)" >&2
  printf '%s\n' "$out" | grep -E '(warning|error) •' >&2
  echo "→ 위 이슈를 해결한 뒤 다시 커밋하세요. (info 는 차단하지 않음)" >&2
  exit 2
fi
exit 0
