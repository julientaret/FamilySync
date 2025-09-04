# Onboarding - FamilySync

## Vue d'ensemble

L'onboarding de FamilySync est l'écran d'accueil qui s'affiche lors de la première utilisation de l'application OU si l'utilisateur n'est pas authentifié. Il guide l'utilisateur à travers les étapes nécessaires pour commencer à utiliser l'application.

## Architecture

### Structure des fichiers

```
Views/
├── Onboarding/
│   ├── OnboardingView1.swift         # Vue principale (première vue)
│   ├── OnboardingViewModel.swift     # Logique métier
│   └── Components/                   # Composants spécifiques à l'onboarding
│       └── OnboardingStep.swift      # Composant pour chaque étape
```

### Composants

#### 1. OnboardingView1
- **Responsabilité** : Affichage principal de l'onboarding (première vue)
- **Fonctionnalités** :
  - Fond peach chaleureux
  - Titre "Start with FamilySync"
  - Liste des étapes avec checkmarks
  - Illustration `family_onboard`
  - Bouton Sign In With Apple
  - Gestion de l'authentification réussie

#### 2. OnboardingViewModel
- **Responsabilité** : Logique métier de l'onboarding
- **Fonctionnalités** :
  - Vérification du statut d'onboarding
  - Gestion de la première utilisation
  - Gestion de l'état d'authentification
  - Marquage de l'onboarding comme terminé

#### 3. OnboardingStep
- **Responsabilité** : Affichage d'une étape individuelle
- **Éléments** :
  - Icône de checkmark
  - Texte descriptif
  - Couleur orange cohérente avec le design

## Logique de Navigation

### Conditions d'affichage
L'onboarding s'affiche dans deux cas :
1. **Première utilisation** : L'utilisateur n'a jamais vu l'onboarding
2. **Non authentifié** : L'utilisateur n'est pas connecté

### Flux utilisateur
1. **Splash Screen** → **Onboarding** (si première utilisation ou non authentifié)
2. **Onboarding** → **Sign In With Apple** (quand l'utilisateur clique sur le bouton)
3. **Authentification réussie** → **Écran principal** (automatique)

## Design

### Couleurs
- **Fond** : Peach chaleureux (`Color(red: 0.98, green: 0.95, blue: 0.92)`)
- **Titre** : Orange (`Color(red: 1.0, green: 0.6, blue: 0.3)`)
- **Texte des étapes** : Orange cohérent
- **Icônes** : Gris pour les checkmarks

### Typographie
- **Titre** : `system(size: 32, weight: .bold, design: .rounded)`
- **Étapes** : `system(size: 18, weight: .medium, design: .rounded)`

### Espacement
- **VStack principal** : 40 points entre les sections
- **Étapes** : 20 points entre chaque étape
- **Padding horizontal** : 40 points pour les marges

## Intégration

### Dans FamilySyncApp.swift
```swift
if onboardingViewModel.shouldShowOnboarding {
    OnboardingView1()
        .environmentObject(authService)
        .environmentObject(onboardingViewModel)
} else {
    ContentView()
        .environmentObject(appwriteService)
        .environmentObject(authService)
}
```

### Gestion de l'authentification
L'onboarding écoute les changements d'état d'authentification via `onReceive(authService.$isAuthenticated)` et appelle automatiquement `onboardingViewModel.handleAuthenticationSuccess()` quand l'utilisateur se connecte avec succès.

## Tests

### Scénarios à tester
1. **Première utilisation** : L'onboarding s'affiche
2. **Utilisateur non authentifié** : L'onboarding s'affiche
3. **Authentification réussie** : Transition vers l'écran principal
4. **Utilisateur déjà authentifié** : Pas d'onboarding

### Preview
```swift
#Preview {
    OnboardingView1()
        .environmentObject(AuthService.shared)
}
```

## Maintenance

### UserDefaults Keys
- `hasSeenOnboarding` : Bool pour marquer si l'onboarding a été vu

### Extensions futures
- Possibilité d'ajouter plus d'étapes
- Animations entre les étapes
- Personnalisation selon le type d'utilisateur
