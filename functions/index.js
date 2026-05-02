/**
 * Proxy seguro para a API do Claude.
 *
 * Por que usar um proxy?
 * A chave da API do Claude não pode ficar no app mobile — qualquer pessoa
 * com acesso ao APK consegue extraí-la. Esta Cloud Function recebe a
 * requisição do app, verifica a autenticação Firebase e repassa para a
 * Anthropic com a chave guardada no servidor.
 *
 * Como configurar a chave:
 *   firebase functions:config:set claude.key="sk-ant-sua-chave-aqui"
 */

const functions = require('firebase-functions');
const fetch = require('node-fetch');

exports.claudeProxy = functions.https.onCall(async (data, context) => {
  // Rejeita chamadas sem autenticação Firebase
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'É necessário estar autenticado para usar este recurso.',
    );
  }

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // Chave fica no servidor — nunca exposta ao cliente
        'x-api-key': functions.config().claude.key,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(data.payload),
    });

    if (!response.ok) {
      throw new functions.https.HttpsError(
        'internal',
        `Erro na API do Claude: ${response.status}`,
      );
    }

    return response.json();
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
