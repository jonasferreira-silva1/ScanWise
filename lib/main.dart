import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

/// Ponto de entrada do aplicativo.
/// Inicializa dependências assíncronas antes de exibir qualquer tela.
void main() async {
  // Garante que os bindings do Flutter estejam prontos antes de chamadas assíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: '.env');

  // Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(const FinZenApp());
}
