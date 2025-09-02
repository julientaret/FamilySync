//
//  ContentView.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appwriteService: AppwriteService
    @State private var pingResult = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("FamilySync")
                .font(.title)
                .fontWeight(.bold)
            
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
}

#Preview {
    ContentView()
        .environmentObject(AppwriteService.shared)
}
