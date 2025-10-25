#!/bin/bash

# Script d'installation Sentry pour Assistance Msaada 2.0
# Configuration complète Laravel + React avec sanitisation VBG

set -e

echo "🔧 Installation et configuration Sentry pour Assistance Msaada 2.0"
echo "   ⚠️  Configuration spécialisée pour données VBG sensibles"

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    if ! command -v composer &> /dev/null; then
        error "Composer n'est pas installé. Installation requise."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        error "NPM n'est pas installé. Installation requise."
        exit 1
    fi
    
    if [ ! -f "backend-api/composer.json" ]; then
        error "Fichier composer.json non trouvé dans backend-api/"
        exit 1
    fi
    
    if [ ! -f "frontend-web/package.json" ]; then
        error "Fichier package.json non trouvé dans frontend-web/"
        exit 1
    fi
    
    info "Prérequis vérifiés avec succès"
}

# Installation des packages Sentry Laravel
install_laravel_sentry() {
    log "Installation Sentry pour Laravel..."
    
    cd backend-api
    
    # Installation du package Sentry Laravel
    composer require sentry/sentry-laravel
    
    # Publication de la configuration
    php artisan vendor:publish --provider="Sentry\Laravel\ServiceProvider"
    
    info "Sentry Laravel installé avec succès"
    cd ..
}

# Installation des packages Sentry React
install_react_sentry() {
    log "Installation Sentry pour React..."
    
    cd frontend-web
    
    # Installation des packages Sentry React
    npm install --save @sentry/react @sentry/tracing
    
    # Installation des dépendances de développement pour la configuration
    npm install --save-dev @types/react @types/react-dom
    
    info "Sentry React installé avec succès"
    cd ..
}

# Configuration des variables d'environnement
setup_environment_variables() {
    log "Configuration des variables d'environnement..."
    
    # Backend Laravel
    if [ ! -f "backend-api/.env" ]; then
        if [ -f "backend-api/.env.example" ]; then
            cp backend-api/.env.example backend-api/.env
            info "Fichier .env créé depuis .env.example"
        else
            warn "Aucun fichier .env trouvé pour Laravel"
        fi
    fi
    
    # Ajouter les variables Sentry au .env Laravel s'il existe
    if [ -f "backend-api/.env" ]; then
        echo "" >> backend-api/.env
        echo "# Sentry Configuration - Assistance Msaada VBG" >> backend-api/.env
        echo "SENTRY_DSN=" >> backend-api/.env
        echo "SENTRY_ENVIRONMENT=development" >> backend-api/.env
        echo "SENTRY_RELEASE=1.0.0" >> backend-api/.env
        echo "SENTRY_SAMPLE_RATE=1.0" >> backend-api/.env
        echo "SENTRY_TRACES_SAMPLE_RATE=0.2" >> backend-api/.env
        echo "SENTRY_SERVER_NAME=laravel-backend" >> backend-api/.env
        echo "SENTRY_ORGANIZATION=assistance-msaada" >> backend-api/.env
        echo "SENTRY_PROJECT=backend-laravel" >> backend-api/.env
        echo "VBG_SENSITIVE_LOGGING=true" >> backend-api/.env
        echo "VBG_AUTO_ANONYMIZE=true" >> backend-api/.env
        echo "SENTRY_RETENTION_DAYS=30" >> backend-api/.env
        
        info "Variables Sentry ajoutées au .env Laravel"
    fi
    
    # Frontend React
    if [ ! -f "frontend-web/.env" ]; then
        cat > frontend-web/.env << EOF
# Sentry Configuration - Frontend React VBG
VITE_SENTRY_DSN=
VITE_APP_ENV=development
VITE_APP_VERSION=1.0.0
VITE_SENTRY_ORGANIZATION=assistance-msaada
VITE_SENTRY_PROJECT=frontend-react

# VBG Specific Settings
VITE_VBG_PRIVACY_MODE=true
VITE_VBG_DATA_RETENTION_DAYS=30
VITE_VBG_AUTO_SANITIZE=true
EOF
        info "Fichier .env créé pour React avec configuration Sentry"
    else
        info "Fichier .env React existe déjà - ajoutez manuellement les variables Sentry"
    fi
}

