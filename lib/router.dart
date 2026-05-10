import 'package:go_router/go_router.dart';

import 'screens/browse/browse_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/edit/edit_screen.dart';
import 'screens/meal_plan/meal_plan_screen.dart';
import 'screens/shopping_list/shopping_list_screen.dart';
import 'screens/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
      path: '/shopping-list',
      builder: (context, state) => const ShoppingListScreen(),
    ),
  ],
);
