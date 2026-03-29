import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RecipeaApp extends StatelessWidget {
  const RecipeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipea',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
