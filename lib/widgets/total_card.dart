import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  const TotalCard({
    super.key,
    required this.isPlus,
    required this.totalAmountFormat,
    required this.totalReceivedFormat,
    required this.totalGivenFormat,
  });

  final bool isPlus;
  final String totalAmountFormat;
  final String totalReceivedFormat;
  final String totalGivenFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Sizes.size20, vertical: Sizes.size24),
      decoration: BoxDecoration(
          gradient: isPlus
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFFFB9F35)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [secondaryColor, Color(0xFF36D1DC)],
                ),
          borderRadius: BorderRadius.circular(Sizes.size20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총액',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Sizes.size16,
                  letterSpacing: 1.4,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),
            ],
          ),
          Gaps.v10,
          Text(
            totalAmountFormat,
            style: TextStyle(
              fontSize: Sizes.size36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gaps.v20,
          Row(
            children: [
              Expanded(
                child:
                    _AmountTypeBox(received: true, amount: totalReceivedFormat),
              ),
              Container(
                color: Colors.white,
                width: Sizes.size1,
                height: Sizes.size48,
              ),
              Expanded(
                child:
                    _AmountTypeBox(received: false, amount: totalGivenFormat),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountTypeBox extends StatelessWidget {
  final bool received;
  final String amount;

  const _AmountTypeBox({
    required this.received,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              received ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Icon(
                received
                    ? Icons.arrow_upward_outlined
                    : Icons.arrow_downward_outlined,
                size: Sizes.size14,
                color: Colors.white),
            Gaps.h4,
            Text(
              received ? '받은 돈' : '준 돈',
              style: TextStyle(
                color: Colors.white,
                fontSize: Sizes.size14,
              ),
            ),
          ],
        ),
        Gaps.v4,
        Align(
          alignment: received ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w700,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }
}
