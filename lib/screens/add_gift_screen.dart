import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';

class AddGiftScreen extends StatelessWidget {
  const AddGiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('기록 추가'),
          actions: [
            TextButton(
              onPressed: () {
                print("저장됨");
              },
              child: const Text(
                '저 장',
                style: TextStyle(
                  fontSize: Sizes.size20,
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Gaps.h10,
          ],
        ),
        body: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.size20,
            ),
            child: Text('gift_screen')));
  }
}
