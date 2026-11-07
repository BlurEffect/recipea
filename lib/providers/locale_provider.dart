import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_load());

  static Locale _load() {
    final box = Hive.box<String>(HiveBoxes.settings);
    final saved = box.get('locale');
    if (saved == 'de') return const Locale('de');
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    Hive.box<String>(HiveBoxes.settings).put('locale', locale.languageCode);
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
