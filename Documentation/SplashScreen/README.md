# Splash Screen - FamilySync

## Vue d'ensemble

La splash screen de FamilySync est la première interface que voit l'utilisateur lors du lancement de l'application. Elle reproduit fidèlement le design de l'image de référence avec un dégradé rose-orange, l'icône de l'app avec la famille dans la maison, et les textes appropriés.

## Architecture

### Structure des fichiers

```
Views/
├── SplashScreen/
│   ├── SplashScreenView.swift          # Vue principale
│   ├── SplashScreenViewModel.swift     # Logique métier
│   └── Components/                     # Composants spécifiques à la splash screen
│       ├── FamilyAppIcon.swift         # Icône de l'app
│       ├── StartButton.swift           # Bouton START
│       └── LoadingIndicator.swift      # Indicateur de chargement
└── Components/                         # Composants globaux
    └── AppleSignInButton.swift         # Bouton de connexion Apple
```

### Composants

#### 1. SplashScreenView
- **Responsabilité** : Affichage principal de la splash screen
- **Fonctionnalités** :
  - Dégradé de fond rose-orange
  - Affichage conditionnel des éléments selon l'état
  - Gestion de la première utilisation vs connexion
  - **Ombre orange légère** sur le texte "FamilySync" pour améliorer la lisibilité

#### 2. SplashScreenViewModel
- **Responsabilité** : Logique métier de la splash screen
- **Fonctionnalités** :
  - Détection de la première utilisation (UserDefaults)
  - Gestion de l'état d'authentification
  - Navigation vers l'écran principal

#### 3. FamilyAppIcon
- **Responsabilité** : Affichage de l'icône de l'app
- **Éléments** :
  - Utilise l'image `AppIcon` existante dans les assets
  - Redimensionnement automatique avec aspect ratio
  - Coins arrondis pour un rendu moderne

#### 4. StartButton
- **Responsabilité** : Bouton START avec style outline
- **Style** : Rectangle arrondi avec bordure blanche

#### 5. LoadingIndicator
- **Responsabilité** : Indicateur de chargement animé
- **Éléments** : Spinner rotatif + texte "Connecting..."

## Logique de fonctionnement

### Première utilisation
1. L'utilisateur voit la splash screen avec le bouton START
2. Clic sur START → marquage de la première utilisation
3. Navigation vers l'écran principal

### Utilisations suivantes
1. Affichage de la splash screen avec loading
2. Vérification de l'authentification (2 secondes de délai)
3. Si connecté → navigation automatique
4. Si non connecté → affichage du bouton de connexion

## Intégration

### Notification Center
- Utilisation de `NotificationCenter` pour la communication entre composants
- Notification `.splashScreenCompleted` pour déclencher la navigation

### Animations
- Transition fluide entre splash screen et écran principal
- Animation du spinner de chargement
- Effets de scale sur le bouton START

## Personnalisation

### Couleurs
- Dégradé : Rose clair (#FFE6E6) → Orange clair (#FFE6B3)
- Texte : Blanc (#FFFFFF)
- Icône : Couleurs pastel pour la famille

### Typographie
- App name : 32pt, bold, rounded
- Tagline : 16pt, regular, rounded
- Bouton : 18pt, bold, rounded

## Tests

### Preview SwiftUI
Chaque composant dispose d'un PreviewProvider pour validation visuelle rapide.

### Scénarios de test
1. Première utilisation
2. Utilisation avec utilisateur connecté
3. Utilisation avec utilisateur non connecté
4. Transition entre les états

## Maintenance

### Ajout de nouvelles fonctionnalités
- Respecter l'architecture MVVM
- Ajouter la documentation correspondante
- Tester les previews SwiftUI

### Modifications du design
- Maintenir la cohérence avec l'image de référence
- Tester sur différents appareils
- Valider l'accessibilité
