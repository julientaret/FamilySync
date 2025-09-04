import Foundation
import Appwrite
import AppwriteEnums
import Combine
import AuthenticationServices

/// Service principal d'authentification qui coordonne tous les services d'auth
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    // Services d'authentification
    private let oauth2Service = OAuth2Service.shared
    private let appleSignInService = AppleSignInService.shared
    
    // États d'authentification
    @Published var isAuthenticated = false
    @Published var currentUser: AppwriteUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentProvider: AuthProvider = .none
    
    // Types de providers
    enum AuthProvider: String, CaseIterable {
        case none = "none"
        case apple = "apple"
        case github = "github"
        case google = "google"
        
        var displayName: String {
            switch self {
            case .none: return "Aucun"
            case .apple: return "Apple"
            case .github: return "GitHub"
            case .google: return "Google"
            }
        }
    }
    
    private init() {
        setupObservers()
        checkExistingSession()
    }
    
    // MARK: - Configuration des observateurs
    
    private func setupObservers() {
        // Observer les changements d'état d'Apple Sign In
        appleSignInService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth in
                if isAuth {
                    self?.isAuthenticated = true
                    self?.currentProvider = .apple
                }
            }
            .store(in: &cancellables)
        
        appleSignInService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    self?.currentUser = user
                }
            }
            .store(in: &cancellables)
        
        appleSignInService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.isLoading = loading
            }
            .store(in: &cancellables)
        
        appleSignInService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error
            }
            .store(in: &cancellables)
        
        // Observer les changements d'état OAuth2
        oauth2Service.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth in
                if isAuth && self?.currentProvider != .apple {
                    self?.isAuthenticated = true
                }
            }
            .store(in: &cancellables)
        
        oauth2Service.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil && self?.currentProvider != .apple {
                    self?.currentUser = user
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Gestion des sessions
    
    private func checkExistingSession() {
        print("🚨 [ALERT] AuthService.checkExistingSession() appelée")
        Task {
            isLoading = true
            
            do {
                // Essayer de récupérer l'utilisateur connecté
                print("🚨 [ALERT] Tentative de récupération de l'utilisateur Apple")
                try await appleSignInService.fetchCurrentUser()
                
                isLoading = false
                // Vérifier si l'utilisateur a été récupéré
                if currentUser != nil {
                    print("🚨 [ALERT] Utilisateur trouvé, mise à jour de isAuthenticated")
                    isAuthenticated = true
                } else {
                    print("🚨 [ALERT] Aucun utilisateur trouvé")
                }
            } catch {
                print("🚨 [ALERT] Erreur lors de la récupération de l'utilisateur: \(error)")
                isLoading = false
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Connexion avec Apple Sign In utilisant les credentials natifs
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        currentProvider = .apple
        try await appleSignInService.signInWithApple(credential: credential)
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
    
    /// Déconnexion de l'utilisateur
    func signOut() async throws {
        isLoading = true
        
        do {
            switch currentProvider {
            case .apple:
                try await appleSignInService.signOut()
            case .github, .google:
                try await oauth2Service.signOut()
            case .none:
                break
            }
            
            isAuthenticated = false
            currentUser = nil
            currentProvider = .none
            isLoading = false
            errorMessage = nil
            
            // Nettoyer les données UserDefaults directement
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "hasSeenOnboarding")
            userDefaults.removeObject(forKey: "userName") 
            userDefaults.removeObject(forKey: "userBirthday")
            userDefaults.synchronize()
            print("🧹 [DEBUG] Nettoyage UserDefaults effectué lors de la déconnexion")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Efface les erreurs
    func clearError() {
        errorMessage = nil
    }
}