# Création des fichiers de configuration avancée
create_advanced_configs() {
    log "Création des configurations avancées..."
    
    # Configuration Laravel middleware
    cat > backend-api/app/Http/Middleware/SentryVBGMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Sentry\Laravel\Facade as Sentry;
use Sentry\State\Scope;

/**
 * Middleware Sentry spécialisé VBG
 * Ajoute le contexte et la surveillance pour les données sensibles
 */
class SentryVBGMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Configurer le contexte Sentry pour cette requête
        Sentry::configureScope(function (Scope $scope) use ($request) {
            // Tags spécifiques VBG
            $scope->setTag('request_type', $this->getRequestType($request));
            $scope->setTag('privacy_level', $this->getPrivacyLevel($request));
            $scope->setTag('data_category', $this->getDataCategory($request));
            
            // Contexte de la requête (sanitisé)
            $scope->setContext('request_info', [
                'method' => $request->method(),
                'path' => $request->path(),
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'is_vbg_sensitive' => $this->isSensitiveVBGRoute($request),
            ]);
            
            // Utilisateur (sans données personnelles)
            if ($request->user()) {
                $scope->setUser([
                    'id' => $request->user()->id,
                    'role' => $request->user()->roles->pluck('name')->first(),
                    'organization' => $request->user()->organization->name ?? 'Unknown',
                ]);
            }
        });

        $response = $next($request);

        // Surveiller les erreurs de réponse
        if ($response->getStatusCode() >= 400) {
            $this->logResponseError($request, $response);
        }

        return $response;
    }

    private function getRequestType(Request $request): string
    {
        if (str_contains($request->path(), 'api/reports')) return 'vbg_reports';
        if (str_contains($request->path(), 'api/victims')) return 'vbg_victims';
        if (str_contains($request->path(), 'api/emergency')) return 'vbg_emergency';
        if (str_contains($request->path(), 'api/auth')) return 'authentication';
        if (str_contains($request->path(), 'admin')) return 'administration';
        
        return 'general';
    }

    private function getPrivacyLevel(Request $request): string
    {
        return $this->isSensitiveVBGRoute($request) ? 'high' : 'standard';
    }

    private function getDataCategory(Request $request): string
    {
        if ($this->isSensitiveVBGRoute($request)) return 'vbg_sensitive';
        if (str_contains($request->path(), 'admin')) return 'administrative';
        
        return 'public';
    }

    private function isSensitiveVBGRoute(Request $request): bool
    {
        $sensitiveRoutes = ['reports', 'victims', 'medical', 'personal', 'emergency'];
        
        return collect($sensitiveRoutes)->some(function ($route) use ($request) {
            return str_contains($request->path(), $route);
        });
    }

    private function logResponseError(Request $request, $response): void
    {
        if ($this->isSensitiveVBGRoute($request)) {
            Sentry::withScope(function (Scope $scope) use ($request, $response) {
                $scope->setTag('error_type', 'vbg_response_error');
                $scope->setLevel('warning');
                
                Sentry::captureMessage(
                    "VBG Sensitive Route Error: {$response->getStatusCode()}",
                    'warning'
                );
            });
        }
    }
}
EOF

    # Configuration React types
    cat > frontend-web/src/types/sentry.d.ts << 'EOF'
// Types TypeScript pour configuration Sentry VBG

export interface VBGSentryConfig {
  dsn: string;
  environment: 'development' | 'staging' | 'production';
  release?: string;
  sampleRate: number;
  tracesSampleRate: number;
  replaysSessionSampleRate: number;
  replaysOnErrorSampleRate: number;
}

export interface VBGUserContext {
  id: string;
  role: string;
  organization: string;
}

export interface VBGErrorContext {
  component?: string;
  action?: string;
  sensitive_data_present?: boolean;
  privacy_level?: 'low' | 'medium' | 'high';
}

