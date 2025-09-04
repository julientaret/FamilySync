# 📝 Changelog FamilySync

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.2] - 2025-09-04

### 🔧 Modifié
- **Amélioration de la vérification de familyId** : La méthode `isUserInFamilyAsync()` vérifie maintenant si le `familyId` n'est pas vide en plus de vérifier s'il n'est pas `nil`
- **Vérification de chaîne vide** : Ajout de `trimmingCharacters(in: .whitespacesAndNewlines).isEmpty` pour détecter les chaînes vides ou composées uniquement d'espaces

### 🐛 Corrigé
- **Problème de détection de famille** : L'utilisateur avait un `familyId` valide (68b98ba46881fc73e38d) mais la méthode ne vérifiait que si le champ était `nil`, pas s'il était vide
- **Logique de vérification incomplète** : La méthode ne prenait pas en compte les cas où le champ existe mais contient une chaîne vide

### 📚 Documentation
- **Vérification de familyId** : Clarification de la logique de vérification pour les champs non-null mais potentiellement vides

## [1.3.1] - 2025-09-04

### 🔧 Modifié
- **Amélioration de la détection de famille** : Correction de la logique asynchrone pour détecter correctement l'appartenance à une famille
- **Méthode isUserInFamilyAsync()** : Nouvelle méthode asynchrone pour vérifier l'appartenance à une famille directement en base de données
- **Méthode checkAndSkipStepsAsync()** : Version asynchrone qui attend le chargement des données avant de vérifier les étapes

### 🐛 Corrigé
- **Problème de détection de famille** : L'étape 2 s'affichait même quand l'utilisateur était déjà dans une famille
- **Timing des vérifications** : Les vérifications se faisaient avant que les données de famille soient chargées
- **Logique de passage automatique** : Amélioration pour s'assurer que les données sont disponibles avant de prendre les décisions

### 📚 Documentation
- **Détection asynchrone** : Clarification de la logique de détection de famille en base de données

## [1.3.0] - 2025-09-04

### 🎉 Ajouté
- **Passage automatique des étapes** : L'onboarding passe automatiquement les étapes 2 et 3 si l'utilisateur a déjà les informations nécessaires
- **Vérification de l'appartenance à une famille** : L'étape 2 est passée si l'utilisateur est déjà membre d'une famille
- **Vérification du profil utilisateur** : L'étape 3 est passée si l'utilisateur a déjà saisi son nom et sa date de naissance
- **Affichage des informations existantes** : Affichage des données déjà saisies dans les étapes correspondantes
- **Méthodes de vérification** : `isUserInFamily()` et `hasUserProfile()` dans OnboardingViewModel

### 🔧 Modifié
- **OnboardingViewModel** : Ajout de la logique de vérification et de passage automatique des étapes
- **OnboardingView2** : Affichage conditionnel selon l'appartenance à une famille
- **OnboardingView3** : Affichage conditionnel selon l'existence du profil utilisateur
- **Initialisation de l'onboarding** : Chargement automatique des données utilisateur au démarrage

### 📚 Documentation
- **Flux d'onboarding intelligent** : Documentation du nouveau système de passage automatique
- **Logique de vérification** : Explication des conditions de passage des étapes

## [1.2.0] - 2025-09-04

### 🎉 Ajouté
- **OnboardingView4** : Nouvelle vue de récapitulatif avec toutes les informations utilisateur
- **Étape de finalisation** : Écran de récapitulatif avant de terminer l'onboarding
- **Composant InfoRow** : Affichage structuré des informations avec icônes et couleurs
- **Bouton "Let's Go!"** : Finalisation de l'onboarding avec sauvegarde des données

### 🔧 Modifié
- **Navigation onboarding** : Ajout de l'étape 4 dans le flux de navigation
- **OnboardingViewModel** : Mise à jour pour passer à l'étape 4 au lieu de terminer directement
- **Méthode completeOnboarding()** : Amélioration avec sauvegarde complète des données

### 📚 Documentation
- **Flux onboarding complet** : Documentation du nouveau flux en 4 étapes

## [1.1.2] - 2025-09-04

### 🔧 Modifié
- **Simplification de la gestion des permissions** : Suppression de la logique complexe de permissions dans `joinFamily()` pour éviter les erreurs de format
- **Mise à jour sans permissions** : Utilisation de `updateDocument()` sans paramètre `permissions` pour préserver les permissions existantes

