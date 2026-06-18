import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/network/auth_service.dart';
import 'core/network/dio_client.dart';
import 'features/fixtures/presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  // Inicializar auth y dio en segundo plano (no bloquea la UI)
  AuthService.getInstance().then((_) => DioClient.getInstance());
  runApp(const Mundial2026App());
}

class Mundial2026App extends StatelessWidget {
  const Mundial2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundial 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A3D62),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A3D62),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}
