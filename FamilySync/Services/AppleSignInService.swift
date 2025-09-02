import Foundation
import AuthenticationServices
import SwiftUI

@MainActor
class AppleSignInService: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appwriteService = AppwriteService.shared
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid Apple ID credential"
            isLoading = false
            return
        }
        
        let userId = appleIDCredential.user
        let email = appleIDCredential.email ?? "\(userId)@privaterelay.appleid.com"
        let fullName = appleIDCredential.fullName
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
            .isEmpty ? "Apple User" : [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        print("Apple Sign In - Original User ID: \(userId)")
        print("Apple Sign In - Email: \(email)")
        print("Apple Sign In - Name: \(name)")
        
        Task {
            do {
                // Use email as the stable identifier for Apple users
                // If email is available, use it directly, otherwise use the Apple user ID
                let stableEmail: String
                if let providedEmail = appleIDCredential.email, !providedEmail.isEmpty {
                    stableEmail = providedEmail
                    print("Using provided email: \(stableEmail)")
                } else {
                    // For existing users, Apple doesn't provide email again
                    // Use the stable Apple user ID to generate consistent email
                    stableEmail = "\(userId)@privaterelay.appleid.com"
                    print("Using Apple ID based email: \(stableEmail)")
                }
                
                // Create consistent user ID based on email
                let stableUserId = "apple_\(abs(stableEmail.hashValue))"
                print("Apple Sign In - Stable User ID: \(stableUserId)")
                print("Apple Sign In - Email: \(stableEmail)")
                
                // Clear any existing session first
                do {
                    try await appwriteService.logout()
                    print("Existing session cleared")
                } catch {
                    print("No existing session to clear: \(error)")
                }
                
                do {
                    // Try to login first with the stable email
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: stableEmail,
                        password: "AppleUser123!"
                    )
                    print("Login successful with existing Apple account!")
                } catch {
                    print("User doesn't exist yet, creating account...")
                    // Create the account if it doesn't exist
                    _ = try await appwriteService.account.create(
                        userId: stableUserId,
                        email: stableEmail,
                        password: "AppleUser123!",
                        name: name.isEmpty ? "Apple User" : name
                    )
                    print("Account created successfully!")
                    
                    // Login with the newly created account
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: stableEmail,
                        password: "AppleUser123!"
                    )
                    print("Login successful after account creation!")
                }
                
                await MainActor.run {
                    self.isSignedIn = true
                    self.isLoading = false
                }
            } catch {
                print("Apple Sign In Error: \(error)")
                let errorDescription = error.localizedDescription
                await MainActor.run {
                    if errorDescription.contains("Rate limit") {
                        self.errorMessage = "Too many attempts. Please wait a few minutes and try again."
                    } else {
                        self.errorMessage = "Sign in failed: \(errorDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = "Sign in cancelled or failed: \(error.localizedDescription)"
        isLoading = false
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}