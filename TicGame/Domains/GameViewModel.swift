//
//  GameViewModel.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI
import Combine
/*
 Join game
 if there is a game available, join, else create a game and listen for changes.
 
 Created a game / waiting
 block user move.
 Show the notification of waiting
 sync local game with the online
 Scores are 0
 
 Joined a game
 put us as player 2
 block our move
 show notification of started game.
 
 on each click, process the move locally,
 
 if game is over,
 update the score
 update the winnersID
 show notification
 
 
 if its draw
 update winners id to 0
 show notification
 
 
 sync with online

 */

final class GameViewModel: ObservableObject {
    let onlineRepository = OnlineGameRepository()
    
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
    @Published private(set) var onlineGame: Game?
    @Published private(set) var showLoading = false
    
    @Published private var gameMode: GameMode
    @Published private var players: [Player]

    @Published var showAlert = false
    
    private let centerSquare = 4

    private var cancellables: Set<AnyCancellable> = []

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
        
    private func observerData() {
        $players
            .map { $0.first?.name ?? "" }
            .assign(to: &$player1Name)
        
        $players
            .map { $0.last?.name ?? "" }
            .assign(to: &$player2Name)
        
        onlineRepository.$game
            .map { $0 }
            .assign(to: &$onlineGame)

        $onlineGame
            .map { $0?.moves ?? Array(repeating: nil, count: 9) }
            .assign(to: &$moves)
        
        $onlineGame
            .map { $0?.player1Score ?? 0 }
            .assign(to: &$player1Score)
        
        $onlineGame
            .map { $0?.player2Score ?? 0 }
            .assign(to: &$player2Score)
        
        $onlineGame
            .drop(while: { $0 == nil } )
            .map { $0?.player2Id == "" }
            .assign(to: &$showLoading)
        
        $onlineGame
            .drop(while: { $0 == nil } )
            .sink { updatedGame in
                self.syncOnlineWithLocal(onlineGame: updatedGame)
            }
            .store(in: &cancellables)
    }
    
    private func startOnlineGame() {

        gameNotification = AppStrings.waitingForPlayer
        Task {
            await onlineRepository.joinGame()
        }
    }
    
    private func syncOnlineWithLocal(onlineGame: Game?) {
        guard let game = onlineGame else {
            showAlert(for: .quit)
            return
        }
        
        //if its finished, show alert
        if game.winningPlayerId == "0" {
            self.showAlert(for: .draw)
        } else if game.winningPlayerId != "" {
            self.showAlert(for: .finished)
        }

        //set disable
        isGameBoardDisabled = game.player2Id == "" ? true : localPlayerId != game.activePlayerId
                
        //set active player & notification
        setActivePlayerAndNotification(from: game)
        
        //set the notification for new game
        if game.player2Id == "" {
            gameNotification = AppStrings.waitingForPlayer
        }
    }
    
    
    private func setActivePlayerAndNotification(from game: Game) {
        if localPlayerId == game.player1Id {
            if localPlayerId == game.activePlayerId {
                self.activePlayer = .player1
                gameNotification = AppStrings.yourMove
            } else {
                gameNotification = "It's \(activePlayer.name)'s move"
            }
        } else {
            if localPlayerId == game.activePlayerId {
                self.activePlayer = .player2
                gameNotification = AppStrings.yourMove
            } else {
                gameNotification = "It's \(activePlayer.name)'s move"
            }
        }
    }
    
    private func updateOnlineGame(process: GameProcess) {
        guard var tempGame = onlineGame else { return }
        
        //disable board
        isGameBoardDisabled = localPlayerId != tempGame.activePlayerId

        //set active player
        tempGame.activePlayerId = tempGame.activePlayerId == tempGame.player1Id ? tempGame.player2Id : tempGame.player1Id

        //set the score
        tempGame.player1Score = player1Score
        tempGame.player2Score = player2Score
        
        switch process {
        case .win:
            tempGame.winningPlayerId = localPlayerId
        case .draw:
            tempGame.winningPlayerId = "0"
            tempGame.activePlayerId = tempGame.player1Id
        case .reset:
            tempGame.winningPlayerId = ""
            tempGame.activePlayerId = tempGame.player1Id
        case .move:
            break
        }
        
        tempGame.moves = moves

        let gameToSave = tempGame
        
        Task {
            await onlineRepository.updateGame(gameToSave)
        }
    }
    
    
    private func showAlert(for state: GameState) {
        gameNotification = state.name

        switch state {
        case .finished, .draw, .waitingForPlayer:
            let title = state == .finished ? "\(activePlayer.name) has won!" : state.name
            alertItem = AlertItem(title: title, message: AppStrings.tryRematch)

        case .quit:
            let title = state.name
            alertItem = AlertItem(title: title, message: "", buttonTitle: "OK")
            isGameBoardDisabled = true
        }
        
        showAlert = true
    }
    
    
    func processMove(for position: Int) {
        if isSquareOccupied(in: moves, forIndex: position) { return }

        moves[position] = GameMove(player: activePlayer, boardIndex: position)
        
        if checkWinCondition(in: moves) {
            showAlert(for: .finished)
            increaseScore()
            updateOnlineGame(process: .win)
            return
        }
        
        if checkForDraw(in: moves) {
            showAlert(for: .draw)
            updateOnlineGame(process: .draw)
            return
        }
        
        activePlayer = players.first(where: { $0 != activePlayer })!
        
        if gameMode == .vsCPU && activePlayer == .cpu {
            isGameBoardDisabled = true
            computerMove()
        }
        
        updateOnlineGame(process: .move)
        gameNotification = "It's \(activePlayer.name)'s move"
    }
    
    private func computerMove() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in
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
        moves = Array(repeating: nil, count: 9)
        
        if gameMode == .online {
            updateOnlineGame(process: .reset)
        } else {
            gameNotification = "It's \(activePlayer.name)'s move"
        }
    }
    
    func quitTheGame() {
        onlineRepository.quiteGame()
    }
}

