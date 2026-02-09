import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Routines')),
      body: const Center(child: Text('Hier kommen deine Routinen hin')),
    );
  }
}
