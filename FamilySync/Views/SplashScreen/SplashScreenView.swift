//
//  SplashScreenView.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject private var viewModel = SplashScreenViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.7, blue: 0.6),    // Couleur coral/saumon en haut
                      Color(red: 1.0, green: 0.85, blue: 0.7),   // Couleur pêche au milieu
                    Color(red: 0.98, green: 0.75, blue: 0.80)  // Couleur rose pâle en bas
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon
                FamilyAppIcon()
                    .frame(width: 140, height: 140)
                
                // App Name
                Text("FamilySync")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.6), radius: 3, x: 0, y: 2)
                
                // Tagline
                Text("Organize your family life")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.6), radius: 3, x: 0, y: 2)
                    .padding(.bottom, 60)
                StartButton(action: viewModel.startApp)

                // Action Button
                if viewModel.isFirstLaunch {
                    StartButton(action: viewModel.startApp)
                } else if viewModel.isLoading {
                    LoadingIndicator()
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            viewModel.checkFirstLaunch()
            viewModel.checkAuthenticationStatus(authService: authService)
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AuthService.shared)
}
