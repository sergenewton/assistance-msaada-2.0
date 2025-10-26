import React, { useState, useEffect } from 'react'
import { cn } from '@/utils/cn'
import { X } from 'lucide-react'

interface ToastProps {
  message?: string
  type?: 'success' | 'error' | 'warning' | 'info'
  duration?: number
  onClose?: () => void
}

export const Toast: React.FC<ToastProps> = ({ 
  message, 
  type = 'info',
  duration = 5000,
  onClose 
}) => {
  const [isVisible, setIsVisible] = useState(!!message)

  useEffect(() => {
    if (message) {
      setIsVisible(true)
      const timer = setTimeout(() => {
        setIsVisible(false)
        onClose?.()
      }, duration)

      return () => clearTimeout(timer)
    }
  }, [message, duration, onClose])

  if (!message || !isVisible) return null

  const typeStyles = {
    success: 'bg-green-50 border-green-200 text-green-800',
    error: 'bg-red-50 border-red-200 text-red-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    info: 'bg-blue-50 border-blue-200 text-blue-800'
  }

  const handleClose = () => {
    setIsVisible(false)
    onClose?.()
  }

  return (
    <div className="fixed top-4 right-4 z-50">
      <div className={cn(
        'border rounded-lg p-4 shadow-lg flex items-center justify-between min-w-80 max-w-sm',
        typeStyles[type]
      )}>
        <p className="text-sm font-medium pr-8">{message}</p>
        <button
          onClick={handleClose}
          className="flex-shrink-0 ml-2 p-1 rounded-full hover:bg-black hover:bg-opacity-10 transition-colors"
        >
          <X size={16} />
        </button>
      </div>
    </div>
  )
}