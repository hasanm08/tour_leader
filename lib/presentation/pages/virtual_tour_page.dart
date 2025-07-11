import 'package:flutter/material.dart';

class VirtualTourPage extends StatelessWidget {
  const VirtualTourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Tour')),
      body: const Center(
        child: Text('Virtual Tour Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
