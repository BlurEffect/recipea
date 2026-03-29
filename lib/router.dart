import 'package:go_router/go_router.dart';

import 'screens/browse/browse_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/edit/edit_screen.dart';
import 'screens/menu/main_menu_screen.dart';
import 'screens/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MainMenuScreen(),
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
  ],
);
