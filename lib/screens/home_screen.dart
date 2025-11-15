import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Cash Heart',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/share');
            },
            icon: const Icon(
              Icons.settings,
              size: 28.0,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffFF6258),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        child: const Icon(
          Icons.add,
          size: 28.0,
          color: Colors.white,
        ),
      ),
      body: const Column(children: [
        Text(
          'homaasdfsdabafdbdfadfsdafe',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}
