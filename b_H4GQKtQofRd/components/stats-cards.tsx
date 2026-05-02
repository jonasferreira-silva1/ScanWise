'use client'

import { Card, CardContent } from '@/components/ui/card'
import { TrendingUp, TrendingDown, Wallet, ArrowUpRight, ArrowDownRight } from 'lucide-react'
import { cn } from '@/lib/utils'

interface StatsCardsProps {
  totalIncome: number
  totalExpenses: number
  transactionCount: number
}

export function StatsCards({ totalIncome, totalExpenses, transactionCount }: StatsCardsProps) {
  const balance = totalIncome - totalExpenses
  const savingsRate = totalIncome > 0 ? ((balance / totalIncome) * 100).toFixed(0) : '0'

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value)
  }

  return (
    <div className="grid grid-cols-2 gap-3 md:grid-cols-4 md:gap-4">
      <Card className="border-0 bg-card shadow-sm">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
              <Wallet className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Saldo</p>
              <p className={cn(
                'text-lg font-bold',
                balance >= 0 ? 'text-primary' : 'text-destructive'
              )}>
                {formatCurrency(balance)}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border-0 bg-card shadow-sm">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-emerald-500/10">
              <ArrowUpRight className="h-5 w-5 text-emerald-500" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Receitas</p>
              <p className="text-lg font-bold text-foreground">
                {formatCurrency(totalIncome)}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border-0 bg-card shadow-sm">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-rose-500/10">
              <ArrowDownRight className="h-5 w-5 text-rose-500" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Despesas</p>
              <p className="text-lg font-bold text-foreground">
                {formatCurrency(totalExpenses)}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border-0 bg-card shadow-sm">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-500/10">
              {Number(savingsRate) >= 0 ? (
                <TrendingUp className="h-5 w-5 text-blue-500" />
              ) : (
                <TrendingDown className="h-5 w-5 text-rose-500" />
              )}
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Economia</p>
              <p className="text-lg font-bold text-foreground">
                {savingsRate}%
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
