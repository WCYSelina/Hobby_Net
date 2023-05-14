//
//  DatabaseProtocol.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 27/3/2023.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftUI
enum DatabaseChange {
    case add
    case remove
    case update
    case login
}

enum ListenerType{
    case post
    case comment
    case hobby
    case note
    case record
    case all
    case auth
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby])
    func onRecordChange(change: DatabaseChange, record: [Notes])
    func onNoteChange(change: DatabaseChange, notes: [Notes])
    func onHobbyRecordFirstChange(change:DatabaseChange, hobby:Hobby)
    func onWeeklyRecordChange(change:DatabaseChange, records:[Records])
    func onAuthAccount(change:DatabaseChange,user:FirebaseAuth.User?)
    func onCreateAccount(change:DatabaseChange,user:FirebaseAuth.User?)
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser: User?)
    func onCommentChange(change:DatabaseChange, comments:[Comment])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addHobby(name:String) -> Hobby
    func addNote(noteDetails:String,date:String,hobby:Hobby,image: String,completion: @escaping (Hobby) -> Void)
    func addRecord(date:String) -> Records
    func deleteHobby(hobby: Hobby)
    var email:String? {get set}
    var defaultHobby: Hobby {get set}
    var hasLogin:Bool? {get set}
    var hasCreated:Bool? {get set}
    var error:String? {get set}
    var currentDate:String?{get set}
    var startWeek:Date?{get set}
    var endWeek:Date?{get set}
    var selectedImage: UIImage? {get set}
    func onWeeklyChange(records:[Records])
    func addLikeToUser(like:Post) -> Bool
    func deleteLikeFromUser(like:Post) -> Bool
    func uploadImageToStorage(folderPath:String, image:UIImage, completion:@escaping (String) -> Void)
    func addRecordToHobby(record: Records, hobby: Hobby) -> Bool
    func showCorrespondingRecord(hobby:Hobby,date:String,completion: @escaping () -> Void)
    func showRecordWeekly(hobby:Hobby,startWeek:Date, endWeek:Date,completion: @escaping ([Records],[String]) -> Void)
    func addNoteToRecord(note:Notes,date:String,record:Records, completion: @escaping (Records) -> Void)
    func removeNoteFromRecord(note: Notes, record: Records)
    func createAccount(email:String,password:String) async
    func loginAccount(email:String,password:String) async
    func addPost(postDetail:String) -> Post
}
