//
//  GameView.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: GameViewModel
    
    @ViewBuilder
    private func gameStatus() -> some View {
        Text(viewModel.gameNotification)
            .font(.title2)
        if viewModel.showLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
    
    @ViewBuilder
    private func closeButton() -> some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.quitTheGame()
                dismiss()
            } label: {
                Text("Exit")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func scoreView() -> some View {
        HStack() {
            Text("\(viewModel.player1Name): \(viewModel.player1Score)")
            Spacer()
            Text("\(viewModel.player2Name): \(viewModel.player2Score)")
        }
        .font(.title2)
        .fontWeight(.semibold)
    }
    
    @ViewBuilder
    private func gameBoard(geometry: GeometryProxy) -> some View {
        VStack {
            LazyVGrid(columns: viewModel.columns, spacing: 5) {
                ForEach(0..<9) { index in
                    
                    ZStack {
                        BoardCircleView(geometry: geometry)
                        BoardIndicatorView(imageName: viewModel.moves[index]? .indicator ?? "")
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            viewModel.processMove(for: index)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 10)
        .disabled(viewModel.isGameBoardDisabled)
    }
    
    
    @ViewBuilder
    private func main() -> some View {
        GeometryReader { geometry in
            VStack {
                closeButton()
                scoreView()
                Spacer()
                gameStatus()
                Spacer()
                gameBoard(geometry: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .background(.green.gradient)
        }
    }
    
    var body: some View {
        main()
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: viewModel.alertItem!.title, message: viewModel.alertItem?.message, dismissButton: .default(viewModel.alertItem!.buttonTitle) {
                    viewModel.resetGame()
                })
            }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel(with: .vsCPU))
    }
}
