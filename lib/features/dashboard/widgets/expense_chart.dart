import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard_controller.dart';

/// Gráfico de pizza (donut) com gastos por categoria.
///
/// Baseado no ExpenseChart do design de referência (expense-chart.tsx).
/// Usa fl_chart com innerRadius para o efeito donut.
class ExpenseChart extends StatefulWidget {
  final DashboardController controller;
  const ExpenseChart({super.key, required this.controller});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int _secaoSelecionada = -1;

  @override
  Widget build(BuildContext context) {
    final dados = widget.controller.totaisPorCategoria;
    final total = widget.controller.totalDespesas;

    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por Categoria',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textoPrincipal,
              ),
            ),
            const SizedBox(height: 16),

            // Estado vazio
            if (dados.isEmpty)
              const _EstadoVazio()
            else
              Column(
                children: [
                  // Gráfico donut
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (response?.touchedSection != null) {
                                _secaoSelecionada = response!
                                    .touchedSection!.touchedSectionIndex;
                              } else {
                                _secaoSelecionada = -1;
                              }
                            });
                          },
                        ),
                        sections: dados.asMap().entries.map((entry) {
                          final i = entry.key;
                          final categoria = entry.value.key;
                          final valor = entry.value.value;
                          final selecionada = i == _secaoSelecionada;

                          return PieChartSectionData(
                            value: valor,
                            color: AppColors.dCategoria(categoria),
                            radius: selecionada ? 52 : 44,
                            title: selecionada
                                ? '${(valor / total * 100).toStringAsFixed(0)}%'
                                : '',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Total centralizado
                  Text(
                    'Total: ${DashboardController.formatarMoeda(total)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Legenda
                  _Legenda(dados: dados, total: total),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Legenda do gráfico
// -----------------------------------------------------------------------------

class _Legenda extends StatelessWidget {
  final List<MapEntry<String, double>> dados;
  final double total;

  const _Legenda({required this.dados, required this.total});

  @override
  Widget build(BuildContext context) {
    // Exibe no máximo 5 categorias para não poluir
    final itens = dados.take(5).toList();

    return Column(
      children: itens.map((entry) {
        final porcentagem = total > 0
            ? (entry.value / total * 100).toStringAsFixed(0)
            : '0';

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              // Bolinha colorida
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.dCategoria(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Nome da categoria
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoPrincipal,
                  ),
                ),
              ),

              // Porcentagem
              Text(
                '$porcentagem%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoSecundario,
                ),
              ),
              const SizedBox(width: 8),

              // Valor
              Text(
                DashboardController.formatarMoeda(entry.value),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoPrincipal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Estado vazio
// -----------------------------------------------------------------------------

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 40, color: AppColors.textoSecundario),
            SizedBox(height: 8),
            Text(
              'Nenhum gasto registrado ainda',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
