import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'infrastructure/services/supabase_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase initialization (skipped in demo mode)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // In demo mode, we continue without Supabase
    debugPrint('Supabase initialization skipped: $e');
  }
  
  runApp(const ProviderScope(child: TravueApp()));
}

class TravueApp extends StatelessWidget {
  const TravueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Travue',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
