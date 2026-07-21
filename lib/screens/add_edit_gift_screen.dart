import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/amount_keypad_sheet.dart';
import 'package:cash_heart/widgets/app_chip.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/gift_date_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditGiftScreen extends StatefulWidget {
  final int personId;
  final String personName;
  final int? giftId;

  const AddEditGiftScreen(
      {super.key,
      this.giftId,
      required this.personName,
      required this.personId});

  @override
  State<AddEditGiftScreen> createState() => _AddEditGiftScreenState();
}

class _AddEditGiftScreenState extends State<AddEditGiftScreen> {
  bool get _isEdit => widget.giftId != null;

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();

  final _dateController = TextEditingController();

  final _giftNoteController = TextEditingController();

  bool _initialized = false;

  // 카테고리는 필수값이라 기본값을 미리 선택해둔다 — 선택 없이 저장하면
  // 오류가 나던 문제(2026-07-11 검수) 방지. 기본값은 목록의 첫 항목.
  GiftCategory? _currentCategory = GiftCategory.values.first;

  GiftDirection _currentDirection = GiftDirection.received;

  DateTime? _selectedDay = DateTime.now();

  final personNoteRegex = RegExp(r'^[a-zA-Z가-힣\s]+$');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    if (_isEdit) {
      final vm = context.read<GiftViewModel>();
      final existing = vm.getOneGiftByGiftId(widget.giftId!);
      if (existing != null) {
        _amountController.text = existing.amount.toString();
        _currentDirection = existing.direction;
        _currentCategory = existing.category;
        //timestamp(ms)를 DateTime로
        _selectedDay = DateTime.fromMillisecondsSinceEpoch(existing.date);
        _giftNoteController.text = existing.note;
      }
    }

    // 신규 입력 시에도 오늘 날짜를 기본으로 채워둔다 — 비어 있으면 hint("1900.01.01")가
    // 실제 기본값처럼 오해되던 문제(2026-07-11 검수) 방지.
    _dateController.text = DateFormat('yyyy.MM.dd').format(_selectedDay!);

