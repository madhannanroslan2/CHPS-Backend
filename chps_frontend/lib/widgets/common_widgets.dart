import 'package:flutter/material.dart';

class ResourceFormField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const ResourceFormField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  State<ResourceFormField> createState() => _ResourceFormFieldState();
}

class _ResourceFormFieldState extends State<ResourceFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ResourceFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: widget.onChanged,
    );
  }
}
