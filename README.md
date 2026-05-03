# FinZen 💰

> 72% dos brasileiros não controlam os próprios gastos. Não é falta de vontade — é falta de praticidade.

Todos os apps de finanças falham pelo mesmo motivo: exigem digitação manual de cada gasto. Ninguém mantém isso por mais de duas semanas.

**O FinZen resolve com uma foto.**

Fotografe o comprovante → a IA extrai valor, descrição e categoria automaticamente → o gasto está salvo. Sem digitar nada. E quando quiser entender seus gastos, é só perguntar para o assistente de chat.

> 🚧 Projeto pessoal em desenvolvimento ativo. Primeiro commit em maio/2026. Acompanhe o progresso pelo histórico de commits e pelo roadmap abaixo.

---

## Por que estou construindo isso

Estou montando meu portfólio para conseguir minha primeira vaga em desenvolvimento de software. Escolhi esse projeto porque a dor é real — eu mesmo não consigo manter controle financeiro em apps que exigem digitação manual.

A solução que quero construir elimina esse atrito: você fotografa o comprovante do PIX, da nota fiscal ou do boleto e a IA faz o resto. Um assistente de chat responde perguntas como "quanto gastei com alimentação essa semana?" usando os dados reais do seu histórico.

---

## O que vai fazer (funcionalidades planejadas)

- 📸 **Scan inteligente** — fotografa comprovante, OCR extrai o texto, Claude API estrutura os dados (valor, categoria, data, estabelecimento)
- 💬 **Chat financeiro** — assistente com contexto real dos seus gastos responde em linguagem natural
- 📊 **Dashboard** — gráficos de gastos por categoria e evolução mensal
- 🔐 **Login com Google** — autenticação via Firebase Auth, dados isolados por usuário

---

## Arquitetura

```
Flutter App (Mobile)
    │
    ├── Câmera → ML Kit OCR (no dispositivo, sem internet)
    │                │
    │                ▼
    │           Claude API ← extração estruturada dos dados
    │                │
    │                ▼
    └── Firebase Firestore ← armazenamento por usuário
```

**Decisões de design:**

- **ML Kit (on-device)** em vez de OCR na nuvem — o texto do comprovante nunca sai do dispositivo antes de chegar ao Claude. Privacidade por padrão.
- **Claude API** em vez de GPT — melhor desempenho em português brasileiro, especialmente para extrair dados financeiros de notas fiscais com formatação irregular.
- **Firebase** em vez de backend próprio — para um projeto solo com foco em mobile, manter um servidor próprio adicionaria complexidade sem benefício real nessa fase.
- **Provider** em vez de Bloc/Riverpod — suficiente para o escopo atual. Posso migrar para Riverpod se a complexidade de estado crescer.
- **Claude via proxy (Cloud Functions)** em produção — a chave da API nunca fica no app compilado. Em desenvolvimento usa `.env` local.

---

## Stack

| Camada | Tecnologia | Por quê |
|--------|-----------|---------|
| Mobile | Flutter 3.x | Cross-platform, uma codebase para Android e iOS |
| IA / LLM | Claude API (Anthropic) | Melhor extração de dados em português |
| OCR | Google ML Kit | On-device, sem latência de rede |
| Backend | Firebase Auth + Firestore | Zero infraestrutura para manter |
| Estado | Provider | Simples e suficiente para o escopo atual |
| Gráficos | fl_chart | Biblioteca Flutter nativa, sem WebView |

---

## Estrutura do projeto

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # MaterialApp + rotas
├── core/
│   ├── constants/
│   │   └── app_colors.dart      # Paleta de cores
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

---

## Como rodar localmente

**Pré-requisitos:** Flutter SDK >= 3.0.0, conta no [Firebase Console](https://console.firebase.google.com/), chave de API do [Claude (Anthropic)](https://console.anthropic.com/).

```bash
# 1. Clone o repositório
git clone https://github.com/jonasferreira-silva1/finzen.git
cd finzen

# 2. Configure as variáveis de ambiente
cp .env.example .env
# Edite o .env e adicione sua CLAUDE_API_KEY

# 3. Configure o Firebase
# - Crie um projeto no Firebase Console
# - Ative Authentication (Google) e Firestore
# - Baixe google-services.json → android/app/
# - Baixe GoogleService-Info.plist → ios/Runner/

# 4. Instale as dependências
flutter pub get

# 5. Rode o app
flutter run
```

---

## Segurança

- A chave do Claude fica no `.env` apenas em desenvolvimento local
- Em produção, o acesso à API passa por um proxy via Firebase Cloud Functions — a chave nunca fica no app compilado
- As regras do Firestore garantem que cada usuário acessa apenas seus próprios dados
- O OCR roda inteiramente no dispositivo — o texto do comprovante não é enviado para nenhum servidor antes da extração

---

## Roadmap

**Em desenvolvimento**
- [ ] Autenticação com Google (Firebase Auth)
- [ ] Scan de comprovante com ML Kit + Claude API
- [ ] Salvar transações no Firestore

**Próximas etapas**
- [ ] Chat financeiro com histórico de contexto
- [ ] Dashboard com gráficos (fl_chart)
- [ ] Alertas de meta por categoria
- [ ] Publicar na Play Store (acesso antecipado)

**Futuro**
- [ ] Suporte a extratos em PDF
- [ ] Export de relatório mensal em CSV
- [ ] Widget na tela inicial com resumo do mês

---

## Autor

Projeto pessoal desenvolvido por **Jonas Ferreira da Silva** como parte do meu portfólio de desenvolvimento de software.

- GitHub: [@jonasferreira-silva1](https://github.com/jonasferreira-silva1)
- LinkedIn: [jonas-silva01](https://www.linkedin.com/in/jonas-silva01/)

Se quiser trocar ideia sobre o projeto ou tiver sugestões, abre uma issue ou me manda uma mensagem no LinkedIn.

---

## Licença

MIT — veja [LICENSE](LICENSE).
