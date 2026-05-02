export interface Transaction {
  id: string
  description: string
  amount: number
  category: TransactionCategory
  date: string
  establishment?: string
  type: 'income' | 'expense'
}

export type TransactionCategory = 
  | 'alimentacao'
  | 'transporte'
  | 'lazer'
  | 'saude'
  | 'educacao'
  | 'moradia'
  | 'outros'
  | 'salario'
  | 'investimentos'

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: string
}

export interface User {
  id: string
  name: string
  email: string
  avatar?: string
}

export const CATEGORY_LABELS: Record<TransactionCategory, string> = {
  alimentacao: 'Alimentação',
  transporte: 'Transporte',
  lazer: 'Lazer',
  saude: 'Saúde',
  educacao: 'Educação',
  moradia: 'Moradia',
  outros: 'Outros',
  salario: 'Salário',
  investimentos: 'Investimentos',
}

export const CATEGORY_COLORS: Record<TransactionCategory, string> = {
  alimentacao: 'var(--chart-1)',
  transporte: 'var(--chart-2)',
  lazer: 'var(--chart-3)',
  saude: 'var(--chart-4)',
  educacao: 'var(--chart-5)',
  moradia: 'var(--chart-1)',
  outros: 'var(--chart-2)',
  salario: 'var(--success)',
  investimentos: 'var(--chart-3)',
}
