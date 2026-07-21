import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

/// DB 마이그레이션(onUpgrade) 직전 안전장치.
///
/// sqflite/sqlite의 onUpgrade는 이미 트랜잭션으로 감싸져 실행되므로, 마이그레이션
/// 도중 예외가 발생하면 스키마 변경은 자동 롤백되고 DB 파일 자체는 손상되지 않는다
/// (커스텀 롤백 로직 불필요 — tekartik/sqflite `opening_db.md` 참고).
///
/// 이 서비스는 그 위에 얹는 추가 안전판으로, 업그레이드가 실제로 일어나기 직전
/// 시점의 데이터를 CSV로 내보내 사람이 확인/복구할 수 있는 형태로 남긴다.
/// 백업 자체가 실패하더라도 마이그레이션 진행을 막아서는 안 되므로, 모든 예외를
/// 내부에서 흡수하고 실패 시 null을 반환한다.
class BackupService {
  BackupService._internal();
  static final BackupService instance = BackupService._internal();

  static const _tables = ['persons', 'gifts'];

  /// 열려 있는(읽기 가능한) [db]의 `persons`, `gifts` 테이블을 CSV로 내보낸다.
  ///
  /// 저장 위치: `<ApplicationDocumentsDirectory>/backups/<oldVersion>_to_<newVersion>_<epochMs>/`
  /// 그 아래 `persons.csv`, `gifts.csv`를 생성한다.
  ///
  /// 성공 시 백업 디렉토리의 [Directory]를, 실패 시 null을 반환한다. 예외를
  /// 다시 던지지 않는다 — 호출자(AppDatabase)는 백업 성공 여부와 무관하게
  /// 마이그레이션을 계속 진행해야 한다.
  Future<Directory?> backupBeforeMigration({
    required Database db,
    required int oldVersion,
    required int newVersion,
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final epochMs = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory(
        p.join(
          docsDir.path,
          'backups',
          '${oldVersion}_to_${newVersion}_$epochMs',
        ),
      );
      await backupDir.create(recursive: true);

      for (final table in _tables) {
        final rows = await db.query(table);
        final csvString = _rowsToCsv(rows);
        final file = File(p.join(backupDir.path, '$table.csv'));
        await file.writeAsString(csvString);
      }

      return backupDir;
    } catch (e, st) {
      debugPrint('BackupService.backupBeforeMigration error: $e');
      await Sentry.captureException(e, stackTrace: st);
      return null;
    }
  }

  /// 쿼리 결과 행들을 CSV 문자열로 변환한다. 헤더는 하드코딩하지 않고 첫 행의
  /// key 집합에서 동적으로 뽑는다(스키마 변경에 안전). 행이 비어 있으면 헤더 없이
  /// 빈 문자열을 반환한다.
  String _rowsToCsv(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return '';

    final headers = rows.first.keys.toList();
    final data = <List<Object?>>[
      headers,
      for (final row in rows) headers.map((h) => row[h]).toList(),
    ];

    return csv.encode(data);
  }
}
