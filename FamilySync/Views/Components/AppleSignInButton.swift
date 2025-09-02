import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 16) {
            // Bouton Sign in with Apple natif (RGPD compliant)
            SignInWithAppleButton(
                onRequest: { request in
                    // Ne demander AUCUNE donnée personnelle (RGPD compliant)
                    request.requestedScopes = []
                },
                onCompletion: { result in
                    handleSignInWithApple(result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .disabled(isLoading)
            
            // Indicateur de chargement
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Connexion en cours...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Message d'erreur
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        try await authService.signInWithApple(credential: appleIDCredential)
                        await MainActor.run {
                            isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Erreur de connexion: \(error.localizedDescription)"
                            isLoading = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur: Credential Apple ID invalide"
                    self.isLoading = false
                }
            }
            
        case .failure(let error):
            DispatchQueue.main.async {
                if let authError = error as? ASAuthorizationError {
                    switch authError.code {
                    case ASAuthorizationError.canceled:
                        self.errorMessage = "Connexion Apple annulée"
                    case ASAuthorizationError.failed:
                        self.errorMessage = "Échec de la connexion Apple"
                    case ASAuthorizationError.invalidResponse:
                        self.errorMessage = "Réponse Apple invalide"
                    case ASAuthorizationError.notHandled:
                        self.errorMessage = "Connexion Apple non gérée"
                    case ASAuthorizationError.unknown:
                        self.errorMessage = "Erreur Apple inconnue"
                    case ASAuthorizationError.notInteractive:
                        self.errorMessage = "Connexion Apple non interactive"
                    case ASAuthorizationError.matchedExcludedCredential:
                        self.errorMessage = "Credential Apple exclu"
                    case ASAuthorizationError.credentialImport:
                        self.errorMessage = "Erreur d'import de credential"
                    case ASAuthorizationError.credentialExport:
                        self.errorMessage = "Erreur d'export de credential"
                    @unknown default:
                        self.errorMessage = "Erreur Apple: \(authError.localizedDescription)"
                    }
                } else {
                    self.errorMessage = "Erreur de connexion: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    AppleSignInButton()
        .environmentObject(AuthService.shared)
        .padding()
}