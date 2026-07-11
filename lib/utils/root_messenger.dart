import 'package:flutter/material.dart';

/// 화면 전환(pushReplacement/pop) 도중에도 안정적으로 SnackBar를 띄우기 위한
/// 앱 전역 ScaffoldMessenger — 특정 Scaffold의 생명주기에 묶이지 않는다.
/// (온보딩 종료 시 "설정에서 다시 볼 수 있어요" 안내 등에 사용.)
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
