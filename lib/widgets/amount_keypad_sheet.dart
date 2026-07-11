import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 금액 입력 전용 계산기 스타일 숫자패드. 시스템 키보드 대신 사용 — 숫자를
/// 누르면 상단에 콤마 포맷으로 실시간 표시되고, '완료'를 눌러야 값이 반영된다.
Future<int?> showAmountKeypadSheet(
  BuildContext context, {
  int? initialAmount,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AmountKeypadSheet(initialAmount: initialAmount),
  );
}

class AmountKeypadSheet extends StatefulWidget {
  final int? initialAmount;

  const AmountKeypadSheet({super.key, this.initialAmount});

  @override
  State<AmountKeypadSheet> createState() => _AmountKeypadSheetState();
}

class _AmountKeypadSheetState extends State<AmountKeypadSheet> {
  static const _maxDigits = 12;
  late String _digits;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAmount;
    _digits = (initial != null && initial > 0) ? initial.toString() : '';
  }

  void _onDigit(String digit) {
    setState(() {
      _digits = _digits == '0' ? digit : _digits + digit;
      if (_digits.length > _maxDigits) {
        _digits = _digits.substring(0, _maxDigits);
      }
    });
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _onConfirm() {
    final amount = int.tryParse(_digits) ?? 0;
    Navigator.of(context).pop(amount > 0 ? amount : null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final displayText = _digits.isEmpty
        ? '0'
        : NumberFormat.decimalPattern('ko_KR').format(int.parse(_digits));

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          Sizes.size20,
          Sizes.size16,
          Sizes.size20,
          Sizes.size12,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Gaps.v20,
            Text(
              '$displayText원',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            Gaps.v20,
            _KeypadRow(labels: const ['1', '2', '3'], onTap: _onDigit),
            Gaps.v8,
            _KeypadRow(labels: const ['4', '5', '6'], onTap: _onDigit),
            Gaps.v8,
            _KeypadRow(labels: const ['7', '8', '9'], onTap: _onDigit),
            Gaps.v8,
            Row(
              children: [
                Expanded(
                  child: _KeypadButton(
                    label: '00',
                    onTap: () => _onDigit('00'),
                  ),
                ),
                Gaps.h8,
                Expanded(
                  child: _KeypadButton(label: '0', onTap: () => _onDigit('0')),
                ),
                Gaps.h8,
                Expanded(
                  child: _KeypadButton(
                    icon: Icons.backspace_outlined,
                    onTap: _onBackspace,
                  ),
                ),
              ],
            ),
            Gaps.v16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _digits.isEmpty ? null : _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: EdgeInsets.symmetric(vertical: Sizes.size14),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadRow extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<String> onTap;

  const _KeypadRow({required this.labels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final label in labels) ...[
          Expanded(
            child: _KeypadButton(label: label, onTap: () => onTap(label)),
          ),
          if (label != labels.last) Gaps.h8,
        ],
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Material(
      color: colors.bg,
      borderRadius: BorderRadius.circular(AppRadii.btn),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.btn),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 22, color: colors.text2)
                : Text(
                    label!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
