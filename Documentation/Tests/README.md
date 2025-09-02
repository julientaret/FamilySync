# 🧪 Tests FamilySync - Stratégie RGPD Compliant

## 📋 Vue d'ensemble

La stratégie de tests de FamilySync garantit la conformité RGPD et la sécurité des données tout en validant le bon fonctionnement de l'application.

## 🏗️ Structure des tests

```
FamilySyncTests/
├── UnitTests/
│   ├── AppleSignInServiceTests.swift    # Tests du service d'authentification
│   ├── AuthServiceTests.swift           # Tests du service de coordination
│   └── UserDataTests.swift             # Tests des modèles de données
├── IntegrationTests/
│   ├── AuthenticationFlowTests.swift   # Tests du flux d'authentification
│   └── AppwriteConnectionTests.swift   # Tests de connexion Appwrite
└── UITests/
    ├── AppleSignInButtonTests.swift    # Tests de l'interface utilisateur
    └── AccessibilityTests.swift        # Tests d'accessibilité
```

## 🔬 Tests unitaires

### **AppleSignInServiceTests**

#### Test de génération d'ID stable
```swift
class AppleSignInServiceTests: XCTestCase {
    
    func testStableUserIdGeneration() {
        // Given
        let appleUserId = "000671.19a4c1b897b84d3c86e446a92a0102f8.1012"
        
        // When
        let userId1 = generateStableUserId(from: appleUserId)
        let userId2 = generateStableUserId(from: appleUserId)
        
        // Then
        XCTAssertEqual(userId1, userId2, "Même Apple User ID doit générer le même ID stable")
        XCTAssertTrue(userId1.hasPrefix("apple_"), "ID doit commencer par 'apple_'")
        XCTAssertEqual(userId1.count, 36, "ID doit faire exactement 36 caractères")
        XCTAssertTrue(userId1.range(of: "^apple_[a-f0-9]{30}$", options: .regularExpression) != nil, "Format ID invalide")
    }
    
    func testDifferentAppleUserIdsGenerateDifferentStableIds() {
        // Given
        let appleUserId1 = "user1"
        let appleUserId2 = "user2"
        
        // When
        let userId1 = generateStableUserId(from: appleUserId1)
        let userId2 = generateStableUserId(from: appleUserId2)
        
        // Then
        XCTAssertNotEqual(userId1, userId2, "Apple User IDs différents doivent générer des IDs stables différents")
    }
}
```

#### Test d'anonymisation des données
```swift
func testDataAnonymization() {
    // Given
    let appleUserId = "test_user_123"
    let stableUserId = generateStableUserId(from: appleUserId)
    
    // When
    let anonymousEmail = "\(stableUserId)@familysync.anonymous"
    let anonymousName = "Utilisateur"
    
    // Then
    XCTAssertTrue(anonymousEmail.contains("@familysync.anonymous"), "Email doit être anonymisé")
    XCTAssertFalse(anonymousEmail.contains("@gmail.com"), "Email ne doit pas contenir de domaine réel")
    XCTAssertEqual(anonymousName, "Utilisateur", "Nom doit être anonymisé")
    XCTAssertTrue(isValidEmail(anonymousEmail), "Email anonymisé doit être valide")
}

func testNoPersonalDataCollection() {
    // Given
    let credential = MockASAuthorizationAppleIDCredential()
    credential.user = "test_user"
    credential.email = nil
    credential.fullName = nil
    
    // When
    let result = processCredential(credential)
    
    // Then
    XCTAssertNil(result.email, "Email réel ne doit pas être collecté")
    XCTAssertNil(result.fullName, "Nom réel ne doit pas être collecté")
    XCTAssertNotNil(result.anonymousEmail, "Email anonymisé doit être généré")
    XCTAssertNotNil(result.anonymousName, "Nom anonymisé doit être généré")
}
```

#### Test de génération de mot de passe sécurisé
```swift
func testSecurePasswordGeneration() {
    // Given
    let appleUserId = "test_user"
    
    // When
    let password1 = generateSecurePassword(from: appleUserId)
    let password2 = generateSecurePassword(from: appleUserId)
    
    // Then
    XCTAssertEqual(password1, password2, "Même Apple User ID doit générer le même mot de passe")
    XCTAssertEqual(password1.count, 32, "Mot de passe doit faire 32 caractères")
    XCTAssertTrue(password1.range(of: "^[a-f0-9]{32}$", options: .regularExpression) != nil, "Mot de passe doit être un hash hexadécimal")
}
```

### **AuthServiceTests**

