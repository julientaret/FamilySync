//
//  OnboardingView3.swift
//  FamilySync
//
//  Created by Julien TARET on 04/09/2025.
//

import SwiftUI

struct OnboardingView3: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @State private var userName: String = ""
    @State private var selectedDate = Date()
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Title
                    OnboardingTitle(firstLine: "Tell us about", secondLine: "Yourself")
                    
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
                            isCompleted: true
                        )
                        
                        OnboardingStep(
                            icon: "checkmark.circle.fill",
                            text: "Set your profile",
                            isCompleted: onboardingViewModel.hasUserProfile()
                        )
                    }
                    
                    // Family Illustration
                    Image("onboard3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .padding(.horizontal, 40)
                    
                    // Si l'utilisateur a déjà un profil
                    if onboardingViewModel.hasUserProfile() {
                        VStack(spacing: 16) {
                            Text("✅ Votre profil est déjà configuré !")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                            
                            VStack(spacing: 8) {
                                Text("Nom : \(onboardingViewModel.userName)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Text("Date de naissance : \(formatDate(onboardingViewModel.userBirthday))")
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
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 40)
                        }
                    } else {
                        // Input Fields
                        VStack(spacing: 20) {
                            // Name Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What Should We Call You?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(OnboardingColors.primary)
                                
                                TextField("Enter your name", text: $userName)
                                    .textFieldStyle(OnboardingTextFieldStyle())
                            }
                            
                            // Birthday Input
                            HStack(spacing: 8) {
                                Text("Your Birthday?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(OnboardingColors.primary)
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .cornerRadius(12)
                                    .contentShape(Rectangle()) // Cette ligne rend toute la zone cliquable
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Continue Button
                        Button(action: {
                            onboardingViewModel.handleProfileSetup(name: userName, birthday: selectedDate)
                        }) {
                            HStack {
                                if onboardingViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(onboardingViewModel.isLoading ? "Sauvegarde..." : "It's Ok!")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#e9906f"))
                            .cornerRadius(10)
                        }
                        .disabled(userName.isEmpty || onboardingViewModel.isLoading)
                        .opacity((userName.isEmpty || onboardingViewModel.isLoading) ? 0.6 : 1.0)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        
                        // Error Message
                        if let errorMessage = onboardingViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
    }
}

// Custom TextField Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    OnboardingView3()
        .environmentObject(AuthService.shared)
        .environmentObject(OnboardingViewModel())
}
