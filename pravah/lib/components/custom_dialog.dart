import 'package:flutter/material.dart';

class CustomDialogBox extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;

  const CustomDialogBox({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        // Confirm Button
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
