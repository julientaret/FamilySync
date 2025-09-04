//
//  FamilyAppIcon.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct FamilyAppIcon: View {
    var body: some View {
        Image("FSIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    FamilyAppIcon()
        .frame(width: 120, height: 120)
        .background(Color.gray.opacity(0.2))
}
