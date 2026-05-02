'use client'

import { useState, useRef, useEffect } from 'react'
import { Navigation } from '@/components/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { 
  Send, 
  ArrowLeft,
  Bot,
  User,
  Sparkles
} from 'lucide-react'
import Link from 'next/link'
import { ChatMessage } from '@/lib/types'
import { mockChatMessages } from '@/lib/mock-data'
import { cn } from '@/lib/utils'

const SUGGESTED_QUESTIONS = [
  'Quanto gastei esse mês?',
  'Qual minha maior despesa?',
  'Como estou economizando?',
  'Gastos com alimentação',
]

export default function ChatPage() {
  const [messages, setMessages] = useState<ChatMessage[]>(mockChatMessages)
  const [inputValue, setInputValue] = useState('')
  const [isTyping, setIsTyping] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const generateResponse = (question: string): string => {
    const lowerQuestion = question.toLowerCase()
    
    if (lowerQuestion.includes('gastei') || lowerQuestion.includes('despesa')) {
      return 'Este mês você gastou R$ 2.193,90 no total. Suas maiores categorias de gastos foram:\n\n• Moradia: R$ 1.680,00 (77%)\n• Alimentação: R$ 332,50 (15%)\n• Lazer: R$ 61,80 (3%)\n\nSeu gasto está 8% menor que o mês passado. Continue assim!'
    }
    
    if (lowerQuestion.includes('economiz') || lowerQuestion.includes('economia')) {
      return 'Com base nos seus dados, você está economizando aproximadamente 58% da sua renda mensal - isso é excelente! 🎯\n\nDica: considere investir parte dessa economia em renda fixa para fazer seu dinheiro render.'
    }
    
    if (lowerQuestion.includes('alimenta')) {
      return 'Seus gastos com alimentação este mês:\n\n• Supermercado Extra: R$ 287,50\n• iFood - Almoço: R$ 45,00\n\nTotal: R$ 332,50\n\nIsso representa 15% das suas despesas. A média brasileira é 20%, então você está bem!'
    }
    
    if (lowerQuestion.includes('maior')) {
      return 'Sua maior despesa este mês foi o Aluguel, no valor de R$ 1.500,00. Seguido pela Conta de Luz de R$ 180,00.\n\nDespesas fixas representam 77% dos seus gastos totais.'
    }
    
    return 'Analisando seus dados financeiros... Com base no seu histórico, posso ver que você tem um bom controle dos gastos. Quer que eu detalhe alguma categoria específica ou sugira formas de economizar mais?'
  }

  const handleSend = (text?: string) => {
    const messageText = text || inputValue.trim()
    if (!messageText) return

    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: messageText,
      timestamp: new Date().toISOString(),
    }

    setMessages(prev => [...prev, userMessage])
    setInputValue('')
    setIsTyping(true)

    // Simulate AI response
    setTimeout(() => {
      const assistantMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: generateResponse(messageText),
        timestamp: new Date().toISOString(),
      }
      setMessages(prev => [...prev, assistantMessage])
      setIsTyping(false)
    }, 1500)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <Navigation />
      
      <main className="flex flex-1 flex-col pb-24 md:pb-0">
        {/* Header */}
        <header className="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur-sm">
          <div className="flex items-center gap-4 px-4 py-4 md:px-6">
            <Link href="/" className="md:hidden">
              <Button variant="ghost" size="icon">
                <ArrowLeft className="h-5 w-5" />
              </Button>
            </Link>
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary">
                <Sparkles className="h-5 w-5 text-primary-foreground" />
              </div>
              <div>
                <h1 className="text-lg font-semibold text-foreground">Assistente FinZen</h1>
                <p className="text-xs text-muted-foreground">Pergunte sobre suas finanças</p>
              </div>
            </div>
          </div>
        </header>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 md:p-6">
          <div className="mx-auto max-w-2xl space-y-4">
            {messages.map((message) => (
              <div
                key={message.id}
                className={cn(
                  'flex gap-3',
                  message.role === 'user' ? 'flex-row-reverse' : 'flex-row'
                )}
              >
                <div className={cn(
                  'flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full',
                  message.role === 'user' 
                    ? 'bg-foreground' 
                    : 'bg-primary'
                )}>
                  {message.role === 'user' ? (
                    <User className="h-4 w-4 text-background" />
                  ) : (
                    <Bot className="h-4 w-4 text-primary-foreground" />
                  )}
                </div>
                <div className={cn(
                  'rounded-2xl px-4 py-3 max-w-[80%]',
                  message.role === 'user'
                    ? 'bg-foreground text-background'
                    : 'bg-card border border-border'
                )}>
                  <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                </div>
              </div>
            ))}

            {isTyping && (
              <div className="flex gap-3">
                <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-primary">
                  <Bot className="h-4 w-4 text-primary-foreground" />
                </div>
                <div className="rounded-2xl bg-card border border-border px-4 py-3">
                  <div className="flex gap-1">
                    <span className="h-2 w-2 rounded-full bg-muted-foreground animate-bounce" style={{ animationDelay: '0ms' }} />
                    <span className="h-2 w-2 rounded-full bg-muted-foreground animate-bounce" style={{ animationDelay: '150ms' }} />
                    <span className="h-2 w-2 rounded-full bg-muted-foreground animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </div>
            )}

            <div ref={messagesEndRef} />
          </div>
        </div>

        {/* Suggested Questions */}
        {messages.length === 1 && (
          <div className="px-4 pb-2 md:px-6">
            <div className="mx-auto max-w-2xl">
              <p className="text-xs text-muted-foreground mb-2">Sugestões:</p>
              <div className="flex flex-wrap gap-2">
                {SUGGESTED_QUESTIONS.map((question) => (
                  <Button
                    key={question}
                    variant="outline"
                    size="sm"
                    className="text-xs"
                    onClick={() => handleSend(question)}
                  >
                    {question}
                  </Button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Input */}
        <div className="border-t border-border bg-background p-4 md:p-6">
          <div className="mx-auto max-w-2xl">
            <div className="flex gap-2">
              <Input
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Pergunte sobre seus gastos..."
                className="flex-1"
              />
              <Button 
                size="icon" 
                onClick={() => handleSend()}
                disabled={!inputValue.trim() || isTyping}
              >
                <Send className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
