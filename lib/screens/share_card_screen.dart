import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/utils/event_message_handler.dart';
import 'package:cash_heart/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareCardScreen extends StatelessWidget {
  final others = "김씨";
  final amount = 50000;

  const ShareCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShareCard(others: others, amount: amount),
            Gaps.v40,
            const _ShareButton(),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final String others;
  final int amount;

  const _ShareCard({
    required this.others,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final messages = getRandomEventMessage(amount);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.size28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "💌 To: $others",
            style: const TextStyle(
              fontSize: Sizes.size16,
            ),
          ),
          Gaps.v16,
          Text(
            MoneyFormatter.formatCurrency(amount, 'ko_KR', '₩'),
            style: const TextStyle(
              fontSize: Sizes.size40,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          Gaps.v10,
          Text(
            messages,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          Gaps.v10,
          const Text(
            "CashHeart",
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        debugPrint("이것은 공유창");
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.shareNodes,
            size: Sizes.size20,
          ),
          Gaps.h10,
          Text(
            'Share',
            style: TextStyle(
              fontSize: Sizes.size20,
            ),
          )
        ],
      ),
    );
  }
}