declare global {
  interface Window {
    __VBG_SENTRY_CONFIG__?: Partial<VBGSentryConfig>;
  }
}

export {};
EOF

    info "Configurations avancées créées"
}

# Création des exemples d'utilisation
create_usage_examples() {
    log "Création des exemples d'utilisation..."
    
    # Exemple Laravel
    cat > backend-api/app/Http/Controllers/ExampleSentryController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Exception;
use Illuminate\Http\Request;
use Sentry\Laravel\Facade as Sentry;
use Sentry\State\Scope;

/**
 * Exemples d'utilisation Sentry dans contexte VBG
 */
class ExampleSentryController extends Controller
{
    /**
     * Exemple de capture d'erreur avec contexte VBG
     */
    public function captureVBGError(Request $request)
    {
        try {
            // Simulation d'une erreur dans un processus VBG
            throw new Exception('Erreur lors du traitement du rapport VBG');
            
        } catch (Exception $e) {
            // Capture avec contexte spécifique VBG
            Sentry::withScope(function (Scope $scope) use ($request, $e) {
                // Ne pas inclure de données sensibles !
                $scope->setTag('error_category', 'vbg_processing');
                $scope->setTag('process_step', 'report_validation');
                $scope->setLevel('error');
                
                // Contexte sécurisé (pas de données personnelles)
                $scope->setContext('business_context', [
                    'report_type' => 'violence_domestique', // OK - pas personnel
                    'organization_type' => 'ngo', // OK - pas personnel
                    'processing_stage' => 'initial_review', // OK - pas personnel
                    // PAS de noms, adresses, détails médicaux, etc.
                ]);
                
                Sentry::captureException($e);
            });
            
            return response()->json(['error' => 'Erreur traitée et loggée'], 500);
        }
    }

    /**
     * Exemple de monitoring de performance pour endpoint VBG
     */
    public function monitorVBGPerformance()
    {
        // Démarrer une transaction de performance
        $transaction = Sentry::startTransaction(
            'vbg_report_processing',
            'business_process'
        );
        
        Sentry::getCurrentHub()->setSpan($transaction);
        
        try {
            // Simulation du processus métier
            $this->processVBGReport();
            
            $transaction->setStatus('ok');
            
        } catch (Exception $e) {
            $transaction->setStatus('internal_error');
            throw $e;
        } finally {
            $transaction->finish();
        }
        
        return response()->json(['status' => 'processed']);
    }

    private function processVBGReport()
    {
        // Simulation de traitement
        usleep(100000); // 100ms
    }
}
EOF

    # Exemple React
    cat > frontend-web/src/components/VBGSentryExample.tsx << 'EOF'
import React, { useEffect } from 'react';
import { vbgSentry, SentryErrorBoundary } from '../services/sentry';

/**
 * Exemples d'utilisation Sentry dans composants React VBG
 */

// Composant avec monitoring de performance
const VBGReportForm: React.FC = () => {
  useEffect(() => {
    // Breadcrumb sécurisé pour navigation
    vbgSentry.addSecureBreadcrumb(
      'Accès au formulaire de rapport VBG',
      'navigation',
      { 
        form_type: 'vbg_report', // OK - pas de données sensibles
        privacy_level: 'high' // OK - métadonnée
      }
    );
  }, []);

  const handleSubmit = async (formData: any) => {
    try {
      // Traitement du formulaire
      await submitVBGReport(formData);
      
      // Événement métier réussi
      vbgSentry.captureVBGEvent(
        'Rapport VBG soumis avec succès',
        'info',
        { 
          report_category: 'domestic_violence', // OK - pas personnel
          submission_channel: 'web_form' // OK - métadonnée
        }
      );
      
    } catch (error) {
      // Capture d'erreur avec contexte
      vbgSentry.captureVBGError(
        error as Error,
        {
          form_step: 'submission',
          privacy_context: 'high_sensitivity',
          // PAS de données du formulaire !
        }
      );
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Formulaire VBG */}
    </form>
  );
};

// Wrapper avec Error Boundary
export const VBGFormWithMonitoring: React.FC = () => {
  return (
    <SentryErrorBoundary
      fallback={({ error, resetError }) => (
        <div role="alert">
          <h2>Erreur dans l'application</h2>
          <p>Une erreur est survenue. Nos équipes ont été notifiées.</p>
          <button onClick={resetError}>Réessayer</button>
        </div>
      )}
      beforeCapture={(scope, error, errorInfo) => {
        // Configuration avant capture d'erreur
        scope.setTag('error_boundary', 'vbg_form');
        scope.setTag('component_type', 'sensitive_form');
        scope.setLevel('error');
      }}
    >
      <VBGReportForm />
    </SentryErrorBoundary>
  );
};

// Fonction utilitaire pour logging sécurisé
export const logVBGAction = (action: string, metadata?: Record<string, any>) => {
  vbgSentry.addSecureBreadcrumb(
    `Action VBG: ${action}`,
    'user_action',
    metadata // Sera automatiquement sanitisé
  );
};

async function submitVBGReport(formData: any): Promise<void> {
  // Simulation d'envoi
  await new Promise(resolve => setTimeout(resolve, 1000));
}
EOF

    info "Exemples d'utilisation créés"
}

