import 'package:flutter/material.dart';

const primaryColor = Color(0xffFF6258);
const cashBlueColor = Color(0xff027DFD);

/// 카테고리별 색상
const Map<String, Color> categoryColors = {
  '가족': Color(0xFFFF4538),
  '친구': Color(0xFF027DFD),
  '직장': Color(0xFFFFB038),
  '지인': Color(0xFF4CAF50),
  '그외': Color(0xFF9E9E9E),
};

/// 카테고리 색상 가져오기 (기본값: 회색)
Color getCategoryColor(String? category) {
  return categoryColors[category] ?? const Color(0xFF9E9E9E);
}
