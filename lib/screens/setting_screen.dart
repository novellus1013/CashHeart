import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/theme_provider.dart';
import 'package:cash_heart/screens/policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final String _version = '1.1.0';
  final String _lang = 'ko';

  Future<void> _showInfoDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                '문의하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Sizes.size20,
                ),
              ),
              content: Text(
                'noveluslab@proton.me',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gaps.v24,
            _SectionTitle(title: '일반'),
            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.currency_yen,
                  title: '통화',
                  trailing: 'KRW (₩)',
                  isChevron: false,
                  onTap: () {},
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.translate,
                  title: '언어',
                  trailing: '한국어',
                  isChevron: false,
                  onTap: () {},
                ),
                _Divider(),
                _SettingsToggleItem(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: '다크 모드',
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.setDarkMode(value);
                  },
                ),
              ],
            ),
            Gaps.v24,
            _SectionTitle(title: '지원 및 법적 고지'),
            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.help_outline,
                  title: '문의하기',
                  onTap: () => _showInfoDialog(context),
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.policy_outlined,
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
                _Divider(),
                _SettingsItem(
                  icon: Icons.gavel_outlined,
                  title: '이용약관',
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
            Gaps.v24,
            Center(
              child: Text(
                '버전 $_version',
                style: TextStyle(
                  fontSize: Sizes.size12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: Text(
                'Cash Heart',
                style: TextStyle(
                  fontSize: Sizes.size12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Gaps.v32,
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Sizes.size8, bottom: Sizes.size8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: Sizes.size12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Sizes.size12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isChevron;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.isChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.grey.shade800
        : const Color(0xFFF8F6F5).withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.size12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.size16,
            vertical: Sizes.size14,
          ),
          child: Row(
            children: [
              Container(
                width: Sizes.size36,
                height: Sizes.size36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: Sizes.size20, color: primaryColor),
              ),
              Gaps.h16,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade500,
                  ),
                ),
                Gaps.h8,
              ],
              Icon(
                isChevron ? Icons.chevron_right : null,
                size: Sizes.size20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.grey.shade800
        : const Color(0xFFF8F6F5).withValues(alpha: 0.5);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size16,
        vertical: Sizes.size8,
      ),
      child: Row(
        children: [
          Container(
            width: Sizes.size36,
            height: Sizes.size36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: Sizes.size20, color: primaryColor),
          ),
          Gaps.h16,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Sizes.size16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return primaryColor;
              }
              return Colors.grey.shade400;
            }),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
