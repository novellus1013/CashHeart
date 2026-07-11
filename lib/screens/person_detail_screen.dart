import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/screens/add_edit_gift_screen.dart';
import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/widgets/app_bottom_sheet.dart';
import 'package:cash_heart/widgets/category_bars.dart';
import 'package:cash_heart/widgets/confirm_dialog.dart';
import 'package:cash_heart/widgets/hero_card.dart';
import 'package:cash_heart/widgets/icon_badge.dart';
import 'package:cash_heart/widgets/legend.dart';
import 'package:cash_heart/widgets/section_title.dart';
import 'package:cash_heart/widgets/stream_chart.dart';
import 'package:cash_heart/widgets/txn_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  Future<void> _onDeletePerson(
      BuildContext context, PersonViewModel personVm) async {
    final shouldDelete = await showConfirmDialog(
      context,
      title: '정말 삭제하시겠습니까?',
      message: '이 사람과 관련된 모든 거래 내역이 함께 삭제됩니다. 한 번 삭제하면 돌이킬 수 없습니다.',
      confirmLabel: '삭제하기',
    );

    if (shouldDelete) {
      await personVm.deletePerson(widget.personId);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _onCardShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카드 공유는 다음 업데이트에서 만나요.')),
    );
  }

  Future<void> _onMore(
    BuildContext context,
    PersonViewModel personVm,
    String personName,
  ) async {
    await showAppBottomSheet(
      context,
      title: personName,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('정보 수정'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditPersonScreen(personId: widget.personId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).extension<AppColors>()!.primary,
              ),
              title: Text(
                '삭제',
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _onDeletePerson(context, personVm);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final giftVm = context.watch<GiftViewModel>();
    final colors = Theme.of(context).extension<AppColors>()!;

    final person = personVm.getPersonById(widget.personId);

    // 삭제 후 rebuild 시 person이 null일 수 있음
    if (person == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (giftVm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final personName = person.name;
    final stats = giftVm.stats;
    final sortedGifts = [...giftVm.gifts]
      ..sort((a, b) => b.date.compareTo(a.date));

    final byCategory = GiftCategory.values
        .map((category) {
          final catGifts =
              giftVm.gifts.where((g) => g.category == category);
          return CategoryBarData(
            label: category.label,
            icon: category.iconOutlined,
            received: catGifts
                .where((g) => g.direction == GiftDirection.received)
                .fold(0, (a, g) => a + g.amount),
            given: catGifts
                .where((g) => g.direction == GiftDirection.given)
                .fold(0, (a, g) => a + g.amount),
          );
        })
        .where((c) => c.received + c.given > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(personName),
        actions: [
          IconButton(
            onPressed: () => _onCardShare(context),
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: '카드 공유',
          ),
          IconButton(
            onPressed: () => _onMore(context, personVm, personName),
            icon: const Icon(Icons.more_horiz),
            tooltip: '더보기',
          ),
        ],
      ),
      floatingActionButton: stats.count > 0
          ? FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: colors.primary,
              onPressed: () {
                final giftVm = context.read<GiftViewModel>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: giftVm,
                      child: AddEditGiftScreen(
                        personId: widget.personId,
                        personName: personName,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.playlist_add, color: Colors.white),
              label: const Text('내역 추가', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          Sizes.size20,
          Sizes.size10,
          Sizes.size20,
          Sizes.size96 + Sizes.size24,
        ),
        children: [
          HeroCard(
            label: '오고 간 정(情) · 순잔액',
            netAmount: stats.net,
            givenAmount: stats.given,
            receivedAmount: stats.received,
            amountStyle: AppTextStyles.detailAmount,
            statePill: stats.count > 0
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.size11,
                      vertical: Sizes.size6,
                    ),
                    decoration: BoxDecoration(
                      color: stats.state.softColor(colors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      balanceStateLabel(stats.state),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stats.state.color(colors),
                      ),
                    ),
                  )
                : null,
            extra: stats.count >= 2 ? StreamChart(gifts: giftVm.gifts) : null,
            quoteMessage:
                balanceToneMessage(count: stats.count, state: stats.state),
          ),
          Gaps.v14,
          _MemoCard(note: person.note, personId: widget.personId),
          if (byCategory.isNotEmpty) ...[
            Gaps.v14,
            Container(
              padding: EdgeInsets.all(Sizes.size18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.borderSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('경조사별 오고 간 마음'),
                  Gaps.v14,
                  CategoryBars(byCategory: byCategory),
                  const Legend(),
                ],
              ),
            ),
          ],
          Gaps.v14,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle('거래 내역'),
              Text(
                '${stats.count}건',
                style: TextStyle(fontSize: 13, color: colors.text3),
              ),
            ],
          ),
          Gaps.v10,
          if (stats.count == 0) _EmptyDetail(personId: widget.personId, personName: personName),
          if (stats.count == 1) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.size14,
                vertical: Sizes.size10,
              ),
              decoration: BoxDecoration(
                color: colors.secondarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 17, color: colors.secondary),
                  Gaps.h8,
                  Expanded(
                    child: Text(
                      '더 많은 기록이 쌓이면 관계의 흐름이 보여요.',
                      style: TextStyle(fontSize: 13, color: colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.v10,
          ],
          for (final gift in sortedGifts) ...[
            _TxnRowWithMenu(gift: gift, personName: personName),
            Gaps.v8,
          ],
        ],
      ),
    );
  }
}

