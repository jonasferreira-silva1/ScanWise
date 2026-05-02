import { Transaction, ChatMessage, User } from './types'

export const mockUser: User = {
  id: '1',
  name: 'Jonas Silva',
  email: 'jonas@example.com',
}

export const mockTransactions: Transaction[] = [
  {
    id: '1',
    description: 'Supermercado Extra',
    amount: 287.50,
    category: 'alimentacao',
    date: '2026-05-02',
    establishment: 'Extra Hipermercados',
    type: 'expense',
  },
  {
    id: '2',
    description: 'Uber - Casa para trabalho',
    amount: 23.90,
    category: 'transporte',
    date: '2026-05-02',
    establishment: 'Uber',
    type: 'expense',
  },
  {
    id: '3',
    description: 'Netflix',
    amount: 39.90,
    category: 'lazer',
    date: '2026-05-01',
    establishment: 'Netflix',
    type: 'expense',
  },
  {
    id: '4',
    description: 'Farmácia Drogasil',
    amount: 67.80,
    category: 'saude',
    date: '2026-05-01',
    establishment: 'Drogasil',
    type: 'expense',
  },
  {
    id: '5',
    description: 'Curso Udemy',
    amount: 27.90,
    category: 'educacao',
    date: '2026-04-30',
    establishment: 'Udemy',
    type: 'expense',
  },
  {
    id: '6',
    description: 'Aluguel',
    amount: 1500.00,
    category: 'moradia',
    date: '2026-04-30',
    establishment: 'Imobiliária',
    type: 'expense',
  },
  {
    id: '7',
    description: 'Salário',
    amount: 5200.00,
    category: 'salario',
    date: '2026-04-28',
    establishment: 'Empresa XYZ',
    type: 'income',
  },
  {
    id: '8',
    description: 'iFood - Almoço',
    amount: 45.00,
    category: 'alimentacao',
    date: '2026-04-29',
    establishment: 'iFood',
    type: 'expense',
  },
  {
    id: '9',
    description: 'Conta de Luz',
    amount: 180.00,
    category: 'moradia',
    date: '2026-04-28',
    establishment: 'CPFL',
    type: 'expense',
  },
  {
    id: '10',
    description: 'Spotify',
    amount: 21.90,
    category: 'lazer',
    date: '2026-04-27',
    establishment: 'Spotify',
    type: 'expense',
  },
]

export const mockChatMessages: ChatMessage[] = [
  {
    id: '1',
    role: 'assistant',
    content: 'Olá! Sou seu assistente financeiro do FinZen. Posso ajudar você a entender seus gastos, criar metas e responder perguntas sobre suas finanças. Como posso ajudar hoje?',
    timestamp: '2026-05-02T10:00:00',
  },
]

export function getMonthlyData(transactions: Transaction[]) {
  const expenses = transactions.filter(t => t.type === 'expense')
  const income = transactions.filter(t => t.type === 'income')
  
  return {
    totalExpenses: expenses.reduce((sum, t) => sum + t.amount, 0),
    totalIncome: income.reduce((sum, t) => sum + t.amount, 0),
    transactionCount: transactions.length,
  }
}

export function getCategoryTotals(transactions: Transaction[]) {
  const expenses = transactions.filter(t => t.type === 'expense')
  const totals: Record<string, number> = {}
  
  expenses.forEach(t => {
    totals[t.category] = (totals[t.category] || 0) + t.amount
  })
  
  return Object.entries(totals).map(([category, total]) => ({
    category,
    total,
  }))
}
