//
//  OnboardingView.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct OnboardingView1: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @State private var showSignIn = false
    
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
            ).opacity(0.2)
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title
                VStack(spacing: 8) {
                    Text("Start with")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.5))
                    Text("FamilySync")
                        .font(.system(size: 35, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.5))
                }
                .shadow(color: Color.white.opacity(0.4), radius: 3, x: 0, y: 2)

                .padding(.top, 40)
                
                // Steps
                VStack(spacing: 20) {
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Log in with your Apple Account"
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Create or join a Family"
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Set your profile"
                    )
                }
                
                Spacer()
                
                // Family Illustration
                Image("family_onboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Sign In Button
                AppleSignInButton()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .onReceive(authService.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                onboardingViewModel.handleAuthenticationSuccess()
            }
        }
    }
}

#Preview {
    OnboardingView1()
        .environmentObject(AuthService.shared)
}
