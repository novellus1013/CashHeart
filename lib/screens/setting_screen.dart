import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/theme_provider.dart';
import 'package:cash_heart/screens/onboarding_screen.dart';
import 'package:cash_heart/screens/policy_screen.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const _inAppUpdateNotifKey = 'in_app_update_notification_enabled';

  String _version = '';
  bool _inAppUpdateNotifEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadNotificationPref();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _inAppUpdateNotifEnabled = prefs.getBool(_inAppUpdateNotifKey) ?? true;
    });
  }

  Future<void> _setNotificationPref(bool value) async {
    setState(() => _inAppUpdateNotifEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inAppUpdateNotifKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(fontSize: Sizes.size18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gaps.v24,
            _SectionTitle(title: '화면'),
            _SettingsCard(
              children: [
                _ThemeModeRadio(
                  label: '자동(기기 설정 따름)',
                  icon: Icons.brightness_auto,
                  mode: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) => themeProvider.setThemeMode(mode),
                ),
                _Divider(),
                _ThemeModeRadio(
                  label: '라이트',
                  icon: Icons.light_mode,
                  mode: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) => themeProvider.setThemeMode(mode),
                ),
                _Divider(),
                _ThemeModeRadio(
                  label: '다크',
                  icon: Icons.dark_mode,
                  mode: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) => themeProvider.setThemeMode(mode),
                ),
              ],
            ),
            Gaps.v24,
            _SectionTitle(title: '알림'),
            _SettingsCard(
              children: [
                _SettingsToggleItem(
                  icon: Icons.system_update_outlined,
                  title: '인앱 업데이트 알림',
                  value: _inAppUpdateNotifEnabled,
                  onChanged: _setNotificationPref,
                ),
              ],
            ),
            Gaps.v24,
            _SectionTitle(title: '데이터'),
            _SettingsCard(
              children: [
                _SettingsDisabledItem(
                  icon: Icons.file_upload_outlined,
                  title: 'CSV 내보내기',
                  subtitle: '곧 추가될 기능이에요',
                ),
                _Divider(),
                _SettingsDisabledItem(
                  icon: Icons.file_download_outlined,
                  title: 'CSV 가져오기',
                  subtitle: '곧 추가될 기능이에요',
                ),
                _Divider(),
                _SettingsDisabledItem(
                  icon: Icons.cloud_sync_outlined,
                  title: '클라우드 동기화',
                  subtitle: '곧 추가될 기능이에요',
                ),
              ],
            ),
            Gaps.v24,
            _SectionTitle(title: '앱정보'),
            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.auto_awesome_outlined,
                  title: '온보딩 다시 보기',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    );
                  },
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.system_update_outlined,
                  title: '업데이트 안내',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PolicyScreen(type: 'update'),
                      ),
                    );
                  },
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.policy_outlined,
                  title: '개인정보 처리방침',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PolicyScreen(type: 'privacy'),
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
                        builder: (context) => PolicyScreen(type: 'terms'),
                      ),
                    );
                  },
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.mail_outline,
                  title: '문의',
                  trailing: 'support@novelus.dev',
                  isChevron: false,
                  onTap: () {},
                ),
                _Divider(),
                _SettingsItem(
                  icon: Icons.info_outline,
                  title: '버전',
                  trailing: _version,
                  isChevron: false,
                  onTap: () {},
                ),
              ],
            ),
            Gaps.v24,
            Center(
              child: Text(
                'CashHeart made by Novelus',
                style: TextStyle(
                  fontSize: Sizes.size11,
                  color: colors.text3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Gaps.v32,
            Gaps.v96,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: EdgeInsets.only(left: Sizes.size8, bottom: Sizes.size8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: Sizes.size12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colors.text3,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Sizes.size12),
        border: Border.all(color: colors.borderSoft),
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
    final colors = Theme.of(context).extension<AppColors>()!;

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
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: Sizes.size20, color: colors.primary),
              ),
              Gaps.h16,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: TextStyle(fontSize: Sizes.size14, color: colors.text3),
                ),
                Gaps.h8,
              ],
              if (isChevron)
                Icon(Icons.chevron_right, size: Sizes.size20, color: colors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDisabledItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsDisabledItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size16,
        vertical: Sizes.size14,
      ),
      child: Row(
        children: [
          Container(
            width: Sizes.size36,
            height: Sizes.size36,
            decoration: BoxDecoration(color: colors.bg, shape: BoxShape.circle),
            child: Icon(icon, size: Sizes.size20, color: colors.text3),
          ),
          Gaps.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.w500,
                    color: colors.text3,
                  ),
                ),
                Gaps.v2,
                Text(
                  subtitle,
                  style: TextStyle(fontSize: Sizes.size12, color: colors.text3),
                ),
              ],
            ),
          ),
        ],
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
    final colors = Theme.of(context).extension<AppColors>()!;

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
              color: colors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: Sizes.size20, color: colors.primary),
          ),
          Gaps.h16,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Sizes.size16,
                fontWeight: FontWeight.w500,
                color: colors.text,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colors.primary.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primary;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeRadio extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeRadio({
    required this.label,
    required this.icon,
    required this.mode,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final selected = mode == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(mode),
        borderRadius: BorderRadius.circular(Sizes.size12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.size16,
            vertical: Sizes.size12,
          ),
          child: Row(
            children: [
              Container(
                width: Sizes.size36,
                height: Sizes.size36,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: Sizes.size20, color: colors.primary),
              ),
              Gaps.h16,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: colors.text,
                  ),
                ),
              ),
              Radio<ThemeMode>(
                value: mode,
                groupValue: groupValue,
                activeColor: colors.primary,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
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
      color: Theme.of(context).dividerColor,
    );
  }
}
