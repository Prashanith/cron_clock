import 'package:flutter/material.dart';

class PlainScaffold extends StatelessWidget {
  const PlainScaffold({
    required this.widget,
    this.removePadding = false,
    super.key,
  });

  final Widget widget;
  final bool removePadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: Padding(padding: EdgeInsets.zero, child: widget),
      ),
    );
  }
}
