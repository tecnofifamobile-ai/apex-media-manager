import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryDatabaseProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/channel_categories.json');
    final Map<String, dynamic> rawMap = jsonDecode(jsonStr);
    return rawMap.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    return {};
  }
});
