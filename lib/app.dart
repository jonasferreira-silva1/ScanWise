import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/login_page.dart';
import 'features/auth/auth_controller.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/dashboard/dashboard_controller.dart';
import 'features/scan/scan_controller.dart';
import 'features/chat/chat_controller.dart';

/// Raiz do aplicativo.
/// Configura o tema, os providers de estado e a navegação inicial.
class FinZenApp extends StatelessWidget {
  const FinZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controller de autenticação — disponível em toda a árvore
        ChangeNotifierProvider(create: (_) => AuthController()),
        // Controllers das features — criados sob demanda
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => ScanController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: MaterialApp(
        title: 'FinZen',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        // Decide a tela inicial com base no estado de autenticação
        home: const _AuthGate(),
      ),
    );
  }

  /// Define o tema visual do app com a paleta FinZen.
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaria,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.superficie,
        foregroundColor: AppColors.textoPrincipal,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        selectedItemColor: AppColors.primaria,
        unselectedItemColor: AppColors.textoSecundario,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

/// Observa o estado de autenticação do Firebase e redireciona
/// para Login ou Dashboard conforme o usuário esteja logado ou não.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto aguarda a resposta do Firebase, exibe um loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuário autenticado → Dashboard (com navegação por abas)
        if (snapshot.hasData) {
          return const DashboardPage();
        }

        // Usuário não autenticado → Login
        return const LoginPage();
      },
    );
  }
}
