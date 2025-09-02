import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: FamilySyncUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appwriteService = AppwriteService.shared
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        Task {
            do {
                let user = try await appwriteService.getCurrentUser()
                self.isAuthenticated = true
                self.currentUser = FamilySyncUser(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    createdAt: user.registration,
                    familyId: nil
                )
            } catch {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await appwriteService.createAccount(
                    email: email,
                    password: password,
                    name: name
                )
                
                try await appwriteService.login(email: email, password: password)
                
                self.isAuthenticated = true
                self.currentUser = FamilySyncUser(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    createdAt: user.registration,
                    familyId: nil
                )
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await appwriteService.login(email: email, password: password)
                let user = try await appwriteService.getCurrentUser()
                
                self.isAuthenticated = true
                self.currentUser = FamilySyncUser(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    createdAt: user.registration,
                    familyId: nil
                )
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await appwriteService.logout()
                self.isAuthenticated = false
                self.currentUser = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}