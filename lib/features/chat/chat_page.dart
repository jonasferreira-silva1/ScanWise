import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart';
import 'chat_controller.dart';

/// Perguntas sugeridas exibidas quando a conversa tem apenas a mensagem inicial.
const _perguntasSugeridas = [
  'Quanto gastei esse mês?',
  'Qual minha maior despesa?',
  'Como estou economizando?',
  'Gastos com alimentação',
];

/// Tela do chat financeiro com o assistente FinZen.
///
/// Exibe histórico de mensagens, indicador de digitação animado,
/// perguntas sugeridas e campo de entrada com envio por botão ou Enter.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Rola para o final da lista após nova mensagem ser adicionada.
  void _rolarParaBaixo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar(ChatController controller) async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty) return;
    _inputController.clear();
    await controller.enviar(texto);
    _rolarParaBaixo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(child: _ListaMensagens(scrollController: _scrollController)),

          // Perguntas sugeridas (só aparece no início da conversa)
          const _PerguntasSugeridas(),

          // Campo de entrada
          _CampoEntrada(
            controller: _inputController,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.superficie,
      foregroundColor: AppColors.textoPrincipal,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
      title: Row(
        children: [
          // Avatar do assistente
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaria,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assistente FinZen',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                'Pergunte sobre suas finanças',
                style: TextStyle(
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
        // Botão para limpar conversa
        Consumer<ChatController>(
          builder: (context, controller, _) => IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Nova conversa',
            onPressed: controller.limparConversa,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Lista de mensagens
// =============================================================================

class _ListaMensagens extends StatelessWidget {
  final ScrollController scrollController;
  const _ListaMensagens({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, controller, _) {
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount:
              controller.mensagens.length + (controller.digitando ? 1 : 0),
          itemBuilder: (context, index) {
            // Último item quando digitando = indicador de digitação
            if (controller.digitando &&
                index == controller.mensagens.length) {
              return const _IndicadorDigitando();
            }
            return _BolhaMensagem(
              mensagem: controller.mensagens[index],
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Bolha de mensagem individual
// =============================================================================

class _BolhaMensagem extends StatelessWidget {
  final ChatMessage mensagem;
  const _BolhaMensagem({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final isUser = mensagem.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar do assistente (lado esquerdo)
          if (!isUser) ...[
            _AvatarAssistente(),
            const SizedBox(width: 8),
          ],

          // Bolha de texto
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.textoPrincipal : AppColors.superficie,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                mensagem.texto,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : AppColors.textoPrincipal,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Avatar do usuário (lado direito)
          if (isUser) ...[
            const SizedBox(width: 8),
            _AvatarUsuario(),
          ],
        ],
      ),
    );
  }
}

class _AvatarAssistente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.primaria,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
    );
  }
}

class _AvatarUsuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.textoPrincipal,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 14),
    );
  }
}

// =============================================================================
// Indicador de digitação animado (três pontos pulsando)
// =============================================================================

class _IndicadorDigitando extends StatefulWidget {
  const _IndicadorDigitando();

  @override
  State<_IndicadorDigitando> createState() => _IndicadorDigitandoState();
}

class _IndicadorDigitandoState extends State<_IndicadorDigitando>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animacoes;

  @override
  void initState() {
    super.initState();

    // Cria 3 controllers com delays escalonados para o efeito de onda
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true, period: Duration(milliseconds: 600 + i * 150));
    });

    _animacoes = _controllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Inicia cada animação com delay escalonado
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AvatarAssistente(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.superficie,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animacoes[i],
                  builder: (context, _) {
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.textoSecundario.withOpacity(
                          0.4 + _animacoes[i].value * 0.6,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Perguntas sugeridas
// =============================================================================

class _PerguntasSugeridas extends StatelessWidget {
  const _PerguntasSugeridas();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, controller, _) {
        // Só exibe quando há apenas a mensagem de boas-vindas
        if (controller.mensagens.length != 1) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sugestões:',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _perguntasSugeridas.map((pergunta) {
                  return ActionChip(
                    label: Text(
                      pergunta,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => controller.enviar(pergunta),
                    backgroundColor: AppColors.superficie,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Campo de entrada de texto
// =============================================================================

class _CampoEntrada extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(ChatController) onEnviar;

  const _CampoEntrada({
    required this.controller,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Consumer<ChatController>(
        builder: (context, chatController, _) {
          return Row(
            children: [
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !chatController.carregando,
                  maxLines: null, // permite múltiplas linhas
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onEnviar(chatController),
                  decoration: InputDecoration(
                    hintText: 'Pergunte sobre seus gastos...',
                    hintStyle: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.fundo,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botão de envio
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final temTexto = controller.text.trim().isNotEmpty;
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: temTexto && !chatController.carregando
                          ? AppColors.primaria
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: temTexto && !chatController.carregando
                          ? () => onEnviar(chatController)
                          : null,
                      icon: chatController.carregando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
