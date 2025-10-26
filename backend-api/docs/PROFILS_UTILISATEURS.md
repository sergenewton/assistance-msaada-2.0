# PROFILS UTILISATEURS - ASSISTANCE MSAADA 2.0

## Vue d'ensemble des 6 profils d'acteurs

### 1. 👩‍🦱 SURVIVANTE / TÉMOIN
**Profil**: Victime directe ou personne témoin d'une violence  
**Accès**: Application mobile uniquement  
**Authentification**: Téléphone + Mot de passe  

#### Permissions spécifiques:
- ✅ `reports.create` - Créer un signalement (anonyme ou nominatif)
- ✅ `reports.view_own_status` - Consulter le statut de son cas
- ✅ `messages.send_to_aps` - Communiquer avec son APS assigné
- ✅ `alerts.receive` - Recevoir des alertes et rappels
- ✅ `resources.access_awareness` - Accéder aux ressources de sensibilisation
- ✅ `feedback.submit_quality` - Évaluer la qualité de la prise en charge

#### Utilisateur de test:
- **Téléphone**: +243901234567
- **Mot de passe**: SurvivantSecure123!

---

### 2. 👨‍⚕️ AGENT PSYCHOSOCIAL (APS)
**Profil**: Professionnel formé au soutien psychosocial  
**Accès**: Application web + mobile  
**Authentification**: Email + Mot de passe  

#### Permissions spécifiques:
- ✅ `cases.view_assigned` - Visualiser les cas qui lui sont assignés
- ✅ `messages.secure_chat` - Communiquer avec la survivante (chat sécurisé)
- ✅ `cases.update_status` - Mettre à jour le statut de prise en charge
- ✅ `sessions.document` - Documenter les séances d'accompagnement
- ✅ `referrals.request` - Solliciter des référencements complémentaires
- ✅ `reports.generate_progress` - Générer des rapports d'étape

#### Utilisateur de test:
- **Email**: aps@msaada.org
- **Mot de passe**: APSSecure123!

---

### 3. 📞 OPÉRATEUR CENTRE D'ÉCOUTE
**Profil**: Personnel du centre d'écoute formé à la gestion de crise  
**Accès**: Application web uniquement  
**Authentification**: Email + Mot de passe  

#### Permissions spécifiques:
- ✅ `reports.receive_all` - Recevoir et triager tous les signalements
- ✅ `cases.evaluate_urgency` - Évaluer le niveau d'urgence et de danger
- ✅ `referrals.create` - Référencer les cas vers les organisations compétentes
- ✅ `cases.assign_aps` - Assigner un APS à chaque cas
- ✅ `cases.monitor_progress` - Suivre l'évolution globale des cas
- ✅ `organizations.follow_up` - Relancer les organisations en cas de retard
- ✅ `cases.validate_closure` - Valider la clôture des cas

#### Utilisateur de test:
- **Email**: operateur@msaada.org
- **Mot de passe**: OperatorSecure123!

---

### 4. 🏥 ORGANISATION PARTENAIRE
**Profil**: ONG, hôpital, police, service juridique, etc.  
**Accès**: Application web (portail dédié)  
**Authentification**: Email + Mot de passe  

#### Permissions spécifiques:
- ✅ `referrals.receive` - Recevoir les cas référencés dans leur domaine
- ✅ `referrals.accept_decline` - Accepter ou décliner une prise en charge (avec justification)
- ✅ `cases.update_progress` - Mettre à jour le statut d'avancement
- ✅ `documents.upload` - Uploader des documents (certificats médicaux, PV, etc.)
- ✅ `referrals.cross_reference` - Proposer des référencements croisés
- ✅ `cases.view_history` - Consulter l'historique des cas traités

#### Utilisateurs de test par secteur:

**🏥 Secteur Médical**:
- **Email**: hopital@partenaire.org
- **Mot de passe**: HopitalSecure123!
- **Organisation**: Hôpital Général de Kinshasa

**👮 Secteur Sécurité**:
- **Email**: police@partenaire.org
- **Mot de passe**: PoliceSecure123!
- **Organisation**: Police Nationale Congolaise - Bureau VBG

**⚖️ Secteur Juridique**:
- **Email**: juridique@partenaire.org
- **Mot de passe**: JuridiqueSecure123!
- **Organisation**: Centre d'Assistance Juridique aux Femmes

---

### 5. ⚙️ ADMINISTRATEUR SYSTÈME
**Profil**: Responsable technique et sécurité de la plateforme  
**Accès**: Application web (panneau admin)  
**Authentification**: Email + Mot de passe  

