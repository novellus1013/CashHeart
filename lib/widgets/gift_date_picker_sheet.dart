import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late DateTime _tempSelected;
  late DateTime _focusedDay;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _tempSelected = widget.initialDate;
    _focusedDay = widget.initialDate;
    _today = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gaps.v8,
          Container(
            width: Sizes.size40,
            height: Sizes.size4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(Sizes.size2),
            ),
          ),
          Gaps.v12,
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size20,
              vertical: Sizes.size4,
            ),
            child: Row(
              children: [
                const Text(
                  '날짜 선택',
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 캘린더
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size16,
              vertical: Sizes.size8,
            ),
            child: TableCalendar(
              locale: 'ko_KR',
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_tempSelected, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _tempSelected = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: cashBlueColor.withValues(
                    alpha: 0.2,
                  ),
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
                weekendStyle: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Sizes.size16, Sizes.size8, Sizes.size16, Sizes.size16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSelected = _today;
                      _focusedDay = _today;
                    });
                  },
                  child: const Text('오늘'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                Gaps.h8,
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_tempSelected);
                  },
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_tempSelected),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
