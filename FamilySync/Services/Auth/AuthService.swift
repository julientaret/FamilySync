import Foundation
import Appwrite
import AppwriteEnums

/// Service principal d'authentification qui coordonne tous les services d'auth
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let oauth2Service: OAuth2Service
    private let appleSignInService: AppleSignInService
    
    @Published var isAuthenticated = false
    @Published var currentUser: AppwriteUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentProvider: AuthProvider = .none
    
    enum AuthProvider {
        case none
        case apple
        case github
        case google
        case email
    }
    
    private init() {
        self.oauth2Service = OAuth2Service.shared
        self.appleSignInService = AppleSignInService.shared
        
        // Observer les changements des services
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observer les changements du service OAuth2
        oauth2Service.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.updateAuthState()
            }
            .store(in: &cancellables)
        
        oauth2Service.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (user: AppwriteUser?) in
                self?.currentUser = user
            }
            .store(in: &cancellables)
        
        oauth2Service.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        oauth2Service.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)
        
        // Observer les changements du service Apple
        appleSignInService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.updateAuthState()
            }
            .store(in: &cancellables)
        
        appleSignInService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (user: AppwriteUser?) in
                self?.currentUser = user
            }
            .store(in: &cancellables)
        
        appleSignInService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        appleSignInService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication Methods
    
    /// Connexion avec Apple Sign In
    func signInWithApple() async throws {
        currentProvider = .apple
        try await appleSignInService.signInWithApple()
    }
    
    /// Connexion avec GitHub
    func signInWithGitHub() async throws {
        currentProvider = .github
        try await oauth2Service.signInWithGitHub()
    }
    
    /// Connexion avec Google
    func signInWithGoogle() async throws {
        currentProvider = .google
        try await oauth2Service.signInWithGoogle()
    }
    
    /// Connexion avec email et mot de passe
    func signInWithEmail(email: String, password: String) async throws {
        currentProvider = .email
        try await signInWithEmailPassword(email: email, password: password)
    }
    
    /// Déconnexion
    func signOut() async throws {
        isLoading = true
        
        do {
            switch currentProvider {
            case .apple:
                try await appleSignInService.signOut()
            case .github, .google, .email:
                try await oauth2Service.signOut()
            case .none:
                break
            }
            
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                currentProvider = .none
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors de la déconnexion: \(error.localizedDescription)"
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Session Management
    
    /// Vérifie l'état de l'authentification au démarrage
    func checkAuthState() async {
        isLoading = true
        
        do {
            // Vérifier d'abord Apple Sign In
            try await appleSignInService.checkAppleSession()
            
            if !isAuthenticated {
                // Si pas connecté avec Apple, vérifier OAuth2
                try await oauth2Service.checkSession()
            }
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Erreur lors de la vérification de l'authentification: \(error.localizedDescription)"
            }
        }
    }
    
    /// Rafraîchit la session si nécessaire
    func refreshSession() async {
        do {
            switch currentProvider {
            case .apple:
                try await appleSignInService.refreshAppleSession()
            case .github, .google:
                try await oauth2Service.refreshOAuth2Session()
            case .email, .none:
                break
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors du rafraîchissement de la session: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateAuthState() {
        isAuthenticated = oauth2Service.isAuthenticated || appleSignInService.isAuthenticated
        
        if !isAuthenticated {
            currentProvider = .none
        }
    }
    
    private func signInWithEmailPassword(email: String, password: String) async throws {
        // Implémentation pour la connexion email/mot de passe
        // À implémenter selon les besoins
        throw NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Connexion email non implémentée"])
    }
    
    // MARK: - Utility Methods
    
    /// Nettoie les messages d'erreur
    func clearError() {
        errorMessage = nil
        oauth2Service.clearError()
        appleSignInService.clearError()
    }
    
    /// Initialise le service au démarrage de l'app
    func initialize() async {
        await checkAuthState()
    }
    
    /// Vérifie si un provider est disponible
    func isProviderAvailable(_ provider: AuthProvider) -> Bool {
        switch provider {
        case .apple:
            return appleSignInService.isAppleSignInAvailable()
        case .github, .google:
            return true
        case .email:
            return true
        case .none:
            return false
        }
    }
}

// MARK: - Combine Extensions

import Combine

extension AuthService {
    /// Publisher pour les changements d'authentification
    var authStatePublisher: AnyPublisher<Bool, Never> {
        $isAuthenticated
            .eraseToAnyPublisher()
    }
    
    /// Publisher pour les changements d'utilisateur
    var userPublisher: AnyPublisher<AppwriteUser?, Never> {
        $currentUser
            .eraseToAnyPublisher()
    }
    
    /// Publisher pour les erreurs
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage
            .eraseToAnyPublisher()
    }
}
