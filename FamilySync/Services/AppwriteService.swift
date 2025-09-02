import Foundation
import Appwrite

class AppwriteService: ObservableObject {
    static let shared = AppwriteService()
    
    let client: Client
    let account: Account
    let databases: Databases
    let storage: Storage
    
    private init() {
        client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        account = Account(client)
        databases = Databases(client)
        storage = Storage(client)
    }
    
    // MARK: - Authentication
    func createAccount(email: String, password: String, name: String) async throws -> User {
        return try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
    }
    
    func login(email: String, password: String) async throws -> Session {
        return try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }
    
    func logout() async throws {
        try await account.deleteSession(sessionId: "current")
    }
    
    func getCurrentUser() async throws -> User {
        return try await account.get()
    }
    
    // MARK: - Database Operations
    func createDocument<T: Codable>(
        databaseId: String,
        collectionId: String,
        data: T,
        documentId: String = ID.unique()
    ) async throws -> Document {
        return try await databases.createDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
    }
    
    func getDocument(
        databaseId: String,
        collectionId: String,
        documentId: String
    ) async throws -> Document {
        return try await databases.getDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId
        )
    }
    
    func listDocuments(
        databaseId: String,
        collectionId: String,
        queries: [String] = []
    ) async throws -> DocumentList {
        return try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: collectionId,
            queries: queries
        )
    }
    
    func updateDocument<T: Codable>(
        databaseId: String,
        collectionId: String,
        documentId: String,
        data: T
    ) async throws -> Document {
        return try await databases.updateDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: data
        )
    }
    
    func deleteDocument(
        databaseId: String,
        collectionId: String,
        documentId: String
    ) async throws {
        try await databases.deleteDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId
        )
    }
    
    // MARK: - File Storage
    func uploadFile(
        bucketId: String,
        fileId: String = ID.unique(),
        file: InputFile
    ) async throws -> File {
        return try await storage.createFile(
            bucketId: bucketId,
            fileId: fileId,
            file: file
        )
    }
    
    func getFile(
        bucketId: String,
        fileId: String
    ) async throws -> File {
        return try await storage.getFile(
            bucketId: bucketId,
            fileId: fileId
        )
    }
    
    func deleteFile(
        bucketId: String,
        fileId: String
    ) async throws {
        try await storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId
        )
    }
    
    func getFilePreview(
        bucketId: String,
        fileId: String,
        width: Int? = nil,
        height: Int? = nil
    ) -> URL {
        return storage.getFilePreview(
            bucketId: bucketId,
            fileId: fileId,
            width: width,
            height: height
        )
    }
}