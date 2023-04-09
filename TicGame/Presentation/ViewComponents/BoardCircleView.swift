//
//  BoardCircleView.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

struct BoardCircleView: View {
    var geometry: GeometryProxy
    
    var body: some View {
        Circle()
            .foregroundColor(.blue.opacity(0.7))
            .frame(width: geometry.size.width / 3 - 15, height: geometry.size.width / 3 - 15)
    }
}

struct BoardCircleView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            BoardCircleView(geometry: geometry)
        }
    }
}
