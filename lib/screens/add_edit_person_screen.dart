import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/app_chip.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditPersonScreen extends StatefulWidget {
  final int? personId;

  const AddEditPersonScreen({
    super.key,
    this.personId,
  });

  @override
  State<AddEditPersonScreen> createState() => _AddEditPersonScreenState();
}

class _AddEditPersonScreenState extends State<AddEditPersonScreen> {
  bool get _isEdit => widget.personId != null;

  final _formKey = GlobalKey<FormState>();

  final personNameRegex = RegExp(r'^[a-zA-Z가-힣\s]+$');

  final _personNameController = TextEditingController();
  final _personNoteController = TextEditingController();

  bool _initialized = false;

  // 관계 기본값은 목록의 첫 항목으로(2026-07-11 검수).
  String? _selectedCategory = '가족';

  @override
  void initState() {
    super.initState();
    // 이름 입력에 따라 아바타 프리뷰/글자 수 카운터를 실시간으로 갱신.
    _personNameController.addListener(() => setState(() {}));
    _personNoteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _personNoteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    if (_isEdit) {
      final vm = context.read<PersonViewModel>();
      final existing = vm.getPersonById(widget.personId!);
      if (existing != null) {
        _personNameController.text = existing.name;
        _personNoteController.text = existing.note ?? '';
        _selectedCategory = existing.category ?? '그외';
      }
    }

    _initialized = true;
  }

  void _onSave() async {
    //FormKey의 모든 validation을 작동해서 하나라도 통과하지 못하면 false
    //!false = true를 이용해 db에 잘못된 값 삽입 방지
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<PersonViewModel>();
    //trim()은 문자열 앞과 뒤의 공백 제거
    final name = _personNameController.text.trim();
    final note = _personNoteController.text.trim().isEmpty
        ? null
        : _personNoteController.text.trim();

    final category = _selectedCategory;

    final person = Person(
      id: _isEdit ? widget.personId : null,
      name: name,
      note: note,
      category: category,
    );

    if (_isEdit) {
      await vm.updatePerson(person);
    } else {
      await vm.addPerson(person);
    }

    //mounted는 화면이 살아있는지 확인할 수 있는 State class의 내장 함수
    //mounted는 해당 State에서 context를 사용해도 좋은지 확인하는 안전장치
    if (!mounted) return;
    Navigator.of(context).pop();
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
            title: Text(_isEdit ? '지인 수정' : '지인 추가'),
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
          body: Padding(
            padding: EdgeInsets.all(
              Sizes.size20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.v10,
                  Center(
                    child: _personNameController.text.trim().isEmpty
                        ? Icon(
                            Icons.person_outline,
                            size: 44,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .text3,
                          )
                        : Avatar(
                            name: _personNameController.text.trim(),
                            tintSeed: widget.personId ?? 0,
                            size: 76,
                          ),
                  ),
                  Gaps.v20,
                  Text('이름'),
                  Gaps.v10,
                  CustomTextFormField(
                    controller: _personNameController,
                    hintText: '이름 입력',
                    maxLength: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해 주세요.';
                      }

                      if (!personNameRegex.hasMatch(value)) {
                        return '이름은 완성된 한글 혹은 영문만 입력 가능합니다.';
                      }

                      if (value.length < 2 || value.length > 30) {
                        return '이름은 2자 이상 30자 이하여야 합니다.';
                      }

                      return null;
                    },
                  ),
                  Gaps.v10,
                  Text('관계'),
                  Gaps.v10,
                  ChipRow<String>(
                    items: const ['가족', '친구', '직장', '지인', '그외'],
                    value: _selectedCategory,
                    labelOf: (category) => category,
                    // 2026-07-11 검수: 내역 추가 화면의 경조사 칩과 선택색 통일.
                    activeColor: colors.primary,
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                  Gaps.v10,
                  Text('메모 (선택)'),
                  Gaps.v10,
                  CustomTextFormField(
                    controller: _personNoteController,
                    hintText: '이 사람과의 관계나 기억을 적어두세요',
                    maxLength: 200,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      if (value.length > 200) {
                        return '메모는 200자 이하여야 합니다.';
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
    );
  }
}
