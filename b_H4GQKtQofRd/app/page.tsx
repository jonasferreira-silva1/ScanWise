'use client'

import { Navigation } from '@/components/navigation'
import { StatsCards } from '@/components/stats-cards'
import { ExpenseChart } from '@/components/expense-chart'
import { TransactionList } from '@/components/transaction-list'
import { mockTransactions, getMonthlyData, getCategoryTotals } from '@/lib/mock-data'
import { Camera, Wallet } from 'lucide-react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function DashboardPage() {
  const monthlyData = getMonthlyData(mockTransactions)
  const categoryTotals = getCategoryTotals(mockTransactions)

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <Navigation />
      
      <main className="flex-1 pb-24 md:pb-0">
        {/* Header */}
        <header className="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur-sm">
          <div className="flex items-center justify-between px-4 py-4 md:px-6">
            <div className="flex items-center gap-3 md:hidden">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary">
                <Wallet className="h-5 w-5 text-primary-foreground" />
              </div>
              <div>
                <h1 className="text-lg font-bold text-foreground">FinZen</h1>
                <p className="text-xs text-muted-foreground">Maio 2026</p>
              </div>
            </div>
            <div className="hidden md:block">
              <h1 className="text-2xl font-bold text-foreground">Dashboard</h1>
              <p className="text-sm text-muted-foreground">Visão geral das suas finanças</p>
            </div>
            <Link href="/scan">
              <Button size="sm" className="gap-2">
                <Camera className="h-4 w-4" />
                <span className="hidden sm:inline">Novo Gasto</span>
              </Button>
            </Link>
          </div>
        </header>

        {/* Content */}
        <div className="space-y-4 p-4 md:space-y-6 md:p-6">
          <StatsCards
            totalIncome={monthlyData.totalIncome}
            totalExpenses={monthlyData.totalExpenses}
            transactionCount={monthlyData.transactionCount}
          />

          <div className="grid gap-4 md:grid-cols-2 md:gap-6">
            <ExpenseChart data={categoryTotals} />
            <TransactionList transactions={mockTransactions} />
          </div>
        </div>
      </main>
    </div>
  )
}
