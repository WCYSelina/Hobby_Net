//
//  DatabaseProtocol.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 27/3/2023.
//

import Foundation
import FirebaseAuth
enum DatabaseChange {
    case add
    case remove
    case update
    case login
}

enum ListenerType{
    case user
    case hobby
    case record
    case all
    case auth
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onUserChange(change: DatabaseChange, hobbies: [Hobby])
    func onHobbyChange(change: DatabaseChange, record: [Records])
    func onRecordChange(change: DatabaseChange, notes: [Notes])
//    func onAuthAccount(change:DatabaseChange,user:FirebaseAuth.User?)
//    func onCreateAccount(change:DatabaseChange,user:FirebaseAuth.User?)
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addHobby(name:String)
    -> Hobby
    func deleteHobby(hobby: Hobby)
    var defaultHobby: Hobby {get}
    var hasLogin:Bool? {get set}
    var hasCreated:Bool? {get set}
    var error:String? {get set}
    func addRecordToHobby(record: Records, hobby: Hobby) -> Bool
    func removeRecordFromHobby(record: Records, hobby: Hobby)
    func addNoteToRecord(note: Notes, record: Records) -> Bool
    func removeNoteFromRecord(note: Notes, record: Records)
//    func createAccount(email:String,password:String) async
//    func loginAccount(email:String,password:String) async
}
