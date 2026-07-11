import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

Future<DateTime?> showGiftDatePickerBottomSheet({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    // 2026-07-11 검수: 기본 Material3 배경이 살짝 회색빛이라 흰색(surface)으로 고정.
    backgroundColor: Theme.of(context).extension<AppColors>()!.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Sizes.size24),
      ),
    ),
    builder: (context) {
      return GiftDatePickerSheet(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
  );
}

class GiftDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const GiftDatePickerSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<GiftDatePickerSheet> createState() => _GiftDatePickerSheetState();
}

class _GiftDatePickerSheetState extends State<GiftDatePickerSheet> {
  late DateTime _focusedDay;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selected = widget.initialDate;
  }

  // 연/월을 좌우 화살표뿐 아니라 직접 입력으로도 이동할 수 있게 헤더 타이틀을
  // 탭하면 연/월 휠만 고르는 간단한 피커를 띄운다(2026-07-11 검수: 풀 캘린더
  // 형태의 네이티브 showDatePicker는 원하는 UI가 아니라는 피드백으로 교체).
  Future<void> _onJumpToDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Theme.of(context).extension<AppColors>()!.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.size24)),
      ),
      builder: (context) => _YearMonthPickerSheet(
        initialYear: _focusedDay.year,
        initialMonth: _focusedDay.month,
        firstYear: widget.firstDate.year,
        lastYear: widget.lastDate.year,
      ),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => _focusedDay = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      // Android 제스처 내비게이션 바 등 하단 safe-area에 버튼 행이 잘리는 문제(부록 A) 방지.
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gaps.v8,

            // 커스텀 헤더 — 좌우 화살표 + 탭하면 직접 입력 가능한 연/월 타이틀.
            // 드래그 핸들 바는 넣지 않는다(2026-07-11 검수 참고 이미지에 없음).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.size8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onJumpToDate,
                      child: Center(
                        child: Text(
                          '${_focusedDay.year}년 ${_focusedDay.month}월',
                          style: const TextStyle(
                            fontSize: Sizes.size16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // 캘린더 — 날짜를 탭하면 바로 선택/확정되어 닫힌다(별도 확인 버튼 없음).
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.size16,
                vertical: Sizes.size8,
              ),
              child: TableCalendar(
                locale: 'ko_KR',
                headerVisible: false,
                firstDay: widget.firstDate,
                lastDay: widget.lastDate,
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selected, day),
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.of(context).pop(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: primaryColor),
                ),
              ),
            ),
            Gaps.v8,
          ],
        ),
      ),
    );
  }
}

/// 연/월만 고르는 단순 휠 피커 — 날짜(일)까지 확정하지 않고 캘린더가 보여줄
/// 월만 이동시킨다. 실제 일자 선택은 이 시트가 닫힌 뒤 캘린더에서 이어간다.
class _YearMonthPickerSheet extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int firstYear;
  final int lastYear;

  const _YearMonthPickerSheet({
    required this.initialYear,
    required this.initialMonth,
    required this.firstYear,
    required this.lastYear,
  });

  @override
  State<_YearMonthPickerSheet> createState() => _YearMonthPickerSheetState();
}

class _YearMonthPickerSheetState extends State<_YearMonthPickerSheet> {
  late int _year = widget.initialYear;
  late int _month = widget.initialMonth;
  late final List<int> _years = [
    for (var y = widget.firstYear; y <= widget.lastYear; y++) y,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final itemStyle = TextStyle(fontSize: Sizes.size16, color: colors.text);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gaps.v8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소', style: TextStyle(color: colors.text3)),
                ),
                Text(
                  '연월 선택',
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(DateTime(_year, _month)),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _years.indexOf(_year),
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) => _year = _years[index],
                    children: [
                      for (final y in _years)
                        Center(child: Text('$y년', style: itemStyle)),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _month - 1,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) => _month = index + 1,
                    children: [
                      for (var m = 1; m <= 12; m++)
                        Center(child: Text('$m월', style: itemStyle)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gaps.v8,
        ],
      ),
    );
  }
}
