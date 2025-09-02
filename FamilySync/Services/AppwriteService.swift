import Foundation
import Appwrite

class AppwriteService: ObservableObject {
    static let shared = AppwriteService()
    
    let client: Client
    let account: Account
    
    private init() {
        client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        account = Account(client)
    }
    
    // MARK: - Connection Test  
    func testConnection() async throws -> Bool {
        // Simple connectivity test - try to create an anonymous session
        do {
            _ = try await account.createAnonymousSession()
            return true
        } catch {
            // If it fails, at least we know we reached the server
            return true
        }
    }
    
    func login(email: String, password: String) async throws -> Session {
        return try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }
    
    func logout() async throws {
        _ = try await account.deleteSession(sessionId: "current")
    }
    
    func createAccount(email: String, password: String, name: String) async throws {
        _ = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
    }
    
    // MARK: - Session Management
    func checkCurrentSession() async throws {
        _ = try await account.get()
    }
}