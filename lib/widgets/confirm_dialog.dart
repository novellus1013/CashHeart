import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `ConfirmDialog` 이식. `showConfirmDialog`로 호출하며,
/// 사용자가 확인을 누르면 true, 취소/바깥 탭이면 false/null을 반환한다.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final bool danger;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = '삭제',
    this.danger = true,
  });

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
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 17,
                color: colors.text,
              ),
            ),
            if (message != null) ...[
              Gaps.v8,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: colors.text2,
                  height: 1.5,
                ),
              ),
            ],
            Gaps.v20,
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: '취소',
                    background: colors.bg,
                    foreground: colors.text2,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                Gaps.h9,
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    background: danger ? colors.primary : colors.text,
                    foreground: Colors.white,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.btn),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.btn),
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// [ConfirmDialog]를 띄우고 사용자의 선택(확인=true)을 반환한다.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = '삭제',
  bool danger = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      danger: danger,
    ),
  );
  return result ?? false;
}
