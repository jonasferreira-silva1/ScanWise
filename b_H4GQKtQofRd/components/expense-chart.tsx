'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts'
import { CATEGORY_LABELS, TransactionCategory } from '@/lib/types'

interface ExpenseChartProps {
  data: { category: string; total: number }[]
}

const COLORS = [
  'hsl(160, 84%, 39%)',
  'hsl(199, 89%, 48%)',
  'hsl(280, 67%, 51%)',
  'hsl(45, 93%, 47%)',
  'hsl(12, 76%, 61%)',
]

export function ExpenseChart({ data }: ExpenseChartProps) {
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value)
  }

  const chartData = data.map(item => ({
    ...item,
    name: CATEGORY_LABELS[item.category as TransactionCategory] || item.category,
  }))

  const total = data.reduce((sum, item) => sum + item.total, 0)

  return (
    <Card className="border-0 bg-card shadow-sm">
      <CardHeader className="pb-2">
        <CardTitle className="text-base font-semibold">Gastos por Categoria</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={chartData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={80}
                paddingAngle={5}
                dataKey="total"
              >
                {chartData.map((_, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip
                formatter={(value: number) => formatCurrency(value)}
                contentStyle={{
                  backgroundColor: 'hsl(var(--card))',
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px',
                }}
              />
              <Legend
                layout="vertical"
                verticalAlign="middle"
                align="right"
                formatter={(value) => (
                  <span className="text-sm text-foreground">{value}</span>
                )}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
        <div className="mt-4 text-center">
          <p className="text-sm text-muted-foreground">Total de despesas</p>
          <p className="text-2xl font-bold text-foreground">{formatCurrency(total)}</p>
        </div>
      </CardContent>
    </Card>
  )
}
