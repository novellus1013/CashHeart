import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PolicyScreen extends StatelessWidget {
  final String type;
  final String lang;

  const PolicyScreen({super.key, required this.type, required this.lang});

  Future<String> _loadPolicy(String type, String lang) async {
    return await rootBundle.loadString('assets/$type/${type}_$lang.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == 'privacy' ? '개인정보처리방침' : '이용약관',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Sizes.size20,
              horizontal: Sizes.size28,
            ),
            child: FutureBuilder(
              future: _loadPolicy(type, lang),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('문서를 불러올 수 없습니다.'),
                  );
                }

                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            )),
      ),
    );
  }
}
