# 🚀 GUIDE D'ACCÈS AUX PAGES - ASSISTANCE MSAADA 2.0

## 📋 **URLs Disponibles**

### 🔐 **Pages d'Authentification**

#### **Page de Connexion**
- ✅ `http://localhost:3000/login`
- ✅ `http://localhost:3000/auth/login` 

#### **Page d'Inscription** 
- ✅ `http://localhost:3000/register`
- ✅ `http://localhost:3000/auth/register`

### 🏠 **Pages Protégées**

#### **Tableau de Bord**
- ✅ `http://localhost:3000/dashboard` (nécessite connexion)
- ✅ `http://localhost:3000/` (redirige vers dashboard)

---

## 🔗 **Navigation entre les Pages**

### **Depuis la Page de Connexion**
- **Lien "Créer un compte"** → Vous amène à la page d'inscription
- **Bouton "Se connecter"** → Vous connecte et redirige vers le dashboard

### **Depuis la Page d'Inscription** 
- **Lien "Se connecter"** → Vous amène à la page de connexion  
- **Bouton "Créer mon compte"** → Vous inscrit et redirige vers le dashboard

---

## 🎯 **Comment Accéder à la Page d'Inscription**

### **Méthode 1: URL Directe**
1. Ouvrez votre navigateur
2. Tapez : `http://localhost:3000/register`
3. Appuyez sur Entrée

### **Méthode 2: Depuis la Page de Connexion**
1. Allez sur : `http://localhost:3000/login`
2. En bas de la page, cliquez sur **"Créer un compte"**
3. Vous serez redirigé vers la page d'inscription

### **Méthode 3: Autres URLs**
- `http://localhost:3000/auth/register` (alternative)

---

## 🔧 **Résolution des Problèmes**

### **Si la page ne se charge pas**
1. ✅ Vérifiez que le frontend est lancé :
   ```bash
   cd "assistance msaada 2/frontend-web"
   npm run dev
   ```

2. ✅ Vérifiez l'URL : `http://localhost:3000/register`

3. ✅ Effacez le cache du navigateur (Ctrl+F5 ou Cmd+Shift+R)

### **Si vous voyez une page blanche**
1. ✅ Ouvrez les outils de développement (F12)
2. ✅ Regardez l'onglet Console pour les erreurs
3. ✅ Rechargez la page

### **Si vous êtes redirigé**
- ✅ Si vous êtes connecté, vous serez automatiquement redirigé vers `/dashboard`
- ✅ Pour tester l'inscription, déconnectez-vous d'abord

---

## 📋 **Formulaire d'Inscription - Champs Requis**

### **Informations Personnelles**
- ✅ **Nom d'utilisateur** : 3 caractères minimum
- ✅ **Nom complet** : Prénom et nom
- ✅ **Email** : Format valide requis
- ✅ **Téléphone** : Numéro complet

### **Sécurité**
- ✅ **Mot de passe** : 6 caractères minimum
- ✅ **Confirmer le mot de passe** : Doit correspondre

### **Rôle Professionnel** (obligatoire)
- ✅ Agent Psychosocial (APS)
- ✅ Opérateur Centre d'Écoute  
- ✅ Organisation Partenaire
- ✅ Superviseur / Coordinateur

---

## ⚠️ **Notes Importantes**

### **Approbation Required**
- ✅ Votre compte sera **en attente d'approbation** après inscription
- ✅ Un administrateur doit valider votre compte
- ✅ Vous recevrez une notification une fois approuvé

### **Rôles Disponibles**
- ❌ **"Survivante"** n'est PAS disponible sur le web (mobile uniquement)
- ✅ **Rôles professionnels** uniquement sur l'interface web

---

## 🧪 **Test Rapide**

### **Exemple d'Inscription Test**
```
Nom d'utilisateur: testuser123
Nom complet: Test Utilisateur  
Email: test@example.com
Téléphone: +243901234567
Mot de passe: TestPass123!
Rôle: Agent Psychosocial (APS)
```

---

## 📞 **Besoin d'Aide ?**

Si vous ne parvenez toujours pas à accéder à la page d'inscription :
1. ✅ Vérifiez que vous utilisez : `http://localhost:3000/register`
2. ✅ Confirmez que le frontend fonctionne : `http://localhost:3000/login`  
3. ✅ Redémarrez le frontend si nécessaire
4. ✅ Utilisez un navigateur différent (Chrome, Firefox, Safari)

---

*Guide créé le 25 octobre 2025 - Assistance Msaada 2.0*