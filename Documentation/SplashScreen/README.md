# SplashScreen - Documentation

## Vue d'ensemble

Le SplashScreen est l'écran d'accueil de l'application FamilySync qui gère l'affichage initial et la navigation vers les différentes étapes de l'application.

## Architecture

### Structure des fichiers

```
Views/SplashScreen/
├── SplashScreenView.swift          # Vue principale du splash screen
├── SplashScreenViewModel.swift     # ViewModel gérant la logique métier
└── Components/
    ├── FamilyAppIcon.swift         # Icône de l'application
    ├── LoadingIndicator.swift      # Indicateur de chargement
    ├── StartButton.swift           # Bouton de démarrage (première utilisation)
    └── LoginButton.swift           # Bouton de connexion (nouveau)
```

## Fonctionnalités

### États du SplashScreen

Le SplashScreen peut être dans trois états différents :

1. **Première utilisation** (`isFirstLaunch = true`)
   - Affiche le bouton "Commencer" (`StartButton`)
   - Permet à l'utilisateur de démarrer l'onboarding

2. **Chargement** (`isLoading = true`)
   - Affiche l'indicateur de chargement (`LoadingIndicator`)
   - Vérifie l'état d'authentification de l'utilisateur

3. **Utilisateur non connecté** (`showLoginButton = true`)
   - Affiche le bouton "Se connecter" (`LoginButton`)
   - Permet à l'utilisateur de naviguer vers l'onboarding pour se connecter

### Logique de navigation

```swift
// Dans SplashScreenViewModel
func checkAuthenticationStatus(authService: AuthService) {
    if !isFirstLaunch {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
            
            await MainActor.run {
                if authService.isAuthenticated {
                    shouldNavigateToMain = true
                    NotificationCenter.default.post(name: .splashScreenCompleted, object: nil)
                } else {
                    // Si pas connecté, on affiche le bouton de connexion
                    isLoading = false
                    showLoginButton = true
                }
            }
        }
    }
}
```

## Problème résolu

### Problème initial
- Quand l'utilisateur n'était pas connecté, le splash screen affichait un indicateur de chargement puis ne montrait rien
- L'utilisateur ne pouvait pas naviguer vers l'onboarding pour se connecter

### Solution implémentée

1. **Ajout d'une nouvelle propriété** dans `SplashScreenViewModel` :
   ```swift
   @Published var showLoginButton: Bool = false
   ```

2. **Modification de la logique d'authentification** :
   - Quand l'utilisateur n'est pas connecté après le délai de chargement
   - `isLoading` passe à `false`
   - `showLoginButton` passe à `true`

3. **Création du composant `LoginButton`** :
   - Bouton stylisé avec les couleurs de l'application
   - Action pour naviguer vers l'onboarding
   - Design cohérent avec les autres composants

4. **Mise à jour de la vue** :
   ```swift
   if viewModel.isFirstLaunch {
       StartButton(action: viewModel.startApp)
   } else if viewModel.isLoading {
       LoadingIndicator()
   } else if viewModel.showLoginButton {
       LoginButton(action: viewModel.proceedToLogin)
   }
   ```

## Composants

### LoginButton

Nouveau composant créé pour permettre la connexion depuis le splash screen.

**Caractéristiques :**
- Design cohérent avec l'identité visuelle
- Gradient de couleurs coral/saumon
- Icône utilisateur
- Animation au toucher
- Ombre portée pour la profondeur

**Utilisation :**
```swift
LoginButton(action: viewModel.proceedToLogin)
```

## Flux utilisateur

1. **Première utilisation** : SplashScreen → Onboarding
2. **Utilisateur connecté** : SplashScreen → ContentView (écran principal)
3. **Utilisateur non connecté** : SplashScreen → Onboarding (pour connexion)

## Tests

Le build a été testé avec succès :
```bash
xcodebuild -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Maintenance

### Points d'attention
- Vérifier que le délai de chargement (2 secondes) est approprié
- S'assurer que la navigation vers l'onboarding fonctionne correctement
- Maintenir la cohérence visuelle avec les autres écrans

### Évolutions possibles
- Ajouter des animations de transition
- Personnaliser le délai de chargement selon les besoins
- Ajouter des analytics pour suivre l'usage
