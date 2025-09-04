# Plan de Développement - Gestion des Familles

## TODOs

### Phase 1: Modèles et Services ✅
- [x] **TODO 1.1** : Créer le modèle `Family` avec Codable
- [x] **TODO 1.2** : Créer `FamilyDatabaseService` avec les méthodes CRUD
- [x] **TODO 1.3** : Mettre à jour `UserDocument` pour inclure `familyId`
- [x] **TODO 1.4** : Ajouter `updateUserFamily` dans `UserDatabaseService`
- [x] **TODO 1.5** : Créer la fonction de génération de codes d'invitation

### Phase 2: ViewModels ✅
- [x] **TODO 2.1** : Créer `FamilyManagementViewModel` pour gérer l'état
- [x] **TODO 2.2** : Ajouter les propriétés pour les modals dans `OnboardingViewModel`
- [x] **TODO 2.3** : Implémenter la logique de création de famille
- [x] **TODO 2.4** : Implémenter la logique de rejoindre une famille
- [x] **TODO 2.5** : Gérer les états de chargement et d'erreur

### Phase 3: Interface Utilisateur ✅
- [x] **TODO 3.1** : Créer `CreateFamilyModal` avec validation
- [x] **TODO 3.2** : Créer `JoinFamilyModal` avec validation
- [x] **TODO 3.3** : Créer `InviteCodeModal` pour afficher le code
- [x] **TODO 3.4** : Mettre à jour `OnboardingView2` pour intégrer les modals
- [x] **TODO 3.5** : Ajouter les indicateurs de chargement

### Phase 4: Intégration et Tests ✅
- [x] **TODO 4.1** : Intégrer les services dans l'application
- [x] **TODO 4.2** : Tester le flux de création de famille
- [x] **TODO 4.3** : Tester le flux de rejoindre une famille
- [x] **TODO 4.4** : Valider la gestion des erreurs
- [x] **TODO 4.5** : Tests de compilation et build

## Ordre d'exécution

1. **Commencer par Phase 1** : Les modèles et services sont la base ✅
2. **Phase 2** : Les ViewModels gèrent la logique métier ✅
3. **Phase 3** : L'interface utilisateur pour l'interaction ✅
4. **Phase 4** : Tests et intégration finale ✅

## Points d'attention

- Respecter l'architecture MVVM ✅
- Gérer les erreurs réseau et de validation ✅
- Maintenir la cohérence avec l'existant ✅
- Documenter les nouvelles fonctionnalités ✅
- Tester à chaque étape ✅

## Résumé de l'implémentation

✅ **Modèle Family** : Créé avec Codable et Equatable
✅ **FamilyDatabaseService** : Service complet avec CRUD et gestion des codes d'invitation
✅ **UserDatabaseService** : Mis à jour pour inclure familyId
✅ **FamilyManagementViewModel** : Gestion complète de l'état et de la logique métier
✅ **Modals** : CreateFamilyModal, JoinFamilyModal, InviteCodeModal
✅ **Intégration** : OnboardingView2 mis à jour avec les modals
✅ **Compilation** : Projet compile sans erreurs
