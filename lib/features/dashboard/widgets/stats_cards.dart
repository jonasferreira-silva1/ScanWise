import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard_controller.dart';

/// Quatro cards de resumo financeiro do mês:
/// Despesas totais, número de transações, maior categoria e média diária.
///
/// Baseado no StatsCards do design de referência (stats-cards.tsx).
class StatsCards extends StatelessWidget {
  final DashboardController controller;
  const StatsCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalDespesas = controller.totalDespesas;
    final totalTransacoes = controller.totalTransacoes;
    final maiorCategoria = controller.totaisPorCategoria.isNotEmpty
        ? controller.totaisPorCategoria.first
        : null;

    // Média diária baseada no dia atual do mês
    final diaAtual = DateTime.now().day;
    final mediaDiaria = diaAtual > 0 ? totalDespesas / diaAtual : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _CardStat(
          icone: Icons.arrow_downward_rounded,
          corIcone: const Color(0xFFEF5350),
          corFundo: const Color(0xFFFFEBEE),
          label: 'Despesas',
          valor: DashboardController.formatarMoeda(totalDespesas),
        ),
        _CardStat(
          icone: Icons.receipt_long_outlined,
          corIcone: const Color(0xFF42A5F5),
          corFundo: const Color(0xFFE3F2FD),
          label: 'Transações',
          valor: '$totalTransacoes',
        ),
        _CardStat(
          icone: Icons.category_outlined,
          corIcone: AppColors.primaria,
          corFundo: AppColors.primaria.withOpacity(0.1),
          label: 'Maior gasto',
          valor: maiorCategoria?.key ?? '—',
        ),
        _CardStat(
          icone: Icons.today_outlined,
          corIcone: const Color(0xFFAB47BC),
          corFundo: const Color(0xFFF3E5F5),
          label: 'Média/dia',
          valor: DashboardController.formatarMoeda(mediaDiaria),
        ),
      ],
    );
  }
}

class _CardStat extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final Color corFundo;
  final String label;
  final String valor;

  const _CardStat({
    required this.icone,
    required this.corIcone,
    required this.corFundo,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Ícone com fundo colorido
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: corFundo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, color: corIcone, size: 20),
            ),
            const SizedBox(width: 12),

            // Label e valor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
