# 📚 Documentation FamilySync

## 🎯 Vue d'ensemble

FamilySync est une application iOS développée en SwiftUI qui utilise Appwrite comme backend pour l'authentification et la gestion des données utilisateur.

## 📁 Structure de la documentation

### 🔐 [Authentification](./Authentication/README.md)
- **Apple Sign-In** : Implémentation native avec Appwrite
- **Architecture MVVM** : Services et ViewModels
- **Gestion des sessions** : Persistance et sécurité

### 🏗️ [Architecture](./Architecture/README.md)
- **Structure du projet** : Organisation des dossiers
- **Services** : Couche métier et API
- **Composants** : Réutilisabilité et modularité

### 🧪 [Tests](./Tests/README.md)
- **Tests unitaires** : Validation de la logique métier
- **Tests UI** : Validation des interfaces utilisateur
- **Tests d'intégration** : Validation des flux complets

### 🚀 [Déploiement](./Deployment/README.md)
- **Configuration** : Variables d'environnement
- **Build** : Processus de compilation
- **Distribution** : App Store et TestFlight

## 🛠️ Technologies utilisées

- **Frontend** : SwiftUI, iOS 18.5+
- **Backend** : Appwrite (SDK Swift)
- **Authentification** : Apple Sign-In (AuthenticationServices)
- **Architecture** : MVVM avec Combine
- **Tests** : XCTest, SwiftUI Preview

## 📋 Prérequis

- Xcode 16+
- iOS 18.5+ (Simulateur ou appareil)
- Compte Apple Developer (pour Apple Sign-In)
- Projet Appwrite configuré

## 🚀 Démarrage rapide

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd FamilySync
   ```

2. **Configurer Appwrite**
   - Créer un projet Appwrite
   - Configurer Apple Sign-In OAuth2
   - Mettre à jour `AppwriteConfig.swift`

3. **Lancer l'application**
   ```bash
   xcodebuild -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```

## 📞 Support

Pour toute question ou problème :
- Consulter la documentation spécifique dans chaque section
- Vérifier les logs de debug dans la console Xcode
- Tester avec le simulateur iOS

---

*Dernière mise à jour : Septembre 2024*
