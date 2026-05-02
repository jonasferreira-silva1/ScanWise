import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Serviço de OCR usando Google ML Kit — roda inteiramente no dispositivo.
///
/// Vantagem: o texto do comprovante nunca sai do aparelho antes de ser
/// processado. Privacidade por padrão, sem latência de rede para o OCR.
class OcrService {
  /// Reconhecedor configurado para o alfabeto latino (português, inglês, etc.)
  final _reconhecedor = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extrai o texto de uma imagem e retorna como String limpa.
  ///
  /// Remove linhas vazias e espaços extras para reduzir tokens enviados
  /// ao Claude e melhorar a qualidade da extração.
  ///
  /// Lança [Exception] se o ML Kit não conseguir processar a imagem.
  Future<String> extrairTexto(File imagemArquivo) async {
    final imagemEntrada = InputImage.fromFile(imagemArquivo);

    try {
      final resultado = await _reconhecedor.processImage(imagemEntrada);

      // Limpa o texto: remove linhas vazias e espaços desnecessários
      final linhas = resultado.text
          .split('\n')
          .map((linha) => linha.trim())
          .where((linha) => linha.isNotEmpty)
          .toList();

      if (linhas.isEmpty) {
        throw Exception(
          'Nenhum texto encontrado na imagem. '
          'Tente fotografar com mais luz e o comprovante centralizado.',
        );
      }

      return linhas.join('\n');
    } catch (e) {
      throw Exception('Falha ao processar imagem com OCR: $e');
    }
  }

  /// Libera os recursos do reconhecedor.
  /// Chame quando o serviço não for mais necessário (ex: dispose do controller).
  void dispose() => _reconhecedor.close();
}
