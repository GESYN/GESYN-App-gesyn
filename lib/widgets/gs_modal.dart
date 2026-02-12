import 'package:flutter/material.dart';

enum GsModalType { warning, error, success }

class GsModal extends StatelessWidget {
  final BuildContext parentContext;
  final String text;
  final GsModalType type;
  final VoidCallback? redirect;
  final String buttonText;

  const GsModal({super.key, 
    required this.parentContext,
    required this.text,
    this.type = GsModalType.warning,
    this.redirect,
    this.buttonText = 'OK',
  });

  Color _color() {
    switch (type) {
      case GsModalType.error:
        return Colors.red.shade700;
      case GsModalType.success:
        return Colors.green.shade700;
      case GsModalType.warning:
        return Colors.orange.shade700;
    }
  }

  IconData _icon() {
    switch (type) {
      case GsModalType.error:
        return Icons.error_outline;
      case GsModalType.success:
        return Icons.check_circle_outline;
      case GsModalType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  Future<void> show() async {
    await showDialog(
        context: parentContext,
        builder: (ctx) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(_icon(), color: _color()),
                const SizedBox(width: 8),
                Text(type.toString().split('.').last.toUpperCase()),
              ],
            ),
            content: Text(text),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (redirect != null) {
                    redirect!();
                  }
                },
                child: Text(buttonText),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // not used as a widget; use show() instead.
    return const SizedBox.shrink();
  }
}
