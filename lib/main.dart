import 'package:chess_app/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chess_app/app/app.bottomsheets.dart';
import 'package:chess_app/app/app.dialogs.dart';
import 'package:chess_app/app/app.locator.dart';
import 'package:chess_app/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: k343230),
        scaffoldBackgroundColor: k343230,
      ),
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
