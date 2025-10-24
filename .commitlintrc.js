module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Type énumération (obligatoire)
    'type-enum': [
      2,
      'always',
      [
        'feat',      // ✨ Nouvelle fonctionnalité
        'fix',       // 🐛 Correction de bug
        'docs',      // 📚 Documentation uniquement
        'style',     // 💄 Changements qui n'affectent pas le sens du code
        'refactor',  // ♻️ Changement de code qui ne corrige pas de bug ni n'ajoute de fonctionnalité
        'perf',      // ⚡️ Changement de code qui améliore les performances
        'test',      // ✅ Ajout de tests manquants ou correction de tests existants
        'build',     // 🛠️ Changements qui affectent le système de build ou les dépendances externes
        'ci',        // 👷 Changements dans les fichiers et scripts de configuration CI
        'chore',     // 🔧 Autres changements qui ne modifient pas les fichiers src ou test
        'revert',    // ⏪ Annule un commit précédent
        'security',  // 🔒 Correction de sécurité
        'deps'       // ⬆️ Mise à jour des dépendances
      ]
    ],
    
    // Scope énumération (optionnel mais recommandé)
    'scope-enum': [
      2,
      'always',
      [
        'api',       // Backend Laravel
        'web',       // Frontend React
        'mobile',    // Application Flutter
        'shared',    // Code/types partagés
        'docs',      // Documentation
        'ci',        // CI/CD
        'infra',     // Infrastructure
        'config',    // Configuration
        'deps',      // Dépendances
        'release'    // Release/version
      ]
    ],
    
    // Règles de format
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-leading-blank': [1, 'always'],
    'body-max-line-length': [2, 'always', 100],
    'footer-leading-blank': [1, 'always'],
    'footer-max-line-length': [2, 'always', 100]
  }
}