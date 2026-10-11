import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/hive_boxes.dart';
import 'data/seed_data.dart';
import 'repositories/category_repository.dart';
import 'repositories/custom_tag_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.recipes);
  await Hive.openBox<String>(HiveBoxes.customTags);
  await Hive.openBox<String>(HiveBoxes.categories);
  await Hive.openBox<String>(HiveBoxes.mealPlan);

  await CategoryRepository().seedIfEmpty(seedCategories);
  await CustomTagRepository().seedIfEmpty(seedTags);

  runApp(const ProviderScope(child: RecipeaApp()));
}
