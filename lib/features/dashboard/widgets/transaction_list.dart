import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction.dart';
import '../dashboard_controller.dart';

/// Mapa de ícones por categoria — espelha o CATEGORY_ICONS do design de referência.
const _iconesPorCategoria = <String, IconData>{
  'Alimentação': Icons.restaurant_outlined,
  'Transporte': Icons.directions_car_outlined,
  'Lazer': Icons.sports_esports_outlined,
  'Saúde': Icons.favorite_outline,
  'Educação': Icons.school_outlined,
  'Moradia': Icons.home_outlined,
  'Outros': Icons.more_horiz,
};

/// Lista das transações mais recentes do mês.
///
/// Baseada no TransactionList do design de referência (transaction-list.tsx).
/// Exibe ícone por categoria, descrição, data e valor.
class TransactionList extends StatelessWidget {
  final DashboardController controller;
  const TransactionList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final transacoes = controller.transacoesRecentes;

    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transações Recentes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                Text(
                  '${controller.totalTransacoes} itens',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),

          // Estado vazio
          if (transacoes.isEmpty)
            const _EstadoVazio()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transacoes.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 64,
                color: Colors.grey.shade100,
              ),
              itemBuilder: (context, index) =>
                  _ItemTransacao(transacao: transacoes[index]),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Item individual da lista
// -----------------------------------------------------------------------------

class _ItemTransacao extends StatelessWidget {
  final Transaction transacao;
  const _ItemTransacao({required this.transacao});

  @override
  Widget build(BuildContext context) {
    final icone = _iconesPorCategoria[transacao.categoria] ?? Icons.more_horiz;
    final cor = AppColors.dCategoria(transacao.categoria);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 12),

          // Descrição e categoria + data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.descricao,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textoPrincipal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transacao.categoria} • ${_formatarData(transacao.data)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),

          // Valor
          Row(
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                size: 14,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 2),
              Text(
                DashboardController.formatarMoeda(transacao.valor),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoPrincipal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    const meses = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${data.day.toString().padLeft(2, '0')} de ${meses[data.month - 1]}';
  }
}

// -----------------------------------------------------------------------------
// Estado vazio
// -----------------------------------------------------------------------------

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textoSecundario),
            SizedBox(height: 8),
            Text(
              'Nenhuma transação este mês',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textoSecundario,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Fotografe um comprovante para começar',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
