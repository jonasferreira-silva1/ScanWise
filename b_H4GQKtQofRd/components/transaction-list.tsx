'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Transaction, CATEGORY_LABELS, TransactionCategory } from '@/lib/types'
import { cn } from '@/lib/utils'
import { 
  Utensils, 
  Car, 
  Gamepad2, 
  Heart, 
  GraduationCap, 
  Home, 
  MoreHorizontal,
  Wallet,
  TrendingUp,
  ArrowUpRight,
  ArrowDownRight
} from 'lucide-react'

interface TransactionListProps {
  transactions: Transaction[]
}

const CATEGORY_ICONS: Record<TransactionCategory, typeof Utensils> = {
  alimentacao: Utensils,
  transporte: Car,
  lazer: Gamepad2,
  saude: Heart,
  educacao: GraduationCap,
  moradia: Home,
  outros: MoreHorizontal,
  salario: Wallet,
  investimentos: TrendingUp,
}

export function TransactionList({ transactions }: TransactionListProps) {
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value)
  }

  const formatDate = (dateString: string) => {
    const months = ['jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.']
    const [year, month, day] = dateString.split('-').map(Number)
    return `${day.toString().padStart(2, '0')} de ${months[month - 1]}`
  }

  return (
    <Card className="border-0 bg-card shadow-sm">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-base font-semibold">Transações Recentes</CardTitle>
        <span className="text-sm text-muted-foreground">
          {transactions.length} itens
        </span>
      </CardHeader>
      <CardContent className="p-0">
        <div className="divide-y divide-border">
          {transactions.slice(0, 6).map((transaction) => {
            const Icon = CATEGORY_ICONS[transaction.category] || MoreHorizontal
            const isIncome = transaction.type === 'income'
            
            return (
              <div
                key={transaction.id}
                className="flex items-center gap-4 px-6 py-4 transition-colors hover:bg-muted/50"
              >
                <div className={cn(
                  'flex h-10 w-10 items-center justify-center rounded-lg',
                  isIncome ? 'bg-emerald-500/10' : 'bg-muted'
                )}>
                  <Icon className={cn(
                    'h-5 w-5',
                    isIncome ? 'text-emerald-500' : 'text-muted-foreground'
                  )} />
                </div>
                
                <div className="flex-1 min-w-0">
                  <p className="truncate text-sm font-medium text-foreground">
                    {transaction.description}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {CATEGORY_LABELS[transaction.category]} • {formatDate(transaction.date)}
                  </p>
                </div>
                
                <div className="flex items-center gap-1">
                  {isIncome ? (
                    <ArrowUpRight className="h-4 w-4 text-emerald-500" />
                  ) : (
                    <ArrowDownRight className="h-4 w-4 text-rose-500" />
                  )}
                  <span className={cn(
                    'text-sm font-semibold',
                    isIncome ? 'text-emerald-500' : 'text-foreground'
                  )}>
                    {isIncome ? '+' : '-'}{formatCurrency(transaction.amount)}
                  </span>
                </div>
              </div>
            )
          })}
        </div>
      </CardContent>
    </Card>
  )
}
