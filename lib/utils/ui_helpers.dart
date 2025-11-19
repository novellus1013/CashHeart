import 'package:flutter/material.dart';

//유저가 form 화면에서 저장 없이 이탈하려 할 경우, 경고창 보여줌.
Future<bool?> showWarningPopDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('정말 나가시겠습니까?'),
            content: Text('지금까지 입력한 모든 내용이 사라집니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('나가기'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('취소'),
              ),
            ],
          ));
}
