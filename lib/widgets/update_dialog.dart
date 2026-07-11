import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A(권장) — 닫기 가능한 다이얼로그. B(강제) — 전체 화면, 닫기 불가.
/// 실제 In-App Update API/강제 업데이트 정책 판단은 Sprint 5 소유 — 이 위젯은
/// 레이아웃 2종만 제공한다.
enum UpdateDialogVariant { recommended, forced }

class UpdateDialog extends StatelessWidget {
  final UpdateDialogVariant variant;
  final VoidCallback onUpdate;
  final VoidCallback? onClose;

  const UpdateDialog({
    super.key,
    required this.variant,
    required this.onUpdate,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == UpdateDialogVariant.forced) {
      return _ForcedUpdate(onUpdate: onUpdate);
    }
    return _RecommendedUpdate(onUpdate: onUpdate, onClose: onClose);
  }
}

class _ForcedUpdate extends StatelessWidget {
  final VoidCallback onUpdate;

  const _ForcedUpdate({required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Sizes.size32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colors.primarySoft, shape: BoxShape.circle),
                  child: Icon(Icons.system_security_update_warning, size: 50, color: colors.primary),
                ),
                Gaps.v28,
                Text(
                  '업데이트가 필요해요',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.text),
                ),
                Gaps.v14,
                Text(
                  '보안 강화를 위해\n새 버전으로 업데이트해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.text2, height: 1.6),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('업데이트하러 가기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedUpdate extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback? onClose;

  const _RecommendedUpdate({required this.onUpdate, this.onClose});

  static const _highlights = [
    '관계의 균형 시각화가 부드러워졌어요',
    '카드 공유 디자인 3종 추가',
    '거래 입력 속도 개선',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(Sizes.size24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.secondarySoft, shape: BoxShape.circle),
              child: Icon(Icons.rocket_launch, size: 32, color: colors.secondary),
            ),
            Gaps.v16,
            Text(
              '새 버전이 있어요',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: colors.text),
            ),
            Gaps.v16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in _highlights) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: colors.secondary),
                      Gaps.h9,
                      Expanded(
                        child: Text(
                          line,
                          style: TextStyle(fontSize: 14, color: colors.text, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                  Gaps.v10,
                ],
              ],
            ),
            Gaps.v12,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onUpdate, child: const Text('지금 업데이트')),
            ),
            TextButton(
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: Text('나중에', style: TextStyle(color: colors.text3, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