### 🐛 Corrigé
- **Erreur de permissions lors de la jointure** : L'erreur "Permissions must be one of: (any, users, user:apple_3f201280b-becb1a222809532d658a6, user:apple_3f201280b-becb1a222809532d658a6/unverified, users/unverified)" lors de la jointure d'une famille
- **Format d'ID utilisateur incorrect** : Suppression de la troncature d'ID utilisateur qui causait des problèmes de permissions
- **Gestion des permissions complexes** : Simplification pour éviter les conflits avec le format attendu par Appwrite

### 📚 Documentation
- **Gestion des permissions** : Clarification de l'approche simplifiée pour les permissions de famille

## [1.1.1] - 2025-09-04

### 🔧 Modifié
- **Correction du format des codes d'invitation** : Mise à jour de la validation pour accepter le format correct `CODE-TIMESTAMP`
- **Suppression de la limitation à 8 caractères** : Le champ de saisie accepte maintenant la longueur complète du code d'invitation
- **Mise à jour des messages d'erreur** : Messages plus clairs expliquant le format attendu

### 🐛 Corrigé
- **Limitation à 8 caractères** : Le champ de saisie pour rejoindre une famille limitait incorrectement à 8 caractères
- **Incohérence de validation** : La validation attendait 8 caractères alors que les codes générés font 16+ caractères
- **Messages d'erreur confus** : Messages ne correspondant pas au format réel des codes d'invitation

### 📚 Documentation
- **Format des codes d'invitation** : Clarification du format `CODE-TIMESTAMP` (ex: ABCD1234EFGH5678-ABC123)

## [1.1.0] - 2025-09-04

### 🎉 Ajouté
- **Enregistrement du profil utilisateur** : Sauvegarde du nom et de la date de naissance en base de données
- **Colonnes utilisateur** : Ajout des champs `name` et `birthday` dans la table `users`
- **Service de mise à jour de profil** : `UserDatabaseService.updateUserProfile()` pour sauvegarder les données
- **Validation des données** : Contrôles côté client et serveur pour le nom et la date
- **États de chargement** : Indicateur de progression pendant la sauvegarde
- **Gestion d'erreurs** : Messages d'erreur spécifiques pour différents cas d'usage
- **Documentation onboarding** : Guide complet de l'étape 3 de configuration du profil

### 🔧 Modifié
- **Modèle UserDocument** : Ajout des propriétés `name` et `birthday`
- **OnboardingViewModel** : Intégration de la logique de sauvegarde en base de données
- **OnboardingView3** : Interface utilisateur avec états de chargement et d'erreur
- **UserDatabaseService** : Mise à jour de toutes les méthodes pour inclure les nouveaux champs

### 🛡️ Sécurité
- **Validation des entrées** : Nettoyage des espaces dans le nom
- **Formatage sécurisé** : Dates au format `yyyy-MM-dd` pour éviter les injections
- **Authentification requise** : Vérification de l'utilisateur connecté avant sauvegarde

### 📚 Documentation
- **Documentation onboarding étape 3** : Guide technique complet
- **Flux de données** : Description détaillée du processus de sauvegarde
- **Gestion des erreurs** : Types d'erreurs et stratégies de récupération

## [1.0.0] - 2024-12-19

### 🎉 Ajouté
- **Authentification Apple Sign-In RGPD compliant** : Implémentation native sans collecte de données personnelles
- **Service d'authentification** : `AppleSignInService` avec anonymisation complète des données
- **Service de coordination** : `AuthService` pour la gestion des sessions
- **Interface utilisateur** : `AppleSignInButton` sans demande de données personnelles
- **Génération d'ID stable** : Hash SHA256 de l'Apple User ID pour éviter les duplications
- **Anonymisation des données** : Emails `@familysync.anonymous` et noms "Utilisateur"
- **Gestion des sessions** : Persistance et reconnexion automatique
- **Configuration Appwrite** : Connexion sécurisée au backend
- **Documentation complète** : Guides d'authentification, architecture, tests et déploiement

### 🔧 Modifié
- **Architecture MVVM** : Optimisée pour la conformité RGPD
- **Gestion d'état** : Centralisée dans `AuthService` avec `@Published` properties
- **Flux d'authentification** : Simplifié et sécurisé

### 🛡️ Sécurité
- **Conformité RGPD** : Aucune collecte de données personnelles
- **Anonymisation** : Hashage SHA256 des identifiants
- **Anti-duplication** : IDs stables pour éviter les comptes multiples
- **Validation** : Contrôles stricts des données d'entrée

### 📚 Documentation
- **README principal** : Vue d'ensemble du projet
- **Documentation d'authentification** : Guide technique RGPD compliant
- **Documentation d'architecture** : Structure MVVM et flux de données
- **Documentation des tests** : Stratégie de tests complète
- **Documentation de déploiement** : Guide de mise en production