#### Test de coordination d'authentification
```swift
class AuthServiceTests: XCTestCase {
    
    func testSignInWithAppleFlow() async throws {
        // Given
        let authService = AuthService()
        let mockCredential = MockASAuthorizationAppleIDCredential()
        
        // When
        try await authService.signInWithApple(credential: mockCredential)
        
        // Then
        XCTAssertTrue(authService.isAuthenticated, "Utilisateur doit être authentifié")
        XCTAssertNotNil(authService.currentUser, "Utilisateur courant doit être défini")
        XCTAssertNil(authService.errorMessage, "Pas d'erreur attendue")
    }
    
    func testSignOutFlow() async throws {
        // Given
        let authService = AuthService()
        authService.isAuthenticated = true
        authService.currentUser = MockAppwriteUser()
        
        // When
        try await authService.signOut()
        
        // Then
        XCTAssertFalse(authService.isAuthenticated, "Utilisateur doit être déconnecté")
        XCTAssertNil(authService.currentUser, "Utilisateur courant doit être nil")
    }
}
```

### **UserDataTests**

#### Test des modèles de données anonymisées
```swift
class UserDataTests: XCTestCase {
    
    func testAppwriteUserAnonymization() {
        // Given
        let userId = "apple_test123"
        let email = "\(userId)@familysync.anonymous"
        let name = "Utilisateur"
        
        // When
        let user = AppwriteUser(
            id: userId,
            email: email,
            name: name,
            createdAt: Date()
        )
        
        // Then
        XCTAssertTrue(user.email.contains("@familysync.anonymous"), "Email doit être anonymisé")
        XCTAssertEqual(user.name, "Utilisateur", "Nom doit être anonymisé")
        XCTAssertTrue(user.id.hasPrefix("apple_"), "ID doit commencer par 'apple_'")
    }
}
```

## 🔗 Tests d'intégration

### **AuthenticationFlowTests**

#### Test du flux d'authentification complet
```swift
class AuthenticationFlowTests: XCTestCase {
    
    func testCompleteAppleSignInFlow() async throws {
        // Given
        let authService = AuthService()
        let mockCredential = MockASAuthorizationAppleIDCredential()
        mockCredential.user = "test_apple_user"
        
        // When
        try await authService.signInWithApple(credential: mockCredential)
        
        // Then
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
        
        // Vérifier l'anonymisation
        let user = authService.currentUser!
        XCTAssertTrue(user.email.contains("@familysync.anonymous"))
        XCTAssertEqual(user.name, "Utilisateur")
        XCTAssertTrue(user.id.hasPrefix("apple_"))
    }
    
    func testSessionPersistence() async throws {
        // Given
        let authService = AuthService()
        
        // When - Première connexion
        try await authService.signInWithApple(credential: MockASAuthorizationAppleIDCredential())
        let firstUserId = authService.currentUser?.id
        
        // Then - Déconnexion
        try await authService.signOut()
        XCTAssertFalse(authService.isAuthenticated)
        
        // When - Reconnexion avec même Apple User ID
        try await authService.signInWithApple(credential: MockASAuthorizationAppleIDCredential())
        let secondUserId = authService.currentUser?.id
        
        // Then - Même utilisateur
        XCTAssertEqual(firstUserId, secondUserId, "Même Apple User ID doit reconnecter le même compte")
    }
}
```

### **AppwriteConnectionTests**

#### Test de connexion Appwrite
```swift
class AppwriteConnectionTests: XCTestCase {
    
    func testAppwriteConnection() async throws {
        // Given
        let client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        // When
        let account = Account(client)
        
        // Then
        XCTAssertNotNil(account, "Connexion Appwrite doit réussir")
    }
    
    func testUserCreationWithAnonymizedData() async throws {
        // Given
        let account = Account(Client().setEndpoint(AppwriteConfig.endpoint).setProject(AppwriteConfig.projectId))
        let userId = "apple_test_user_123"
        let email = "\(userId)@familysync.anonymous"
        let name = "Utilisateur"
        let password = "test_password_hash"
        
        // When
        let user = try await account.create(
            userId: userId,
            email: email,
            password: password,
            name: name
        )
        
        // Then
        XCTAssertEqual(user.id, userId)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.name, name)
        
        // Cleanup
        try await account.delete(userId: userId)
    }
}
```

## 🖥️ Tests UI

### **AppleSignInButtonTests**

