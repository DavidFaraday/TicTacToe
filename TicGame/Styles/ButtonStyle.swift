//
//  ButtonStyle.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

struct AppButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .font(.title2)
            .fontWeight(.semibold)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.5 : 1)
            .shadow(radius: 8)
    }
}

extension ButtonStyle where Self == AppButtonStyle {
    static func appButton(color: Color) -> AppButtonStyle {
        return AppButtonStyle(color: color)
    }
}
