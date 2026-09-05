import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;

  const ErrorStateWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}
