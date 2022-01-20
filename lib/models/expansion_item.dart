import 'package:flutter/material.dart';

class ExpansionItem {
  // source: https://www.youtube.com/watch?v=VXplWh0c4dA
  bool isExpanded;
  final String title;
  Icon icon;
  Widget body;

  ExpansionItem(
      {this.isExpanded = false,
      required this.title,
      required this.icon,
      required this.body});
}
