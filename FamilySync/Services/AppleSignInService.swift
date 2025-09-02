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
                // Create a simple, unique user ID instead of using Apple's complex ID
                let simpleUserId = "apple_\(abs(userId.hashValue))"
                print("Apple Sign In - Simple User ID: \(simpleUserId)")
                
                // Try to login first (user might already exist)
                let success = try await loginWithAppleID(userId: simpleUserId)
                if !success {
                    // If login fails, create new account
                    try await createAccountWithAppleID(userId: simpleUserId, email: email, name: name)
                }
                
                await MainActor.run {
                    self.isSignedIn = true
                    self.isLoading = false
                }
            } catch {
                print("Apple Sign In Error: \(error)")
                await MainActor.run {
                    self.errorMessage = "Sign in failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = "Sign in cancelled or failed: \(error.localizedDescription)"
        isLoading = false
    }
    
    private func loginWithAppleID(userId: String) async throws -> Bool {
        do {
            let emailAddress = "\(userId)@appleid.com"
            print("Attempting login with email: \(emailAddress)")
            
            // Try to create a session with Apple ID as both email and password
            // This is a workaround since Appwrite doesn't have native Apple Sign In
            _ = try await appwriteService.account.createEmailPasswordSession(
                email: emailAddress,
                password: "AppleUser123!"  // Fixed strong password
            )
            print("Login successful!")
            return true
        } catch {
            print("Login attempt failed: \(error)")
            // If login fails, user doesn't exist yet
            return false
        }
    }
    
    private func createAccountWithAppleID(userId: String, email: String, name: String) async throws {
        print("Creating account for: \(name) with userId: \(userId)")
        
        let emailAddress = "\(userId)@appleid.com"
        print("Using email address: \(emailAddress)")
        
        // Create account with simple Apple user ID
        _ = try await appwriteService.account.create(
            userId: userId, // userId is already clean (apple_123456)
            email: emailAddress,
            password: "AppleUser123!",  // Fixed strong password
            name: name
        )
        
        print("Account created successfully, now logging in...")
        
        // Immediately login after creation
        _ = try await appwriteService.account.createEmailPasswordSession(
            email: emailAddress, 
            password: "AppleUser123!"
        )
        
        print("Login successful!")
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