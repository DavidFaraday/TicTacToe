//
//  ContentView.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

struct HomeView: View {
    
    @State private var gameMode: GameMode?
    @State private var showGameView: Bool = false
    
    @ViewBuilder
    private func titleView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "number")
                .renderingMode(.original)
                .resizable()
                .frame(width: 180, height: 180)
            
            Text(AppStrings.appName)
                .font(.largeTitle)
                .fontWeight(.semibold)
        }
        .foregroundColor(.indigo)
        .padding(.top, 50)
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        
        VStack(spacing: 15) {
            ForEach(GameMode.allCases, id:\.self) { mode in
                Button {
                    gameMode = mode
                    showGameView = true
                } label: {
                    Text(mode.name)
                }
                .buttonStyle(.appButton(color: mode.color))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 50)
    }
    
    @ViewBuilder
    private func main() -> some View {
        VStack {
            titleView()
            Spacer()
            buttonView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 0.91, green: 0.89, blue: 0.90))
    }
    
    
    var body: some View {
        main()
            .fullScreenCover(item: $gameMode, content: { mode in
                GameView(viewModel: GameViewModel(with: mode))
            })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
