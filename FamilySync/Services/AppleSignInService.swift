import Foundation
import AuthenticationServices
import SwiftUI
import Appwrite

@MainActor
class AppleSignInService: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appwriteService = AppwriteService.shared
    
    override init() {
        super.init()
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        Task {
            do {
                _ = try await appwriteService.checkCurrentSession()
                await MainActor.run {
                    self.isSignedIn = true
                    print("Found existing session, user is already signed in")
                }
            } catch {
                await MainActor.run {
                    self.isSignedIn = false
                    print("No existing session found")
                }
            }
        }
    }
    
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
        
        print("Apple Sign In - User ID: \(userId)")
        print("Apple Sign In - Email: \(email)")
        print("Apple Sign In - Name: \(name)")
        
        Task {
            do {
                // Use Apple User ID as stable identifier - respects user privacy
                let stableUserId = "apple_\(abs(userId.hashValue))"
                
                // Only use email if provided by user, otherwise use a privacy-friendly approach
                let userEmail: String
                if let providedEmail = appleIDCredential.email, !providedEmail.isEmpty {
                    userEmail = providedEmail
                    print("User provided email: \(userEmail)")
                } else {
                    // Create a unique but privacy-friendly email for Appwrite
                    userEmail = "\(stableUserId)@appleid.local"
                    print("Using privacy-friendly email: \(userEmail)")
                }
                
                print("Using stable user ID: \(stableUserId)")
                
                // Clear any existing session first
                do {
                    try await appwriteService.logout()
                    print("Existing session cleared")
                } catch {
                    print("No existing session to clear: \(error)")
                }
                
                // Try to login first
                do {
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: userEmail,
                        password: "AppleUser123!"
                    )
                    print("Login successful with existing Apple account!")
                } catch {
                    print("User doesn't exist, creating account...")
                    // Create the account if it doesn't exist
                    _ = try await appwriteService.account.create(
                        userId: stableUserId,
                        email: userEmail,
                        password: "AppleUser123!",
                        name: name.isEmpty ? "Apple User" : name
                    )
                    print("Account created successfully!")
                    
                    // Login with the newly created account
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: userEmail,
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