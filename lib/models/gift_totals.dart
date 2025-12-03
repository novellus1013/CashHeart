class GiftTotals {
  final int personId;
  final int totalReceivedAmount;
  final int totalGivenAmount;

  int get totalAmount => totalReceivedAmount - totalGivenAmount;

  GiftTotals({
    required this.personId,
    required this.totalGivenAmount,
    required this.totalReceivedAmount,
  });
}
