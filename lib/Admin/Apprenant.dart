import 'package:flutter/material.dart';

class ApprenantPage extends StatefulWidget {
  const ApprenantPage({super.key});

  @override
  State<ApprenantPage> createState() => _ApprenantPageState();
}

class _ApprenantPageState extends State<ApprenantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apprenants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
