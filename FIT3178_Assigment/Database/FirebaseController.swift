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

class FirebaseController: NSObject,DatabaseProtocol{
    
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
    
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        hobbyList = [Hobby]()
        defaultHobby = Hobby()
        defaultUser = User()
        notesList = [Notes]()
        recordList = [Records]()
        super.init()
        
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
                
                try await database.collection("users").document(currentUser!.uid).setData(["name":"username"])
            }
            catch {
                fatalError("Firebase Authentication Failed with Error\(String(describing: error))")
            }
            self.setupHobbyListener()
            self.setupRecordListener()
            self.setupNotesListener()

        }
    }
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        
        if listener.listenerType == .hobby || listener.listenerType == .all {
            listener.onHobbyChange(change: .update, hobbies: hobbyList)
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
//        if listener.listenerType == .auth || listener.listenerType == .all {
//            listener.onAuthAccount(change: .login, user: currentUser)
//        }
//        if listener.listenerType == .auth || listener.listenerType == .all {
//            listener.onCreateAccount(change: .add, user: currentUser)
//        }
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    func addHobby(name: String) -> Hobby {
        var hobby = Hobby()
        hobby.name = name
        hobby.records = []
        do{
            if let hobbyRef = try hobbyRef?.addDocument(from: hobby) {
                hobby.id = hobbyRef.documentID
            }
//            let _ = self.addHobbyToUser(hobby: hobby, user: defaultUser)
        } catch {
            print("Failed to serialize hero")
        }
        return hobby
    }
    func deleteHobby(hobby: Hobby) {
        if let hobbyID = hobby.id {
            let recordRef = self.database.collection("hobby4").document(hobbyID)
            recordRef.getDocument{ (document,error) in
                let oneHobbyRecords = document!.data()!["records"] as! [DocumentReference]
                self.parseSpecificRecord(recordRefArray: oneHobbyRecords){ allRecords in
                    let records = allRecords
                    self.hobbyRef?.document(hobbyID).delete(){ delete in
                        self.hobbyList.removeAll(where: {$0.id == hobbyID})
                        for record in records {
                            let docRef = self.database.collection("record5").document((record.id)!)
                            docRef.getDocument{ (document, error) in
                                let oneRecordNotes = document!.data()!["notes"] as! [DocumentReference]
                                self.parseSpecificNote(noteRefArray: oneRecordNotes){ allNotes in
                                    for note in allNotes {
                                        self.deleteNote(note: note)
                                    }
                                }
                                self.deleteRecord(record: record)
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
    
    func addNote(noteDetails:String,date:String,hobby:Hobby, completion: @escaping (Hobby) -> Void) {
        let note = Notes()
        note.noteDetails = noteDetails
        if let noteRef =  noteRef?.addDocument(data: ["noteDetails" : noteDetails]) {
            note.id = noteRef.documentID
        }
        var record = getRecordByTimestamp(date: date)
        if record != nil {
            record?.notes.append(note)
            self.listeners.invoke{ listener in
//                if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {print("dddd")
//                    listener.onRecordChange(change: .update, record: record!.notes)
//
//                }
            }
            let _ = addNoteToRecord(note: note, date: date, record: record!){ oneRecord in
                completion(hobby)
            }
        }else{
            record = self.addRecord(date: date)
            let _ = self.addNoteToRecord(note: note, date: date, record: record!){oneRecord in
                self.defaultRecord = oneRecord
                
                let _ = self.addRecordToHobby(record: oneRecord, hobby: hobby)
//                self.listeners.invoke{ listener in
//                    if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {print("dddd")
//                        print(oneRecord.notes)
//                        listener.onRecordChange(change: .update, record: oneRecord.notes)
                        completion(hobby)
//                    }
//                }
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

    func addHobbyToUser(hobby: Hobby, user: User) -> Bool {
        guard let hobbyID = hobby.id, let userID = user.id else {
            return false
        }

        if let newHobbyRef = hobbyRef?.document(hobbyID) {
            userRef?.document(userID).updateData(
                ["hobby" : FieldValue.arrayUnion([newHobbyRef])])
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
    func getRecordByTimestamp(date:String) -> Records? {
        for record in recordList {
            if record.date == date {
                return record
            }
        }
        return nil
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
    
    func showRecordWeekly(hobby:Hobby,startWeek:Date, endWeek:Date,completion: @escaping () -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var datesInRange:[String] = []
        var currentDate = startWeek
        
        while currentDate <= endWeek{ // get the all the dates between startWeek and endWeek
            datesInRange.append(dateFormatter.string(from: currentDate))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let records = hobby.records
        var recordsCorrespondToDates:[Records] = []
        for range in datesInRange {
            let recordToAdd = records.first(where: {$0.date == range})
            if recordToAdd != nil{
                recordsCorrespondToDates.append(recordToAdd!)
            }
        }
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onRecordChange(change: .update, record: self.currentRecNotesList!)
            }
        }
        completion()
    }
    func showCorrespondingRecord(hobby:Hobby,date:String,completion: @escaping () -> Void) {
        self.currentHobby = hobby
        self.notes = []
        let records = hobby.records
        var record = records.first(where: {$0.date == date})
//        print("recordF:\(record)")
        if defaultRecord != nil , record == nil{
            record = defaultRecord
            defaultRecord = nil
        }
        if record != nil {
            let docRef = database.collection("record5").document((record?.id)!)
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
    func setupHobbyListener() {
        hobbyRef = database.collection("hobby4")
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
        let docRef = database.collection("hobby4").document(parsedHobby.id!)
        docRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                if change.type == .added {
                    self.hobbyList.insert(parsedHobby, at: Int(change.newIndex))
                }
                else if change.type == .modified {
                    self.hobbyList[Int(change.oldIndex)] = parsedHobby
                }
                else if change.type == .removed {
                    self.hobbyList.remove(at: Int(change.oldIndex))
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
                                listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
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
                                    listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func parseSpecificRecord(recordRefArray:[DocumentReference], completion: @escaping ([Records]) -> Void){
        var counter = 0
        var resultRecordsList:[Records] = []
        recordRefArray.forEach{ oneRecordRef in
            oneRecordRef.getDocument{ (oneRecordDoc,error)  in
                if let document = oneRecordDoc, document.exists{
                    var oneRecordObj = Records()
                    oneRecordObj.id = document.documentID
                    oneRecordObj.date = document.data()!["date"] as? String
                    self.parseSpecificNote(noteRefArray: oneRecordDoc?.data()!["notes"] as! [DocumentReference]){ allNotes in
                        oneRecordObj.notes = allNotes
                        resultRecordsList.append(oneRecordObj)
                        self.recordList.append(oneRecordObj)
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
        recordRef = database.collection("record5")
        recordRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
//            self.parseHobbySnapshot(snapshot: querySnapshot)
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
        noteRef = database.collection("notes4")
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

    
//    func createAccount(email: String, password: String) async {
//        do{
//            let result = try await authController.createUser(withEmail: email, password: password)
//            self.currentUser = result.user
//        }catch{
//            self.error = error.localizedDescription
//
//            hasCreated = false
//        }
//        if hasCreated == nil{
//            hasCreated = true
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
//                listener.onCreateAccount(change:.add,user:self.currentUser)
//            }
//        }
//        self.teamName = self.currentUser?.uid
//        if heroesRef == nil{
//            self.setupHeroListener()
//        }
//        if self.teamsRef == nil {
//            self.setupTeamListener()
//            if let teamName = self.teamName{
//                let _ = self.addTeam(teamName: teamName)
//            }
//        } else{
//            if let teamName = self.teamName{
//                let _ = self.addTeam(teamName: teamName)
//            }
//        }
//        self.setupTeamListener()
//    }
//
//    func loginAccount(email: String, password: String) async {
//        do{
//            let result = try await authController.signIn(withEmail: email, password: password)
//            currentUser = result.user
//        } catch{
//            self.error = error.localizedDescription
//            hasLogin = false
//        }
//        if hasLogin == nil{
//            hasLogin = true
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
//                listener.onAuthAccount(change:.login,user: currentUser)
//            }
//        }
//        teamName = self.currentUser?.uid
//        self.setupTeamListener()
//    }
}