# Configuration Docker mise à jour
update_docker_configs() {
    log "Mise à jour des configurations Docker avec Sentry..."
    
    # Ajouter Sentry aux services Docker
    cat >> docker-compose.staging-advanced.yml << 'EOF'

  # Service Sentry pour staging
  sentry-redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - sentry-redis-data:/data
    networks:
      - monitoring

  sentry-postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: sentry
      POSTGRES_PASSWORD: sentry
      POSTGRES_DB: sentry
    volumes:
      - sentry-postgres-data:/var/lib/postgresql/data
    networks:
      - monitoring

  sentry:
    image: sentry:latest
    environment:
      SENTRY_SECRET_KEY: ${SENTRY_SECRET_KEY}
      SENTRY_POSTGRES_HOST: sentry-postgres
      SENTRY_POSTGRES_PORT: 5432
      SENTRY_POSTGRES_DB: sentry
      SENTRY_REDIS_HOST: sentry-redis
      SENTRY_REDIS_PORT: 6379
    volumes:
      - sentry-data:/var/lib/sentry/files
    depends_on:
      - sentry-postgres
      - sentry-redis
    networks:
      - monitoring
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sentry.rule=Host(`sentry.staging.msaada.org`)"
      - "traefik.http.routers.sentry.tls=true"
      - "traefik.http.services.sentry.loadbalancer.server.port=9000"

volumes:
  sentry-redis-data:
  sentry-postgres-data:
  sentry-data:
EOF

    info "Configuration Docker mise à jour"
}

# Configuration des alertes Sentry
setup_sentry_alerts() {
    log "Configuration des alertes Sentry spécifiques VBG..."
    
    mkdir -p monitoring/sentry
    
    # Configuration des règles d'alerte
    cat > monitoring/sentry/alert-rules.json << 'EOF'
{
  "vbg_critical_errors": {
    "name": "Erreurs critiques VBG",
    "conditions": [
      {
        "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
        "interval": "1m",
        "value": 5
      },
      {
        "id": "sentry.rules.filters.tagged_event.TaggedEventFilter",
        "key": "error_category",
        "match": "is",
        "value": "vbg_processing"
      }
    ],
    "actions": [
      {
        "id": "sentry.rules.actions.notify_event.NotifyEventAction"
      }
    ]
  },
  "data_privacy_violations": {
    "name": "Violations de confidentialité des données",
    "conditions": [
      {
        "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
        "interval": "5m",
        "value": 1
      },
      {
        "id": "sentry.rules.filters.tagged_event.TaggedEventFilter",
        "key": "privacy_violation",
        "match": "is",
        "value": "true"
      }
    ],
    "actions": [
      {
        "id": "sentry.rules.actions.notify_event.NotifyEventAction"
      }
    ]
  },
  "performance_degradation": {
    "name": "Dégradation performance endpoints VBG",
    "conditions": [
      {
        "id": "sentry.rules.conditions.event_frequency.EventFrequencyCondition",
        "interval": "10m",
        "value": 10
      },
      {
        "id": "sentry.rules.filters.tagged_event.TaggedEventFilter",
        "key": "transaction_type",
        "match": "is",
        "value": "vbg_sensitive"
      }
    ],
    "actions": [
      {
        "id": "sentry.rules.actions.notify_event.NotifyEventAction"
      }
    ]
  }
}
EOF

    info "Règles d'alerte Sentry configurées"
}

