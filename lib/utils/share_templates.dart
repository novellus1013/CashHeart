import 'dart:convert';
import 'dart:math';

import 'package:cash_heart/utils/share_card_case.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 카드 공유 케이스 1개의 칭호 + 정적 문구 목록. 실제 문구는
/// `assets/data/share_templates.json`에 있으며 `.claude/rules/copy-tone.md`의
/// "유저 자발 공유 카드" 예외(담백한 유머 허용, 실제 금액 노출 금지) 기준으로
/// AI가 초안 생성 후 사람이 큐레이션한다(Sprint 4 사용자 게이트).
class ShareTemplate {
  final String title;
  final List<String> messages;

  const ShareTemplate({required this.title, required this.messages});
}

const _assetPath = 'assets/data/share_templates.json';

Map<ShareCardCase, ShareTemplate>? _cache;

const _caseKeys = {
  ShareCardCase.oneWayGiven: 'oneWayGiven',
  ShareCardCase.oneWayReceived: 'oneWayReceived',
  ShareCardCase.soulmate: 'soulmate',
};

/// [caseType]의 [ShareTemplate]을 로드한다. `ShareCardCase.none`은 호출부에서
/// 걸러져야 한다(카드 공유 화면 자체에 진입하지 않으므로).
Future<ShareTemplate> loadShareTemplate(ShareCardCase caseType) async {
  final key = _caseKeys[caseType];
  if (key == null) {
    throw ArgumentError('ShareCardCase.none은 템플릿이 없습니다.');
  }

  final all = _cache ??= await _loadAll();
  return all[caseType]!;
}

Future<Map<ShareCardCase, ShareTemplate>> _loadAll() async {
  final raw = await rootBundle.loadString(_assetPath);
  final decoded = json.decode(raw) as Map<String, dynamic>;

  return {
    for (final entry in _caseKeys.entries)
      entry.key: ShareTemplate(
        title: decoded[entry.value]['title'] as String,
        messages: List<String>.from(decoded[entry.value]['messages'] as List),
      ),
  };
}

final _random = Random();

/// [messages]에서 무작위로 1개를 고른다. [exclude]와 다른 값을 우선 반환하되
/// (카드의 "🔄 다른 문구" 버튼용), 후보가 1개뿐이면 그대로 반환한다.
String pickRandomMessage(List<String> messages, {String? exclude}) {
  if (messages.isEmpty) return '';
  if (messages.length == 1) return messages.first;

  final candidates =
      exclude == null ? messages : messages.where((m) => m != exclude).toList();
  final pool = candidates.isEmpty ? messages : candidates;
  return pool[_random.nextInt(pool.length)];
}
