# FinZen 💰

> Saúde financeira com IA pessoal — fotografe comprovantes e converse com seu dinheiro.

## O que é

FinZen elimina a principal razão pela qual apps de finanças falham: **a digitação manual**.
Você fotografa o comprovante, a IA extrai valor, descrição e categoria automaticamente.
Um assistente de chat responde perguntas sobre seus gastos com contexto real dos seus dados.

## Funcionalidades

- 📸 **Scan de comprovantes** — OCR local (ML Kit) + Claude API para extração estruturada
- 💬 **Chat financeiro** — assistente com contexto dos seus gastos do mês
- 📊 **Dashboard** — gráficos de gastos por categoria e evolução mensal
- 🔐 **Login com Google** — autenticação via Firebase Auth

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Mobile | Flutter 3.x |
| IA / LLM | Claude API (Anthropic) |
| OCR | Google ML Kit (on-device) |
| Backend | Firebase (Auth + Firestore) |
| Estado | Provider |
| Gráficos | fl_chart |

## Estrutura do projeto

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # MaterialApp + rotas
├── core/
│   ├── constants/
│   │   └── app_colors.dart      # Paleta de cores do app
│   └── services/
│       ├── claude_service.dart  # Integração com Claude API
│       ├── ocr_service.dart     # Leitura de texto em imagens
│       └── firebase_service.dart
├── features/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── auth_controller.dart
│   ├── dashboard/
│   │   ├── dashboard_page.dart
│   │   └── dashboard_controller.dart
│   ├── scan/
│   │   ├── scan_page.dart
│   │   └── scan_controller.dart
│   └── chat/
│       ├── chat_page.dart
│       └── chat_controller.dart
└── models/
    ├── transaction.dart
    └── chat_message.dart
```

## Como rodar

### Pré-requisitos

- Flutter SDK >= 3.0.0
- Conta no [Firebase Console](https://console.firebase.google.com/)
- Chave de API do [Claude (Anthropic)](https://console.anthropic.com/)

### Configuração

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/finzen.git
   cd finzen
   ```

2. Configure as variáveis de ambiente:
   ```bash
   cp .env.example .env
   # Edite .env e adicione sua CLAUDE_API_KEY
   ```

3. Configure o Firebase:
   - Crie um projeto no Firebase Console
   - Ative Authentication (Google) e Firestore
   - Baixe o `google-services.json` e coloque em `android/app/`
   - Baixe o `GoogleService-Info.plist` e coloque em `ios/Runner/`

4. Instale as dependências:
   ```bash
   flutter pub get
   ```

5. Rode o app:
   ```bash
   flutter run
   ```

## Segurança

- A chave do Claude fica no `.env` apenas em desenvolvimento
- Em produção, use o proxy via Firebase Cloud Functions (ver `functions/`)
- As regras do Firestore garantem que cada usuário acessa apenas seus próprios dados

## Licença

MIT
