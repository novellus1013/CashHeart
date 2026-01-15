import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/screens/policy_screen.dart';
import 'package:flutter/material.dart';

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
                  color: Colors.black,
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
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F6F5),
        title: Text(
          'Settings',
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
            _SectionTitle(title: 'General'),
            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.currency_yen,
                  title: 'Currency',
                  trailing: 'KRW (₩)',
                  isChevron: false,
                  onTap: () {},
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.translate,
                  title: 'Language',
                  trailing: '한국어',
                  isChevron: false,
                  onTap: () {},
                ),
              ],
            ),
            Gaps.v24,
            _SectionTitle(title: 'Support & Legal'),
            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.help_outline,
                  title: 'Contact Support',
                  onTap: () => _showInfoDialog(context),
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
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
                  title: 'Terms of Service',
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
                'Version $_version',
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
        color: Colors.white,
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
    final iconBgColor = Color(0xFFF8F6F5).withValues(alpha: 0.5);

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withValues(alpha: 0.05),
    );
  }
}
