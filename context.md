# Contexte Technique

## Stack choisi
- Backend: Laravel 11
- Frontend: React 18 + TypeScript
- Mobile: Flutter 3.19
- BDD: MySQL 8

## Conventions
- Nommage API: snake_case
- Nommage React: camelCase
- Prefix tables: pas de prefix

## Structure réponses API
{
  "success": true,
  "data": {},
  "message": "Success"
}
```

Collez ce contexte au début de chaque conversation importante.

### 2. Template de prompt pour composants similaires

Une fois qu'un composant marche bien, réutilisez le prompt :
```
"En suivant EXACTEMENT la même structure que le composant 
CaseListPage que tu m'as créé (avec filtres, pagination, etc.),
crée maintenant le composant OrganizationListPage avec les champs
[lister les champs spécifiques]"
```

### 3. Debug avec Claude
```
"J'ai cette erreur : [coller l'erreur]

Voici mon code : [coller le code problématique]

Explique-moi l'erreur et donne-moi le code corrigé."
```

### 4. Revue de code
```
"Peux-tu revoir ce code et me suggérer des améliorations :
- Sécurité
- Performance
- Lisibilité
- Best practices Laravel/React

[Coller le code]"
```

---

## 🎯 CHECKLIST AVANT DE COMMENCER

- [ ] J'ai lu et compris les spécifications complètes
- [ ] J'ai découpé le projet en petites tâches (max 2h chacune)
- [ ] J'ai mon environnement de développement prêt (Laravel, Node, Flutter)
- [ ] J'ai créé un repo Git pour versionner mon code
- [ ] J'ai un fichier PROGRESS.md pour suivre l'avancement
- [ ] J'ai un fichier CONTEXT.md avec les décisions techniques
- [ ] Je sais que je vais itérer : V1 simple → amélioration progressive

---

## 🚀 COMMENCEZ MAINTENANT

**Votre première conversation avec Claude devrait être :**
```
Je veux développer une plateforme de signalement VBG. 
Voici le document complet des spécifications : [coller votre document]

Pour commencer, aide-moi à :
1. Créer la structure de la base de données MySQL complète
2. Générer les migrations Laravel pour les 5 tables principales :
   - users
   - roles
   - reports
   - organizations
   - referrals

Donne-moi le code complet de chaque migration, avec les relations
et index nécessaires. Format : un artifact par migration.