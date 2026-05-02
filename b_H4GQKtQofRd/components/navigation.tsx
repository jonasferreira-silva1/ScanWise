'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import { 
  LayoutDashboard, 
  Camera, 
  MessageCircle, 
  User,
  Wallet
} from 'lucide-react'

const navItems = [
  { href: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { href: '/scan', icon: Camera, label: 'Scan' },
  { href: '/chat', icon: MessageCircle, label: 'Chat' },
  { href: '/login', icon: User, label: 'Perfil' },
]

export function Navigation() {
  const pathname = usePathname()

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-card/95 backdrop-blur-sm md:relative md:border-t-0 md:border-r md:h-screen md:w-20 md:flex-shrink-0">
      <div className="flex items-center justify-around px-2 py-3 md:flex-col md:justify-start md:gap-4 md:px-3 md:py-6">
        {/* Logo for desktop */}
        <div className="hidden md:flex md:flex-col md:items-center md:mb-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary">
            <Wallet className="h-6 w-6 text-primary-foreground" />
          </div>
          <span className="mt-2 text-xs font-semibold text-foreground">FinZen</span>
        </div>
        
        {navItems.map((item) => {
          const isActive = pathname === item.href
          const Icon = item.icon
          
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex flex-col items-center gap-1 rounded-lg px-4 py-2 transition-colors md:px-3 md:py-3',
                isActive
                  ? 'text-primary'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <div
                className={cn(
                  'flex h-10 w-10 items-center justify-center rounded-xl transition-colors',
                  isActive
                    ? 'bg-primary/10'
                    : 'hover:bg-muted'
                )}
              >
                <Icon className="h-5 w-5" />
              </div>
              <span className="text-[10px] font-medium md:text-xs">{item.label}</span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
