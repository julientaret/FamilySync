//
//  StartButton.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct StartButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("START")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: 200)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.6), radius: 3, x: 0, y: 2)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: true)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.8, blue: 0.8),
                Color(red: 1.0, green: 0.9, blue: 0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        StartButton(action: {})
            .padding(.horizontal, 40)
    }
}
