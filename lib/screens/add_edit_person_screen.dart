import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
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
  bool get isEdit => widget.personId != null;

  final _formKey = GlobalKey<FormState>();

  final personNameRegex = RegExp(r'^[a-zA-Z가-힣\s]+$');

  final _personNameController = TextEditingController();
  final _personNoteController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    if (isEdit) {
      final vm = context.read<PersonViewModel>();
      final existing = vm.getPersonById(widget.personId!);
      if (existing != null) {
        _personNameController.text = existing.name;
        _personNoteController.text = existing.note ?? '';
      }
    }

    _initialized = true;
  }

  void _onSave() async {
    //FormKey의 모든 validation을 작동해서 하나라도 통과하지 못하면 false
    //!false = true를 이용해 db에 잘못된 값 삽입 방지
    if (!_formKey.currentState!.validate()) return;

    final _vm = context.read<PersonViewModel>();
    //trim()은 문자열 앞과 뒤의 공백 제거
    final name = _personNameController.text.trim();
    final note = _personNoteController.text.trim().isEmpty
        ? null
        : _personNoteController.text.trim();

    final _person = Person(
      id: isEdit ? widget.personId : null,
      name: name,
      note: note,
    );

    if (isEdit) {
      await _vm.updatePerson(_person);
    } else {
      await _vm.addPerson(_person);
    }

    //mounted는 화면이 살아있는지 확인할 수 있는 State class의 내장 함수
    //mounted는 해당 State에서 context를 사용해도 좋은지 확인하는 안전장치
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        //만약 이미 pop 되었다면 실행 x
        if (didPop) return;

        final shouldPop = await showWarningPopDialog(context);

        if (shouldPop == true) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? '지인 수정하기' : '지인 추가하기'),
          actions: [
            ElevatedButton(
              onPressed: _onSave,
              child: Text(
                isEdit ? '수 정' : '저 장',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Gaps.h10,
          ],
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.all(
            Sizes.size20,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Form(
              key: _formKey,
              canPop: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.v20,
                  Text('이름'),
                  Gaps.v10,
                  CustomTextFormField(
                    controller: _personNameController,
                    hintText: '이름 (필수)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해 주세요.';
                      }

                      if (!personNameRegex.hasMatch(value)) {
                        return '이름은 완성된 한글 혹은 영문만 입력 가능합니다.';
                      }

                      if (value.length < 2 || value.length > 20) {
                        return '이름은 2자 이상 20자 미만이어야 합니다.';
                      }

                      return null;
                    },
                  ),
                  Gaps.v10,
                  Text('메모 (선택)'),
                  Gaps.v10,
                  CustomTextFormField(
                    controller: _personNoteController,
                    hintText: '관계, 이메일, 전화번호, 별칭 등 (20자 이하)',
                    maxLength: 20,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      if (value.length >= 50) {
                        return '메모는 50자 미만이어야 합니다.';
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
