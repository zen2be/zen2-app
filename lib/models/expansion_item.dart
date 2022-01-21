import 'package:flutter/material.dart';
import 'package:zen2app/models/timeslot.dart';

class ExpansionItem {
  // source: https://www.youtube.com/watch?v=VXplWh0c4dA
  bool isExpanded;
  final String title;
  Icon icon;

  ExpansionItem(
      {this.isExpanded = false, required this.title, required this.icon});
}
