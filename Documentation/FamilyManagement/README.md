# Gestion des Familles - Onboarding 2

## Vue d'ensemble

L'étape 2 de l'onboarding permet aux utilisateurs de créer ou rejoindre une famille. Cette fonctionnalité est essentielle pour l'expérience collaborative de FamilySync.

## Fonctionnalités

### 1. Création d'une famille
- **Action** : L'utilisateur clique sur "Create New Family"
- **Processus** :
  1. Ouverture d'une modal pour saisir le nom de la famille
  2. Validation et création en base de données
  3. Génération automatique d'un `invite_code` unique
  4. Affichage du code d'invitation à l'utilisateur
  5. Passage à l'étape suivante de l'onboarding

### 2. Rejoindre une famille
- **Action** : L'utilisateur clique sur "Join Existing Family"
- **Processus** :
  1. Ouverture d'une modal pour saisir le code d'invitation
  2. Validation du code d'invitation
  3. Ajout de l'utilisateur à la famille
  4. Passage à l'étape suivante de l'onboarding

## Modèle de données

### Structure de la famille (Collection `families`)
```swift
struct Family: Codable {
    let id: String                    // $id (généré automatiquement)
    let familiesId: String            // ID unique de la famille
    let name: String                  // Nom de la famille
    let creatorId: String             // ID du créateur
    let members: [String]             // Array des IDs des membres
    let inviteCode: String            // Code d'invitation unique
    let createdAt: String             // $createdAt
    let updatedAt: String             // $updatedAt
}
```

### Structure de l'utilisateur (Mise à jour)
```swift
struct UserDocument: Codable {
    let id: String
    let userId: String
    let familyId: String?             // ID de la famille (optionnel)
    let createdAt: String
    let updatedAt: String
}
```

## Services

### FamilyDatabaseService
- `createFamily(name: String, creatorId: String) -> Family`
- `joinFamily(inviteCode: String, userId: String) -> Family`
- `getFamily(familyId: String) -> Family?`
- `updateFamily(familyId: String, data: [String: Any]) -> Family`
- `generateInviteCode() -> String`

### UserDatabaseService (Mise à jour)
- `updateUserFamily(userId: String, familyId: String) -> UserDocument`

## Interface utilisateur

### Modals
1. **CreateFamilyModal** : Saisie du nom de la famille
2. **JoinFamilyModal** : Saisie du code d'invitation
3. **InviteCodeModal** : Affichage du code généré

### États de chargement
- Indicateurs de chargement pendant les opérations réseau
- Gestion des erreurs avec messages utilisateur
- Validation des champs en temps réel

## Sécurité

- Validation du code d'invitation côté serveur
- Génération sécurisée des codes d'invitation
- Vérification des permissions d'accès aux familles
- Protection contre les attaques par force brute sur les codes

## Tests

- Tests unitaires pour les services de base de données
- Tests d'intégration pour les flux de création/rejoindre
- Tests UI pour les modals et la validation
- Tests de sécurité pour les codes d'invitation