### 🧪 Tests
- **Tests unitaires** : Couverture complète des services d'authentification
- **Tests d'intégration** : Validation du flux d'authentification complet
- **Tests UI** : Interface utilisateur et accessibilité
- **Tests RGPD** : Validation de la conformité

### 🚀 Déploiement
- **Scripts de build** : Automatisation du processus de compilation
- **Configuration CI/CD** : GitHub Actions et Fastlane
- **Validation RGPD** : Scripts de vérification automatique
- **Monitoring** : Métriques anonymisées et logs de sécurité

## [0.9.0] - 2024-12-18

### 🔄 Modifié
- **Revert vers Apple Sign-In natif** : Abandon de l'approche OAuth2 web
- **Correction des IDs utilisateur** : Implémentation du hashage SHA256
- **Validation des noms** : Gestion des cas limites et fallbacks

### 🐛 Corrigé
- **Erreur "Invalid userId param"** : Génération d'ID conforme aux règles Appwrite
- **Erreur "Invalid name param"** : Validation et fallback pour les noms vides
- **Duplication de comptes** : IDs stables pour éviter les créations multiples

## [0.8.0] - 2024-12-17

### 🔄 Modifié
- **Implémentation OAuth2 Appwrite** : Utilisation de `account.createOAuth2Session('apple')`
- **Nettoyage du code** : Suppression de l'ancien système d'authentification
- **Configuration callback** : URL Appwrite pour Apple Sign-In

### 🐛 Corrigé
- **"Inscription non terminée"** : Problèmes avec le flux web OAuth2

## [0.7.0] - 2024-12-16

### 🔄 Modifié
- **Revert vers Apple Sign-In natif** : Résolution des problèmes OAuth2
- **Génération d'ID stable** : Hashage de l'Apple User ID pour éviter les duplications
- **Session persistante** : Gestion de la reconnexion automatique

### 🐛 Corrigé
- **"User cancelled login"** : Problèmes récurrents avec l'authentification
- **Création de nouveaux utilisateurs** : IDs stables pour maintenir la cohérence

## [0.6.0] - 2024-12-15

### 🔄 Modifié
- **Approche OAuth2 web** : Tentative d'utilisation du flux web Appwrite
- **Configuration deep linking** : Setup pour les callbacks OAuth2

### 🐛 Corrigé
- **"Inscription non terminée"** : Problèmes avec le flux web

## [0.5.0] - 2024-12-14

### 🔄 Modifié
- **Apple Sign-In natif** : Implémentation avec `AuthenticationServices`
- **Gestion des credentials** : Traitement des données Apple
- **Intégration Appwrite** : Création et connexion d'utilisateurs

### 🐛 Corrigé
- **"User cancelled login"** : Problèmes avec l'authentification Apple

## [0.4.0] - 2024-12-13

### 🎉 Ajouté
- **Bouton Apple Sign-In** : Interface utilisateur pour l'authentification
- **Service d'authentification** : Première version du service Apple Sign-In

### 🔧 Modifié
- **Interface utilisateur** : Intégration du bouton de connexion

## [0.3.0] - 2024-12-12

### 🎉 Ajouté
- **Services d'authentification** : Structure de base pour Apple Sign-In et OAuth2
- **Configuration Appwrite** : Setup de la connexion backend

### 🔧 Modifié
- **Architecture** : Organisation des services dans le dossier `Services/Auth`

## [0.2.0] - 2024-12-11

### 🔄 Modifié
- **Nettoyage du projet** : Suppression de tout le code d'authentification existant
- **État primaire** : Retour à une connexion Appwrite basique avec bouton ping

### 🗑️ Supprimé
- **Anciens services d'authentification** : Code legacy supprimé
- **Configurations OAuth2** : Anciennes configurations retirées

## [0.1.0] - 2024-12-10

### 🎉 Ajouté
- **Projet FamilySync** : Création initiale du projet iOS
- **Configuration de base** : Setup Xcode et dépendances
- **Connexion Appwrite** : Première implémentation de la connexion backend
- **Bouton ping** : Test de connectivité Appwrite

### 🔧 Modifié
- **Structure du projet** : Organisation MVVM de base

---

## 📋 Types de changements

- **🎉 Ajouté** : Nouvelles fonctionnalités
- **🔧 Modifié** : Changements dans les fonctionnalités existantes
- **🐛 Corrigé** : Corrections de bugs
- **🗑️ Supprimé** : Suppression de fonctionnalités
- **🛡️ Sécurité** : Améliorations de sécurité
- **📚 Documentation** : Mises à jour de la documentation
- **🧪 Tests** : Ajouts ou modifications de tests
- **🚀 Déploiement** : Changements liés au déploiement
