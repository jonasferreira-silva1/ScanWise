import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gerencia o estado de autenticação do usuário.
///
/// Expõe o usuário atual e métodos de login/logout com Google.
/// O [AuthGate] em app.dart observa o stream do Firebase diretamente,
/// então este controller é usado apenas para ações manuais (login/logout).
class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Usuário atualmente autenticado. Null se não estiver logado.
  User? get usuarioAtual => _auth.currentUser;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  // ---------------------------------------------------------------------------
  // Login com Google
  // ---------------------------------------------------------------------------

  /// Inicia o fluxo de autenticação com Google.
  ///
  /// Abre o seletor de conta do Google, obtém as credenciais e
  /// autentica no Firebase. O [AuthGate] detecta a mudança automaticamente
  /// e redireciona para o Dashboard.
  Future<void> logarComGoogle() async {
    _setCarregando(true);
    _erro = null;

    try {
      // Abre o seletor de conta do Google
      final contaGoogle = await _googleSignIn.signIn();

      // Usuário cancelou o fluxo
      if (contaGoogle == null) {
        _setCarregando(false);
        return;
      }

      // Obtém as credenciais de autenticação
      final autenticacao = await contaGoogle.authentication;
      final credencial = GoogleAuthProvider.credential(
        accessToken: autenticacao.accessToken,
        idToken: autenticacao.idToken,
      );

      // Autentica no Firebase com as credenciais do Google
      await _auth.signInWithCredential(credencial);
    } on FirebaseAuthException catch (e) {
      _erro = _traduzirErroFirebase(e.code);
    } catch (e) {
      _erro = 'Não foi possível fazer login. Tente novamente.';
    } finally {
      _setCarregando(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Encerra a sessão do usuário no Firebase e no Google.
  Future<void> sair() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      _erro = 'Erro ao sair. Tente novamente.';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Utilitários privados
  // ---------------------------------------------------------------------------

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  /// Traduz códigos de erro do Firebase para mensagens em português.
  String _traduzirErroFirebase(String codigo) {
    switch (codigo) {
      case 'account-exists-with-different-credential':
        return 'Esta conta já existe com outro método de login.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      default:
        return 'Erro ao fazer login. Tente novamente.';
    }
  }
}
