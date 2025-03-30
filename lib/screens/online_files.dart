import 'package:flutter/material.dart';

class OnlineFilesScreen extends StatelessWidget {
  const OnlineFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Files'),
      ),
      body: Center(
        child: const Text('Welcome to the Online Files Screen'),
      ),
    );
  }
}
