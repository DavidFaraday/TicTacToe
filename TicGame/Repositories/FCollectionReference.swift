//
//  FCollectionReference.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation
import Firebase

enum FCollectionReference: String {
    case Game
}


func FirebaseReference(_ reference: FCollectionReference) -> CollectionReference {
    Firestore.firestore().collection(reference.rawValue)
}
