import SwiftUI

/// Modal pour créer une nouvelle famille
struct CreateFamilyModal: View {
    @EnvironmentObject var familyViewModel: FamilyManagementViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#e9906f"))
                    
                    Text("Créer une famille")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Donnez un nom à votre famille pour commencer")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nom de la famille")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Ex: Famille Martin", text: $familyViewModel.familyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                        
                        if !familyViewModel.familyName.isEmpty && !familyViewModel.validateFamilyName() {
                            Text("Le nom doit contenir entre 2 et 50 caractères")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            if let userId = authService.currentUser?.id {
                                await familyViewModel.createFamily(userId: userId)
                            }
                        }
                    }) {
                        HStack {
                            if familyViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Créer la famille")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            familyViewModel.validateFamilyName() && !familyViewModel.isLoading
                            ? Color(hex: "#e9906f")
                            : Color.gray
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!familyViewModel.validateFamilyName() || familyViewModel.isLoading)
                    
                    Button(action: {
                        familyViewModel.resetModalData()
                        dismiss()
                    }) {
                        Text("Annuler")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .alert("Erreur", isPresented: $familyViewModel.showError) {
            Button("OK") {
                familyViewModel.showError = false
            }
        } message: {
            Text(familyViewModel.errorMessage ?? "Une erreur est survenue")
        }
    }
}

#Preview {
    CreateFamilyModal()
        .environmentObject(FamilyManagementViewModel())
        .environmentObject(AuthService.shared)
}

