/// 경조사비 구간별 메시지 데이터를 담는 클래스
class EventMessageData {
  final double minAmount;
  final double maxAmount;
  final List<String> messages;

  const EventMessageData({
    required this.minAmount,
    required this.maxAmount,
    required this.messages,
  });
}
