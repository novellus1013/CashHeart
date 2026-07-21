import 'package:flutter/material.dart';

/// design_handoff `AVATAR_TINTS` — Avatar 위젯의 배경/글자 색 페어.
/// person.id 기반 인덱스로 순환 배정한다(person별 고정 톤).
class AvatarTint {
  final Color background;
  final Color foreground;

  const AvatarTint(this.background, this.foreground);
}

const List<AvatarTint> avatarTints = [
  AvatarTint(Color(0xFFFFE3E0), Color(0xFFE5564B)),
  AvatarTint(Color(0xFFE2F0FF), Color(0xFF0A6BD6)),
  AvatarTint(Color(0xFFE6F4EA), Color(0xFF2E7D43)),
  AvatarTint(Color(0xFFFCEFD9), Color(0xFFC77E1A)),
  AvatarTint(Color(0xFFEFE7FB), Color(0xFF6C44C4)),
  AvatarTint(Color(0xFFFDE5F0), Color(0xFFC03571)),
  AvatarTint(Color(0xFFE3F3F4), Color(0xFF1B8A8F)),
  AvatarTint(Color(0xFFEEEFF2), Color(0xFF5A6172)),
];

AvatarTint avatarTintFor(int seed) {
  final index = seed % avatarTints.length;
  return avatarTints[index < 0 ? index + avatarTints.length : index];
}
