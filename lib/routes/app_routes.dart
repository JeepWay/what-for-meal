import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../logging/logging.dart';
import '../pages/personal_list_display.dart';
import '../pages/shared_list_diplay.dart';

GoRouter get router => _router;

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    bool isLoggedIn = (FirebaseAuth.instance.currentUser != null);
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
    GoRoute(
      path: '/list/:listID/:listTitle',
      name: 'list',
      builder: (context, state) => ListPage(
        listID: state.pathParameters['listID']!,
        listTitle: state.pathParameters['listTitle']!,
      ),
    ),
    GoRoute(
      path: '/sharedList/:listID/:listTitle',
      name: 'sharedList',
      builder: (context, state) => SharedListPage(
        listID: state.pathParameters['listID']!,
        listTitle: state.pathParameters['listTitle']!,
      ),
    ),
  ],
);