import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'states/app_state.dart';
import 'routes/app_routes.dart';
import 'themes/theme.dart';
import 'firebase/firebase_service.dart';
import 'logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initializeFirebase();
    logger.i('Firebase initialization success!');
  } catch (e) {
    logger.e('Firebase initialization failed: $e');
    return;
  }
  final appState = AppState();
  await appState.initAsync();
  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      builder: ((context, child) => const App()),
    )
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'What For Meal',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
