# ASSISTANCE MSAADA 2.0 - Modèles Eloquent - Documentation Complète

## 📋 Résumé des Modèles Créés

### ✅ Système Complet de 15 Modèles Eloquent

#### 1. **Modèles de Base - Utilisateurs & Permissions**
- **`User`** - Gestion des utilisateurs avec chiffrement des données sensibles
- **`Role`** - Rôles du système (admin, superviseur, aps, operateur, organisation, survivante)  
- **`Permission`** - Permissions granulaires avec méthodes de vérification

#### 2. **Modèles d'Organisation & Signalements**
- **`Organization`** - Organisations partenaires avec gestion de capacité
- **`Report`** - Signalements VBG avec calcul automatique d'urgence
- **`ReportNeed`** - Besoins spécifiques par signalement
- **`ReportFile`** - Fichiers sécurisés joints aux signalements

#### 3. **Système de Référencement**
- **`Referral`** - Référencements vers organisations avec workflow complet
- **`ReferralUpdate`** - Historique des mises à jour de référencement

#### 4. **Communication Sécurisée**
- **`Conversation`** - Conversations entre APS et survivantes
- **`Message`** - Messages chiffrés avec suppression automatique

#### 5. **Système d'Audit & Notifications**
- **`Notification`** - Notifications multi-canaux (SMS, email, push, WhatsApp)
- **`Feedback`** - Retours d'expérience avec système de notation
- **`AuditLog`** - Logs d'audit complets pour traçabilité

#### 6. **Contenu de Sensibilisation**
- **`ContentArticle`** - Articles multilingues avec système de publication
- **`ContentVideo`** - Vidéos éducatives avec détection de plateforme
- **`FAQ`** - FAQ multilingues avec système d'ordre

---

## 🔐 Fonctionnalités de Sécurité Implémentées

### Chiffrement Automatique (`HasEncryptedAttributes` Trait)
- **Données utilisateur** : email, téléphone, secret 2FA
- **Signalements** : narrative, mot de code de sécurité
- **Communications** : contenu des messages
- **Fichiers** : noms et chemins de stockage

### Audit et Traçabilité
- Logs automatiques des actions sensibles
- Traçabilité complète des modifications
- Gestion des accès aux données personnelles
- Export de données avec audit

### Gestion des Permissions
- Système de rôles hiérarchiques
- Vérifications de permissions granulaires
- Contrôle d'accès aux fonctionnalités

---

## 🚀 Fonctionnalités Métier Avancées

### Calcul Automatique d'Urgence
```php
// Dans Report.php - Calcul automatique du score d'urgence
public function calculateUrgencyScore(): int
{
    $score = 0;
    // Facteurs de base + facteurs de risque
    // Score de 0 à 100 avec seuils critiques
}
```

### Gestion Intelligente des Organisations
```php
// Dans Organization.php - Gestion de la capacité
public function canAcceptNewCases(): bool
public function updatePerformanceScore(): void
```

### Communication Sécurisée
```php
// Dans Message.php - Chiffrement et suppression automatique
public function scheduleAutoDelete(int $hours = 24): void
public function getSecureContentForUser(User $user): ?string
```

### Système de Référencement
```php
// Dans Referral.php - Workflow complet
public function accept(User $user, ?string $comment = null): void
public function decline(User $user, string $reason): void
public function complete(User $user, ?string $comment = null, array $documents = []): void
```

---

## 🔄 Relations Eloquent Configurées

### Relations Principales
```php
// User
- belongsTo: Role, Organization
- hasMany: createdReports, assignedReports, referrals, notifications

// Report  
- belongsTo: reporter, assignedAPS
- hasMany: needs, files, referrals, conversations, feedbacks

// Organization
- hasMany: users, referrals, pendingReferrals, acceptedReferrals

// Conversation
- belongsTo: report, aps, survivor
- hasMany: messages, unreadMessages
```

---

