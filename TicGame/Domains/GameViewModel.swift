//
//  GameViewModel.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI


final class GameViewModel: ObservableObject {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    private let winPatterns: Set<Set<Int>> = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]
    
    @Published private(set) var moves: [GameMove?] = Array(repeating: nil, count: 9)
    @Published private(set) var isGameBoardDisabled = false
    @Published private(set) var activePlayer: Player = .player1
    @Published private(set) var player1Score = 0
    @Published private(set) var player2Score = 0
    @Published private(set) var player1Name = ""
    @Published private(set) var player2Name = ""
    @Published private(set) var gameNotification = ""
    @Published private(set) var alertItem: AlertItem?
    @Published private(set) var game: Game?
    
    @Published private var gameMode: GameMode
    @Published private var players: [Player]

    @Published var showAlert = false
    
    private let centerSquare = 4

    init(with gameMode: GameMode) {
        
        self.gameMode = gameMode
        
        switch gameMode {
        case .vsHuman:
            self.players = [.player1, .player2]
        case .online:
            self.players = [.player1, .player2]
            startOnlineGame()
        case .vsCPU:
            self.players = [.player1, .cpu]
        }
        
        gameNotification = "It's \(activePlayer.name)'s move"
        observerData()
    }
    
    private func startOnlineGame() {
        
    }
    
    private func observerData() {
        $players
            .map({ $0.first?.name ?? "" })
            .assign(to: &$player1Name)
        
        $players
            .map({ $0.last?.name ?? "" })
            .assign(to: &$player2Name)
    }
    
    private func showAlert(for state: GameState) {
        var title = ""
        
        switch state {
        case .finished:
            title = "\(activePlayer.name) has won!"
            gameNotification = state.name
        case .draw:
            title = state.name
            gameNotification = state.name
        }
        
        alertItem = AlertItem(title: title, message: "Try rematching!")
        showAlert = true
    }
    
    func processMove(for position: Int) {
        if isSquareOccupied(in: moves, forIndex: position) { return }

        moves[position] = GameMove(player: activePlayer, boardIndex: position)
        
        if checkWinCondition(in: moves) {
            showAlert(for: .finished)
            increaseScore()
            return
        }
        
        if checkForDraw(in: moves) {
            showAlert(for: .draw)
            return
        }
        
        activePlayer = players.first(where: { $0 != activePlayer })!
        
        if gameMode == .vsCPU && activePlayer == .cpu {
            isGameBoardDisabled = true
            computerMove()
        }
        
        gameNotification = "It's \(activePlayer.name)'s move"
    }
    
    private func computerMove() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            processMove(for: getAIMovePosition(in: moves))
            isGameBoardDisabled = false
        }
    }
    
    
    private func getAIMovePosition(in moves: [GameMove?]) -> Int {
        
        // If AI can win, then win
        let computerMoves = moves.compactMap{ $0 }.filter { $0.player == .cpu }
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        
        if let position = getTheWinningSpot(for: computerPositions) {
            return position
        }
        
        // If AI can't win, then block the player
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .player1 }
        let humanPositions = Set(humanMoves.map { $0.boardIndex })
        
        if let position = getTheWinningSpot(for: humanPositions) {
            return position
        }
        
        // If AI can't block, then take middle square
        if !isSquareOccupied(in: moves, forIndex: centerSquare) { return centerSquare }
        
        // If AI can't take middle square, then take random available square
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    
    private func increaseScore() {
        if activePlayer == .player1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
    }
    
    private func checkWinCondition(in moves: [GameMove?]) -> Bool {
        let playerMoves = moves.compactMap {$0}.filter { $0.player == activePlayer }
        let playerPositions = Set(playerMoves.map { $0.boardIndex } )
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
    
    
    private func isSquareOccupied(in moves: [GameMove?], forIndex index: Int) -> Bool {
        moves.contains(where: { $0?.boardIndex == index})
    }
    
    private func checkForDraw(in moves: [GameMove?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }
    
    private func getTheWinningSpot(for positions: Set<Int>) -> Int? {
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(positions)
            
            if winPositions.count == 1 && !isSquareOccupied(in: moves, forIndex: winPositions.first!) {
                return winPositions.first!
            }
        }
        
        return nil
    }
    
    func resetGame() {
        activePlayer = .player1
        gameNotification = "It's \(activePlayer.name)'s move"
        moves = Array(repeating: nil, count: 9)
    }
}
