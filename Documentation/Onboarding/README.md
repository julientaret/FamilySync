# Onboarding Flow - FamilySync

## Vue d'ensemble

L'onboarding de FamilySync est un flux en 3 étapes conçu pour guider les nouveaux utilisateurs à travers la configuration initiale de leur compte et de leur famille.

## Architecture

### Structure des fichiers

```
FamilySync/Views/Onboarding/
├── OnboardingView1.swift          # Étape 1: Connexion Apple
├── OnboardingView2.swift          # Étape 2: Création/Rejoindre une famille
├── OnboardingView3.swift          # Étape 3: Configuration du profil
├── OnboardingViewModel.swift     # Logique métier et navigation
└── Components/
    ├── OnboardingStep.swift      # Composant d'étape
    └── OnboardingStyles.swift    # Styles et composants partagés
```

### Flux de navigation

```
SplashScreen → OnboardingView1 → OnboardingView2 → OnboardingView3 → ContentView
```

## Étapes détaillées

### Étape 1: Connexion Apple (`OnboardingView1`)

**Objectif:** Authentification de l'utilisateur via Apple Sign In

**Composants:**
- Titre: "Start with FamilySync"
- Étapes de progression avec indicateurs visuels
- Illustration: `onboard1`
- Bouton "Sign in with Apple"

**Logique:**
- Utilise `AppleSignInButton` pour l'authentification
- Écoute les changements d'état via `authService.$isAuthenticated`
- Passe automatiquement à l'étape 2 après authentification réussie

### Étape 2: Création/Rejoindre une famille (`OnboardingView2`)

**Objectif:** Permettre à l'utilisateur de créer une nouvelle famille ou rejoindre une existante

**Composants:**
- Titre: "Create or Join Your Family"
- Étapes de progression (étape 2 active)
- Illustration: `onboard2`
- Deux boutons d'action:
  - "Create New Family" (primaire)
  - "Join Existing Family" (secondaire)

**Logique:**
- Les deux actions passent à l'étape 3
- Préparation pour la logique métier future (création/rejoindre famille)

### Étape 3: Configuration du profil (`OnboardingView3`)

**Objectif:** Collecter les informations de base de l'utilisateur

**Composants:**
- Titre: "Tell us about Yourself"
- Étapes de progression (étape 3 active)
- Illustration: `onboard3`
- Champs de saisie:
  - Nom d'utilisateur (obligatoire)
  - Date de naissance (jour et mois)
- Bouton "It's Ok!" (activé uniquement si le nom est saisi)

**Styles personnalisés:**
- `OnboardingTextFieldStyle`: Champs de texte avec ombre et coins arrondis
- `OnboardingDatePickerStyle`: Sélecteur de date stylisé

## ViewModel (`OnboardingViewModel`)

### Propriétés principales

```swift
@Published var shouldShowOnboarding: Bool = false
@Published var isAuthenticated: Bool = false
@Published var currentOnboardingStep: Int = 1
@Published var userName: String = ""
@Published var userBirthday: Date = Date()
```

### Méthodes clés

- `checkOnboardingStatus(authService:)`: Détermine si l'onboarding doit être affiché
- `handleAuthenticationSuccess()`: Gère la transition après authentification
- `handleProfileSetup(name:birthday:)`: Sauvegarde les données utilisateur et termine l'onboarding
- `nextStep()` / `previousStep()`: Navigation entre les étapes

### Persistance des données

Les données utilisateur sont sauvegardées dans `UserDefaults`:
- `userName`: Nom de l'utilisateur
- `userBirthday`: Date de naissance
- `hasSeenOnboarding`: Flag pour éviter de re-afficher l'onboarding

## Intégration avec l'application

### Navigation dans `FamilySyncApp.swift`

```swift
switch onboardingViewModel.currentOnboardingStep {
case 1:
    OnboardingView1()
case 2:
    OnboardingView2()
case 3:
    OnboardingView3()
default:
    OnboardingView1()
}
```

### Conditions d'affichage

L'onboarding s'affiche si:
1. Première utilisation de l'application (`!hasSeenOnboarding`)
2. OU si l'utilisateur n'est pas authentifié (`!isAuthenticated`)

## Styles et Design

### Couleurs
- Fond: Dégradé orange peach vers blanc
- Texte principal: Orange `#e9906f`
- Boutons: Orange `#e9906f` avec coins arrondis
- Champs de saisie: Blanc avec ombre légère