    _initialized = true;
  }

  void _onSave() async {
    //FormKey의 모든 validation을 작동해서 하나라도 통과하지 못하면 false
    //!false = true를 이용해 db에 잘못된 값 삽입 방지
    if (!_formKey.currentState!.validate()) return;

    final giftVm = context.read<GiftViewModel>();
    final personVm = context.read<PersonViewModel>();
    //trim()은 문자열 앞과 뒤의 공백 제거
    final direction = _currentDirection;
    final amount = int.parse(_amountController.text.trim());
    final category = _currentCategory;
    final date = _selectedDay ?? DateTime.now();
    final note = _giftNoteController.text.trim();

    final gift = Gift(
      id: _isEdit ? widget.giftId : null,
      personId: widget.personId,
      direction: direction,
      amount: amount,
      category: category!,
      date: date.millisecondsSinceEpoch,
      note: note,
    );

    if (_isEdit) {
      await giftVm.updateGift(gift);
    } else {
      await giftVm.addGift(gift);
    }

    await personVm.refreshTotals();

    // //mounted는 화면이 살아있는지 확인할 수 있는 State class의 내장 함수
    // //mounted는 해당 State에서 context를 사용해도 좋은지 확인하는 안전장치
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _formDatePicker() async {
    final today = DateTime.now();
    final initial = _selectedDay ?? today;

    final selected = await showGiftDatePickerBottomSheet(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: today,
    );

    if (selected != null) {
      setState(() {
        _selectedDay = selected;
        _dateController.text = DateFormat('yyyy.MM.dd').format(selected);
      });
    }
  }

  Future<void> _onAmountTap() async {
    final current = int.tryParse(_amountController.text.trim());
    final entered =
        await showAmountKeypadSheet(context, initialAmount: current);
    if (entered != null) {
      setState(() => _amountController.text = entered.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        //만약 이미 pop 되었다면 실행 x
        if (didPop) return;

        final shouldPop = await showWarningPopDialog(context);

        if (!mounted) return;

        if (shouldPop == true) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? '내역 수정' : '내역 추가'),
            actions: [
              TextButton(
                onPressed: _onSave,
                child: Text(
                  _isEdit ? '수정' : '저장',
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
              Gaps.h10,
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.all(
                Sizes.size20,
              ),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Gaps.v10,
                      _DirectionSegmentedControl(
                        currentDirection: _currentDirection,
                        onChanged: (value) =>
                            setState(() => _currentDirection = value),
                      ),
                      Gaps.v20,
                      Text('누구와'),
                      Gaps.v10,
                      _PersonSummaryCard(personId: widget.personId, personName: widget.personName),
                      Gaps.v20,
                      Text('금액 (필수)'),
                      Gaps.v10,
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        maxLines: 1,
                        controller: _amountController,
                        readOnly: true,
                        showCursor: false,
                        onTap: _onAmountTap,
                        decoration: InputDecoration(
                          hintText: "0",
                          suffix: Text('원'),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '금액을 입력해주세요.';
                          }

                          final number = int.tryParse(value);

                          if (number == null) {
                            return '올바른 숫자를 입력해주세요.';
                          }

                          if (number <= 0) {
                            return '금액은 0보다 커야 합니다.';
                          }

                          return null;
                        },
                      ),
                      Gaps.v10,
                      Text('경조사'),
                      Gaps.v10,
                      ChipRow<GiftCategory>(
                        items: GiftCategory.values,
                        value: _currentCategory,
                        labelOf: (category) => category.label,
                        iconOf: (category) => category.icon,
                        // 2026-07-11 검수: 지인 추가의 관계 칩과 선택색 통일(방향별 틴트 제거).
                        activeColor: colors.primary,
                        onChanged: (value) =>
                            setState(() => _currentCategory = value),
                      ),
                      if (_currentCategory == null) ...[
                        Gaps.v4,
                        Text(
                          '카테고리를 선택해주세요.',
                          style: TextStyle(
                            fontSize: Sizes.size12,
                            color: colors.primary,
                          ),
                        ),
                      ],
                      Gaps.v20,
                      Text('날짜'),
                      Gaps.v10,
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          hintText: '날짜를 선택해주세요',
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: _formDatePicker,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "날짜를 선택해주세요";
                          }

                          return null;
                        },
                      ),
                      Gaps.v10,
                      Text('메모'),
                      Gaps.v10,
                      TextFormField(
                        controller: _giftNoteController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        maxLines: 1,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: "한 줄 메모... (선택)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }

                          if (!personNoteRegex.hasMatch(value)) {
                            return '메모는 완성된 한글 혹은 영문만 입력 가능합니다.';
                          }

                          if (value.length > 20) {
                            return '메모는 20자 이하여야 합니다.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 준/받은 마음을 하나의 통합 세그먼트(공백 없이 붙은 두 반쪽)로 표현한다.
class _DirectionSegmentedControl extends StatelessWidget {
  final GiftDirection currentDirection;
  final ValueChanged<GiftDirection> onChanged;

  const _DirectionSegmentedControl({
    required this.currentDirection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.btn),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: colors.border)),
        child: Row(
          children: [
            Expanded(
              child: _DirectionSegment(
                label: '준 마음',
                active: currentDirection == GiftDirection.given,
                activeColor: colors.given,
                activeBg: colors.secondarySoft,
                onTap: () => onChanged(GiftDirection.given),
              ),
            ),
            Expanded(
              child: _DirectionSegment(
                label: '받은 마음',
                active: currentDirection == GiftDirection.received,
                activeColor: colors.received,
                activeBg: colors.primarySoft,
                onTap: () => onChanged(GiftDirection.received),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionSegment extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  const _DirectionSegment({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        color: active ? activeBg : colors.surface,
        child: Text(
          label,
          style: TextStyle(
            fontSize: Sizes.size14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? activeColor : colors.text3,
          ),
        ),
      ),
    );
  }
}

/// "누구와" — 대상 지인을 아바타+이름+관계 배지로 보여준다. 이 화면은 진입 시
/// 이미 특정 지인이 고정된 컨텍스트라 읽기 전용 표시만 한다(다른 지인으로
/// 전환하는 기능은 범위 밖 — 2026-07-11 확인).
class _PersonSummaryCard extends StatelessWidget {
  final int personId;
  final String personName;

  const _PersonSummaryCard({required this.personId, required this.personName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final person = context.watch<PersonViewModel>().getPersonById(personId);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.size14, vertical: Sizes.size12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Avatar(name: personName, tintSeed: personId, size: 40),
          Gaps.h12,
          Expanded(
            child: Text(
              personName,
              style: TextStyle(
                fontSize: Sizes.size16,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          if (person?.category != null)
            Text(
              person!.category!,
              style: TextStyle(fontSize: Sizes.size12, color: colors.text3),
            ),
        ],
      ),
    );
  }
}