#### Permissions spécifiques:
- ✅ `users.manage_all` - Gérer tous les utilisateurs et leurs accès
- ✅ `system.configure` - Configurer les paramètres système
- ✅ `organizations.manage` - Gérer les organisations partenaires
- ✅ `audit.view_logs` - Consulter les logs d'audit
- ✅ `backups.manage` - Gérer les sauvegardes
- ✅ `notifications.configure` - Configurer les alertes et notifications
- ✅ `content.manage_awareness` - Gérer les contenus de sensibilisation
- ✅ `data.extract_anonymized` - Extraire des données anonymisées pour recherche
- ✅ Accès à toutes les permissions pour maintenance système

#### Utilisateur de test:
- **Email**: admin@msaada.org
- **Mot de passe**: AdminSecure123!

---

### 6. 👔 SUPERVISEUR / COORDINATEUR
**Profil**: Responsable de la coordination générale  
**Accès**: Application web (vue d'ensemble)  
**Authentification**: Email + Mot de passe  

#### Permissions spécifiques:
- ✅ `dashboard.full_access` - Accès complet aux tableaux de bord
- ✅ `cases.view_all` - Vue consolidée de tous les cas
- ✅ `reports.strategic` - Génération de rapports stratégiques
- ✅ `performance.monitor` - Supervision des performances (temps de réponse, etc.)
- ✅ `cases.reassign` - Réaffectation de cas en cas de problème
- ✅ `statistics.export_anonymized` - Export de données statistiques anonymisées

#### Utilisateur de test:
- **Email**: superviseur@msaada.org
- **Mot de passe**: SupervisorSecure123!

---

## Organisations Partenaires Créées

### 🏥 Secteur Médical
1. **Hôpital Général de Kinshasa**
   - Services: Soins d'urgence, certificats médicaux, suivi psychologique
   - Contact: Dr. Michel Tshala
   - Disponibilité: 24h/7j

2. **Centre Médical Monkole**
   - Services: Consultations VBG, soins post-viol, accompagnement psychologique
   - Contact: Dr. Marie Nzuzi
   - Disponibilité: Lun-Ven 7h-17h, Urgences 24h

### 👮 Secteur Sécurité/Justice
1. **Police Nationale Congolaise - Bureau VBG**
   - Services: Dépôt de plaintes, protection des victimes, enquêtes spécialisées
   - Contact: Commissaire Grace Matondo
   - Disponibilité: 24h/7j

2. **Bureau Spécialisé VBG - Parquet de Kinshasa**
   - Services: Poursuites judiciaires, instruction des dossiers VBG
   - Contact: Procureur Adjoint Joseph Mbala
   - Disponibilité: Lun-Ven 8h-16h

### ⚖️ Secteur Juridique
1. **Centre d'Assistance Juridique aux Femmes (CAJF)**
   - Services: Conseil juridique gratuit, représentation en justice
   - Contact: Me. Antoinette Nsimba
   - Disponibilité: Lun-Ven 8h-17h

2. **Association des Femmes Juristes du Congo (AFJC)**
   - Services: Assistance juridique VBG, plaidoyer juridique
   - Contact: Me. Claudine Mukamana
   - Disponibilité: Lun-Ven 8h-16h

### 🧠 Secteur Psychosocial
1. **HEAL Africa**
   - Services: Thérapie individuelle/groupe, réinsertion sociale
   - Contact: Dr. Zawadi Mukamana
   - Disponibilité: Lun-Sam 8h-18h

2. **Centre Olame - Accompagnement Psychosocial**
   - Services: Counseling VBG, thérapie familiale, groupes de parole
   - Contact: Psychologue Sarah Kambale
   - Disponibilité: Lun-Ven 8h-17h

### 🏠 Secteur Hébergement
1. **Foyer d'Accueil Sécurisé Mama Jeanne**
   - Services: Hébergement d'urgence, sécurité 24h, accompagnement social
   - Contact: Coordinatrice Mama Jeanne
   - Disponibilité: 24h/7j - Urgences uniquement

### 💼 Secteur Économique
1. **Programme de Réinsertion Économique des Femmes (PREF)**
   - Services: Formation professionnelle, micro-crédit, accompagnement business
   - Contact: Coordinateur Albert Mukendi
   - Disponibilité: Lun-Ven 8h-16h

---

## Architecture d'Authentification

| Plateforme | Utilisateurs | Méthode d'Authentification |
|------------|-------------|---------------------------|
| **Mobile Flutter** | Survivantes/Témoins | Téléphone + Mot de passe |
| **Web React** | Professionnels (APS, Opérateurs, Organisations, Admin, Superviseurs) | Email + Mot de passe |

---

## Commandes pour Seeding

```bash
# Lancer tous les seeders
cd backend-api
php artisan db:seed

# Lancer un seeder spécifique
php artisan db:seed --class=RolesAndPermissionsSeeder
php artisan db:seed --class=OrganizationsSeeder  
php artisan db:seed --class=UsersSeeder

# Reset et seed complet
php artisan migrate:fresh --seed
```

---

*Documentation générée pour ASSISTANCE MSAADA 2.0 - Système de gestion des Violences Basées sur le Genre*