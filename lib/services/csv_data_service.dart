import 'dart:io';

import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// 사용자가 Settings "데이터" 섹션에서 직접 트리거하는 CSV 내보내기/가져오기.
///
/// Sprint 1 `BackupService`(마이그레이션 직전 persons/gifts 원본 테이블을 그대로
/// 덤프하는 내부 안전장치, id 등 DB 내부 컬럼 포함)와는 목적이 다르다 — 이쪽은
/// 스프레드시트에서 바로 알아볼 수 있는 "거래 1행 = 기록 1건" 형태의 단일 CSV로
/// 사람이 직접 다루게 한다. person_id 같은 내부 FK 대신 이름으로 인물을 식별한다.
///
/// 가져오기는 기존 데이터를 덮어쓰지 않고 **병합**한다 — 이름이 같은 기존 인물은
/// 재사용하고, 없으면 새로 만든다. 행 단위로 실패해도 전체를 중단하지 않고
/// 성공/실패 건수를 [CsvImportResult]로 보고한다.
class CsvDataService {
  CsvDataService({
    PersonRepository? personRepository,
    GiftRepository? giftRepository,
  })  : _personRepository = personRepository ?? PersonRepository.instance,
        _giftRepository = giftRepository ?? GiftRepository.instance;

  static final CsvDataService instance = CsvDataService();

  final PersonRepository _personRepository;
  final GiftRepository _giftRepository;

  static const _headers = ['이름', '인물분류', '금액', '구분', '항목', '날짜', '메모'];
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  static final _directionByLabel = {
    for (final direction in GiftDirection.values) direction.label: direction,
  };
  static final _categoryByLabel = {
    for (final category in GiftCategory.values) category.label: category,
  };

  /// 현재 DB의 모든 거래를 CSV 문자열로 직렬화한다(person 이름 조인 포함).
  @visibleForTesting
  Future<String> exportToCsvString() async {
    final persons = await _personRepository.getAllPersons();
    final personById = {for (final person in persons) person.id: person};
    final gifts = await _giftRepository.getAllGifts();

    final rows = <List<Object?>>[
      _headers,
      for (final gift in gifts)
        [
          personById[gift.personId]?.name ?? '',
          personById[gift.personId]?.category ?? '',
          gift.amount,
          gift.direction.label,
          gift.category.label,
          _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(gift.date)),
          gift.note,
        ],
    ];

    return csv.encode(rows);
  }

  /// [exportToCsvString]을 임시 디렉토리에 파일로 저장하고 반환한다.
  /// 공유(`share_plus`) 트리거는 호출자(Screen) 책임.
  Future<File> exportToFile() async {
    final content = await exportToCsvString();
    final dir = await getTemporaryDirectory();
    final epochMs = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(dir.path, 'cashheart_export_$epochMs.csv'));
    return file.writeAsString(content);
  }

  /// CSV 파일을 읽어 [importFromCsvString]으로 위임한다.
  Future<CsvImportResult> importFromFile(File file) async {
    final content = await file.readAsString();
    return importFromCsvString(content);
  }

  @visibleForTesting
  Future<CsvImportResult> importFromCsvString(String content) async {
    List<CsvRow> rows;
    try {
      rows = csv.decodeWithHeaders(content);
    } catch (e, st) {
      debugPrint('CsvDataService.importFromCsvString parse error: $e');
      await Sentry.captureException(e, stackTrace: st);
      throw const FormatException('CSV 형식을 읽을 수 없어요.');
    }

    final existingPersons = await _personRepository.getAllPersons();
    final personIdByName = {
      for (final person in existingPersons) person.name: person.id!,
    };

    var importedGifts = 0;
    var failedRows = 0;

    for (final row in rows) {
      try {
        final name = (row['이름'] as String?)?.trim();
        if (name == null || name.isEmpty) {
          failedRows++;
          continue;
        }

        final direction = _directionByLabel[(row['구분'] as String?)?.trim()];
        final category = _categoryByLabel[(row['항목'] as String?)?.trim()];
        final amount = int.tryParse((row['금액'] as String? ?? '').trim());
        final dateText = (row['날짜'] as String?)?.trim();

        if (direction == null || category == null || amount == null || dateText == null) {
          failedRows++;
          continue;
        }
        final date = _dateFormat.parse(dateText);

        var personId = personIdByName[name];
        if (personId == null) {
          final personCategory = (row['인물분류'] as String?)?.trim();
          personId = await _personRepository.insertPerson(Person(
            name: name,
            category: (personCategory == null || personCategory.isEmpty)
                ? null
                : personCategory,
          ));
          personIdByName[name] = personId;
        }

        await _giftRepository.insertGift(Gift(
          personId: personId,
          amount: amount,
          direction: direction,
          category: category,
          date: date.millisecondsSinceEpoch,
          note: (row['메모'] as String?) ?? '',
        ));
        importedGifts++;
      } catch (e) {
        failedRows++;
      }
    }

    return CsvImportResult(importedGifts: importedGifts, failedRows: failedRows);
  }
}

class CsvImportResult {
  final int importedGifts;
  final int failedRows;

  const CsvImportResult({
    required this.importedGifts,
    required this.failedRows,
  });
}
