//
//  Firebase Controller.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 10/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import Foundation
import SwiftUI
import FirebaseStorage

class FirebaseController: NSObject,DatabaseProtocol{
    var selectedImage: UIImage?
    var startWeek: Date?
    var endWeek: Date?
    var hasLogin: Bool? = nil
    var hasCreated: Bool? = nil
    var error: String?
    var listeners = MulticastDelegate<DatabaseListener>()
    var hobbyList: [Hobby]
    var notesList: [Notes]
    var recordList: [Records]
    var defaultHobby: Hobby
    var defaultUser: User
    var defaultRecord: Records?
    var authController: Auth
    var database: Firestore
    var firebaseStorage:Storage
    var hobbyRef: CollectionReference?
    var recordRef: CollectionReference?
    var noteRef: CollectionReference?
    var userRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var DEFAULT_USERNAME = "username"
    var currentRecord:Records?
    var hobbyName:String?
    var records: [Records] = []
    var hobbyData: [String: Any]?
    var notes:[Notes] = []
    var currentHobby:Hobby?
    var currentRecNotesList: [Notes]?
    var currentDate:String?
    var tempRecord:Records?
    var defaultRecordWeekly:Records?
    var userList: [User]
    
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        firebaseStorage = Storage.storage()
        database = Firestore.firestore()
        hobbyList = [Hobby]()
        userList = [User]()
        defaultHobby = Hobby()
        defaultUser = User()
        notesList = [Notes]()
        recordList = [Records]()
        super.init()
        
//        Task {
//            do {
//                let authDataResult = try await authController.signInAnonymously()
//                currentUser = authDataResult.user
//
//                try await database.collection("users").document(currentUser!.uid).setData(["name":"username"])
//            }
//            catch {
//                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
//            }
//
//        }
    }
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        
        if listener.listenerType == .hobby || listener.listenerType == .all {
            listener.onHobbyChange(change: .update, hobbies: defaultUser.hobbies)
        }
        if listener.listenerType == .record || listener.listenerType == .all {
            let records = defaultHobby.records
            let record = records.first(where: {$0.date == currentDate})
            if record != nil {
                self.notes.append(contentsOf:record!.notes)
                currentRecNotesList = self.notes
            }
            else{
                currentRecNotesList = []
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            var datesInRange:[String] = []
            var today = Date()
            
            for _ in 0..<7 {
                datesInRange.append(dateFormatter.string(from: today))
                today = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            }
            var recordsCorrespondToDates:[Records] = []
            for range in datesInRange {
                let recordToAdd = records.first(where: {$0.date == range})
                if recordToAdd != nil{
                    recordsCorrespondToDates.append(recordToAdd!)
                }
            }
 
            listener.onRecordChange(change: .update, record: currentRecNotesList!)
            listener.onHobbyRecordFirstChange(change: .update, hobby: defaultHobby)
            listener.onWeeklyRecordChange(change: .update, records: recordsCorrespondToDates)
        }
        if listener.listenerType == .note || listener.listenerType == .all {
            listener.onNoteChange(change: .update, notes: notesList)
        }
        if listener.listenerType == .auth || listener.listenerType == .all {
            listener.onAuthAccount(change: .login, user: currentUser)
        }
        if listener.listenerType == .auth || listener.listenerType == .all {
            listener.onCreateAccount(change: .add, user: currentUser)
        }
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    func uploadImageToStorage(folderPath:String, image:UIImage, completion:@escaping (String) -> Void) {
        Task{
            //build storage reference
            let path = folderPath + "images_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString).jpeg"
            let storageRef = self.firebaseStorage.reference(withPath: path)
            //build imageData
            guard let imageData = image.jpegData(compressionQuality: 1) else{
                return
            }
//            //upload image
//            let uploadTask = storageRef.putData(imageData)
//            uploadTask.observe(.progress){ storageTaskSnapshot in
//                let progress = storageTaskSnapshot.progress
//                let percentComplete = 100 * Double(progress!.completedUnitCount) / Double (progress!.totalUnitCount)
//                print("percent: \(percentComplete)")
//                if percentComplete == 100.0{
//                    //check and get storage location
//                    completion(storageTaskSnapshot.reference.fullPath)
//                }
//            }
            // Upload image
            let uploadTask = storageRef.putData(imageData, metadata: nil) { metaData, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        return
                    }
                    if let _ = url {
                        storageRef.getMetadata { metadata, error in
                            if let error = error {
                                print("Error getting metadata: \(error)")
                                return
                            }
                            if let _ = metadata {
                                let fullPath = "gs://fit3178assignment-ed2ba.appspot.com/" + (metaData?.path)!
                                completion(fullPath)
                            }
                        }
                    }
                }
            }
            uploadTask.observe(.progress) { storageTaskSnapshot in
                let progress = storageTaskSnapshot.progress
                let percentComplete = 100 * Double(progress!.completedUnitCount) / Double(progress!.totalUnitCount)
            }
        }
    }
    func addHobby(name: String) -> Hobby {
        var hobby = Hobby()
        hobby.name = name
        hobby.records = []
        do{
            if let hobbyRef = try hobbyRef?.addDocument(from: hobby) {
                hobby.id = hobbyRef.documentID
            }
            let _ = addHobbyToUser(hobby: hobby)
        } catch {
            print("Failed to serialize hero")
        }
        return hobby
    }
    func deleteHobby(hobby: Hobby) {
        if let hobbyID = hobby.id {
            let recordRef = self.database.collection("hobby").document(hobbyID)
            recordRef.getDocument{ (document,error) in
                let oneHobbyRecords = document!.data()!["records"] as! [DocumentReference]
                if !oneHobbyRecords.isEmpty{
                    self.parseSpecificRecord(recordRefArray: oneHobbyRecords){ allRecords in
                        let records = allRecords
                        self.hobbyRef?.document(hobbyID).delete(){ delete in
                            self.hobbyList.removeAll(where: {$0.id == hobbyID})
                            for record in records {
                                let docRef = self.database.collection("records").document((record.id)!)
                                docRef.getDocument{ (document, error) in
                                    let oneRecordNotes = document!.data()!["notes"] as! [DocumentReference]
                                    self.parseSpecificNote(noteRefArray: oneRecordNotes){ allNotes in
                                        for note in allNotes {
                                            self.deleteNote(note: note)
                                        }
                                    }
                                    self.deleteRecord(record: record)
                                    
                                    //
                                    //                                self.defaultRecord = nil
                                }
                                self.listeners.invoke{ listener in
                                    if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                        listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                    self.hobbyRef?.document(hobbyID).delete { delete in
                        self.hobbyList.removeAll(where: { $0.id == hobbyID })
                        self.listeners.invoke { listener in
                            if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
                            }
                        }
                    }
                }
            }
        }
    }
    func deleteRecord(record:Records){
        if let recordID = record.id{
            recordRef?.document(recordID).delete()
        }
    }
    func deleteNote(note:Notes){
        if let noteID = note.id{
            noteRef?.document(noteID).delete()
        }
    }
    
    func addNote(noteDetails:String,date:String,hobby:Hobby,image:String, completion: @escaping (Hobby) -> Void) {
        let note = Notes()
        note.noteDetails = noteDetails
        note.image = image
        if let noteRef =  noteRef?.addDocument(data: ["noteDetails" : noteDetails, "image" : image]) {
            note.id = noteRef.documentID
        }
        var record = getRecordByTimestamp(date: date,hobby: hobby)
        if record != nil {
            record?.notes.append(note)
            let _ = addNoteToRecord(note: note, date: date, record: record!){ oneRecord in
                completion(hobby)
            }
        }else{
            record = self.addRecord(date: date)
            let _ = self.addNoteToRecord(note: note, date: date, record: record!){oneRecord in
                self.defaultRecord = oneRecord
                self.defaultRecordWeekly = oneRecord
                let _ = self.addRecordToHobby(record: oneRecord, hobby: hobby)
                        completion(hobby)
            }
        }
    }
    func addNoteToRecord(note:Notes,date:String,record:Records, completion: @escaping (Records) -> Void){
        guard let noteID = note.id, let recordID = record.id else {
            return
        }
        if let newNoteRef = noteRef?.document(noteID) {
            recordRef?.document(recordID).updateData(
                ["notes" : FieldValue.arrayUnion([newNoteRef])]){ error in
                    if let error = error{
                        print(error)
                    }else{
                        self.recordRef?.document(recordID).getDocument{ (updateRecord,error) in
                            if let error = error{
                                print(error.localizedDescription)
                                completion(record)
                            }else{
                                self.tempRecord = record
                                self.tempRecord?.notes.append(note)
                                completion(self.tempRecord!)
                                }
                            }
                        }
                    }
                }
            }
    
    func addRecordToHobby(record: Records, hobby: Hobby) -> Bool {
        guard let recordID = record.id, let hobbyID = hobby.id else {
            return false
        }
        self.currentHobby?.records.append(record)
        if let newRecordRef = self.recordRef?.document(recordID) {
            self.hobbyRef?.document(hobbyID).updateData(
                ["records" : FieldValue.arrayUnion([newRecordRef])])
        }
        self.listeners.invoke{ listener in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onHobbyRecordFirstChange(change: .update, hobby: self.currentHobby!)
            }
        }
        return true
    }
    
    func addRecord(date:String) -> Records{
        var record = Records()
        record.date = date
        record.notes = []
        do{
            if let recordRef = try recordRef?.addDocument(from: record) {
                record.id = recordRef.documentID
                self.defaultHobby.records.append(record)
            }
        } catch {
            print("Failed to serialize hero")
        }
        return record
    }

    func addHobbyToUser(hobby: Hobby) -> Bool {
        guard let hobbyID = hobby.id, let userID = self.defaultUser.id else {
            return false
        }

        if let newHobbyRef = hobbyRef?.document(hobbyID) {
            userRef?.document(userID).updateData(
                ["hobbies" : FieldValue.arrayUnion([newHobbyRef])])
        }
        defaultUser.hobbies.append(hobby)
        self.listeners.invoke{ listener in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onHobbyChange(change: .update, hobbies: self.defaultUser.hobbies)
            }
        }
        return true
    }
    
    
    func removeNoteFromRecord(note: Notes, record: Records) {
        if record.notes.contains(note), let recordID = record.id, let noteID = note.id {
            if let removedNoteRef = noteRef?.document(noteID) {
                recordRef?.document(recordID).updateData(
                    ["records": FieldValue.arrayRemove([removedNoteRef])]
                )
            }
        }
    }
    func cleanup() {}

    func getHobbyByID(_ id: String) -> Hobby? {
        for hobby in hobbyList {
            if hobby.id == id {
                return hobby
            }
        }
        return nil
    }
    func getRecordByTimestamp(date:String,hobby:Hobby) -> Records? {
        for record in recordList {
            if record.date == date, hobby.records.contains(where: {$0.id == record.id}){
                return record
            }
        }
        return nil
    }
    func onWeeklyChange(records:[Records]){
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onWeeklyRecordChange(change: .update, records: records)
            }
        }
    }
    func convertToDateOnly(date:Date) -> Timestamp {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Create a new Date object with the extracted date components
        let dateOnly = calendar.date(from: DateComponents(year: year, month: month, day: day))!

        // Convert the date-only object to a Timestamp
        let timestamp = Timestamp(date: dateOnly)
        return timestamp
    }
    
    func showRecordWeekly(hobby:Hobby,startWeek:Date, endWeek:Date,completion: @escaping ([Records],[String]) -> Void) {
        print("startWeek\(startWeek)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var datesInRange:[String] = []
        var currentDate = startWeek
        
        while currentDate <= endWeek{ // get the all the dates between startWeek and endWeek
            datesInRange.append(dateFormatter.string(from: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        var records = hobby.records
        if defaultRecordWeekly != nil{
            records.append(defaultRecordWeekly!)
            defaultRecordWeekly = nil
        }
        var recordsCorrespondToDates:[Records] = []
        for range in datesInRange {
            let recordToAdd = records.first(where: {$0.date == range})
            if recordToAdd != nil{
                recordsCorrespondToDates.append(recordToAdd!)
            }
        }
        var recordReference:[DocumentReference] = []
        for recordsCorrespondToDate in recordsCorrespondToDates {
            let docRef = database.collection("records").document(recordsCorrespondToDate.id!)
            recordReference.append(docRef)
        }
        if recordReference.count != 0{
            self.parseSpecificRecord(recordRefArray: recordReference){ records in
                completion(records,datesInRange)
            }
        }else{
            records = []
            completion(records,datesInRange)
        }
    }
    func showCorrespondingRecord(hobby:Hobby,date:String,completion: @escaping () -> Void) {
        self.currentHobby = hobby
        self.notes = []
        let records = hobby.records
        var record = records.first(where: {$0.date == date})
        if defaultRecord != nil , record == nil, currentDate == date{
            record = defaultRecord
            defaultRecord = nil
        }
        if record != nil {
            let docRef = database.collection("records").document((record?.id)!)
            docRef.getDocument{ (document, error) in
                let oneRecordNotes = document!.data()!["notes"] as! [DocumentReference]
                self.parseSpecificNote(noteRefArray: oneRecordNotes){ allNotes in
                    record?.notes = allNotes
                    self.currentRecNotesList = record?.notes
                    self.listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                            listener.onRecordChange(change: .update, record: self.currentRecNotesList!)
                        }
                    }
                    completion()
                }
            }
        }
        else{
            currentRecNotesList = []
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                    listener.onRecordChange(change: .update, record: self.currentRecNotesList!)
                }
            }
            completion()
        }
    }
    func setupUserListener(completion: @escaping () -> Void){
        userRef = database.collection("user")
        userRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseUserSnapshot(snapshot: querySnapshot){ user in
                print("kkkk\(user.hobbies)")
                self.listeners.invoke { (listener) in
                    print("hhhhhhhhh")
                    if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                        listener.onHobbyChange(change: .update, hobbies: user.hobbies)
                    }
                    completion()
                }
            }
        }
    }
    func parseUserSnapshot(snapshot: QuerySnapshot, completion: @escaping (User) -> Void){
        print("Entry parseSpecificUser")
        snapshot.documentChanges.forEach{ (change) in
            var parsedUser = User()
            if change.document.exists{
                if currentUser?.uid == change.document.documentID{
                    parsedUser.id = change.document.documentID
                    parsedUser.name = change.document.data()["name"] as? String
                    let hobbyRef = change.document.data()["hobbies"] as! [DocumentReference]
                    if hobbyRef == []{
                        parsedUser.hobbies = []
                        self.addToUserList(change: change, parsedUser: parsedUser){
                            completion(parsedUser)
                        }
                    }
                    else{
                        self.parseSpecificHobby(hobbyRefArray: hobbyRef){ resultHobbies in
                            parsedUser.hobbies = resultHobbies
                            print("Leave parseSpecificUser")
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                print(parsedUser)
                                completion(parsedUser)
                            }
                        }
                    }
                }
            }
        }
    }
    func addToUserList(change:DocumentChange,parsedUser:User, completion: @escaping () -> Void){
        let docRef = database.collection("user").document(parsedUser.id!)
        docRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                if change.type == .added {

                    if let index = self.userList.firstIndex(where: { $0.id == parsedUser.id }) {
                        // If the parsedHobby already exists in the list, update it
                        self.userList[index] = parsedUser
                    } else {
                        // If the parsedHobby doesn't exist in the list, add it
                        self.userList.append(parsedUser)
                    }
                } else if change.type == .modified {
                    if let index = self.userList.firstIndex(where: { $0.id == parsedUser.id }) {
                        // If the parsedHobby exists in the list, update it
                        self.userList[index] = parsedUser
                    }
                } else if change.type == .removed {
                    if let index = self.userList.firstIndex(where: { $0.id == parsedUser.id }) {
                        // If the parsedHobby exists in the list, remove it
                        self.userList.remove(at: index)
                    }
                }
            }
            completion() //return, finished executing
        }
    }
    func setupHobbyListener() {
        hobbyRef = database.collection("hobby")
        hobbyRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseHobbySnapshot(snapshot: querySnapshot){ () in
                // nothing to do
                
            }
        }
    }
 
    func addToHobbyList(change:DocumentChange,parsedHobby:Hobby, completion: @escaping () -> Void){
        let docRef = database.collection("hobby").document(parsedHobby.id!)
        
        docRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                if change.type == .added {
                    if let index = self.hobbyList.firstIndex(where: { $0.id == parsedHobby.id }) {
                        // If the parsedHobby already exists in the list, update it
                        self.hobbyList[index] = parsedHobby
                    } else {
                        // If the parsedHobby doesn't exist in the list, add it
                        self.hobbyList.append(parsedHobby)
                    }
                } else if change.type == .modified {
                    if let index = self.hobbyList.firstIndex(where: { $0.id == parsedHobby.id }) {
                        // If the parsedHobby exists in the list, update it
                        self.hobbyList[index] = parsedHobby
                    }
                } else if change.type == .removed {
                    if let index = self.hobbyList.firstIndex(where: { $0.id == parsedHobby.id }) {
                        // If the parsedHobby exists in the list, remove it
                        self.hobbyList.remove(at: index)
                    }
                }
            }
            completion() //return, finished executing
        }
    }
 
    func parseHobbySnapshot(snapshot: QuerySnapshot, completion: @escaping () -> Void){
        snapshot.documentChanges.forEach{ (change) in
            var parsedHobby = Hobby()
            if change.document.exists{
                parsedHobby.id = change.document.documentID
                parsedHobby.name = change.document.data()["name"] as? String
                let recordRef = change.document.data()["records"] as! [DocumentReference]
                if recordRef == []{
                    parsedHobby.records = []
                    self.addToHobbyList(change: change, parsedHobby: parsedHobby){ [weak self] in
                        //[weak self] and the next line make sure the following line execute after addToHobbyList finished executing
                        guard let self = self else { return }
                        self.listeners.invoke { (listener) in
                            if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                self.defaultUser = self.findUserById(id: self.currentUser!.uid)!
                                listener.onHobbyChange(change: .update, hobbies: self.defaultUser.hobbies)
                            }
                        }
                    }
                }
                else{
                    self.parseSpecificRecord(recordRefArray: recordRef){ resultRecords in
                        parsedHobby.records = resultRecords
                        self.addToHobbyList(change: change, parsedHobby: parsedHobby){ [weak self] in
                            guard let self = self else { return }
                            self.listeners.invoke { (listener) in
                                if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                    self.defaultUser = self.findUserById(id: self.currentUser!.uid)!
                                    listener.onHobbyChange(change: .update, hobbies: self.defaultUser.hobbies)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func parseSpecificHobby(hobbyRefArray:[DocumentReference], completion: @escaping ([Hobby]) -> Void){
        if hobbyRefArray.count == 0{
            completion([])
        }
        var counter = 0
        var resultHobbyList:[Hobby] = []
        hobbyRefArray.forEach{ oneHobbyRef in
            oneHobbyRef.getDocument{ (oneHobbyDoc,error) in
                if let document = oneHobbyDoc, document.exists{
                    var oneHobbyObj = Hobby()
                    oneHobbyObj.id = document.documentID
                    oneHobbyObj.name = document.data()!["name"] as? String
                    self.parseSpecificRecord(recordRefArray: oneHobbyDoc?.data()!["records"] as! [DocumentReference]){ allRecords in
                        oneHobbyObj.records = allRecords
                        resultHobbyList.append(oneHobbyObj)
                        counter += 1
                        if counter == hobbyRefArray.count{
                            completion(resultHobbyList)
                        }
                    }
                }
            }
        }
    }
    func parseSpecificRecord(recordRefArray:[DocumentReference], completion: @escaping ([Records]) -> Void){
        if recordRefArray.count == 0 {
            completion([])
        }
        var counter = 0
        var resultRecordsList:[Records] = []
        print(recordRefArray.count)
        recordRefArray.forEach{ oneRecordRef in
            oneRecordRef.getDocument{ (oneRecordDoc,error)  in
                if let document = oneRecordDoc, document.exists{
                    print(document.documentID)
                    var oneRecordObj = Records()
                    oneRecordObj.id = document.documentID
                    oneRecordObj.date = document.data()!["date"] as? String
                    self.parseSpecificNote(noteRefArray: oneRecordDoc?.data()!["notes"] as! [DocumentReference]){ allNotes in
                        oneRecordObj.notes = allNotes
                        resultRecordsList.append(oneRecordObj)
                        counter += 1
                        if counter == recordRefArray.count{
                            completion(resultRecordsList)
                        }
                    }
                }
            }
        }
    }
    func parseSpecificNote(noteRefArray:[DocumentReference], completion: @escaping ([Notes]) -> Void){
        if noteRefArray.count == 0{
            completion([])
        }
        var NotesList:[Notes] = []
        var count = 0
        noteRefArray.forEach{ onoNoteRef in
            onoNoteRef.getDocument{ (oneNoteDoc,error) in
                if let document = oneNoteDoc, document.exists{
                    var parsedNote: Notes?
                    do {
                        parsedNote = try document.data(as: Notes.self)
                    } catch {
                        print("Unable to decode notes.: Note")
                        return
                    }
                    guard let note = parsedNote else {
                        print("Document doesn't exist: Note")
                        return
                    }
                    NotesList.append(note)
                    count += 1
                    if count == noteRefArray.count{
                        completion(NotesList)
                    }
                }
            }
        }
    }
    func setupRecordListener() {
        recordRef = database.collection("records")
        recordRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseRecordSnapshot(snapshot: querySnapshot){ () in
                // nothing to do
                
            }
        }
    }
    func parseRecordSnapshot(snapshot: QuerySnapshot, completion: @escaping () -> Void){
        print("heyyyyyy")
        snapshot.documentChanges.forEach{ (change) in
            var parsedRecord = Records()
            if change.document.exists{
                parsedRecord.id = change.document.documentID
                parsedRecord.date = change.document.data()["date"] as? String
                let noteRef = change.document.data()["notes"] as! [DocumentReference]
                if noteRef == []{
                    parsedRecord.notes = []
                    self.addToRecordList(change: change, parsedRecord: parsedRecord)
                }
                else{
                    self.parseSpecificNote(noteRefArray: noteRef){ allNotes in
                        parsedRecord.notes = allNotes
                        self.addToRecordList(change: change, parsedRecord: parsedRecord)
                    }
                }
            }
        }
    }
    func addToRecordList(change:DocumentChange,parsedRecord:Records){
        if change.type == .added {
            if self.recordList.count == change.newIndex{
                self.recordList.insert(parsedRecord, at: Int(change.newIndex))
            }
        }
        else if change.type == .modified {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.string(from: Date())
            self.showCorrespondingRecord(hobby: self.currentHobby!,date: date){ [weak self] in
                guard let self = self else { return }
                self.recordList[Int(change.oldIndex)] = parsedRecord
            }
        }
        else if change.type == .removed {
            self.recordList.remove(at: Int(change.oldIndex))
        }
    }
    func setupNotesListener() {
        noteRef = database.collection("note")
        noteRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseNotesSnapshot(snapshot: querySnapshot)
        }
    }
    func parseNotesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            
            var parsedNote: Notes?
            do {
                parsedNote = try change.document.data(as: Notes.self)
            } catch {
                print("Unable to decode notes.")
                return
            }
            guard let note = parsedNote else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                notesList.insert(note, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                notesList[Int(change.oldIndex)] = note
            }
            else if change.type == .removed {
                notesList.remove(at: Int(change.oldIndex))
            }
        }
    }
    func addUser(name: String, id:String) -> User {
        var user = User()
        user.name = name
        user.hobbies = []
        userRef?.document(id).setData(["name":name, "hobbies":user.hobbies])
        return user
    }
    
    func createAccount(email: String, password: String) async {
        do{
            let result = try await authController.createUser(withEmail: email, password: password)
            self.currentUser = result.user
        }catch{
            self.error = error.localizedDescription

            hasCreated = false
        }
        if hasCreated == nil{
            hasCreated = true
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
                listener.onCreateAccount(change:.add,user:self.currentUser)
            }
        }
        self.setupUserListener(){ () in
            
        }
        let _ = self.addUser(name: email,id: self.currentUser!.uid)
    }
    
    func findUserById(id:String) -> User? {
        for user in userList {
            if user.id == id{
                return user
            }
        }
        return nil
    }

    func loginAccount(email: String, password: String) async {
        do{
            let result = try await authController.signIn(withEmail: email, password: password)
            currentUser = result.user
        } catch{
            self.error = error.localizedDescription
            hasLogin = false
        }
        if hasLogin == nil{
            hasLogin = true
        }
        self.setupUserListener(){ () in
            self.setupHobbyListener()
            self.setupRecordListener()
            self.setupNotesListener()
        }
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
                listener.onAuthAccount(change:.login,user: self.currentUser)
            }
        }
        
    }
}
