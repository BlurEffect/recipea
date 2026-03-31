import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/hive_boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.recipes);
  await Hive.openBox<String>(HiveBoxes.customTags);
  runApp(const ProviderScope(child: RecipeaApp()));
}
