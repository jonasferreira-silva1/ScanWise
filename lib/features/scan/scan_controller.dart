import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/claude_service.dart';
import '../../core/services/firebase_service.dart';
import '../../models/transaction.dart';

/// Estados possíveis do fluxo de scan.
enum EstadoScan { idle, capturando, processandoOcr, processandoIa, sucesso, erro }

/// Orquestra o fluxo completo de scan de comprovante:
/// câmera → OCR → Claude API → confirmação → Firestore.
class ScanController extends ChangeNotifier {
  final _ocr = OcrService();
  final _claude = ClaudeService();
  final _firebase = FirebaseService();
  final _picker = ImagePicker();

  EstadoScan _estado = EstadoScan.idle;
  EstadoScan get estado => _estado;

  /// Imagem capturada — usada para preview na tela de confirmação.
  File? imagemCapturada;

  /// Transação extraída pelo Claude — exibida para o usuário confirmar.
  Transaction? transacaoExtraida;

  /// Mensagem de erro amigável para exibir na UI.
  String? mensagemErro;

  // ---------------------------------------------------------------------------
  // Fluxo principal
  // ---------------------------------------------------------------------------

  /// Abre a câmera, extrai texto com OCR e envia para o Claude.
  ///
  /// [origem] define se usa câmera ou galeria.
  Future<void> escanear({ImageSource origem = ImageSource.camera}) async {
    _setEstado(EstadoScan.capturando);
    mensagemErro = null;

    try {
      // 1. Captura a imagem
      final foto = await _picker.pickImage(
        source: origem,
        imageQuality: 85, // reduz tamanho sem perder legibilidade do texto
        preferredCameraDevice: CameraDevice.rear,
      );

      // Usuário cancelou a câmera
      if (foto == null) {
        _setEstado(EstadoScan.idle);
        return;
      }

      imagemCapturada = File(foto.path);
      _setEstado(EstadoScan.processandoOcr);

      // 2. Extrai texto da imagem com ML Kit (on-device)
      final textoExtraido = await _ocr.extrairTexto(imagemCapturada!);
      _setEstado(EstadoScan.processandoIa);

      // 3. Envia texto para o Claude estruturar os dados financeiros
      final dadosExtraidos = await _claude.extrairTransacao(textoExtraido);

      // 4. Monta o objeto Transaction para confirmação
      transacaoExtraida = Transaction(
        id: const Uuid().v4(),
        valor: (dadosExtraidos['valor'] as num).toDouble(),
        descricao: dadosExtraidos['descricao'] as String? ?? 'Sem descrição',
        categoria: dadosExtraidos['categoria'] as String? ?? 'Outros',
        data: dadosExtraidos['data'] != null
            ? DateTime.tryParse(dadosExtraidos['data'] as String) ?? DateTime.now()
            : DateTime.now(),
        uid: FirebaseAuth.instance.currentUser!.uid,
      );

      _setEstado(EstadoScan.sucesso);
    } catch (e) {
      mensagemErro = _traduzirErro(e.toString());
      _setEstado(EstadoScan.erro);
    }
  }

  // ---------------------------------------------------------------------------
  // Confirmação e salvamento
  // ---------------------------------------------------------------------------

  /// Salva a transação confirmada no Firestore e reseta o estado.
  Future<void> confirmarESalvar() async {
    if (transacaoExtraida == null) return;

    try {
      await _firebase.salvarTransacao(transacaoExtraida!);
      resetar();
    } catch (e) {
      mensagemErro = 'Erro ao salvar. Verifique sua conexão e tente novamente.';
      notifyListeners();
    }
  }

  /// Permite editar o valor antes de salvar.
  void atualizarValor(double novoValor) {
    if (transacaoExtraida == null) return;
    transacaoExtraida = transacaoExtraida!.copyWith(valor: novoValor);
    notifyListeners();
  }

  /// Permite editar a descrição antes de salvar.
  void atualizarDescricao(String novaDescricao) {
    if (transacaoExtraida == null) return;
    transacaoExtraida = transacaoExtraida!.copyWith(descricao: novaDescricao);
    notifyListeners();
  }

  /// Permite editar a categoria antes de salvar.
  void atualizarCategoria(String novaCategoria) {
    if (transacaoExtraida == null) return;
    transacaoExtraida = transacaoExtraida!.copyWith(categoria: novaCategoria);
    notifyListeners();
  }

  /// Reseta o controller para o estado inicial.
  void resetar() {
    _estado = EstadoScan.idle;
    imagemCapturada = null;
    transacaoExtraida = null;
    mensagemErro = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Utilitários privados
  // ---------------------------------------------------------------------------

  void _setEstado(EstadoScan novoEstado) {
    _estado = novoEstado;
    notifyListeners();
  }

  /// Traduz mensagens de erro técnicas para linguagem amigável.
  String _traduzirErro(String erro) {
    if (erro.contains('Nenhum texto encontrado')) {
      return 'Não consegui ler o comprovante. Tente com mais luz e o documento centralizado.';
    }
    if (erro.contains('API do Claude') || erro.contains('statusCode')) {
      return 'Erro ao processar com IA. Verifique sua conexão e tente novamente.';
    }
    if (erro.contains('JSON')) {
      return 'Não consegui identificar os dados do comprovante. Tente outro ângulo.';
    }
    return 'Algo deu errado. Tente novamente.';
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }
}
