//
//  BoardIndicatorView.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

struct BoardIndicatorView: View {
    
    var imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .frame(width: 40, height: 40)
            .scaledToFit()
            .foregroundColor(.white)
    }
}

struct BoardIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        BoardIndicatorView(imageName: "applelogo")
    }
}
