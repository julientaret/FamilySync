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
            // Background
            OnboardingBackground()
            
            VStack(spacing: 40) {
                // Title
                OnboardingTitle(firstLine: "Start with", secondLine: "FamilySync")
                
                // Steps
                VStack(spacing: 20) {
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Log in with your Apple Account",
                        isCompleted: false
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Create or join a Family",
                        isCompleted: false
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Set your profile",
                        isCompleted: false
                    )
                }
                                
                // Family Illustration
                Image("onboard1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .padding(.horizontal, 40)
                
                
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
