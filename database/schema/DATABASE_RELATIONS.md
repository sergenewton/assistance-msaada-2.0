# ASSISTANCE MSAADA 2.0 - Documentation Base de Données

## Relations et Clés Étrangères

### 1. SYSTÈME UTILISATEURS

#### `users`
- **role_id** → `roles(id)` - Rôle de l'utilisateur
- **organization_id** → `organizations(id)` - Organisation de rattachement (nullable)

#### `role_permissions`
- **role_id** → `roles(id)` - Référence au rôle
- **permission_id** → `permissions(id)` - Référence à la permission

---

### 2. SIGNALEMENTS

#### `reports`
- **reporter_id** → `users(id)` - Utilisateur qui a fait le signalement (nullable si anonyme)
- **assigned_aps_id** → `users(id)` - Agent de Protection Sociale assigné

#### `report_needs`
- **report_id** → `reports(id)` CASCADE - Signalement associé

#### `report_files`
- **report_id** → `reports(id)` CASCADE - Signalement associé
- **uploaded_by** → `users(id)` - Utilisateur qui a uploadé le fichier

---

### 3. RÉFÉRENCEMENTS

#### `referrals`
- **report_id** → `reports(id)` CASCADE - Signalement référé
- **organization_id** → `organizations(id)` - Organisation destinataire
- **referred_by** → `users(id)` - Utilisateur qui a fait le référencement
- **accepted_by** → `users(id)` - Utilisateur qui a accepté (nullable)

#### `referral_updates`
- **referral_id** → `referrals(id)` CASCADE - Référencement mis à jour
- **updated_by** → `users(id)` - Utilisateur qui a fait la mise à jour

---

### 4. COMMUNICATIONS

#### `conversations`
- **report_id** → `reports(id)` CASCADE - Signalement associé
- **aps_id** → `users(id)` - Agent de Protection Sociale
- **survivor_id** → `users(id)` - Survivante

#### `messages`
- **conversation_id** → `conversations(id)` CASCADE - Conversation associée
- **sender_id** → `users(id)` - Expéditeur du message

---

### 5. NOTIFICATIONS & FEEDBACK

#### `notifications`
- **user_id** → `users(id)` CASCADE - Destinataire de la notification

#### `feedbacks`
- **report_id** → `reports(id)` CASCADE - Signalement évalué

#### `audit_logs`
- **user_id** → `users(id)` SET NULL - Utilisateur ayant effectué l'action

---

### 6. CONTENUS

#### `content_articles`
- **author_id** → `users(id)` - Auteur de l'article

---

## Index de Performance

### Index Composites Critiques

1. **reports**
   - `(status, urgency_level)` - Tri des cas par statut et urgence
   - `(assigned_aps_id, status)` - Cases assignées par APS
   - `(violence_type, created_at)` - Statistiques par type de violence

2. **referrals**
   - `(organization_id, status)` - Références par organisation
   - `(response_deadline, status)` - Gestion des délais
   - `(status, priority)` - Tri par statut et priorité

3. **messages**
   - `(conversation_id, created_at)` - Chronologie des messages
   - `(auto_delete_at, created_at)` - Nettoyage automatique

4. **audit_logs**
   - `(user_id, created_at)` - Activité par utilisateur
   - `(resource_type, created_at)` - Audit par type de ressource

---

## Sécurité et Chiffrement

### Données Chiffrées
- `users.email` - Email chiffré
- `users.phone` - Téléphone chiffré
- `users.two_factor_secret` - Secret 2FA chiffré
- `reports.narrative` - Description du signalement
- `reports.safety_code_word` - Mot de code de sécurité
- `messages.content` - Contenu des messages
- `report_files.file_name` - Nom de fichier original
- `report_files.file_path` - Chemin de stockage

### Contraintes de Sécurité
1. Soft deletes sur toutes les tables critiques
2. Audit automatique via triggers ou observers
3. Chiffrement des communications sensibles
4. Gestion des permissions granulaires

---

## Optimisations Recommandées

### 1. Partitioning
- `audit_logs` par mois/trimestre
- `messages` par conversation_id

### 2. Archivage
- Reports fermés > 2 ans
- Messages > 1 an (configurable)
- Audit logs > 5 ans

### 3. Cache
- Statistiques dashboard
- Permissions utilisateur
- Contenu multilingue

---

## Commandes MySQL de Maintenance

```sql
-- Nettoyage automatique des messages expirés
DELETE FROM messages WHERE auto_delete_at < NOW();

-- Archivage des signalements anciens
UPDATE reports SET deleted_at = NOW() 
WHERE status = 'closed' AND closed_at < DATE_SUB(NOW(), INTERVAL 2 YEAR);

-- Statistiques de performance
ANALYZE TABLE reports, referrals, messages;
```

---

## Triggers Automatiques

1. **generate_report_number** - Génération automatique du numéro VBG-YYYY-XXXXX
2. **update_organization_load** - Mise à jour de la charge des organisations
3. **audit_sensitive_access** - Log des accès aux données sensibles

---

## Configuration Laravel Recommandée

### .env
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=assistance_msaada
DB_USERNAME=root
DB_PASSWORD=

# Chiffrement
ENCRYPTION_KEY=base64:generated_key_here

# Files Storage
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=msaada-secure-files
```