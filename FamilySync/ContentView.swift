//
//  ContentView.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI
import Appwrite

struct ContentView: View {
    @EnvironmentObject var appwriteService: AppwriteService
    @StateObject private var appleSignInService = AppleSignInService()
    @State private var pingResult = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("FamilySync")
                .font(.title)
                .fontWeight(.bold)
            
            if appleSignInService.isSignedIn {
                VStack(spacing: 15) {
                    Text("Welcome!")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Button("Sign Out") {
                        signOut()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack(spacing: 15) {
                    Text("Sign in to continue")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    SignInWithAppleButton(appleSignInService: appleSignInService)
                        .frame(maxWidth: 280)
                    
                    #if targetEnvironment(simulator)
                    Button("Simulate Apple Sign In") {
                        simulateAppleSignIn()
                    }
                    .buttonStyle(.borderedProminent)
                    #endif
                    
                    Button("Test Account Creation") {
                        testAccountCreation()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Divider()
                .padding()
            
            Button("Send a ping") {
                sendPing()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
            
            if !pingResult.isEmpty {
                Text(pingResult)
                    .foregroundColor(pingResult.contains("Success") ? .green : .red)
                    .multilineTextAlignment(.center)
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
                try await appwriteService.logout()
                await MainActor.run {
                    appleSignInService.isSignedIn = false
                }
            } catch {
                print("Sign out error: \(error)")
            }
        }
    }
    
    private func simulateAppleSignIn() {
        Task {
            do {
                let simulatedUserId = "apple_123456789"
                let simulatedEmail = "\(simulatedUserId)@appleid.com"
                let simulatedName = "Simulator User"
                
                print("🍎 Simulating Apple Sign In...")
                print("Simulated User ID: \(simulatedUserId)")
                print("Simulated Email: \(simulatedEmail)")
                
                // Try to login first (user might already exist)
                var loginSuccess = false
                do {
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: simulatedEmail,
                        password: "AppleUser123!"
                    )
                    loginSuccess = true
                    print("✅ Login successful with existing account!")
                } catch {
                    print("❌ Login failed, will create new account: \(error)")
                }
                
                if !loginSuccess {
                    // Create new account
                    _ = try await appwriteService.account.create(
                        userId: simulatedUserId,
                        email: simulatedEmail,
                        password: "AppleUser123!",
                        name: simulatedName
                    )
                    
                    print("✅ Account created successfully!")
                    
                    // Login after creation
                    _ = try await appwriteService.account.createEmailPasswordSession(
                        email: simulatedEmail,
                        password: "AppleUser123!"
                    )
                    
                    print("✅ Login successful after account creation!")
                }
                
                await MainActor.run {
                    appleSignInService.isSignedIn = true
                }
                
            } catch {
                print("❌ Simulation failed: \(error)")
                await MainActor.run {
                    appleSignInService.errorMessage = "Simulation failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func testAccountCreation() {
        Task {
            do {
                let testEmail = "test@example.com"
                let testPassword = "TestUser123!"
                let testName = "Test User"
                
                print("Testing account creation...")
                
                // Use ID.unique() or a simple valid ID
                _ = try await appwriteService.account.create(
                    userId: ID.unique(), // Let Appwrite generate the ID
                    email: testEmail,
                    password: testPassword,
                    name: testName
                )
                
                print("Account created successfully!")
                
                _ = try await appwriteService.account.createEmailPasswordSession(
                    email: testEmail,
                    password: testPassword
                )
                
                await MainActor.run {
                    appleSignInService.isSignedIn = true
                }
                
                print("Login successful!")
            } catch {
                print("Test failed: \(error)")
                await MainActor.run {
                    appleSignInService.errorMessage = "Test failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
