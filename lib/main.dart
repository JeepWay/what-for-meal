import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase/firebase_setup.dart';
import 'states/app_state.dart';
import 'routes/app_routes.dart';
import 'themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initializeFirebase();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
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
    );
  }
}
