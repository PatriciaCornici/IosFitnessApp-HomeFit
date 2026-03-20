//
//  ProfileCard.swift
//  HomeFitApp
//
//  Created by Stoica Patricia on 15.05.2025.
//

import Foundation
import SwiftUI

struct ProfileCard: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.homefitTextDark)

            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
