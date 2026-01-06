import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';

class NewznabResultData {
  String title;
  String category;
  int size;
  String linkDownload;
  String linkComments;
  String linkInfo;
  String date;
  int? grabs;
  String? posterUrl;

  NewznabResultData({
    required this.title,
    required this.category,
    required this.size,
    required this.linkComments,
    required this.linkDownload,
    this.linkInfo = '',
    required this.date,
    this.grabs,
    this.posterUrl,
  });

  DateTime? get dateObject {
    try {
      DateFormat _format = DateFormat('EEE, dd MMM yyyy hh:mm:ss', 'en');
      int? _offset = int.tryParse(date.substring(date.length - 5));
      DateTime _date = _format.parseUtc(date);
      if (_offset != null)
        _date = _date.add(Duration(hours: (-(_offset / 100).round())));
      return _date.toLocal().isAfter(DateTime.now())
          ? DateTime.now()
          : _date.toLocal();
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  String get age => dateObject?.asAge() ?? 'zagreus.Unknown'.tr();

  int get posix => dateObject?.millisecondsSinceEpoch ?? 0;

  /// Returns an icon based on the category name
  IconData get categoryIcon {
    final cat = category.toLowerCase();
    if (cat.contains('movie') || cat.contains('film')) return Icons.movie_rounded;
    if (cat.contains('tv') || cat.contains('television') || cat.contains('series')) return Icons.live_tv_rounded;
    if (cat.contains('music') || cat.contains('audio')) return Icons.music_note_rounded;
    if (cat.contains('game') || cat.contains('gaming') || cat.contains('console')) return Icons.games_rounded;
    if (cat.contains('book') || cat.contains('ebook')) return Icons.book_rounded;
    if (cat.contains('software') || cat.contains('pc') || cat.contains('app')) return Icons.computer_rounded;
    if (cat.contains('xxx') || cat.contains('adult')) return Icons.lock_rounded;
    return Icons.category_rounded;
  }

  /// Returns a color based on the category name
  Color get categoryIconColor {
    final cat = category.toLowerCase();
    if (cat.contains('movie') || cat.contains('film')) return const Color(0xFF26A69A); // Teal
    if (cat.contains('tv') || cat.contains('television') || cat.contains('series')) return const Color(0xFFAB47BC); // Purple
    if (cat.contains('music') || cat.contains('audio')) return const Color(0xFFEF5350); // Red
    if (cat.contains('game') || cat.contains('gaming') || cat.contains('console')) return const Color(0xFF5C6BC0); // Blue
    if (cat.contains('book') || cat.contains('ebook')) return const Color(0xFF29B6F6); // Light Blue
    if (cat.contains('software') || cat.contains('pc') || cat.contains('app')) return const Color(0xFFFF9800); // Orange
    if (cat.contains('xxx') || cat.contains('adult')) return const Color(0xFF78909C); // Grey
    return const Color(0xFF26A69A); // Teal
  }
}
