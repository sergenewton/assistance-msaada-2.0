import React, { Component, ErrorInfo, ReactNode } from 'react'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
          <div className="max-w-md w-full bg-white dark:bg-gray-800 shadow-lg rounded-lg p-8">
            <div className="text-center">
              <div className="text-red-500 text-6xl mb-4">⚠️</div>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                Oups ! Une erreur est survenue
              </h1>
              <p className="text-gray-600 dark:text-gray-400 mb-6">
                Nous nous excusons pour le dérangement. Une erreur inattendue s'est produite.
              </p>
              <div className="space-y-4">
                <button
                  onClick={() => window.location.reload()}
                  className="w-full bg-purple-600 hover:bg-purple-700 text-white font-medium py-2 px-4 rounded-lg transition-colors"
                >
                  Recharger la page
                </button>
                <button
                  onClick={() => this.setState({ hasError: false })}
                  className="w-full bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-900 dark:text-white font-medium py-2 px-4 rounded-lg transition-colors"
                >
                  Réessayer
                </button>
              </div>
              {process.env.NODE_ENV === 'development' && this.state.error && (
                <details className="mt-6 text-left">
                  <summary className="cursor-pointer text-sm text-gray-500 dark:text-gray-400 mb-2">
                    Détails techniques
                  </summary>
                  <pre className="text-xs text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/20 p-4 rounded overflow-auto">
                    {this.state.error.stack}
                  </pre>
                </details>
              )}
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}