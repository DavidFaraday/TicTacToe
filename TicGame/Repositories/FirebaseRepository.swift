//
//  FirebaseRepository.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation
import FirebaseFirestoreSwift

public typealias EncodableIdentifiable = Encodable & Identifiable

protocol FirebaseRepositoryProtocol {
    func getDocuments<T: Codable>(from collection: FCollectionReference, for playerId: String) async throws -> [T]?
    func getDocument<T: Codable>(from collection: FCollectionReference) async throws -> T?
    func deleteDocument(with id: String, from collection: FCollectionReference)
    func saveData<T: EncodableIdentifiable>(data: T, to collection: FCollectionReference) throws
}


final class FirebaseRepository: FirebaseRepositoryProtocol {
    
    func getDocuments<T: Codable>(from collection: FCollectionReference, for playerId: String) async throws -> [T]? {

        let snapshot = try await FirebaseReference(collection).whereField("player2Id", isEqualTo: "").whereField("player1Id", isNotEqualTo: playerId).getDocuments()

        return snapshot.documents.compactMap { queryDocumentSnapshot -> T? in
            return try? queryDocumentSnapshot.data(as: T.self)
        }
    }

    func getDocument<T: Codable>(from collection: FCollectionReference) async throws -> T? {
//        let snapshot = try await FirebaseReference(collection).document(id).getDocument()
//        return try? snapshot.data(as: T.self)
        return nil
    }
    
    func deleteDocument(with id: String, from collection: FCollectionReference) {
        FirebaseReference(collection).document(id).delete()
    }
    
    func saveData<T: EncodableIdentifiable>(data: T, to collection: FCollectionReference) throws {
        let id = data.id as? String ?? UUID().uuidString

        do {
            try FirebaseReference(collection).document(id).setData(from: data.self)
        } catch {
            throw error
        }
    }

}
