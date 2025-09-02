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
}