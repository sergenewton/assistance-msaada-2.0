# SPÉCIFICATION TECHNIQUE - PLATEFORME ASSISTANCE MSAADA
## Plateforme Numérique de Signalement et Prise en Charge des VBG

*Version 1.0 - Octobre 2025*

---

## Table des Matières

1. [Présentation Générale](#1-présentation-générale)
2. [Acteurs et Rôles](#2-acteurs-et-rôles)
3. [Architecture Technique](#3-architecture-technique)
4. [Modules Fonctionnels](#4-modules-fonctionnels)
5. [Spécifications Techniques](#5-spécifications-techniques)
6. [Sécurité](#6-sécurité)
7. [Indicateurs de Performance](#7-indicateurs-de-performance)
8. [Roadmap de Développement](#8-roadmap-de-développement)

---

## 1. PRÉSENTATION GÉNÉRALE

### 1.1 Contexte et enjeux
La plateforme vise à créer un écosystème numérique sécurisé et intégré pour la lutte contre les Violences Basées sur le Genre (VBG), en facilitant le signalement, l'orientation et le suivi des survivantes tout en garantissant leur protection maximale.

### 1.2 Objectifs stratégiques

- **Accessibilité** : Offrir un canal sécurisé accessible 24/7 pour signaler les VBG
- **Rapidité** : Réduire le délai entre signalement et première intervention (objectif : < 2h pour urgences)
- **Coordination** : Faciliter la communication entre tous les acteurs (centre d'écoute, APS, organisations)
- **Confidentialité** : Garantir l'anonymat et la protection des données des survivantes
- **Traçabilité** : Assurer un suivi complet de chaque cas de la dénonciation à la clôture
- **Evidence-based** : Produire des données fiables pour influencer les politiques publiques

### 1.3 Indicateurs de succès

- Réduction de 60% du temps moyen de première réponse
- Taux de satisfaction des survivantes > 80%
- 100% des cas référencés sous 24h
- Taux de clôture effective des cas > 70%
- Zéro fuite de données personnelles

---

## 2. ACTEURS ET RÔLES

### 2.1 Survivante / Témoin
**Profil** : Victime directe ou personne témoin d'une violence  
**Accès** : Application mobile

**Permissions** :
- Créer un signalement (anonyme ou nominatif)
- Consulter le statut de son cas
- Communiquer avec son APS assigné
- Recevoir des alertes et rappels
- Accéder aux ressources de sensibilisation
- Évaluer la qualité de la prise en charge

### 2.2 Agent Psychosocial (APS)
**Profil** : Professionnel formé au soutien psychosocial  
**Accès** : Application web + mobile

**Permissions** :
- Visualiser les cas qui lui sont assignés
- Communiquer avec la survivante (chat sécurisé)
- Mettre à jour le statut de prise en charge
- Documenter les séances d'accompagnement
- Solliciter des référencements complémentaires
- Générer des rapports d'étape

### 2.3 Opérateur Centre d'Écoute
**Profil** : Personnel du centre d'écoute formé à la gestion de crise  
**Accès** : Application web

**Permissions** :
- Recevoir et triager tous les signalements
- Évaluer le niveau d'urgence et de danger
- Référencer les cas vers les organisations compétentes
- Assigner un APS à chaque cas
- Suivre l'évolution globale des cas
- Relancer les organisations en cas de retard
- Valider la clôture des cas

### 2.4 Organisation Partenaire
**Profil** : ONG, hôpital, police, service juridique, etc.  
**Accès** : Application web (portail dédié)

**Permissions** :
- Recevoir les cas référencés dans leur domaine
- Accepter ou décliner une prise en charge (avec justification)
- Mettre à jour le statut d'avancement
- Uploader des documents (certificats médicaux, PV, etc.)
- Proposer des référencements croisés
- Consulter l'historique des cas traités

### 2.5 Administrateur Système
**Profil** : Responsable technique et sécurité de la plateforme  
**Accès** : Application web (panneau admin)

**Permissions** :
- Gérer tous les utilisateurs et leurs accès
- Configurer les paramètres système
- Gérer les organisations partenaires
- Consulter les logs d'audit
- Gérer les sauvegardes
- Configurer les alertes et notifications
- Gérer les contenus de sensibilisation
- Extraire des données anonymisées pour recherche

### 2.6 Superviseur / Coordinateur
**Profil** : Responsable de la coordination générale  
**Accès** : Application web (vue d'ensemble)

**Permissions** :
- Accès complet aux tableaux de bord
- Vue consolidée de tous les cas
- Génération de rapports stratégiques
- Supervision des performances (temps de réponse, etc.)
- Réaffectation de cas en cas de problème
- Export de données statistiques anonymisées

---

## 3. ARCHITECTURE TECHNIQUE

### 3.1 Stack Technologique

```
Backend API (Laravel 11)
├── Framework: Laravel 11
├── Base de données: MySQL 8
├── Cache: Redis
├── Queue: Redis/Database
├── Storage: AWS S3 / Local
└── WebSockets: Laravel Echo + Socket.io

Frontend Web (React 18)
├── Framework: React 18 + TypeScript
├── Routing: React Router v6
├── State: Redux Toolkit
├── UI: Tailwind CSS + Headless UI
├── Forms: React Hook Form + Zod
└── Bundler: Vite

Application Mobile (Flutter 3.19)
├── Framework: Flutter 3.19
├── State: Riverpod / Bloc
├── Storage: Hive / SQLite
├── Security: Flutter Secure Storage
├── Push: Firebase Cloud Messaging
└── Chat: End-to-End Encryption

Infrastructure
├── Hébergement: AWS / DigitalOcean
├── CDN: CloudFlare
├── CI/CD: GitHub Actions
├── Monitoring: Sentry + AWS CloudWatch
└── Backups: Automatisés quotidiens
```

### 3.2 Architecture des données

```sql
-- Structure principale de la base de données

-- Table des rôles
roles (id, name, description, permissions_json, created_at, updated_at)

-- Table des utilisateurs
users (
    id, email, phone, password, role_id,
    first_name_encrypted, last_name_encrypted,
    is_active, last_login_at, two_factor_enabled,
    created_at, updated_at, deleted_at
)

-- Table des organisations
organizations (
    id, name, type, contact_email, contact_phone,
    address, services_offered_json, availability_hours,
    performance_score, is_active, created_at, updated_at
)

-- Table des signalements
reports (
    id, reporter_user_id, violence_type, 
    narrative_encrypted, victim_age_range, victim_gender,
    incident_date, incident_location, 
    urgency_score, status, assigned_aps_id,
    is_anonymous, created_at, updated_at, deleted_at
)

-- Table des référencements
referrals (
    id, report_id, organization_id, service_type,
    status, requested_at, responded_at, 
    assigned_staff_name, notes, created_at, updated_at
)

-- Table des messages (chat)
messages (
    id, conversation_id, sender_id, content_encrypted,
    message_type, is_read, expires_at, 
    created_at, updated_at, deleted_at
)

-- Table des feedbacks
feedback (
    id, report_id, feedback_type, rating,
    comments, submitted_at, created_at, updated_at
)

-- Table des logs d'audit
audit_logs (
    id, user_id, action, resource_type, resource_id,
    ip_address, user_agent, metadata_json,
    created_at
)
```

---

## 4. MODULES FONCTIONNELS

### 4.1 Module Authentification & Sécurité

#### 4.1.1 Inscription

**Survivante (app mobile)** :
- Inscription simplifiée : Téléphone OU Email (optionnel)
- Vérification OTP (SMS ou Email)
- Création d'un code PIN à 4 chiffres
- Possibilité d'utiliser la biométrie (empreinte/face ID)
- Option anonymat total : Génération d'un identifiant unique sans données personnelles

**Autres acteurs (web)** :
- Inscription administrative par l'administrateur
- Email professionnel obligatoire
- Mot de passe fort requis (min 12 caractères)
- Authentification à 2 facteurs (2FA) obligatoire
- Validation du compte par le superviseur

#### 4.1.2 Connexion

- JWT tokens (access token : 15min, refresh token : 7 jours)
- Détection de connexions suspectes (IP inhabituelle)
- Limitation des tentatives (5 max, blocage 30min)
- Session unique par utilisateur (déconnexion auto sur autre device)
- Déconnexion automatique après 15min d'inactivité

#### 4.1.3 Gestion des rôles et permissions (RBAC)

```
Rôles prédéfinis :
├── survivante (accès limité à son cas)
├── aps (accès aux cas assignés)
├── operateur (gestion complète des cas)
├── organisation (accès aux cas référencés)
├── superviseur (vue d'ensemble + rapports)
└── admin (gestion système complète)

Permissions granulaires :
├── cas.voir
├── cas.creer
├── cas.modifier
├── cas.supprimer
├── cas.referer
├── utilisateurs.gerer
├── rapports.generer
└── parametres.modifier
```

### 4.2 Module Signalement (Application Mobile)

#### 4.2.1 Interface de signalement

**A. Formulaire structuré**

Étapes du formulaire :

1. **Type de violence** (liste prédéfinie)
   - Violence physique
   - Violence sexuelle
   - Violence psychologique
   - Violence économique
   - Mariage forcé
   - MGF (Mutilations Génitales Féminines)
   - Autre

2. **Informations sur la victime**
   - Âge (tranches : 0-12, 13-17, 18-25, 26-35, 36-50, 50+)
   - Sexe
   - Situation (célibataire, mariée, divorcée, veuve)
   - Nombre d'enfants
   - Localisation (province, commune, quartier) [optionnel]

3. **Informations sur l'incident**
   - Date approximative
   - Lieu (domicile, travail, espace public, autre)
   - Fréquence (première fois, répété, chronique)
   - Description narrative (texte libre)
   - Relation avec l'auteur (conjoint, parent, voisin, inconnu, etc.)

4. **État actuel**
   - En sécurité actuellement ? (Oui/Non)
   - Blessures nécessitant soins urgents ? (Oui/Non)
   - Enfants en danger ? (Oui/Non)
   - Menaces de mort récentes ? (Oui/Non)

5. **Besoins exprimés** (multi-sélection)
   - Écoute psychologique
   - Soins médicaux
   - Assistance juridique
   - Hébergement d'urgence
   - Assistance économique
   - Protection policière

6. **Preuves** (optionnel)
   - Photos (max 5, chiffrées)
   - Audio (max 2min, chiffré)
   - Documents scannés (certificats, PV)
   - Capture d'écrans (messages, menaces)

7. **Modalités de contact**
   - Préférence : SMS / Appel / WhatsApp / In-app
   - Horaires préférés (éviter heures risquées)
   - Mot de code de sécurité (si appel)

**B. Signalement rapide par texto (Chatbot)**

Interface conversationnelle simple :
```
Bot : "Bonjour, je suis ici pour vous aider. Pouvez-vous me dire ce qui vous arrive ?"
Utilisateur : [Répond en texte libre]
Bot : [Analyse et pose questions de clarification]
Bot : "Êtes-vous en sécurité maintenant ?"
Bot : "Avez-vous besoin d'une aide immédiate ?"
...
→ Création automatique du cas avec les infos extraites
→ NLP basique pour catégoriser (violence type, urgence)
```

**C. Message vocal**
- Bouton "Enregistrer mon témoignage"
- Durée max : 5 minutes
- Transcription automatique (Speech-to-Text)
- Analyse par opérateur humain si transcription imprécise
- Conservation de l'audio original (chiffré)

#### 4.2.2 Évaluation automatique du niveau de danger

**Algorithme de scoring** :

Calcul du niveau d'urgence (0-100) :

**Critères de risque élevé (score +20 chacun)** :
- Menaces de mort récentes
- Blessures graves actuelles
- Arme impliquée
- Enfants mineurs en danger
- Victime isolée sans soutien

**Critères de risque modéré (score +10 chacun)** :
- Violence répétée/chronique
- Escalade récente
- Victime enceinte
- Dépendance économique totale
- Auteur a accès au domicile

**Classification finale** :
- 0-30 : FAIBLE (délai réponse 48h)
- 31-60 : MODÉRÉ (délai réponse 24h)
- 61-85 : ÉLEVÉ (délai réponse 4h)
- 86-100 : CRITIQUE (délai réponse immédiat)

**Action automatique selon score** :
- CRITIQUE : Alerte SMS + Appel opérateur immédiat
- ÉLEVÉ : Alerte push + Email opérateur
- MODÉRÉ : Notification standard
- FAIBLE : Intégration dans file d'attente normale

### 4.3 Module Gestion des Cas (Back-office Web)

#### 4.3.1 Workflow de traitement

Étapes standardisées :

1. **RÉCEPTION** (automatique)
   - Cas créé, notification envoyée

2. **TRIAGE** (opérateur, max 2h)
   - Lecture du signalement
   - Évaluation/validation du niveau de danger
   - Identification des besoins prioritaires
   - Changement statut → "En analyse"

3. **ASSIGNATION APS** (opérateur, max 4h après triage)
   - Sélection de l'APS approprié (langue, spécialité, charge)
   - Notification à l'APS
   - Premier contact APS → victime (dans les 24h)
   - Changement statut → "APS assigné"

4. **RÉFÉRENCEMENT** (opérateur, max 24h)
   - Identification des organisations compétentes
   - Création des demandes de référencement
   - Envoi aux organisations (email + notification)
   - Changement statut → "Référencé"

5. **PRISE EN CHARGE** (organisations)
   - Acceptation/refus de la prise en charge (max 48h)
   - Si refus : référencement alternatif
   - Mises à jour régulières (hebdomadaires min)
   - Changement statut → "En prise en charge"

6. **SUIVI** (APS, continu)
   - Contact régulier avec la victime
   - Coordination avec organisations
   - Documentation de l'évolution
   - Identification de besoins additionnels

7. **CLÔTURE** (opérateur, après validation)
   - Tous les services délivrés
   - Victime en sécurité et stabilisée
   - Feedback victime collecté
   - APS confirme
   - Changement statut → "Clos"

### 4.4 Module Communication Sécurisée

#### 4.4.1 Chat APS ↔ Survivante

**Sécurité** :
- Chiffrement de bout en bout (E2E)
- Messages auto-supprimés après lecture (optionnel)
- Aucun historique serveur (stockage local uniquement)
- Indicateur "en train d'écrire..."

**Fonctionnalités** :
- Envoi de texte, audio, images
- Partage de documents (formulaires à remplir)
- Localisation temporaire (rendez-vous)
- Réactions rapides (émojis discrets)
- Statut messages (envoyé, lu, accusé réception)

**Protection victime** :
- Notifications discrètes (pas de preview du message)
- Possibilité de masquer la conversation
- Suppression totale possible par la victime
- Rappel régulier des consignes de sécurité

---

## 5. SPÉCIFICATIONS TECHNIQUES

### 5.1 API Backend (Laravel)

#### 5.1.1 Structure des endpoints

**Authentification (/api/auth)**
```
POST /register          → Inscription
POST /login             → Connexion
POST /logout            → Déconnexion
POST /refresh           → Rafraîchir token
POST /verify-otp        → Vérifier code OTP
POST /forgot-password   → Demande reset password
POST /reset-password    → Reset password
POST /enable-2fa        → Activer 2FA
POST /verify-2fa        → Vérifier code 2FA
```

**Signalements (/api/reports)**
```
POST /reports                      → Créer signalement
GET /reports                       → Liste (selon rôle)
GET /reports/{id}                  → Détails d'un cas
PUT /reports/{id}                  → Modifier cas
DELETE /reports/{id}               → Supprimer (soft delete)
POST /reports/{id}/assign-aps      → Assigner APS
POST /reports/{id}/refer           → Référencer à organisation
GET /reports/{id}/timeline         → Historique complet
POST /reports/{id}/comment         → Ajouter commentaire
POST /reports/{id}/upload          → Uploader fichier
GET /reports/{id}/files            → Liste des fichiers
POST /reports/{id}/close           → Clôturer cas
```

**Utilisateurs (/api/users)**
```
GET /users                  → Liste utilisateurs
POST /users                 → Créer utilisateur
GET /users/{id}             → Profil utilisateur
PUT /users/{id}             → Modifier utilisateur
DELETE /users/{id}          → Supprimer utilisateur
PUT /users/{id}/role        → Changer rôle
PUT /users/{id}/status      → Activer/désactiver
GET /users/{id}/activity    → Logs d'activité
```

#### 5.1.2 Jobs asynchrones (Laravel Queue)

**Jobs critiques** :

```php
// Envoi d'alertes multi-canal
SendCriticalAlertJob
├── Paramètres : report_id, urgency_level, recipients
├── Actions :
│   ├── Envoi SMS (Twilio)
│   ├── Envoi Email (SendGrid)
│   ├── Appel téléphonique (si critical)
│   ├── Notification push (FCM)
│   └── Message WhatsApp (Twilio)
├── Retry : 3 tentatives
└── Timeout : 60 secondes

// Analyse automatique du niveau de danger
CalculateUrgencyScoreJob
├── Paramètres : report_id
├── Actions :
│   ├── Analyse des réponses du formulaire
│   ├── Calcul du score (algorithme)
│   ├── Mise à jour du champ urgency_score
│   └── Déclenchement alerte si score > 85
└── Exécution : Synchrone (bloquant) à la création

// Transcription des messages vocaux
TranscribeAudioReportJob
├── Paramètres : file_path, report_id
├── Actions :
│   ├── Appel API Speech-to-Text (Google Cloud ou AWS)
│   ├── Sauvegarde transcription dans narrative
│   └── Notification opérateur (transcription prête)
├── Retry : 2 tentatives
└── Timeout : 300 secondes
```

---

## 6. SÉCURITÉ

### 6.1 Chiffrement des données

**Architecture de sécurité** :

**Données en transit (HTTPS/TLS 1.3)** :
- Certificat SSL/TLS valide
- Perfect Forward Secrecy activé
- HSTS (HTTP Strict Transport Security)
- Certificate Pinning (app mobile)

**Données au repos (AES-256)** :
- Champs sensibles chiffrés individuellement :
  - Noms et prénoms
  - Numéros de téléphone
  - Adresses email
  - Adresses physiques
  - Numéros d'identité
  - Contenu des témoignages détaillés
- Clés de chiffrement stockées séparément (Key Management System)
- Rotation des clés tous les 6 mois
- Chiffrement des backups

**Chiffrement E2E (chat APS ↔ survivante)** :
- Protocole Signal (double ratchet algorithm)
- Génération de clés par session
- Vérification d'identité (code QR optionnel)
- Messages auto-destructibles (optionnel)

### 6.2 Audit trail et logging

**Événements journalisés** :

**Accès aux données** :
- Qui a consulté quel cas, quand
- Déchiffrement de données sensibles
- Export de données
- Modification d'informations
- Suppression d'éléments

**Actions administratives** :
- Création/modification/suppression utilisateurs
- Changement de permissions
- Modification de paramètres système
- Accès au panneau d'administration

**Événements de sécurité** :
- Tentatives de connexion échouées
- Connexions depuis IP inhabituelles
- Modifications de mots de passe
- Activation/désactivation 2FA
- Détection d'activité suspecte

### 6.3 Protection de l'application mobile

**Stockage local** :
- Flutter Secure Storage (Keychain iOS / Keystore Android)
- Pas de données sensibles en cache non chiffré
- Session tokens chiffrés localement
- Suppression automatique après déconnexion

**Protection de l'interface** :
- Captures d'écran bloquées (sur écrans sensibles)
- Masquage app lors de basculement vers autre app
- Code PIN ou biométrie obligatoire à chaque ouverture
- Déconnexion automatique après 15min d'inactivité
- Option "bouton panique" : efface données + ferme app

---

## 7. INDICATEURS DE PERFORMANCE

### 7.1 KPIs de fonctionnement

**Réactivité** :
- Temps moyen de première réponse (Objectif : < 2h pour urgences, < 24h pour autres)
- Temps moyen d'assignation APS (Objectif : < 4h)
- Temps moyen de référencement (Objectif : < 24h)
- Temps moyen de réponse organisation (Objectif : < 48h)

**Qualité de traitement** :
- Taux de clôture effective (Objectif : > 70%)
- Taux de référencement réussi (Objectif : > 85%)
- Taux de cas sans mise à jour > 7 jours (Objectif : < 10%)
- Taux de réouverture de cas (Objectif : < 15%)

### 7.2 KPIs de satisfaction

**Survivantes** :
- Satisfaction globale (Objectif : > 4.0/5)
- Sentiment de sécurité après prise en charge (Objectif : > 80%)
- Taux de recommandation (NPS) (Objectif : > 50)
- Taux de feedbacks complétés (Objectif : > 60%)

### 7.3 KPIs techniques

**Performance** :
- Disponibilité de la plateforme (Objectif : > 99.5%)
- Temps de chargement moyen pages web (Objectif : < 2 secondes)
- Temps de réponse API (p95) (Objectif : < 500ms)
- Taux d'erreurs serveur (5xx) (Objectif : < 0.1%)

**Sécurité** :
- Nombre d'incidents de sécurité (Objectif : 0)
- Taux de comptes avec 2FA activé (Objectif : 100% pour staff)
- Délai moyen de correctif pour vulnérabilités critiques (Objectif : < 24h)

---

## 8. ROADMAP DE DÉVELOPPEMENT

### Phase 1 : Fondations (Mois 1-2)
- [ ] Architecture de base de données
- [ ] API d'authentification et gestion des rôles
- [ ] Interface web basique (login, dashboard)
- [ ] App mobile basique (inscription, signalement simple)

### Phase 2 : Fonctionnalités Core (Mois 3-4)
- [ ] Module de signalement complet
- [ ] Système de référencement
- [ ] Chat sécurisé APS-survivante
- [ ] Notifications multi-canal

### Phase 3 : Gestion Avancée (Mois 5-6)
- [ ] Tableaux de bord analytiques
- [ ] Système de rapports automatisés
- [ ] Module de feedback
- [ ] Optimisations performance

### Phase 4 : Sécurité Renforcée (Mois 7-8)
- [ ] Chiffrement E2E complet
- [ ] Audit trail avancé
- [ ] Tests de pénétration
- [ ] Conformité GDPR/Sécurité

### Phase 5 : Déploiement et Formation (Mois 9-10)
- [ ] Infrastructure de production
- [ ] Formation des utilisateurs
- [ ] Documentation complète
- [ ] Support et maintenance

---

## CONVENTIONS DE DÉVELOPPEMENT

### Nommage
- **API** : snake_case
- **React** : camelCase
- **Base de données** : snake_case (pas de préfixe)
- **Variables Flutter** : camelCase

### Structure des réponses API
```json
{
  "success": true,
  "data": {},
  "message": "Success"
}
```

### Git Strategy
- Branch principale : `main`
- Branches de feature : `feature/nom-fonctionnalité`
- Branches de hotfix : `hotfix/description-bug`
- Commits conventionnels : `type(scope): description`

---

*Ce document est un guide de référence vivant. Il doit être mis à jour au fur et à mesure de l'évolution du projet.*