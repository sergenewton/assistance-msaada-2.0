import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistance Msaada 2.0',
      home: Scaffold(
        appBar: AppBar(title: Text('Assistance Msaada 2.0')),
        body: Center(
          child: Text('Application créée avec succès!'),
        ),
      ),
    );
  }
}