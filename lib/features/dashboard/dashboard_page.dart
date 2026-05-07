import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../scan/scan_page.dart';
import '../chat/chat_page.dart';
import '../auth/profile_page.dart';
import 'dashboard_controller.dart';
import 'widgets/stats_cards.dart';
import 'widgets/expense_chart.dart';
import 'widgets/transaction_list.dart';

/// Tela principal do app após autenticação.
///
/// Contém a navegação por abas (BottomNavigationBar) com 4 seções:
/// Dashboard, Scan, Chat e Perfil — espelhando o Navigation do design
/// de referência (navigation.tsx).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _abaAtual = 0;

  @override
  void initState() {
    super.initState();
    // Inicia o stream de transações assim que o Dashboard é montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().iniciar();
    });
  }

  /// Páginas correspondentes a cada aba da navegação.
  static const _paginas = [
    _HomeTab(),
    ScanPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a página da aba selecionada
      body: IndexedStack(
        index: _abaAtual,
        children: _paginas,
      ),

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: (index) => setState(() => _abaAtual = index),
        selectedItemColor: AppColors.primaria,
        unselectedItemColor: AppColors.textoSecundario,
        backgroundColor: AppColors.superficie,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Aba Home — conteúdo do Dashboard
// =============================================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final primeiroNome = usuario?.displayName?.split(' ').first ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, controller, _) {
            return CustomScrollView(
              slivers: [
                // Header fixo com saudação e botão de scan rápido
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.superficie,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Divider(height: 1, color: Colors.grey.shade200),
                  ),
                  title: Row(
                    children: [
                      // Logo + saudação
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaria,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, $primeiroNome',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoPrincipal,
                            ),
                          ),
                          Text(
                            _mesAtual(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textoSecundario,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    // Botão de scan rápido no header
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilledButton.icon(
                        onPressed: () {
                          // Navega para a aba de Scan
                          final state = context
                              .findAncestorStateOfType<_DashboardPageState>();
                          state?.setState(() => state._abaAtual = 1);
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text(
                          'Novo Gasto',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaria,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Conteúdo scrollável
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Estado de carregamento
                      if (controller.carregando)
                        const _Carregando()

                      // Estado de erro
                      else if (controller.erro != null)
                        _Erro(mensagem: controller.erro!)

                      // Conteúdo normal
                      else ...[
                        StatsCards(controller: controller),
                        const SizedBox(height: 16),
                        ExpenseChart(controller: controller),
                        const SizedBox(height: 16),
                        TransactionList(controller: controller),
                        const SizedBox(height: 8),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Retorna o mês e ano atual formatado: "Maio 2026"
  String _mesAtual() {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final agora = DateTime.now();
    return '${meses[agora.month - 1]} ${agora.year}';
  }
}

// =============================================================================
// Estados auxiliares
// =============================================================================

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaria),
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  final String mensagem;
  const _Erro({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              mensagem,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
