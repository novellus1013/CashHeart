import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/screens/main_shell_screen.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// 정적 셸 — v1.1 → v2.0 마이그레이션 완료 안내 레이아웃만.
/// 실제 마이그레이션 실행/Firebase Remote Config 연동은 Sprint 5 소유.
class MigrationScreen extends StatelessWidget {
  const MigrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final personVm = context.watch<PersonViewModel>();
    final peopleCount = personVm.persons.length;
    final txCount = personVm.statsByPerson.values
        .fold<int>(0, (sum, stats) => sum + stats.count);
    final today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.cardGrad),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Sizes.size32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.18),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Icon(Icons.verified_user, size: 50, color: colors.primary),
                      ),
                      Gaps.v28,
                      Text(
                        '안전하게 가져왔어요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      Gaps.v14,
                      Text(
                        '기존 $txCount개의 거래와 $peopleCount명의 지인을\n'
                        '안전하게 가져왔어요.\n자동 백업도 만들었어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: colors.text2, height: 1.65),
                      ),
                      Gaps.v24,
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.size16,
                          vertical: Sizes.size14,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.borderSoft),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.secondarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.backup, size: 20, color: colors.secondary),
                            ),
                            Gaps.h11,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '자동 백업 생성됨',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text,
                                    ),
                                  ),
                                  Text(
                                    today,
                                    style: TextStyle(fontSize: 12, color: colors.text3),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle, size: 20, color: colors.balanced),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Sizes.size24,
                  0,
                  Sizes.size24,
                  Sizes.size18,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainShellScreen(),
                        ),
                      );
                    },
                    child: const Text('홈으로'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
