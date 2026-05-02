'use client'

import { useState } from 'react'
import { Navigation } from '@/components/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { 
  ArrowLeft,
  LogOut,
  Settings,
  Shield,
  HelpCircle,
  ChevronRight,
  Wallet,
  User
} from 'lucide-react'
import Link from 'next/link'
import { mockUser } from '@/lib/mock-data'

export default function LoginPage() {
  const [isLoggedIn, setIsLoggedIn] = useState(true)

  const handleLogin = () => {
    // Simulate Google OAuth
    setIsLoggedIn(true)
  }

  const handleLogout = () => {
    setIsLoggedIn(false)
  }

  if (!isLoggedIn) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-background p-4">
        <div className="w-full max-w-sm space-y-8">
          {/* Logo */}
          <div className="flex flex-col items-center">
            <div className="flex h-20 w-20 items-center justify-center rounded-2xl bg-primary mb-4">
              <Wallet className="h-10 w-10 text-primary-foreground" />
            </div>
            <h1 className="text-3xl font-bold text-foreground">FinZen</h1>
            <p className="text-muted-foreground mt-2 text-center">
              Controle financeiro com IA
            </p>
          </div>

          {/* Login Card */}
          <Card className="border-0 shadow-lg">
            <CardHeader className="text-center pb-2">
              <CardTitle className="text-xl">Entrar</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm text-muted-foreground text-center">
                Faça login para sincronizar seus dados e acessar de qualquer dispositivo
              </p>
              
              <Button 
                className="w-full h-12 gap-3" 
                variant="outline"
                onClick={handleLogin}
              >
                <svg className="h-5 w-5" viewBox="0 0 24 24">
                  <path
                    fill="currentColor"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                  />
                  <path
                    fill="currentColor"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                  />
                  <path
                    fill="currentColor"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                  />
                  <path
                    fill="currentColor"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                  />
                </svg>
                Continuar com Google
              </Button>

              <p className="text-xs text-muted-foreground text-center">
                Ao continuar, você concorda com os Termos de Uso e Política de Privacidade
              </p>
            </CardContent>
          </Card>

          {/* Features */}
          <div className="space-y-3 pt-4">
            <div className="flex items-center gap-3 text-sm text-muted-foreground">
              <Shield className="h-4 w-4 text-primary" />
              <span>Seus dados ficam seguros no Firebase</span>
            </div>
            <div className="flex items-center gap-3 text-sm text-muted-foreground">
              <Shield className="h-4 w-4 text-primary" />
              <span>OCR processa tudo no seu dispositivo</span>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <Navigation />
      
      <main className="flex-1 pb-24 md:pb-0">
        {/* Header */}
        <header className="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur-sm">
          <div className="flex items-center gap-4 px-4 py-4 md:px-6">
            <Link href="/" className="md:hidden">
              <Button variant="ghost" size="icon">
                <ArrowLeft className="h-5 w-5" />
              </Button>
            </Link>
            <h1 className="text-xl font-bold text-foreground md:text-2xl">Perfil</h1>
          </div>
        </header>

        {/* Content */}
        <div className="p-4 md:p-6">
          <div className="mx-auto max-w-lg space-y-6">
            {/* Profile Card */}
            <Card className="border-0 bg-card shadow-sm">
              <CardContent className="flex items-center gap-4 p-6">
                <Avatar className="h-16 w-16">
                  <AvatarFallback className="bg-primary text-primary-foreground text-xl">
                    {mockUser.name.split(' ').map(n => n[0]).join('')}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-foreground">{mockUser.name}</h2>
                  <p className="text-sm text-muted-foreground">{mockUser.email}</p>
                </div>
              </CardContent>
            </Card>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-3">
              <Card className="border-0 bg-card shadow-sm">
                <CardContent className="p-4 text-center">
                  <p className="text-2xl font-bold text-primary">10</p>
                  <p className="text-xs text-muted-foreground">Transações</p>
                </CardContent>
              </Card>
              <Card className="border-0 bg-card shadow-sm">
                <CardContent className="p-4 text-center">
                  <p className="text-2xl font-bold text-foreground">5</p>
                  <p className="text-xs text-muted-foreground">Scans</p>
                </CardContent>
              </Card>
              <Card className="border-0 bg-card shadow-sm">
                <CardContent className="p-4 text-center">
                  <p className="text-2xl font-bold text-foreground">1</p>
                  <p className="text-xs text-muted-foreground">Mês</p>
                </CardContent>
              </Card>
            </div>

            {/* Menu */}
            <Card className="border-0 bg-card shadow-sm">
              <CardContent className="p-0 divide-y divide-border">
                <button className="flex w-full items-center justify-between px-4 py-4 hover:bg-muted/50 transition-colors">
                  <div className="flex items-center gap-3">
                    <User className="h-5 w-5 text-muted-foreground" />
                    <span className="text-sm font-medium text-foreground">Editar Perfil</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
                <button className="flex w-full items-center justify-between px-4 py-4 hover:bg-muted/50 transition-colors">
                  <div className="flex items-center gap-3">
                    <Settings className="h-5 w-5 text-muted-foreground" />
                    <span className="text-sm font-medium text-foreground">Configurações</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
                <button className="flex w-full items-center justify-between px-4 py-4 hover:bg-muted/50 transition-colors">
                  <div className="flex items-center gap-3">
                    <Shield className="h-5 w-5 text-muted-foreground" />
                    <span className="text-sm font-medium text-foreground">Privacidade</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
                <button className="flex w-full items-center justify-between px-4 py-4 hover:bg-muted/50 transition-colors">
                  <div className="flex items-center gap-3">
                    <HelpCircle className="h-5 w-5 text-muted-foreground" />
                    <span className="text-sm font-medium text-foreground">Ajuda</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
              </CardContent>
            </Card>

            {/* Logout */}
            <Button 
              variant="outline" 
              className="w-full gap-2 text-destructive hover:text-destructive"
              onClick={handleLogout}
            >
              <LogOut className="h-4 w-4" />
              Sair da conta
            </Button>

            {/* Footer */}
            <div className="text-center pt-4">
              <p className="text-xs text-muted-foreground">
                FinZen v1.0.0 • Desenvolvido por Jonas Silva
              </p>
              <a 
                href="https://github.com/jonasferreira-silva1/finzen" 
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-primary hover:underline"
              >
                GitHub
              </a>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}
