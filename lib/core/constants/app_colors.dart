import 'package:flutter/material.dart';

/// Paleta de cores centralizada do FinZen.
/// Altere aqui para refletir em todo o app.
abstract class AppColors {
  // Cor principal — verde que remete a dinheiro e saúde financeira
  static const Color primaria = Color(0xFF1B8A5A);

  // Variações da cor principal
  static const Color primariaClara = Color(0xFF4CAF82);
  static const Color primariaEscura = Color(0xFF0D5C3A);

  // Cor de destaque — âmbar para alertas e destaques
  static const Color destaque = Color(0xFFFFC107);

  // Fundo das telas
  static const Color fundo = Color(0xFFF5F7FA);

  // Fundo de cards e superfícies
  static const Color superficie = Color(0xFFFFFFFF);

  // Texto principal
  static const Color textoPrincipal = Color(0xFF1A1A2E);

  // Texto secundário / legendas
  static const Color textoSecundario = Color(0xFF6B7280);

  // Cores por categoria de gasto
  static const Map<String, Color> categorias = {
    'Alimentação': Color(0xFFEF5350),
    'Transporte': Color(0xFF42A5F5),
    'Saúde': Color(0xFF66BB6A),
    'Educação': Color(0xFFAB47BC),
    'Lazer': Color(0xFFFF7043),
    'Moradia': Color(0xFF26C6DA),
    'Outros': Color(0xFF8D6E63),
  };

  /// Retorna a cor associada a uma categoria.
  /// Usa 'Outros' como fallback se a categoria não existir.
  static Color dCategoria(String categoria) {
    return categorias[categoria] ?? categorias['Outros']!;
  }
}
