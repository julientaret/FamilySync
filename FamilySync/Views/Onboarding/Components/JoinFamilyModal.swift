import SwiftUI

/// Modal pour rejoindre une famille existante
struct JoinFamilyModal: View {
    @EnvironmentObject var familyViewModel: FamilyManagementViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#e9906f"))
                    
                    Text("Rejoindre une famille")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Entrez le code d'invitation pour rejoindre une famille existante")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Code d'invitation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Ex: ABCD1234EFGH5678-ABC123", text: $familyViewModel.inviteCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onChange(of: familyViewModel.inviteCode) { newValue in
                                // Convertir en majuscules
                                familyViewModel.inviteCode = newValue.uppercased()
                            }
                        
                        if !familyViewModel.inviteCode.isEmpty && !familyViewModel.validateInviteCode() {
                            Text("Le code doit avoir le format: CODE-TIMESTAMP (ex: ABCD1234EFGH5678-ABC123)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        Text("Le code d'invitation se trouve dans les paramètres de la famille")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            if let userId = authService.currentUser?.id {
                                await familyViewModel.joinFamily(userId: userId)
                            }
                        }
                    }) {
                        HStack {
                            if familyViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Rejoindre la famille")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            familyViewModel.validateInviteCode() && !familyViewModel.isLoading
                            ? Color(hex: "#e9906f")
                            : Color.gray
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!familyViewModel.validateInviteCode() || familyViewModel.isLoading)
                    
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
    JoinFamilyModal()
        .environmentObject(FamilyManagementViewModel())
        .environmentObject(AuthService.shared)
}

