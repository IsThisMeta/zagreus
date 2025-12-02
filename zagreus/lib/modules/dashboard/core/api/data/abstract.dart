import 'package:flutter/material.dart';

abstract class CalendarData {
  int id;
  String title;
  String? instanceKey; // null = main instance, otherwise shadow profile key
  List<TextSpan> get body;

  String? backgroundUrl(BuildContext context);
  String? posterUrl(BuildContext context);

  Widget trailing(BuildContext context);
  Future<void> enterContent(BuildContext context);
  Future<void> trailingOnPress(BuildContext context);
  Future<void> trailingOnLongPress(BuildContext context);

  CalendarData(
    this.id,
    this.title, {
    this.instanceKey,
  });
}
