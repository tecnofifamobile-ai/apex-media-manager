import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryDatabaseProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  try {
    final jsonStr = await rootBundle.loadString(
      'assets/channel_categories.json',
    );
    final rawMap = await compute(_decodeCategories, jsonStr);
    return rawMap.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    return {};
  }
});

Map<String, dynamic> _decodeCategories(String value) =>
    jsonDecode(value) as Map<String, dynamic>;