## 📊 Scopes et Requêtes Optimisées

### Scopes par Modèle
- **Report**: `active()`, `urgent()`, `critical()`, `unassigned()`, `byStatus()`
- **User**: `active()`, `availableAPS()`, `byRole()`
- **Organization**: `active()`, `available()`, `withSpecialty()`, `byProvince()`
- **Notification**: `unread()`, `byType()`, `recent()`
- **Referral**: `pending()`, `overdue()`, `urgent()`, `byServiceType()`

### Index de Performance
Tous les modèles incluent des index optimisés pour :
- Recherches fréquentes (statut, type, date)
- Relations (clés étrangères)
- Filtres métier (urgence, province, organisation)

---

## 🌍 Support Multilingue

### Modèles avec Support Multilingue
- **ContentArticle** : titre et contenu en plusieurs langues
- **ContentVideo** : titre et description multilingues  
- **FAQ** : questions et réponses multilingues

### Méthodes Disponibles
```php
public function getTitleInLanguage(string $language = 'fr'): string
public function setTitleInLanguage(string $language, string $title): void
public function getAvailableLanguagesAttribute(): array
public function isAvailableInLanguage(string $language): bool
```

---

## 🛠️ Utilisation et Exemples

### Création d'un Signalement avec Urgence
```php
$report = Report::create([
    'reporter_id' => $user->id,
    'violence_type' => 'physical',
    'urgency_level' => 'high',
    'death_threats' => true,
    'needs_urgent_medical' => true,
    // Le score d'urgence sera calculé automatiquement
]);

// Le score sera automatiquement calculé et pourrait être >= 80 (critique)
```

### Référencement avec Workflow
```php
$referral = Referral::create([
    'report_id' => $report->id,
    'organization_id' => $organization->id,
    'service_type' => 'psychological_support',
    'priority' => 'urgent'
]);

// Acceptation par l'organisation
$referral->accept($orgUser, 'Prise en charge immédiate');

// Completion avec documents
$referral->complete($orgUser, 'Service fourni', ['doc1.pdf', 'rapport.docx']);
```

### Communication Chiffrée
```php
$conversation = Conversation::create([
    'report_id' => $report->id,
    'aps_id' => $aps->id,
    'survivor_id' => $survivor->id
]);

$message = $conversation->sendMessage($aps, 'Message sécurisé pour la survivante');
// Le contenu sera automatiquement chiffré
```

### Audit et Notifications
```php
// Audit automatique
AuditLog::log('viewed_sensitive_data', 'Report', $report->id, $user);

// Notifications multi-canaux
Notification::createAlert($user, 'Cas critique', 'Intervention immédiate requise');
```

---

## 🔧 Prochaines Étapes Recommandées

1. **Tests des Modèles** : Créer des tests unitaires pour chaque modèle
2. **Factory & Seeders** : Générer des données de test réalistes
3. **API Resources** : Transformers pour les réponses API
4. **Observers** : Automatiser les actions (notifications, audit)
5. **Policies** : Contrôle d'accès granulaire
6. **Jobs** : Traitement asynchrone (emails, notifications)

---

## 📋 Checklist de Validation

- ✅ **15 modèles Eloquent** créés avec toutes les relations
- ✅ **Chiffrement automatique** des données sensibles
- ✅ **Système d'audit complet** avec traçabilité
- ✅ **Gestion des permissions** hiérarchiques
- ✅ **Communication sécurisée** avec auto-suppression
- ✅ **Calcul automatique d'urgence** pour les signalements
- ✅ **Système de référencement** avec workflow complet
- ✅ **Support multilingue** pour le contenu
- ✅ **Scopes optimisés** pour les requêtes fréquentes
- ✅ **Relations Eloquent** complètes et performantes

La base de données et les modèles de votre plateforme ASSISTANCE MSAADA 2.0 sont maintenant prêts pour le développement des contrôleurs et de l'interface utilisateur ! 🚀