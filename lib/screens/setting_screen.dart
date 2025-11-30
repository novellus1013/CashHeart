import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/screens/policy_screen.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  final String _version = '1.0.0';
  //TODO: 차후 국제화에 따라 en 버전 추가
  final String _lang = 'ko';

  final String _support = 'noveluslab@gmail.com';

  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Column(
        children: [
          // //TODO: 차후 다양한 설정창 메뉴 추가. mvp가 등록되고 나면 아래 공유하기 기능 부터.
          // _SettingsGroup(
          //   title: '소개',
          //   items: [
          //     _SettingsItem(title: '공유하기', onTap: () {}),
          //   ],
          // ),
          _SettingsGroup(
            title: '정보',
            items: [
              _SettingsItem(
                title: '개인정보 처리방침',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PolicyScreen(type: 'privacy', lang: _lang),
                    ),
                  );
                },
              ),
              _SettingsItem(
                title: '이용 약관',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PolicyScreen(type: 'terms', lang: _lang),
                    ),
                  );
                },
              ),
            ],
          ),
          Gaps.v40,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size36,
              vertical: Sizes.size14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '버전',
                  style: const TextStyle(
                    fontSize: Sizes.size16,
                  ),
                ),
                Text(
                  _version,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size36,
              vertical: Sizes.size14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '문의하기',
                  style: const TextStyle(
                    fontSize: Sizes.size16,
                  ),
                ),
                Text(
                  _support,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: Colors.grey.shade500,
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

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size20,
        vertical: Sizes.size10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: Sizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gaps.v14,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.size16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: items
                  .map((e) => _SettingsItem(title: e.title, onTap: e.onTap))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size16,
          vertical: Sizes.size14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: Sizes.size16,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: Sizes.size16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: 토글 스위치 설정 항목 - 차우 다크모드, 알람 등에 활용
// Widget _buildToggleSettingItem(
//     String title, bool value, ValueChanged<bool> onChanged) {
//   return Container(
//     padding: const EdgeInsets.symmetric(
//         horizontal: Sizes.size16, vertical: Sizes.size14),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: Sizes.size16),
//         ),
//         Switch.adaptive(
//           value: value,
//           onChanged: onChanged,
//           activeTrackColor: primaryColor,
//         ),
//       ],
//     ),
//   );
// }
