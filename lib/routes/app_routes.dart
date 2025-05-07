import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../logging/logging.dart';

GoRouter get router => _router;

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final appState = Provider.of<AppState>(context, listen: false);
    bool isLoggedIn = appState.loggedIn;
    logger.t('isLoggedIn: $isLoggedIn');
    if (!isLoggedIn && state.uri.toString() == '/home') {
      return '/login';
    }
    if (isLoggedIn && state.uri.toString() == '/login') {
      return '/home';
    }
    return null; // don't redirect
  },
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);