//
//  ContentView.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appwriteService: AppwriteService
    @EnvironmentObject var authService: AuthService
    @State private var pingResult = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("FamilySync")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // État d'authentification
            if authService.isAuthenticated {
                VStack(spacing: 15) {
                    Text("Connecté ✅")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    if let user = authService.currentUser {
                        Text("Utilisateur: \(user.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Se déconnecter") {
                        signOut()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Authentification")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Bouton Apple Sign In
                    AppleSignInButton()
                        .frame(maxWidth: 280)
                }
            }
            
            Divider()
            
            // Section test de connexion
            VStack(spacing: 15) {
                Text("Test Appwrite Connection")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Button("Send a ping") {
                    sendPing()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView()
                        .padding()
                }
                
                if !pingResult.isEmpty {
                    Text(pingResult)
                        .foregroundColor(pingResult.contains("Success") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .padding()
    }
    
    private func sendPing() {
        isLoading = true
        pingResult = ""
        
        Task {
            do {
                _ = try await appwriteService.testConnection()
                await MainActor.run {
                    pingResult = "Success! Appwrite connection is working."
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    pingResult = "Ping failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("Erreur lors de la déconnexion: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppwriteService.shared)
        .environmentObject(AuthService.shared)
}
