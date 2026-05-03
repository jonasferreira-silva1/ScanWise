import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'auth_controller.dart';

/// Tela de perfil do usuário autenticado.
///
/// Exibe avatar, nome, email, stats rápidos e menu de opções.
/// Baseada no design de referência (login/page.tsx — estado logado).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.superficie,
        foregroundColor: AppColors.textoPrincipal,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Card do perfil
                _CardPerfil(usuario: usuario),
                const SizedBox(height: 16),

                // Stats rápidos
                _StatsRapidos(),
                const SizedBox(height: 16),

                // Menu de opções
                _MenuOpcoes(),
                const SizedBox(height: 16),

                // Botão de logout
                _BotaoSair(),
                const SizedBox(height: 24),

                // Rodapé
                _Rodape(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Card com avatar, nome e email
// -----------------------------------------------------------------------------

class _CardPerfil extends StatelessWidget {
  final User? usuario;
  const _CardPerfil({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.displayName ?? 'Usuário';
    final email = usuario?.email ?? '';
    final fotoUrl = usuario?.photoURL;

    // Iniciais para o avatar fallback
    final iniciais = nome
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaria,
              backgroundImage:
                  fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null
                  ? Text(
                      iniciais,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Nome e email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
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

// -----------------------------------------------------------------------------
// Stats rápidos (transações, scans, meses)
// -----------------------------------------------------------------------------

class _StatsRapidos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _CardStat(valor: '0', label: 'Transações')),
        const SizedBox(width: 12),
        Expanded(child: _CardStat(valor: '0', label: 'Scans')),
        const SizedBox(width: 12),
        Expanded(child: _CardStat(valor: '1', label: 'Mês')),
      ],
    );
  }
}

class _CardStat extends StatelessWidget {
  final String valor;
  final String label;

  const _CardStat({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaria,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Menu de opções
// -----------------------------------------------------------------------------

class _MenuOpcoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _ItemMenu(
            icone: Icons.person_outline,
            titulo: 'Editar Perfil',
            onTap: () {}, // implementar futuramente
          ),
          _Divisor(),
          _ItemMenu(
            icone: Icons.settings_outlined,
            titulo: 'Configurações',
            onTap: () {},
          ),
          _Divisor(),
          _ItemMenu(
            icone: Icons.shield_outlined,
            titulo: 'Privacidade',
            onTap: () {},
          ),
          _Divisor(),
          _ItemMenu(
            icone: Icons.help_outline,
            titulo: 'Ajuda',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icone, size: 20, color: AppColors.textoSecundario),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textoPrincipal,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Colors.grey.shade100,
    );
  }
}

// -----------------------------------------------------------------------------
// Botão de sair
// -----------------------------------------------------------------------------

class _BotaoSair extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: auth.carregando ? null : () => auth.sair(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sair da conta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Rodapé com versão e link do GitHub
// -----------------------------------------------------------------------------

class _Rodape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'FinZen v1.0.0 • Desenvolvido por Jonas Silva',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textoSecundario,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            // Abrir URL — implementar com url_launcher futuramente
          },
          child: Text(
            'GitHub',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaria,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
