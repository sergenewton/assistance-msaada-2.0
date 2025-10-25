/**
 * Configuration Sentry pour Frontend React
 * Assistance Msaada 2.0 - Surveillance erreurs côté client
 */

import * as Sentry from '@sentry/react';
import { BrowserTracing } from '@sentry/tracing';

interface SentryConfig {
  dsn: string;
  environment: string;
  release?: string;
  sampleRate: number;
  tracesSampleRate: number;
  replaysSessionSampleRate: number;
  replaysOnErrorSampleRate: number;
}

/**
 * Configuration Sentry spécifique VBG
 * ATTENTION: Sanitisation stricte requise pour données sensibles
 */
class VBGSentryConfig {
  private static instance: VBGSentryConfig;
  private config: SentryConfig;

  private constructor() {
    this.config = this.getEnvironmentConfig();
    this.initializeSentry();
  }

  public static getInstance(): VBGSentryConfig {
    if (!VBGSentryConfig.instance) {
      VBGSentryConfig.instance = new VBGSentryConfig();
    }
    return VBGSentryConfig.instance;
  }

  /**
   * Configuration par environnement
   */
  private getEnvironmentConfig(): SentryConfig {
    const environment = import.meta.env.VITE_APP_ENV || 'development';
    
    const baseConfig: SentryConfig = {
      dsn: import.meta.env.VITE_SENTRY_DSN || '',
      environment,
      release: import.meta.env.VITE_APP_VERSION || '1.0.0',
      sampleRate: 1.0,
      tracesSampleRate: 0.1,
      replaysSessionSampleRate: 0.1,
      replaysOnErrorSampleRate: 1.0,
    };

    // Configuration spécifique par environnement
    switch (environment) {
      case 'production':
        return {
          ...baseConfig,
          sampleRate: 0.1, // Réduire la charge en production
          tracesSampleRate: 0.05,
          replaysSessionSampleRate: 0.01, // Très faible en prod pour la vie privée
        };
      
      case 'staging':
        return {
          ...baseConfig,
          sampleRate: 0.5,
          tracesSampleRate: 0.2,
          replaysSessionSampleRate: 0.05,
        };
      
      default: // development
        return baseConfig;
    }
  }

  /**
   * Initialisation Sentry avec configuration VBG
   */
  private initializeSentry(): void {
    if (!this.config.dsn) {
      console.warn('Sentry DSN not configured');
      return;
    }

    Sentry.init({
      dsn: this.config.dsn,
      environment: this.config.environment,
      release: this.config.release,
      
      // Configuration d'échantillonnage
      sampleRate: this.config.sampleRate,
      tracesSampleRate: this.config.tracesSampleRate,

      // Intégrations
      integrations: [
        new BrowserTracing({
          // Traçage des routes React Router
          routingInstrumentation: Sentry.reactRouterV6Instrumentation(
            React.useEffect,
            useLocation,
            useNavigationType,
            createRoutesFromChildren,
            matchRoutes
          ),
          
          // URLs à tracer - Focus sur les endpoints VBG critiques
          tracePropagationTargets: [
            'localhost',
            /^https:\/\/[^/]*\.msaada\.org\/api\/(reports|victims|emergency|auth)/,
          ],
        }),

        // Session Replay avec sanitisation VBG
        new Sentry.Replay({
          maskAllText: true, // CRITIQUE: Masquer tout le texte par défaut pour VBG
          maskAllInputs: true, // CRITIQUE: Masquer toutes les saisies
          blockAllMedia: true, // Bloquer audio/vidéo pour confidentialité
          
          // Sélecteurs spécifiques à masquer (données VBG sensibles)
          mask: [
            '[data-sensitive]',
            '[data-victim-info]',
            '[data-personal]',
            '.victim-details',
            '.medical-info',
            '.incident-description',
            '.contact-info',
            'input[type="password"]',
            'input[name*="victim"]',
            'input[name*="personal"]',
            'textarea[name*="description"]',
          ],
          
          // Bloquer certains éléments complètement
          block: [
            '.confidential',
            '.admin-only',
            '.victim-photo',
            '.medical-documents',
          ],
        }),
      ],

      // Configuration de la capture d'erreurs
      beforeSend: this.sanitizeErrorData.bind(this),
      beforeSendTransaction: this.sanitizeTransactionData.bind(this),

      // Tags globaux pour identification VBG
      initialScope: {
        tags: {
          project: 'assistance-msaada',
          component: 'frontend-react',
          category: 'vbg-platform',
          privacy_level: 'high',
        },
      },

      // Ignorer certaines erreurs communes
      ignoreErrors: [
        // Erreurs réseau communes
        'Network request failed',
        'NetworkError',
        'Failed to fetch',
        
        // Erreurs de navigateur
        'ResizeObserver loop limit exceeded',
        'Non-Error promise rejection captured',
        
        // Erreurs d'extensions navigateur
        /extension\//i,
        /^chrome:\/\//i,
        /^moz-extension:\/\//i,
      ],

      // Réglages session replay
      replaysSessionSampleRate: this.config.replaysSessionSampleRate,
      replaysOnErrorSampleRate: this.config.replaysOnErrorSampleRate,
    });

    // Configurer le contexte utilisateur initial
    this.setupUserContext();
  }