class _MemoCard extends StatelessWidget {
  final String? note;
  final int personId;

  const _MemoCard({required this.note, required this.personId});

  void _onEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditPersonScreen(personId: personId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final hasNote = note != null && note!.isNotEmpty;

    // 메모가 없어도(첫거래 추가 등으로) 언제든 여기서 새로 추가할 수 있어야 한다 —
    // note가 비었다고 카드 자체를 숨기면 메모를 추가할 방법이 사라지는 버그였다.
    if (!hasNote) {
      return GestureDetector(
        onTap: () => _onEdit(context),
        child: Container(
          padding: EdgeInsets.all(Sizes.size16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: colors.text3),
              Gaps.h9,
              Text(
                '메모 추가',
                style: TextStyle(fontSize: 14, color: colors.text3),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(Sizes.size16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 18, color: colors.text3),
          Gaps.h9,
          Expanded(
            child: Text(
              note!,
              style: TextStyle(fontSize: 14, color: colors.text, height: 1.5),
            ),
          ),
          IconButton(
            onPressed: () => _onEdit(context),
            icon: Icon(Icons.edit, size: 17, color: colors.text3),
            tooltip: '메모 편집',
          ),
        ],
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  final int personId;
  final String personName;

  const _EmptyDetail({required this.personId, required this.personName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: EdgeInsets.all(Sizes.size28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSoft),
      ),
      child: Column(
        children: [
          IconBadge(
            icon: Icons.volunteer_activism,
            color: colors.text3,
            soft: colors.bg,
            size: 56,
            iconSize: 28,
          ),
          Gaps.v14,
          Text(
            '아직 오고 간 기록이 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          Gaps.v4,
          Text(
            '첫 마음을 기록하면\n관계의 흐름이 쌓이기 시작해요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.text2, height: 1.5),
          ),
          Gaps.v16,
          ElevatedButton.icon(
            onPressed: () {
              final giftVm = context.read<GiftViewModel>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: giftVm,
                    child: AddEditGiftScreen(
                      personId: personId,
                      personName: personName,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('첫 거래 추가'),
          ),
        ],
      ),
    );
  }
}

class _TxnRowWithMenu extends StatelessWidget {
  final Gift gift;
  final String personName;

  const _TxnRowWithMenu({required this.gift, required this.personName});

  void _onEdit(BuildContext context) {
    final giftVm = context.read<GiftViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: giftVm,
          child: AddEditGiftScreen(
            personName: personName,
            personId: gift.personId,
            giftId: gift.id,
          ),
        ),
      ),
    );
  }

  Future<void> _onMore(BuildContext context) async {
    await showAppBottomSheet(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('수정하기'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _onEdit(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).extension<AppColors>()!.primary,
              ),
              title: Text(
                '삭제하기',
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                ),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final shouldDelete = await showConfirmDialog(
                  context,
                  title: '정말 삭제하시겠습니까?',
                  message: '한 번 삭제하면 돌이킬 수 없습니다.',
                  confirmLabel: '삭제하기',
                );
                if (shouldDelete && context.mounted) {
                  await context.read<GiftViewModel>().deleteGift(gift.id!);
                  // 2026-07-11 검수: 이 경로가 personVm.refreshTotals()를 호출하지
                  // 않아 Home 상단 카드가 갱신 안 되던 버그(add_edit_gift_screen의
                  // 저장 경로에만 refreshTotals가 있었음).
                  if (context.mounted) {
                    await context.read<PersonViewModel>().refreshTotals();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TxnRow(
      gift: gift,
      onTap: () => _onEdit(context),
      onMore: () => _onMore(context),
    );
  }
}
