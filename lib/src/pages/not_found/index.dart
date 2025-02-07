import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Not Found'),
      ),
      body: Center(
        child: Text('404 Not Found'),
      ),
    );
  }
}
