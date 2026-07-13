import 'package:cash_heart/models/relationship_stats.dart';

/// 카드 공유 자격 케이스 — Sprint 4 로드맵의 "선택과 집중" 2케이스만 지원한다.
/// `none`은 공유 버튼/배너 자체를 숨기라는 신호다.
enum ShareCardCase { none, oneWayGiven, oneWayReceived, soulmate }

/// A(일방통행)·E(영혼의 동반자) 판정. 둘 다 만족하면 E가 우선한다(로드맵 명시).
///
/// [rank]는 전체 person 중 총액(given+received 합계) 내림차순 1-indexed 순위,
/// [totalPersonsWithRecords]는 거래 기록이 1건 이상 있는 person 수 — 둘 다
/// [GiftRepository.getTotalRank] 또는 이를 in-memory로 재현한 값이어야 한다.
/// 지인이 5명 미만이면 "상위권"이 통계적으로 의미가 없어 percentile 게이트를 건너뛴다.
ShareCardCase determineShareCardCase({
  required RelationshipStats stats,
  required int rank,
  required int totalPersonsWithRecords,
}) {
  final isMutual = stats.given > 0 && stats.received > 0;
  final isTopTier = totalPersonsWithRecords < 5 ||
      rank <= (totalPersonsWithRecords * 0.2).ceil();

  if (isMutual && stats.count >= 6 && isTopTier) {
    return ShareCardCase.soulmate;
  }

  if (stats.dominantPercent >= 70 && stats.count >= 3) {
    return stats.direction == RelationshipDirection.given
        ? ShareCardCase.oneWayGiven
        : ShareCardCase.oneWayReceived;
  }

  return ShareCardCase.none;
}
