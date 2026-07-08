#!/usr/bin/env python3
"""커밋 1건의 생산성/품질 지표를 tools/metrics/sprint-{N}.json에 append 한다.

PostToolUse 훅(post_commit_metrics.sh)이 `git commit` 성공 직후 호출한다.
- LOC(+/-), 변경 파일 수: `git show --numstat HEAD`
- LLM 저작 여부: 커밋 메시지의 `Co-Authored-By: Claude` 트레일러 (harness 자동 삽입)
- analyze warning/info 카운트: `flutter analyze`

설계 원칙: metrics 수집은 절대 커밋/워크플로우를 막지 않는다 → 어떤 예외에도 exit 0.
"""
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

METRICS_DIR = Path(__file__).resolve().parent
REPO_ROOT = METRICS_DIR.parent.parent


def run(cmd, **kw):
    return subprocess.run(
        cmd, cwd=REPO_ROOT, capture_output=True, text=True, **kw
    )


def resolve_flutter():
    """비대화형 셸에서 PATH가 보장되지 않으므로 견고하게 flutter 경로를 찾는다."""
    found = shutil.which("flutter")
    if found:
        return found
    for cand in (
        Path.home() / "fvm" / "default" / "bin" / "flutter",
        REPO_ROOT / ".fvm" / "flutter_sdk" / "bin" / "flutter",
    ):
        if cand.exists():
            return str(cand)
    return None


def current_sprint():
    r = run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    branch = r.stdout.strip()
    m = re.search(r"sprint-(\d+)", branch)
    return int(m.group(1)) if m else None


def analyze_counts():
    """flutter analyze 심각도별 카운트. flutter 부재/실패 시 None."""
    flutter = resolve_flutter()
    if not flutter:
        return None
    try:
        r = run([flutter, "analyze", "--no-pub"], timeout=180)
    except Exception:
        return None
    counts = {"error": 0, "warning": 0, "info": 0}
    for line in (r.stdout + r.stderr).splitlines():
        s = line.strip()
        for sev in counts:
            if s.startswith(sev + " •") or s.startswith(sev + " -"):
                counts[sev] += 1
    return counts


def head_info():
    fmt = run(["git", "show", "-s", "--format=%H%n%cI%n%B", "HEAD"]).stdout
    parts = fmt.split("\n", 2)
    commit_hash = parts[0].strip()
    iso = parts[1].strip() if len(parts) > 1 else ""
    body = parts[2] if len(parts) > 2 else ""
    llm = bool(re.search(r"Co-Authored-By:\s*Claude", body, re.IGNORECASE))

    added = deleted = files = 0
    numstat = run(["git", "show", "--numstat", "--format=", "HEAD"]).stdout
    for line in numstat.splitlines():
        cols = line.split("\t")
        if len(cols) == 3:
            files += 1
            if cols[0].isdigit():
                added += int(cols[0])
            if cols[1].isdigit():
                deleted += int(cols[1])
    return commit_hash, iso, llm, added, deleted, files


def load_store(path, sprint):
    if path.exists():
        try:
            return json.loads(path.read_text())
        except Exception:
            pass
    return {"sprint": sprint, "commits": []}


def main():
    sprint = current_sprint()
    if sprint is None:
        return 0  # sprint 브랜치가 아니면 기록하지 않음

    commit_hash, iso, llm, added, deleted, files = head_info()
    if not commit_hash:
        return 0

    path = METRICS_DIR / f"sprint-{sprint}.json"
    store = load_store(path, sprint)
    store.setdefault("commits", [])

    # 동일 커밋 중복 기록 방지 (훅 재실행 대비)
    if any(c.get("hash") == commit_hash for c in store["commits"]):
        return 0

    store["commits"].append(
        {
            "hash": commit_hash[:12],
            "timestamp": iso or datetime.now(timezone.utc).isoformat(),
            "files_changed": files,
            "loc_added": added,
            "loc_deleted": deleted,
            "analyze": analyze_counts(),
            "llm_authored": llm,
        }
    )
    path.write_text(json.dumps(store, indent=2, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:  # metrics는 절대 커밋을 막지 않는다
        print(f"[record_commit] skipped: {e}", file=sys.stderr)
        sys.exit(0)
