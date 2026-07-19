# tools/metrics — AI 효과 측정 인프라

CashHeart v2.0 "어필 4축" 중 **1번(AI 도입의 수치적 증명)** 의 정량 근거를 커밋 단위로 누적한다. Sprint 0 baseline vs 출시 직전을 비교해 그래프로 산출하는 것이 최종 목표.

## 수집 방식

`.claude/settings.json`의 **PostToolUse 훅**이 `git commit` 성공 직후 `tools/hooks/post_commit_metrics.sh` → `record_commit.py` 를 실행한다. 사람이 수동으로 실행할 필요 없음.

- metrics 수집은 **non-blocking** — 어떤 실패에도 커밋/워크플로우를 막지 않는다(항상 exit 0).
- sprint 번호는 브랜치명(`feat/sprint-{N}-*`)에서 자동 추출. sprint 브랜치가 아니면 기록하지 않는다.

## 지표

| 지표 | 소스 | 축 |
|------|------|----|
| LOC +/- (커밋당) | `git show --numstat HEAD` | 생산성 |
| LLM 저작 비율 | 커밋 메시지 `Co-Authored-By: Claude` 트레일러 | 생산성 |
| analyze warning/info 추이 | `flutter analyze` | 품질 |
| dart LOC / 파일 수 / coverage | baseline seed (sprint-0.json) | 품질 |

> Story 1개당 소요 시간은 `bmad-dev-story` 시작/종료 타임스탬프에서 별도 수집(Sprint 1+).
> 커버리지(lcov)는 Sprint 6에서 연결됨: `.github/workflows/ci.yml`이 PR마다 `flutter test --coverage`를 실행해 job summary에 표기. `sprint-{N}.json`의 `baseline.coverage_pct`는 sprint 착수 시점 1회 수기 스냅샷(자동 커밋-백 없음) — `flutter test --coverage` 후 `coverage/lcov.info`의 LF/LH 합산으로 산출.

## 파일

- `record_commit.py` — 커밋 1건 지표를 `sprint-{N}.json`의 `commits[]`에 append (중복 hash 방지).
- `summary.py` — 모든 `sprint-*.json`을 읽어 sprint별 추이 표 출력. `python3 tools/metrics/summary.py`
- `sprint-{N}.json` — sprint별 데이터 스토어. `sprint-0.json`은 baseline 레코드 포함.

## 스토어 스키마

```json
{
  "sprint": 0,
  "baseline": { "captured_at": "...", "dart_loc": 4905, "analyze": {"warning":1,"info":3}, ... },
  "commits": [
    {
      "hash": "abc123def456",
      "timestamp": "2026-07-08T12:00:00+09:00",
      "files_changed": 12,
      "loc_added": 340,
      "loc_deleted": 12,
      "analyze": { "error": 0, "warning": 0, "info": 3 },
      "llm_authored": true
    }
  ]
}
```