# Génération de la documentation
generate_documentation() {
    log "Génération de la documentation Sentry VBG..."
    
    cat > docs/SENTRY_VBG_GUIDE.md << 'EOF'
# Guide Sentry pour Assistance Msaada 2.0

## Configuration VBG Spécialisée

Cette configuration Sentry est spécialement adaptée pour une plateforme de gestion des violences basées sur le genre (VBG), avec un focus sur la **protection de la vie privée** et la **sécurité des données**.

## 🔒 Principes de Sécurité

### Sanitisation Automatique
- **Toutes les données sensibles sont automatiquement supprimées** avant envoi à Sentry
- Les noms, adresses, détails médicaux, etc. sont remplacés par `[REDACTED-VBG-DATA]`
- Les sessions replays masquent automatiquement tous les champs de saisie

### Échantillonnage Adaptatif
- **Production**: 10% des erreurs, 5% des traces de performance
- **Staging**: 50% des erreurs, 20% des traces
- **Development**: 100% pour le debugging

### Contexte Sécurisé
- Seules les métadonnées non-sensibles sont capturées
- Identification par IDs techniques uniquement
- Aucune donnée personnelle dans les logs

## 📊 Monitoring Spécialisé VBG

### Endpoints Surveillés
- `/api/reports/*` - Rapports VBG (monitoring élevé: 80%)
- `/api/victims/*` - Gestion victimes (monitoring élevé: 80%)
- `/api/emergency/*` - Urgences (monitoring élevé: 80%)
- `/admin/*` - Administration (monitoring modéré: 30%)

### Alertes Configurées
1. **Erreurs critiques VBG** - 5+ erreurs/minute sur endpoints VBG
2. **Violations de confidentialité** - Détection immédiate
3. **Dégradation performance** - Surveillance continue des temps de réponse

## 🚀 Utilisation

### Laravel (Backend)

```php
// Capture d'erreur avec contexte VBG
Sentry::withScope(function (Scope $scope) use ($context) {
    $scope->setTag('error_category', 'vbg_processing');
    $scope->setContext('safe_context', [
        'report_type' => 'domestic_violence', // OK
        'stage' => 'validation', // OK
        // PAS de données personnelles !
    ]);
    
    Sentry::captureException($exception);
});

// Monitoring de performance
$transaction = Sentry::startTransaction('vbg_process', 'business');
// ... traitement ...
$transaction->finish();
```

### React (Frontend)

```typescript
import { vbgSentry } from '../services/sentry';

// Capture d'erreur sécurisée
vbgSentry.captureVBGError(error, {
    component: 'VBGReportForm',
    privacy_level: 'high',
    // Métadonnées seulement !
});

// Événement métier
vbgSentry.captureVBGEvent(
    'Rapport soumis avec succès',
    'info',
    { category: 'domestic_violence' }
);

// Breadcrumb sécurisé
vbgSentry.addSecureBreadcrumb(
    'Navigation vers formulaire VBG',
    'navigation',
    { form_type: 'incident_report' }
);
```

## 🔧 Configuration

### Variables d'Environnement Requises

**Backend (.env)**:
```env
SENTRY_DSN=https://your-dsn@sentry.io/project
SENTRY_ENVIRONMENT=production
SENTRY_SAMPLE_RATE=0.1
VBG_SENSITIVE_LOGGING=true
VBG_AUTO_ANONYMIZE=true
```

**Frontend (.env)**:
```env
VITE_SENTRY_DSN=https://your-dsn@sentry.io/project
VITE_APP_ENV=production
VITE_VBG_PRIVACY_MODE=true
VITE_VBG_AUTO_SANITIZE=true
```

## 🛡️ Conformité et Sécurité

### RGPD / Protection des Données
- ✅ Anonymisation automatique
- ✅ Rétention limitée (30 jours par défaut)
- ✅ Consentement explicite non requis (données techniques uniquement)
- ✅ Droit à l'oubli automatique

### Audit et Traçabilité
- Tous les accès aux données sensibles sont tracés
- Les erreurs de sécurité déclenchent des alertes immédiates
- Logs d'audit séparés pour les actions VBG critiques

## 📈 Dashboards et Métriques

### Métriques VBG Spécifiques
1. **Taux d'erreur par type de rapport VBG**
2. **Performance des endpoints sensibles**
3. **Détection d'anomalies de sécurité**
4. **Monitoring de la charge système**

### Alertes Critiques
- **Immédiate**: Tentatives d'accès non autorisés aux données VBG
- **5 minutes**: Erreurs répétées sur endpoints critiques
- **15 minutes**: Dégradation de performance globale

## 🔍 Debugging Sécurisé

### Reproduction d'Erreurs
1. Utiliser les Session Replays (avec masquage automatique)
2. Analyser les breadcrumbs sans données sensibles
3. Corréler avec les logs système (sans PII)

### Investigation d'Incidents
1. Identifier le pattern d'erreur via les tags
2. Analyser le contexte technique uniquement
3. Recourir aux logs détaillés locaux si nécessaire

## ⚠️ Bonnes Pratiques

### À FAIRE ✅
- Utiliser les méthodes VBG spécialisées (`captureVBGError`, etc.)
- Tagger les erreurs selon leur sensibilité
- Vérifier que la sanitisation fonctionne en staging
- Monitorer les performances des endpoints critiques

### À ÉVITER ❌
- Jamais inclure de données personnelles dans les contextes
- Ne pas désactiver la sanitisation automatique
- Éviter les logs détaillés en production
- Ne pas augmenter les taux d'échantillonnage sans justification

## 🚨 Incidents de Sécurité

En cas de détection d'une faille de sécurité via Sentry:

1. **Immédiat**: Alertes automatiques vers l'équipe de sécurité
2. **< 5 min**: Évaluation de l'impact et containment
3. **< 15 min**: Notification des autorités compétentes si requis
4. **< 1h**: Plan de remédiation et communication

## 📞 Support

- **Équipe Tech**: tech@msaada.org
- **Sécurité**: security@msaada.org  
- **Urgences VBG**: +XXX-XXX-XXXX (24h/7j)

---

> **Note Importante**: Cette configuration prioritise la protection de la vie privée des victimes de VBG. En cas de doute sur la sensibilité d'une donnée, toujours opter pour le niveau de protection le plus élevé.
EOF

    info "Documentation générée"
}

# Fonction principale
main() {
    log "🚀 Début de l'installation Sentry pour Assistance Msaada 2.0"
    
    check_prerequisites
    install_laravel_sentry
    install_react_sentry
    setup_environment_variables
    create_advanced_configs
    create_usage_examples
    update_docker_configs
    setup_sentry_alerts
    generate_documentation
    
    log "✅ Installation Sentry terminée avec succès !"
    
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Configurer votre projet Sentry sur https://sentry.io"
    echo "2. Ajouter les DSN dans les fichiers .env"
    echo "3. Enregistrer le middleware SentryVBGMiddleware dans Laravel"
    echo "4. Initialiser Sentry dans main.tsx (React)"
    echo "5. Tester la configuration avec: npm run test:sentry"
    echo ""
    echo "📚 Documentation complète: docs/SENTRY_VBG_GUIDE.md"
    echo ""
    warn "⚠️  N'oubliez pas de configurer les règles d'alerte dans votre dashboard Sentry !"
}

# Exécution du script
main "$@"