import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/widgets/app_chip.dart';
import 'package:cash_heart/widgets/share_card_preview.dart';
import 'package:flutter/material.dart';

/// 정적 셸 — ShareCard 프리뷰 + 톤/프리셋 UI만. 이미지 export·9 카드 변형·
/// OpenAI 메시지 생성은 Sprint 4 소유. "공유"는 토스트 스텁이다.
class CardShareScreen extends StatefulWidget {
  final String personName;
  final int tintSeed;
  final RelationshipStats stats;

  const CardShareScreen({
    super.key,
    required this.personName,
    required this.tintSeed,
    required this.stats,
  });

  @override
  State<CardShareScreen> createState() => _CardShareScreenState();
}

class _CardShareScreenState extends State<CardShareScreen> {
  late String _message;
  final _customController = TextEditingController();

  List<String> get _presets => [
        '함께한 ${widget.stats.years > 0 ? widget.stats.years : 1}년 고마워요',
        '균형 잡힌 우리, 응원해요',
        '오랜 정에 감사해요',
        '앞으로도 잘 부탁해요',
      ];

  @override
  void initState() {
    super.initState();
    _message = balanceToneMessage(
      count: widget.stats.count,
      state: widget.stats.state,
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('카드 공유')),
      body: ListView(
        padding: EdgeInsets.all(Sizes.size20),
        children: [
          Center(
            child: ShareCardPreview(
              personName: widget.personName,
              tintSeed: widget.tintSeed,
              stats: widget.stats,
              message: _message,
            ),
          ),
          Gaps.v24,
          Text(
            '추천 메시지',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text2),
          ),
          Gaps.v10,
          Wrap(
            spacing: Sizes.size8,
            runSpacing: Sizes.size8,
            children: [
              for (final preset in _presets)
                AppChip(
                  label: preset,
                  active: _message == preset,
                  onTap: () => setState(() {
                    _message = preset;
                    _customController.clear();
                  }),
                ),
            ],
          ),
          Gaps.v24,
          Text(
            '직접 작성',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text2),
          ),
          Gaps.v10,
          TextField(
            controller: _customController,
            maxLength: 60,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '한 줄 메시지… (최대 60자)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.trim().isEmpty) return;
              setState(() => _message = value);
            },
          ),
          Gaps.v10,
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('카드 공유는 다음 업데이트에서 만나요.')),
              );
            },
            icon: const Icon(Icons.ios_share),
            label: const Text('공유'),
          ),
        ],
      ),
    );
  }
}
