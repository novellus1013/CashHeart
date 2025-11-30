import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/gift_date_picker_sheet.dart';
import 'package:flutter/cupertino.dart';
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

  GiftCategory? _currentCategory;

  GiftDirection _currentDirection = GiftDirection.received;

  DateTime? _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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
        _focusedDay = _selectedDay!;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        _giftNoteController.text = existing.note;
      }
    }

    _initialized = true;
  }

  void _onSave() async {
    //FormKey의 모든 validation을 작동해서 하나라도 통과하지 못하면 false
    //!false = true를 이용해 db에 잘못된 값 삽입 방지
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<GiftViewModel>();
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
      await vm.updateGift(gift);
    } else {
      await vm.addGift(gift);
    }

    // //mounted는 화면이 살아있는지 확인할 수 있는 State class의 내장 함수
    // //mounted는 해당 State에서 context를 사용해도 좋은지 확인하는 안전장치
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _formDatePicker() async {
    FocusScope.of(context).unfocus(); // 키보드 닫기

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
        _focusedDay = selected;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? '지인 수정하기' : '지인 추가하기'),
          actions: [
            ElevatedButton(
              onPressed: _onSave,
              child: Text(
                _isEdit ? '수 정' : '저 장',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
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
                    Gaps.v20,
                    Text('이름'),
                    Gaps.v10,
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: widget.personName,
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                        )),
                      ),
                    ),
                    Gaps.v20,
                    CupertinoSlidingSegmentedControl(
                      backgroundColor: const Color(0xFFFFF5F3),
                      thumbColor: _currentDirection == GiftDirection.received
                          ? primaryColor
                          : cashBlueColor,
                      padding: const EdgeInsets.all(3),
                      groupValue: _currentDirection,
                      children: {
                        GiftDirection.received: _buildItem(
                          label: '받은 돈',
                          selected: _currentDirection == GiftDirection.received,
                        ),
                        GiftDirection.given: _buildItem(
                          label: '준 돈',
                          selected: _currentDirection == GiftDirection.given,
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _currentDirection = value;
                        });
                      },
                    ),
                    Gaps.v20,
                    Text('금액 (필수)'),
                    Gaps.v10,
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('카테고리 (필수)'),
                              Gaps.v10,
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: '목록',
                                  border: OutlineInputBorder(), // 테두리 스타일
                                ),
                                items: GiftCategory.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _currentCategory = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "카테고리를 선택해주세요.";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        Gaps.h20,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('날짜 (필수)'),
                              Gaps.v10,
                              TextFormField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintText: '1900-01-01',
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gaps.v10,
                    Text('거래 내역'),
                    Gaps.v10,
                    TextFormField(
                      controller: _giftNoteController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: "ex) 돌 잔치 축하, (지인) 어머니 팔순 등 (20자 이하)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '거래 내역을 작성해주세요!';
                        }

                        if (value.length > 20) {
                          return '거래 내역은 20자 이하여야 합니다.';
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
    );
  }
}

Widget _buildItem({
  required String label,
  required bool selected,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(
      vertical: Sizes.size10,
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : Colors.black,
      ),
    ),
  );
}
