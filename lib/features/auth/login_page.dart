import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'auth_controller.dart';

/// Tela de login exibida quando o usuário não está autenticado.
///
/// Oferece login via Google. Após autenticação bem-sucedida,
/// o [AuthGate] em app.dart redireciona automaticamente para o Dashboard.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _LogoSection(),
                  const SizedBox(height: 48),
                  const _LoginCard(),
                  const SizedBox(height: 32),
                  const _InfoSeguranca(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Logo e título
// -----------------------------------------------------------------------------

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone principal
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaria,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'FinZen',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textoPrincipal,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Controle financeiro com IA',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textoSecundario,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Card de login
// -----------------------------------------------------------------------------

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Faça login para sincronizar seus dados e acessar de qualquer dispositivo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Mensagem de erro (se houver)
            Consumer<AuthController>(
              builder: (context, auth, _) {
                if (auth.erro == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    auth.erro!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            // Botão de login com Google
            Consumer<AuthController>(
              builder: (context, auth, _) {
                return _BotaoGoogle(
                  carregando: auth.carregando,
                  onPressed: () => auth.logarComGoogle(),
                );
              },
            ),

            const SizedBox(height: 16),
            Text(
              'Ao continuar, você concorda com os Termos de Uso e Política de Privacidade',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Botão do Google
// -----------------------------------------------------------------------------

class _BotaoGoogle extends StatelessWidget {
  final bool carregando;
  final VoidCallback onPressed;

  const _BotaoGoogle({
    required this.carregando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: carregando ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo do Google em SVG simplificado como CustomPaint
                  _LogoGoogle(),
                  const SizedBox(width: 12),
                  const Text(
                    'Continuar com Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Logo do Google (4 paths coloridos)
// -----------------------------------------------------------------------------

class _LogoGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.width / 24; // escala baseada em viewBox 24x24

    // Azul
    paint.color = const Color(0xFF4285F4);
    final pathAzul = Path()
      ..moveTo(22.56 * s, 12.25 * s)
      ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
      ..lineTo(12 * s, 10 * s)
      ..lineTo(12 * s, 14.26 * s)
      ..lineTo(17.92 * s, 14.26 * s)
      ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s)
      ..lineTo(15.71 * s, 20.34 * s)
      ..lineTo(19.28 * s, 20.34 * s)
      ..cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
      ..close();
    canvas.drawPath(pathAzul, paint);

    // Verde
    paint.color = const Color(0xFF34A853);
    final pathVerde = Path()
      ..moveTo(12 * s, 23 * s)
      ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
      ..lineTo(2.18 * s, 14.1 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s)
      ..close();
    canvas.drawPath(pathVerde, paint);

    // Amarelo
    paint.color = const Color(0xFFFBBC05);
    final pathAmarelo = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(5.84 * s, 7.07 * s)
      ..lineTo(2.18 * s, 7.07 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
      ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    canvas.drawPath(pathAmarelo, paint);

    // Vermelho
    paint.color = const Color(0xFFEA4335);
    final pathVermelho = Path()
      ..moveTo(12 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
      ..cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
      ..lineTo(5.84 * s, 9.91 * s)
      ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
      ..close();
    canvas.drawPath(pathVermelho, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Informações de segurança
// -----------------------------------------------------------------------------

class _InfoSeguranca extends StatelessWidget {
  const _InfoSeguranca();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ItemSeguranca(texto: 'Seus dados ficam seguros no Firebase'),
        const SizedBox(height: 12),
        _ItemSeguranca(texto: 'OCR processa tudo no seu dispositivo'),
      ],
    );
  }
}

class _ItemSeguranca extends StatelessWidget {
  final String texto;
  const _ItemSeguranca({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 16, color: AppColors.primaria),
        const SizedBox(width: 8),
        Text(
          texto,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textoSecundario,
              ),
        ),
      ],
    );
  }
}
