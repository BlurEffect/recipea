import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/recipe.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/edit/edit_screen.dart';
import 'screens/meal_plan/meal_plan_screen.dart';
import 'screens/meal_plan/history_screen.dart';
import 'screens/shopping_list/shopping_list_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/more/more_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/legal/data_protection_screen.dart';
import 'screens/legal/imprint_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'widgets/empty_state.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.error_outline,
        message: l.detailRecipeNotFound,
        action: TextButton(
          onPressed: () => context.go('/recipes'),
          child: Text(l.navRecipes),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const BrowseScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => DetailScreen(
            recipeId: state.pathParameters['id']!,
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => EditScreen(
                recipeId: state.pathParameters['id']!,
                initialRecipe: state.extra as Recipe?,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/meal-plan',
      builder: (context, state) => const MealPlanScreen(),
    ),
    GoRoute(
      path: '/meal-plan/history',
      builder: (context, state) => const MealPlanHistoryScreen(),
    ),
    GoRoute(
      path: '/shopping-list',
      builder: (context, state) => const ShoppingListScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/more',
      builder: (context, state) => const MoreScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/legal/data-protection',
      builder: (context, state) => const DataProtectionScreen(),
    ),
    GoRoute(
      path: '/legal/imprint',
      builder: (context, state) => const ImprintScreen(),
    ),
  ],
);
