import 'dart:math';

import 'package:cash_heart/utils/event_message_data.dart';
import 'package:cash_heart/utils/event_message_ko.dart';

final Random _random = Random();

String getRandomEventMessage(int amount) {
  final int amountInManwon = amount ~/ 10000;

  EventMessageData data;

  if (amountInManwon <= -100.0) {
    // 1. amount <= -100만
    data = eventMessagesKo[0];
  } else if (amountInManwon > -100.0 && amountInManwon <= -50.0) {
    // 2. -100만 < amount <= -50만
    data = eventMessagesKo[1];
  } else if (amountInManwon > -50.0 && amountInManwon <= -20.0) {
    // 3. -50만 < amount <= -20만
    data = eventMessagesKo[2];
  } else if (amountInManwon > -20.0 && amountInManwon <= -10.0) {
    // 4. -20만 < amount <= -10만
    data = eventMessagesKo[3];
  } else if (amountInManwon > -10.0 && amountInManwon <= 10.0) {
    // 5. -10만 < amount <= 10만
    data = eventMessagesKo[4];
  } else if (amountInManwon > 10.0 && amountInManwon <= 20.0) {
    // 6. 10만 < amount <= 20만
    data = eventMessagesKo[5];
  } else if (amountInManwon > 20.0 && amountInManwon <= 50.0) {
    // 7. 20만 < amount <= 50만
    data = eventMessagesKo[6];
  } else if (amountInManwon > 50.0 && amountInManwon <= 100.0) {
    // 8. 50만 < amount <= 100만
    data = eventMessagesKo[7];
  } else {
    // 9. 100만 < amount
    data = eventMessagesKo[8];
  }

  final messages = data.messages;

  return messages[_random.nextInt(messages.length)];
}