  /**
   * Sanitisation des données d'erreur AVANT envoi à Sentry
   * CRITIQUE pour la protection des données VBG
   */
  private sanitizeErrorData(event: Sentry.Event): Sentry.Event | null {
    // Supprimer les données sensibles des breadcrumbs
    if (event.breadcrumbs) {
      event.breadcrumbs = event.breadcrumbs.map(breadcrumb => {
        if (breadcrumb.data) {
          breadcrumb.data = this.sanitizeObject(breadcrumb.data);
        }
        return breadcrumb;
      });
    }

    // Nettoyer les contextes
    if (event.contexts?.response?.data) {
      event.contexts.response.data = this.sanitizeObject(event.contexts.response.data);
    }

    // Nettoyer les données de requête
    if (event.request?.data) {
      event.request.data = this.sanitizeObject(event.request.data);
    }

    // Supprimer les headers sensibles
    if (event.request?.headers) {
      const { authorization, cookie, 'x-api-key': apiKey, ...safeHeaders } = event.request.headers;
      event.request.headers = safeHeaders;
    }

    // Ajouter le contexte VBG
    event.tags = {
      ...event.tags,
      'data_classification': 'vbg_sensitive',
      'auto_sanitized': 'true',
    };

    return event;
  }

  /**
   * Sanitisation des données de transaction
   */
  private sanitizeTransactionData(event: Sentry.Event): Sentry.Event | null {
    // Marquer les transactions sensibles VBG
    if (event.transaction) {
      const sensitiveRoutes = ['/reports', '/victims', '/medical', '/personal'];
      const isSensitive = sensitiveRoutes.some(route => 
        event.transaction?.includes(route)
      );

      if (isSensitive) {
        event.tags = {
          ...event.tags,
          'transaction_type': 'vbg_sensitive',
          'enhanced_monitoring': 'true',
        };
      }
    }

    return event;
  }

  /**
   * Nettoyage d'objet - supprime les clés sensibles
   */
  private sanitizeObject(obj: any): any {
    if (!obj || typeof obj !== 'object') return obj;

    const sensitiveKeys = [
      // Données personnelles victimes
      'victim_name', 'victim_phone', 'victim_address', 'victim_email',
      'personal_details', 'medical_details', 'incident_description',
      'full_name', 'phone_number', 'email', 'address',
      
      // Données d'authentification
      'password', 'token', 'api_key', 'access_token', 'refresh_token',
      
      // Données médicales et sensibles
      'medical_history', 'psychological_state', 'physical_injuries',
      'witness_testimony', 'perpetrator_info',
      
      // Données d'identification
      'national_id', 'passport', 'social_security', 'bank_account',
    ];

    const sanitized = { ...obj };

    Object.keys(sanitized).forEach(key => {
      const keyLower = key.toLowerCase();
      
      // Supprimer les clés sensibles
      if (sensitiveKeys.some(sensitive => keyLower.includes(sensitive))) {
        sanitized[key] = '[REDACTED-VBG-DATA]';
      }
      
      // Récursion pour les objets imbriqués
      else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
        sanitized[key] = this.sanitizeObject(sanitized[key]);
      }
    });

    return sanitized;
  }

  /**
   * Configuration du contexte utilisateur (sans données sensibles)
   */
  private setupUserContext(): void {
    // Récupérer les infos utilisateur du store/localStorage
    const userInfo = this.getCurrentUserInfo();
    
    if (userInfo) {
      Sentry.setUser({
        id: userInfo.id,
        role: userInfo.role,
        organization: userInfo.organization,
        // PAS d'email, nom ou autres données personnelles
      });
    }
  }

  /**
   * Récupération sécurisée des infos utilisateur
   */
  private getCurrentUserInfo(): any {
    try {
      // Adapter selon votre système d'auth (Redux, Context, etc.)
      const userStr = localStorage.getItem('user_session');
      if (userStr) {
        const user = JSON.parse(userStr);
        return {
          id: user.id,
          role: user.role,
          organization: user.organization_name || 'Unknown',
        };
      }
    } catch (error) {
      console.warn('Cannot retrieve user info for Sentry context:', error);
    }
    return null;
  }

  /**
   * Méthodes publiques pour l'utilisation dans l'app
   */
  
  /**
   * Capture d'erreur manuelle avec contexte VBG
   */
  public captureVBGError(error: Error, context?: Record<string, any>): void {
    Sentry.withScope(scope => {
      if (context) {
        // Sanitiser le contexte avant ajout
        const sanitizedContext = this.sanitizeObject(context);
        scope.setContext('vbg_context', sanitizedContext);
      }
      
      scope.setTag('error_source', 'vbg_manual');
      scope.setLevel('error');
      
      Sentry.captureException(error);
    });
  }

  /**
   * Capture d'événement métier VBG
   */
  public captureVBGEvent(
    message: string, 
    level: 'info' | 'warning' | 'error' = 'info',
    extra?: Record<string, any>
  ): void {
    Sentry.withScope(scope => {
      scope.setTag('event_type', 'vbg_business');
      scope.setLevel(level);
      
      if (extra) {
        const sanitizedExtra = this.sanitizeObject(extra);
        scope.setExtra('business_context', sanitizedExtra);
      }
      
      Sentry.captureMessage(message);
    });
  }

  /**
   * Ajout de breadcrumb sécurisé
   */
  public addSecureBreadcrumb(
    message: string,
    category: string = 'vbg',
    data?: Record<string, any>
  ): void {
    Sentry.addBreadcrumb({
      message,
      category,
      level: 'info',
      data: data ? this.sanitizeObject(data) : undefined,
    });
  }
}

// Export singleton
export const vbgSentry = VBGSentryConfig.getInstance();

// Export pour utilisation dans les composants React
export const SentryRoute = Sentry.withSentryRouting;
export const SentryErrorBoundary = Sentry.ErrorBoundary;

// HOC pour wrapper les composants avec monitoring
export function withVBGSentryMonitoring<P extends object>(
  Component: React.ComponentType<P>,
  componentName?: string
) {
  return Sentry.withProfiler(Component, { name: componentName });
}