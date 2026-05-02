'use client'

import { useState, useRef } from 'react'
import { Navigation } from '@/components/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { 
  Camera, 
  Upload, 
  FileImage, 
  Loader2, 
  CheckCircle2,
  ArrowLeft,
  Sparkles
} from 'lucide-react'
import Link from 'next/link'
import { CATEGORY_LABELS, TransactionCategory } from '@/lib/types'

type ScanState = 'idle' | 'uploading' | 'processing' | 'success'

interface ExtractedData {
  description: string
  amount: number
  category: TransactionCategory
  establishment: string
}

export default function ScanPage() {
  const [scanState, setScanState] = useState<ScanState>('idle')
  const [selectedImage, setSelectedImage] = useState<string | null>(null)
  const [extractedData, setExtractedData] = useState<ExtractedData | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = () => {
        setSelectedImage(reader.result as string)
        processImage()
      }
      reader.readAsDataURL(file)
    }
  }

  const processImage = () => {
    setScanState('uploading')
    
    // Simulate OCR + AI processing
    setTimeout(() => {
      setScanState('processing')
      
      setTimeout(() => {
        setExtractedData({
          description: 'Supermercado Extra',
          amount: 156.90,
          category: 'alimentacao',
          establishment: 'Extra Hipermercados',
        })
        setScanState('success')
      }, 2000)
    }, 1000)
  }

  const handleSave = () => {
    // In a real app, this would save to Firebase
    alert('Transação salva com sucesso!')
    setScanState('idle')
    setSelectedImage(null)
    setExtractedData(null)
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value)
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
            <div>
              <h1 className="text-xl font-bold text-foreground md:text-2xl">Scan de Comprovante</h1>
              <p className="text-sm text-muted-foreground">Fotografe ou envie uma imagem</p>
            </div>
          </div>
        </header>

        {/* Content */}
        <div className="p-4 md:p-6">
          {scanState === 'idle' && !selectedImage && (
            <div className="mx-auto max-w-lg space-y-4">
              {/* Upload Area */}
              <Card 
                className="border-2 border-dashed border-border bg-card cursor-pointer transition-colors hover:border-primary/50 hover:bg-muted/30"
                onClick={() => fileInputRef.current?.click()}
              >
                <CardContent className="flex flex-col items-center justify-center py-16">
                  <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10 mb-4">
                    <Camera className="h-10 w-10 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold text-foreground mb-2">
                    Envie seu comprovante
                  </h3>
                  <p className="text-sm text-muted-foreground text-center max-w-xs">
                    PIX, nota fiscal, boleto ou qualquer comprovante de pagamento
                  </p>
                  <Input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    capture="environment"
                    className="hidden"
                    onChange={handleFileSelect}
                  />
                </CardContent>
              </Card>

              {/* Quick Actions */}
              <div className="grid grid-cols-2 gap-3">
                <Button 
                  variant="outline" 
                  className="h-auto flex-col gap-2 py-4"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Upload className="h-5 w-5" />
                  <span className="text-sm">Galeria</span>
                </Button>
                <Button 
                  variant="outline" 
                  className="h-auto flex-col gap-2 py-4"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <FileImage className="h-5 w-5" />
                  <span className="text-sm">Documento</span>
                </Button>
              </div>

              {/* Info */}
              <Card className="border-0 bg-primary/5">
                <CardContent className="flex items-start gap-3 p-4">
                  <Sparkles className="h-5 w-5 text-primary flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-foreground">IA extrai automaticamente</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      Valor, descrição, categoria e estabelecimento são identificados automaticamente pelo Claude AI
                    </p>
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          {(scanState === 'uploading' || scanState === 'processing') && (
            <div className="mx-auto max-w-lg">
              <Card className="border-0 bg-card shadow-sm">
                <CardContent className="flex flex-col items-center justify-center py-16">
                  <div className="relative mb-6">
                    <div className="flex h-20 w-20 items-center justify-center rounded-full bg-primary/10">
                      <Loader2 className="h-10 w-10 text-primary animate-spin" />
                    </div>
                  </div>
                  <h3 className="text-lg font-semibold text-foreground mb-2">
                    {scanState === 'uploading' ? 'Enviando imagem...' : 'Processando com IA...'}
                  </h3>
                  <p className="text-sm text-muted-foreground text-center">
                    {scanState === 'uploading' 
                      ? 'Extraindo texto com OCR' 
                      : 'Claude AI está identificando os dados'
                    }
                  </p>
                </CardContent>
              </Card>
            </div>
          )}

          {scanState === 'success' && extractedData && (
            <div className="mx-auto max-w-lg space-y-4">
              <Card className="border-0 bg-card shadow-sm">
                <CardHeader className="pb-2">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="h-5 w-5 text-primary" />
                    <CardTitle className="text-base font-semibold">Dados Extraídos</CardTitle>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {selectedImage && (
                    <div className="rounded-lg overflow-hidden bg-muted aspect-video flex items-center justify-center">
                      <img 
                        src={selectedImage} 
                        alt="Comprovante" 
                        className="max-h-full max-w-full object-contain"
                      />
                    </div>
                  )}
                  
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-2 border-b border-border">
                      <span className="text-sm text-muted-foreground">Valor</span>
                      <span className="text-lg font-bold text-foreground">
                        {formatCurrency(extractedData.amount)}
                      </span>
                    </div>
                    <div className="flex justify-between items-center py-2 border-b border-border">
                      <span className="text-sm text-muted-foreground">Descrição</span>
                      <span className="text-sm font-medium text-foreground">
                        {extractedData.description}
                      </span>
                    </div>
                    <div className="flex justify-between items-center py-2 border-b border-border">
                      <span className="text-sm text-muted-foreground">Categoria</span>
                      <span className="text-sm font-medium text-primary">
                        {CATEGORY_LABELS[extractedData.category]}
                      </span>
                    </div>
                    <div className="flex justify-between items-center py-2">
                      <span className="text-sm text-muted-foreground">Estabelecimento</span>
                      <span className="text-sm font-medium text-foreground">
                        {extractedData.establishment}
                      </span>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <div className="flex gap-3">
                <Button 
                  variant="outline" 
                  className="flex-1"
                  onClick={() => {
                    setScanState('idle')
                    setSelectedImage(null)
                    setExtractedData(null)
                  }}
                >
                  Cancelar
                </Button>
                <Button className="flex-1" onClick={handleSave}>
                  Salvar Transação
                </Button>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
