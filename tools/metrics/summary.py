#!/usr/bin/env python3
"""tools/metrics/sprint-*.json 을 읽어 sprint별 지표 추이를 표로 출력한다.

Sprint 6 최종 "baseline vs 출시" 어필 그래프의 데이터 소스.
사용: python3 tools/metrics/summary.py
"""
import glob
import json
import os
from pathlib import Path

METRICS_DIR = Path(__file__).resolve().parent


def load_all():
    stores = []
    for p in sorted(glob.glob(str(METRICS_DIR / "sprint-*.json"))):
        try:
            stores.append((os.path.basename(p), json.loads(Path(p).read_text())))
        except Exception as e:
            print(f"! {p}: {e}")
    return stores


def main():
    stores = load_all()
    if not stores:
        print("기록된 metrics 없음.")
        return

    print(f"{'sprint':<8}{'commits':<9}{'LLM%':<7}{'LOC+':<9}{'LOC-':<9}{'warn':<6}{'info':<6}")
    print("-" * 54)
    for name, store in stores:
        commits = store.get("commits", [])
        n = len(commits)
        llm = sum(1 for c in commits if c.get("llm_authored"))
        added = sum(c.get("loc_added", 0) for c in commits)
        deleted = sum(c.get("loc_deleted", 0) for c in commits)
        # 최신 커밋의 analyze 카운트(추이의 끝점)
        last_az = next(
            (c.get("analyze") for c in reversed(commits) if c.get("analyze")), None
        )
        warn = last_az.get("warning", "-") if last_az else "-"
        info = last_az.get("info", "-") if last_az else "-"
        llm_pct = f"{(llm / n * 100):.0f}%" if n else "-"
        sprint = store.get("sprint", name)
        print(f"{str(sprint):<8}{n:<9}{llm_pct:<7}{added:<9}{deleted:<9}{str(warn):<6}{str(info):<6}")

    # baseline 표시 (sprint-0)
    for name, store in stores:
        base = store.get("baseline")
        if base:
            az = base.get("analyze", {})
            print()
            print(
                f"baseline ({base.get('captured_at','?')}): "
                f"dart {base.get('dart_loc','?')} LOC / {base.get('dart_files','?')} files, "
                f"test {base.get('test_files','?')} files, coverage {base.get('coverage_pct','?')}%, "
                f"analyze warn={az.get('warning','?')} info={az.get('info','?')}"
            )
            break


if __name__ == "__main__":
    main()