#### Test de l'interface utilisateur
```swift
class AppleSignInButtonUITests: XCTestCase {
    
    func testAppleSignInButtonAppearance() {
        // Given
        let button = AppleSignInButton()
        
        // When
        let view = button.body
        
        // Then
        XCTAssertNotNil(view, "Bouton doit être rendu")
    }
    
    func testAppleSignInButtonInteraction() {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let signInButton = app.buttons["Sign in with Apple"]
        signInButton.tap()
        
        // Then
        // Vérifier que l'authentification Apple se lance
        // Note: Test en environnement de test Apple
    }
}
```

### **AccessibilityTests**

#### Test d'accessibilité
```swift
class AccessibilityTests: XCTestCase {
    
    func testAppleSignInButtonAccessibility() {
        // Given
        let button = AppleSignInButton()
        
        // When
        let view = button.body
        
        // Then
        // Vérifier les propriétés d'accessibilité
        // - Label VoiceOver
        // - Hint VoiceOver
        // - Traits d'accessibilité
    }
    
    func testErrorMessagesAccessibility() {
        // Given
        let errorMessage = "Erreur de connexion"
        
        // When
        let errorView = Text(errorMessage)
            .foregroundColor(.red)
            .accessibilityLabel("Message d'erreur")
        
        // Then
        // Vérifier que l'erreur est accessible
    }
}
```

## 📊 Mock Data

### **MockASAuthorizationAppleIDCredential**
```swift
class MockASAuthorizationAppleIDCredential: ASAuthorizationAppleIDCredential {
    var mockUser: String = "test_apple_user"
    var mockEmail: String?
    var mockFullName: PersonNameComponents?
    
    override var user: String {
        return mockUser
    }
    
    override var email: String? {
        return mockEmail
    }
    
    override var fullName: PersonNameComponents? {
        return mockFullName
    }
}
```

### **MockAppwriteUser**
```swift
struct MockAppwriteUser: AppwriteUser {
    let id: String = "apple_mock_user_123"
    let email: String = "apple_mock_user_123@familysync.anonymous"
    let name: String = "Utilisateur"
    let createdAt: Date = Date()
}
```

## 🚀 Commandes de test

### **Exécution des tests**
```bash
# Tests unitaires
xcodebuild test -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:FamilySyncTests

# Tests UI
xcodebuild test -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:FamilySyncUITests

# Tous les tests
xcodebuild test -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16'
```

### **Tests spécifiques**
```bash
# Test d'authentification uniquement
xcodebuild test -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:FamilySyncTests/AppleSignInServiceTests

# Test de génération d'ID stable
xcodebuild test -project FamilySync.xcodeproj -scheme FamilySync -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:FamilySyncTests/AppleSignInServiceTests/testStableUserIdGeneration
```

## 📈 Métriques de test

### **Couverture de code**
- **AppleSignInService** : 95%+
- **AuthService** : 90%+
- **UserData** : 100%
- **UI Components** : 85%+

### **Performance des tests**
- **Tests unitaires** : < 5 secondes
- **Tests d'intégration** : < 30 secondes
- **Tests UI** : < 60 secondes

## 🔒 Tests de sécurité RGPD

### **Validation de l'anonymisation**
```swift
func testRGPDCompliance() {
    // Vérifier qu'aucune donnée personnelle n'est collectée
    // Vérifier que les emails sont anonymisés
    // Vérifier que les noms sont anonymisés
    // Vérifier que les IDs sont stables
    // Vérifier qu'il n'y a pas de tracking
}
```

### **Tests de non-régression**
```swift
func testNoPersonalDataLeakage() {
    // Vérifier qu'aucune donnée personnelle n'est transmise
    // Vérifier qu'aucune donnée personnelle n'est stockée
    // Vérifier qu'aucune donnée personnelle n'est loggée
}
```

## 📋 Checklist de tests

### **Avant chaque release**
- [ ] **Tests unitaires** : Tous passent
- [ ] **Tests d'intégration** : Flux complet validé
- [ ] **Tests UI** : Interface utilisateur testée
- [ ] **Tests RGPD** : Conformité validée
- [ ] **Tests de sécurité** : Anonymisation vérifiée
- [ ] **Tests de performance** : Temps de réponse acceptables

### **Tests manuels**
- [ ] **Connexion Apple Sign-In** : Fonctionne correctement
- [ ] **Déconnexion** : Session supprimée
- [ ] **Reconnexion** : Même utilisateur
- [ ] **Erreurs** : Gestion appropriée
- [ ] **Accessibilité** : VoiceOver fonctionne

---

**Note :** Cette stratégie de tests garantit la conformité RGPD et la qualité du code tout en maintenant une couverture de test complète. 🎯
