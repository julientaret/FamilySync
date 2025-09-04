//
//  OnboardingView2.swift
//  FamilySync
//
//  Created by Julien TARET on 04/09/2025.
//

import SwiftUI

struct OnboardingView2: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var familyViewModel = FamilyManagementViewModel()
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground()
            
            VStack(spacing: 40) {
                // Title
                OnboardingTitle(firstLine: "Create or Join", secondLine: "Your Family")
                
                // Steps
                VStack(spacing: 20) {
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Log in with your Apple Account",
                        isCompleted: true
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Create or join a Family",
                        isCompleted: onboardingViewModel.isUserInFamily()
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Set your profile",
                        isCompleted: false
                    )
                }
                
                // Family Illustration
                Image("onboard2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                    .padding(.horizontal, 40)
                
                // Si l'utilisateur est déjà dans une famille
                if onboardingViewModel.isUserInFamily() {
                    VStack(spacing: 16) {
                        Text("✅ Vous êtes déjà dans une famille !")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        if let family = onboardingViewModel.currentFamily {
                            Text("Famille : \(family.name)")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            onboardingViewModel.nextStep()
                        }) {
                            Text("Continuer")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#e9906f"))
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            familyViewModel.showCreateFamilyModal = true
                        }) {
                            Text("Create New Family")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#e9906f"))
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            familyViewModel.showJoinFamilyModal = true
                        }) {
                            Text("Join Existing Family")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#e9906f"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(hex: "#e9906f"), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $familyViewModel.showCreateFamilyModal) {
            CreateFamilyModal()
                .environmentObject(familyViewModel)
                .environmentObject(authService)
        }
        .sheet(isPresented: $familyViewModel.showJoinFamilyModal) {
            JoinFamilyModal()
                .environmentObject(familyViewModel)
                .environmentObject(authService)
        }
        .sheet(isPresented: $familyViewModel.showInviteCodeModal) {
            InviteCodeModal()
                .environmentObject(familyViewModel)
                .environmentObject(onboardingViewModel)
        }
        .onChange(of: familyViewModel.currentFamily) { _, family in
            if family != nil && !familyViewModel.showInviteCodeModal {
                // Si une famille a été rejointe (pas créée), passer à l'étape suivante
                onboardingViewModel.currentFamily = family
                onboardingViewModel.nextStep()
            }
        }
    }
}

#Preview {
    OnboardingView2()
        .environmentObject(AuthService.shared)
        .environmentObject(OnboardingViewModel())
}
