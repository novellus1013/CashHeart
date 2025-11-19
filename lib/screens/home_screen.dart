import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPersonId;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Cash Heart',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/setting');
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddEditPersonScreen(),
          ));
        },
        child: const Icon(
          Icons.add,
          size: 28.0,
          color: Colors.white,
        ),
      ),
      body: const Column(children: [
        Text(
          'home_screen',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}
