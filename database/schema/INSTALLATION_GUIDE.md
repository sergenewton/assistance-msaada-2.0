# ASSISTANCE MSAADA 2.0 - Guide d'Installation Base de Données

## Installation et Configuration

### 1. Exécution du Schéma SQL
```bash
# Créer la base de données
mysql -u root -p -e "CREATE DATABASE assistance_msaada CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Exécuter le schéma complet
mysql -u root -p assistance_msaada < database/schema/assistance_msaada_schema.sql
```

### 2. Exécution des Migrations Laravel
```bash
# Dans le dossier backend-api
cd backend-api

# Installer les dépendances
composer install

# Configuration de l'environnement
cp .env.example .env
php artisan key:generate

# Configurer la base de données dans .env
# DB_DATABASE=assistance_msaada

# Exécuter les migrations
php artisan migrate

# Exécuter les seeders
php artisan db:seed --class=RolesAndPermissionsSeeder
```

### 3. Vérification de l'Installation
```bash
# Vérifier les tables créées
php artisan tinker
>>> DB::select('SHOW TABLES');

# Vérifier les rôles et permissions
>>> DB::table('roles')->get();
>>> DB::table('permissions')->count();
```

## Tests de Performance

### 1. Test des Index
```sql
-- Vérifier les index créés
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME 
FROM information_schema.statistics 
WHERE table_schema = 'assistance_msaada' 
ORDER BY TABLE_NAME, INDEX_NAME;

-- Test de performance sur les requêtes critiques
EXPLAIN SELECT * FROM reports WHERE status = 'new' AND urgency_level = 'high';
EXPLAIN SELECT * FROM referrals WHERE organization_id = 'uuid' AND status = 'pending';
```

### 2. Test de Charge
```sql
-- Simuler des données de test
INSERT INTO reports (id, report_number, violence_type, urgency_level, status) 
VALUES 
(UUID(), 'VBG-2025-00001', 'physical', 'high', 'new'),
(UUID(), 'VBG-2025-00002', 'sexual', 'critical', 'triaged');
```

## Sécurité Avancée

### 1. Configuration MySQL
```sql
-- Activer les logs binaires pour la réplication
SET GLOBAL log_bin = ON;

-- Configuration SSL pour les connexions
ALTER USER 'root'@'localhost' REQUIRE SSL;

-- Limitation des connexions simultanées
SET GLOBAL max_connections = 200;
```

### 2. Chiffrement Application Laravel
```bash
# Générer les clés de chiffrement
php artisan key:generate

# Configuration du chiffrement des données sensibles
# Dans config/app.php, vérifier cipher = 'AES-256-CBC'
```

## Monitoring et Maintenance

### 1. Scripts de Maintenance
```bash
# Créer un script de sauvegarde quotidienne
#!/bin/bash
DATE=$(date +"%Y%m%d_%H%M%S")
mysqldump -u root -p assistance_msaada > backup_${DATE}.sql
gzip backup_${DATE}.sql
```

### 2. Surveillance des Performances
```sql
-- Requêtes lentes
SELECT * FROM mysql.slow_log WHERE start_time > NOW() - INTERVAL 1 DAY;

-- Taille des tables
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'assistance_msaada'
ORDER BY (data_length + index_length) DESC;
```

## Troubleshooting

### Problèmes Courants

1. **Erreur de clés étrangères**
   ```sql
   SET foreign_key_checks = 0;
   -- Vos requêtes ici
   SET foreign_key_checks = 1;
   ```

2. **Problème d'encodage UTF-8**
   ```sql
   ALTER DATABASE assistance_msaada CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **Index manquants après migration**
   ```bash
   php artisan migrate:refresh --seed
   ```

## Évolutions Futures

### 1. Sharding Horizontal
- Partitionnement par province
- Séparation des données historiques

### 2. Réplication Master-Slave
- Configuration lecture/écriture
- Haute disponibilité

### 3. Cache Redis
```bash
# Configuration Redis pour les sessions et cache
composer require predis/predis
php artisan config:cache
```