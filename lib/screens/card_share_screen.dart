import 'dart:io';
import 'dart:ui' as ui;

import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:cash_heart/utils/share_templates.dart';
import 'package:cash_heart/widgets/share_card_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// [ShareCardPreview] 프리뷰 + 정적 JSON 템플릿(assets/data/share_templates.json)
/// 기반 메시지 편집 + 캡처 공유. [caseType]은 `ShareCardCase.none`이 아니어야
/// 하며(호출부가 가드), 그 케이스의 칭호·문구 목록을 로드해 초기 메시지를 정한다.
class CardShareScreen extends StatefulWidget {
  final String personName;
  final RelationshipStats stats;
  final ShareCardCase caseType;

  const CardShareScreen({
    super.key,
    required this.personName,
    required this.stats,
    required this.caseType,
  });

  @override
  State<CardShareScreen> createState() => _CardShareScreenState();
}

/// 카드가 도착하는 랜딩 링크 — 이미지 안 QR 대신 공유 caption 텍스트로 함께
/// 전달한다(채팅 앱에서 자동으로 눌리는 링크가 되어 QR 스캔보다 마찰이 적음).
const _shareLandingUrl = 'https://cashheart.novelus.dev/';

class _CardShareScreenState extends State<CardShareScreen> {
  final _captureKey = GlobalKey();
  final _shareButtonKey = GlobalKey();
  final _customController = TextEditingController();

  late Future<ShareTemplate> _templateFuture;
  ShareTemplate? _template;
  String _message = '';
  bool _hasEdited = false;
  bool _isSharing = false;

  /// 실제 금액(준/받은 원화) 노출 여부 — 기본 공개(2026-07-11 사용자 확정), 원치
  /// 않으면 공유 직전 직접 끌 수 있다.
  bool _showAmount = true;

  /// 지인 이름에 "님"을 붙일지 — 기본 존칭(공유 대상이 그 지인 본인일 수 있음).
  bool _useHonorific = true;

  /// 공유 완료율/인카드 편집율/🔄 사용율 측정(로드맵 "측정" 항목) — 별도 인프라 없이
  /// 기존 Sentry breadcrumb으로 기록한다(Repository의 Sentry.captureException과
  /// 같은 이유로 dev에서는 SDK 미초기화라 사실상 no-op).
  void _trackEvent(String message) {
    Sentry.addBreadcrumb(
      Breadcrumb(category: 'share_card', message: message),
    );
  }

  @override
  void initState() {
    super.initState();
    _templateFuture = loadShareTemplate(widget.caseType).then((template) {
      final initial = pickRandomMessage(template.messages);
      setState(() {
        _template = template;
        _message = initial;
        _customController.text = initial;
      });
      return template;
    });
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _onReroll() {
    final template = _template;
    if (template == null) return;

    final next = pickRandomMessage(template.messages, exclude: _message);
    setState(() {
      _message = next;
      _customController.text = next;
    });
    _trackEvent('template_rerolled');
  }

  void _onMessageChanged(String value) {
    if (value.trim().isEmpty) return;
    if (!_hasEdited) {
      _hasEdited = true;
      _trackEvent('message_edited');
    }
    setState(() => _message = value);
  }

  Future<void> _onShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    FocusScope.of(context).unfocus();
    // 포커스 해제 → 키보드 내림 애니메이션이 끝날 시간을 준 뒤 캡처한다.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('카드 렌더 결과를 찾을 수 없어요.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('이미지 변환에 실패했어요.');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/cashheart_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 앱을 모르는 수신자도 무슨 카드인지 알 수 있게 설명 + 랜딩 링크를 caption으로
      // 함께 보낸다. sharePositionOrigin은 iPad에서 공유 시트가 뜰 위치를 지정하는
      // 필수 파라미터(없으면 iPad에서 실패할 수 있음, share_plus 공식 문서 명시).
      final buttonBox =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final result = await SharePlus.instance.share(
        ShareParams(
          text: 'CashHeart로 만든 우리 사이 마음 카드예요\n$_shareLandingUrl',
          files: [XFile(file.path)],
          sharePositionOrigin: buttonBox == null
              ? null
              : buttonBox.localToGlobal(Offset.zero) & buttonBox.size,
        ),
      );

      if (result.status == ShareResultStatus.success) {
        _trackEvent('share_completed');
      }
    } catch (e, st) {
      debugPrint('card share capture error: $e');
      await Sentry.captureException(e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카드 공유 중 문제가 생겼어요. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('카드 공유')),
      body: FutureBuilder<ShareTemplate>(
        future: _templateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              _template == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final template = _template!;

          return ListView(
            padding: EdgeInsets.all(Sizes.size20),
            children: [
              Center(
                child: RepaintBoundary(
                  key: _captureKey,
                  child: ShareCardPreview(
                    personName: widget.personName,
                    stats: widget.stats,
                    message: _message,
                    caseType: widget.caseType,
                    cardTitle: template.title,
                    showAmount: _showAmount,
                    useHonorific: _useHonorific,
                  ),
                ),
              ),
              Gaps.v24,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showAmount,
                onChanged: (value) => setState(() => _showAmount = value),
                title: Text(
                  '실제 금액 표시',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text2),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _useHonorific,
                onChanged: (value) => setState(() => _useHonorific = value),
                title: Text(
                  '존칭 사용 (이름 뒤 "님")',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text2),
                ),
              ),
              Gaps.v10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '메시지 편집',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text2),
                  ),
                  TextButton.icon(
                    onPressed: _onReroll,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('다른 문구'),
                  ),
                ],
              ),
              Gaps.v10,
              TextFormField(
                controller: _customController,
                maxLength: 60,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '한 줄 메시지… (최대 60자)',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onMessageChanged,
              ),
              Gaps.v10,
              ElevatedButton.icon(
                key: _shareButtonKey,
                onPressed: _isSharing ? null : _onShare,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share),
                label: const Text('공유'),
              ),
            ],
          );
        },
      ),
    );
  }
}
