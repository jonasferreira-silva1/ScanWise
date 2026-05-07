# Testes — FinZen

Documentação da estratégia de testes adotada no projeto.

## Filosofia

Testamos a **lógica de negócio** — cálculos financeiros, serialização de dados, parsing de respostas da API e tradução de erros. Não testamos widgets do Flutter ou chamadas reais ao Firebase/Claude, pois isso exigiria mocks complexos e infraestrutura de CI com emuladores.

O objetivo é garantir que as partes críticas do app funcionem corretamente e que regressões sejam detectadas rapidamente.

---

## Como rodar os testes

```bash
# Rodar todos os testes
flutter test

# Rodar com cobertura
flutter test --coverage

# Rodar um arquivo específico
flutter test test/models/transaction_test.dart

# Rodar com output detalhado
flutter test --reporter expanded
```

---

## Estrutura dos testes

```
test/
├── models/
│   ├── transaction_test.dart      # Serialização e copyWith
│   └── chat_message_test.dart     # Criação e timestamp
├── features/
│   ├── dashboard/
│   │   └── dashboard_controller_test.dart  # Cálculos financeiros
│   └── auth/
│       └── auth_controller_test.dart       # Tradução de erros
└── core/
    └── services/
        └── claude_service_test.dart        # Parsing de resposta da API
```

---

## Cobertura por módulo

### `Transaction` (models/transaction_test.dart)
| Cenário | Resultado |
|---------|-----------|
| `toMap()` converte todos os campos | ✅ |
| `toMap()` serializa data em ISO 8601 | ✅ |
| `fromMap()` reconstrói a transação | ✅ |
| `fromMap()` converte int para double | ✅ |
| Ida e volta `toMap → fromMap` | ✅ |
| `copyWith()` altera campo específico | ✅ |
| `copyWith()` não modifica original | ✅ |

### `ChatMessage` (models/chat_message_test.dart)
| Cenário | Resultado |
|---------|-----------|
| Cria mensagem do usuário | ✅ |
| Cria mensagem do assistente | ✅ |
| Timestamp automático | ✅ |
| Timestamp personalizado preservado | ✅ |

### `DashboardController` (features/dashboard/dashboard_controller_test.dart)
| Cenário | Resultado |
|---------|-----------|
| `formatarMoeda()` valor simples | ✅ |
| `formatarMoeda()` com milhar | ✅ |
| `formatarMoeda()` zero | ✅ |
| `formatarMoeda()` valor grande | ✅ |
| Estado inicial correto | ✅ |
| Soma de transações | ✅ |
| Agrupamento por categoria | ✅ |
| Ordenação maior → menor | ✅ |
| Limite de 6 transações recentes | ✅ |

### `ClaudeService` (core/services/claude_service_test.dart)
| Cenário | Resultado |
|---------|-----------|
| Parseia JSON limpo | ✅ |
| Remove markdown ` ```json ` | ✅ |
| Remove markdown ` ``` ` simples | ✅ |
| Converte int para double | ✅ |
| Trata data null sem erro | ✅ |
| Parseia data válida | ✅ |
| Valida categorias aceitas | ✅ |
| Estrutura do corpo da requisição | ✅ |

### `AuthController` (features/auth/auth_controller_test.dart)
| Cenário | Resultado |
|---------|-----------|
| Traduz `account-exists-with-different-credential` | ✅ |
| Traduz `network-request-failed` | ✅ |
| Traduz `user-disabled` | ✅ |
| Mensagem genérica para código desconhecido | ✅ |
| Todos os erros conhecidos têm mensagem específica | ✅ |

---

## O que não é testado (e por quê)

| Módulo | Motivo |
|--------|--------|
| Chamadas reais à Claude API | Exige chave de API e conexão — não adequado para CI |
| Firebase Auth / Firestore | Exige emulador Firebase ou mock complexo |
| Widgets Flutter | Cobertura de UI é feita por testes manuais no dispositivo |
| OCR (ML Kit) | Roda on-device, não disponível em ambiente de teste headless |

---

## Próximos passos (melhorias futuras)

- [ ] Adicionar mocks do Firebase com `fake_cloud_firestore`
- [ ] Widget tests para `StatsCards` e `TransactionList`
- [ ] Integration test do fluxo Scan → Dashboard
- [ ] Configurar GitHub Actions para rodar testes no CI a cada push
