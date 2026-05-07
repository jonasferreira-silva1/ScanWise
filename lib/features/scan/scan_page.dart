import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import 'scan_controller.dart';

/// Tela de scan de comprovante.
///
/// Gerencia os 4 estados visuais do fluxo:
/// idle → processando (OCR + IA) → sucesso (confirmação) → erro
class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Scan de Comprovante'),
        backgroundColor: AppColors.superficie,
        foregroundColor: AppColors.textoPrincipal,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Consumer<ScanController>(
        builder: (context, controller, _) {
          return switch (controller.estado) {
            EstadoScan.idle => _TelaIdle(controller: controller),
            EstadoScan.capturando ||
            EstadoScan.processandoOcr ||
            EstadoScan.processandoIa =>
              _TelaProcessando(estado: controller.estado),
            EstadoScan.sucesso => _TelaConfirmacao(controller: controller),
            EstadoScan.erro => _TelaErro(controller: controller),
          };
        },
      ),
    );
  }
}

// =============================================================================
// Estado: idle — área de upload e botões de ação
// =============================================================================

class _TelaIdle extends StatelessWidget {
  final ScanController controller;
  const _TelaIdle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Área principal de upload (clicável)
              _AreaUpload(
                onTap: () => controller.escanear(origem: ImageSource.camera),
              ),
              const SizedBox(height: 16),

              // Botões secundários: galeria e documento
              Row(
                children: [
                  Expanded(
                    child: _BotaoAcao(
                      icone: Icons.photo_library_outlined,
                      label: 'Galeria',
                      onTap: () =>
                          controller.escanear(origem: ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotaoAcao(
                      icone: Icons.insert_drive_file_outlined,
                      label: 'Documento',
                      onTap: () =>
                          controller.escanear(origem: ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card informativo sobre a IA
              _CardInfoIa(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaUpload extends StatelessWidget {
  final VoidCallback onTap;
  const _AreaUpload({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaria.withOpacity(0.3),
            width: 2,
            // Borda tracejada simulada com BoxDecoration
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com fundo circular
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaria.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: AppColors.primaria,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Envie seu comprovante',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textoPrincipal,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'PIX, nota fiscal, boleto ou qualquer comprovante de pagamento',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textoSecundario,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;

  const _BotaoAcao({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icone, size: 22, color: AppColors.textoSecundario),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfoIa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaria.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.primaria),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IA extrai automaticamente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Valor, descrição, categoria e estabelecimento são identificados automaticamente pelo Claude AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Estado: processando — loader com mensagem dinâmica
// =============================================================================

class _TelaProcessando extends StatelessWidget {
  final EstadoScan estado;
  const _TelaProcessando({required this.estado});

  String get _titulo {
    return switch (estado) {
      EstadoScan.capturando => 'Abrindo câmera...',
      EstadoScan.processandoOcr => 'Extraindo texto...',
      EstadoScan.processandoIa => 'Processando com IA...',
      _ => 'Processando...',
    };
  }

  String get _subtitulo {
    return switch (estado) {
      EstadoScan.capturando => 'Prepare o comprovante',
      EstadoScan.processandoOcr => 'OCR lendo o documento no dispositivo',
      EstadoScan.processandoIa => 'Claude AI está identificando os dados',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loader circular com fundo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaria.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primaria,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Estado: sucesso — dados extraídos para confirmação
// =============================================================================

class _TelaConfirmacao extends StatelessWidget {
  final ScanController controller;
  const _TelaConfirmacao({required this.controller});

  @override
  Widget build(BuildContext context) {
    final transacao = controller.transacaoExtraida!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // Card com dados extraídos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primaria,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Dados Extraídos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoPrincipal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview da imagem capturada
                      if (controller.imagemCapturada != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            controller.imagemCapturada!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (controller.imagemCapturada != null)
                        const SizedBox(height: 16),

                      // Linha: Valor
                      _LinhaInfo(
                        label: 'Valor',
                        valor: 'R\$ ${transacao.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                        destaque: true,
                      ),
                      const Divider(height: 1),

                      // Linha: Descrição
                      _LinhaInfo(
                        label: 'Descrição',
                        valor: transacao.descricao,
                      ),
                      const Divider(height: 1),

                      // Linha: Categoria
                      _LinhaInfo(
                        label: 'Categoria',
                        valor: transacao.categoria,
                        corValor: AppColors.primaria,
                      ),
                      const Divider(height: 1),

                      // Linha: Data
                      _LinhaInfo(
                        label: 'Data',
                        valor: _formatarData(transacao.data),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.resetar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await controller.confirmarESalvar();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transação salva com sucesso!'),
                              backgroundColor: AppColors.primaria,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaria,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Salvar Transação'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    const meses = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${data.day.toString().padLeft(2, '0')} de ${meses[data.month - 1]}. de ${data.year}';
  }
}

class _LinhaInfo extends StatelessWidget {
  final String label;
  final String valor;
  final bool destaque;
  final Color? corValor;

  const _LinhaInfo({
    required this.label,
    required this.valor,
    this.destaque = false,
    this.corValor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textoSecundario,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 17 : 14,
              fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
              color: corValor ?? AppColors.textoPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Estado: erro — mensagem e botão de tentar novamente
// =============================================================================

class _TelaErro extends StatelessWidget {
  final ScanController controller;
  const _TelaErro({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de erro
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 36,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Não consegui processar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.mensagemErro ?? 'Algo deu errado. Tente novamente.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: controller.resetar,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tentar novamente'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