### Typographie
- Titres: System Rounded, Bold/Black
- Texte: System Medium
- Tailles adaptatives pour l'accessibilité

### Animations
- Transitions fluides entre les étapes
- Animations d'apparition pour les éléments UI
- Feedback visuel sur les interactions

## Accessibilité

- Support VoiceOver complet
- Dynamic Type pour les tailles de texte
- Contraste suffisant pour la lisibilité
- Navigation au clavier pour les champs de saisie

## Tests

### Tests unitaires recommandés
- `OnboardingViewModel.checkOnboardingStatus()`
- `OnboardingViewModel.handleProfileSetup()`
- Persistance des données dans UserDefaults

### Tests UI recommandés
- Flux complet de l'onboarding
- Validation des champs de saisie
- Navigation entre les étapes
- Gestion des erreurs d'authentification

## Évolutions futures

### Fonctionnalités prévues
- Validation avancée des champs de saisie
- Intégration avec l'API backend pour la création de famille
- Support de plusieurs langues
- Personnalisation des illustrations selon le contexte

### Améliorations techniques
- Migration vers Core Data pour la persistance
- Gestion d'état plus robuste avec Combine
- Tests automatisés complets
- Analytics pour mesurer l'engagement utilisateur

# Onboarding - Étape 3 : Configuration du Profil Utilisateur

## Vue d'ensemble

L'étape 3 de l'onboarding permet à l'utilisateur de configurer son profil en saisissant son nom et sa date de naissance. Ces informations sont ensuite enregistrées en base de données dans la table `users`.

## Fonctionnalités

### Champs de saisie
- **Nom** : Champ de texte pour saisir le nom de l'utilisateur
- **Date de naissance** : Sélecteur de date pour choisir la date de naissance

### Validation
- Le nom ne peut pas être vide (espaces et retours à la ligne sont supprimés)
- La date de naissance est toujours valide (sélecteur natif iOS)

### Enregistrement en base de données
- Les données sont sauvegardées dans les colonnes `name` et `birthday` de la table `users`
- La date est formatée au format `yyyy-MM-dd` pour le stockage
- L'utilisateur doit être authentifié pour que l'enregistrement fonctionne

## Architecture

### Modèle de données
```swift
struct UserDocument: Codable {
    let id: String
    let userId: String
    let familyId: String?
    let name: String?
    let birthday: String?
    let createdAt: String
    let updatedAt: String
}
```

### Service de base de données
- `UserDatabaseService.updateUserProfile()` : Met à jour le profil utilisateur
- `UserDatabaseService.ensureUserExists()` : S'assure que l'utilisateur existe en base

### ViewModel
- `OnboardingViewModel.handleProfileSetup()` : Gère la logique de sauvegarde
- États de chargement et d'erreur pour une meilleure UX

## Interface utilisateur

### États visuels
- **Normal** : Bouton "It's Ok!" activé si le nom n'est pas vide
- **Chargement** : Indicateur de progression et texte "Sauvegarde..."
- **Erreur** : Message d'erreur affiché en rouge sous le bouton

### Validation en temps réel
- Le bouton est désactivé si le nom est vide
- L'opacité du bouton change selon l'état de validation

## Flux de données

1. L'utilisateur saisit son nom et sa date de naissance
2. Il clique sur le bouton "It's Ok!"
3. Validation des données côté client
4. Récupération de l'ID utilisateur depuis le service d'authentification
5. Vérification de l'existence de l'utilisateur en base
6. Mise à jour du profil avec les nouvelles données
7. Sauvegarde locale des données
8. Passage à l'étape suivante ou fin de l'onboarding

## Gestion des erreurs

### Types d'erreurs
- **Nom vide** : "Le nom ne peut pas être vide"
- **Utilisateur non connecté** : "Erreur: Utilisateur non connecté"
- **Erreur réseau/base de données** : Message d'erreur spécifique

### Récupération
- Les erreurs sont affichées à l'utilisateur
- L'état de chargement est réinitialisé
- L'utilisateur peut réessayer

## Sécurité

- Validation côté client et serveur
- Utilisation de l'ID utilisateur authentifié
- Formatage sécurisé des dates
- Nettoyage des espaces dans le nom

## Tests

### Tests unitaires recommandés
- Validation du nom (vide, espaces, caractères spéciaux)
- Formatage des dates
- Gestion des erreurs réseau
- États de chargement

### Tests d'intégration
- Flux complet de sauvegarde
- Synchronisation avec la base de données
- Persistance locale des données
