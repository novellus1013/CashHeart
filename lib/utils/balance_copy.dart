import 'package:cash_heart/theme/balance_state.dart';

/// 관계 균형/일방성 관련 사용자 노출 문구 — 전부 `.claude/rules/copy-tone.md` 대상.
/// Sprint 3 카피 톤 검수 게이트 전까지는 가안(design_handoff `toneLabel`/`toneMessage`
/// 이식)이며, 실기기 검수에서 최종 확정된다. 한 파일에 모아 게이트 리뷰를 쉽게 한다.

/// design_handoff `toneLabel` 이식 — 균형 상태를 가리키는 짧은 pill 라벨.
String balanceStateLabel(BalanceState state) {
  switch (state) {
    case BalanceState.balanced:
      return '균형';
    case BalanceState.tilted:
      return '기울어짐';
    case BalanceState.severe:
      return '한쪽으로 흐름';
  }
}

/// design_handoff `toneMessage` 이식 — Person Detail hero 인용구.
String balanceToneMessage({required int count, required BalanceState state}) {
  if (count == 0) return '아직 오고 간 기록이 없어요.';
  if (count == 1) return '더 많은 기록이 쌓이면 관계의 흐름이 보여요.';
  switch (state) {
    case BalanceState.balanced:
      return '주고받음이 균형 잡혀 있어요.';
    case BalanceState.tilted:
      return '주고받음이 한쪽으로 기울어 있어요.';
    case BalanceState.severe:
      return '이 관계는 한쪽으로 흐르고 있어요.';
  }
}

/// design_handoff Report `InsightGroup` tilted 그룹의 per-row note.
/// tilt > 0: 받은 마음 비중이 큼 / tilt < 0: 준 마음 비중이 큼.
String tiltDirectionNote(double tilt) {
  return tilt > 0 ? '받은 마음이 많아요' : '준 마음이 많아요';
}

/// Report "가장 많이 나눈 사람" per-row note — 거래 건수를 정(情)의 횟수로 표현.
String frequencyNote(int count) {
  return '$count번의 마음을 나눴어요';
}

/// Report 계절성 인사이트 — peakMonths(1~12, 최대 2개)를 문장으로.
String? peakSeasonNote(List<int> peakMonths) {
  if (peakMonths.isEmpty) return null;
  if (peakMonths.length == 1) return '${peakMonths.first}월에 마음을 나누는 일이 많아요';
  final sorted = [...peakMonths]..sort();
  return '${sorted[0]}월과 ${sorted[1]}월에 마음을 나누는 일이 많아요';
}

/// Report 전년 동기 대비 인사이트 — percent는 (올해-작년)/작년*100.
String yoyNote(double percent) {
  final rounded = percent.abs().round();
  if (rounded == 0) return '작년 이맘때와 비슷한 만큼 마음을 나눴어요';
  return percent > 0
      ? '작년 이맘때보다 오고 간 마음이 $rounded% 늘었어요'
      : '작년 이맘때보다 오고 간 마음이 $rounded% 줄었어요';
}

/// design_handoff `relativeLast` 이식 — 마지막 기록 시점의 상대적 표현.
String relativeTimeLabel(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays < 1) return '오늘';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
  return '${(diff.inDays / 365).floor()}년 전';
}
