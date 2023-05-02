//
//  Firebase Controller.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 10/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject,DatabaseProtocol{
    
    var hasLogin: Bool? = nil
    var hasCreated: Bool? = nil
    var error: String?
    let DEFAULT_HOBBY_NAME = "Running"
    var listeners = MulticastDelegate<DatabaseListener>()
    var hobbyList: [Hobby]
    var notesList: [Notes]
    var recordList: [Records]
    var defaultHobby: Hobby
    var defaultUser: User
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
            self.setupNotesListener()
        }
    }
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        
        if listener.listenerType == .hobby || listener.listenerType == .all {
            listener.onHobbyChange(change: .update, hobbies: hobbyList)
        }
        if listener.listenerType == .record || listener.listenerType == .all {
            listener.onRecordChange(change: .update, record: recordList)
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
        let hobby = Hobby()
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
            hobbyRef?.document(hobbyID).delete()
        }
    }
    func addNote(noteDetails:String,date:Date) -> Notes {
        let note = Notes()
        note.noteDetails = noteDetails
        if let noteRef = noteRef?.addDocument(data: ["noteDetails" : noteDetails]) {
            note.id = noteRef.documentID
        }
        let timestamp = Timestamp(date: date)
//        addNoteToRecord(note: note, date: timestamp, record: <#T##Records#>)
        return note
    }
    func addNoteToRecord(note:Notes,date:Timestamp,record:Records) {
        guard let noteID = note.id, let recordID = record.id else {
            let record = addRecord(date: date)
            let _ = addNoteToRecord(note: note, record: record)
            return 
        }
        if let newNoteRef = noteRef?.document(noteID) {
            recordRef?.document(recordID).updateData(
                ["notes" : FieldValue.arrayUnion([newNoteRef])])
        }
    }
    func addRecord(date:Timestamp) -> Records{
        let record = Records()
        record.date = date
        record.notes = []
        do{
            if let recordRef = try recordRef?.addDocument(from: record) {
                record.id = recordRef.documentID
            }
//            let _ = self.addHobbyToUser(hobby: hobby, user: defaultUser)
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
                ["hobbies" : FieldValue.arrayUnion([newHobbyRef])])
        }
        return true
    }
    
    func addRecordToHobby(record: Records, hobby: Hobby) -> Bool {
        guard let recordID = record.id, let hobbyID = hobby.id else {
            return false
        }
        if let newRecordRef = recordRef?.document(recordID) {
            hobbyRef?.document(hobbyID).updateData(
                ["records" : FieldValue.arrayUnion([newRecordRef])])
        }
        return true
    }
    
    func removeRecordFromHobby(record: Records, hobby: Hobby) {
        if hobby.records.contains(record), let hobbyID = hobby.id, let recordID = record.id {
            if let removedRecordRef = recordRef?.document(recordID) {
                hobbyRef?.document(hobbyID).updateData(
                    ["records": FieldValue.arrayRemove([removedRecordRef])]
                )
            }
        }
    }
    
    func addNoteToRecord(note: Notes, record: Records) -> Bool {
        guard let noteID = note.id, let recordID = record.id else {
            return false
        }
        if let newNoteRef = noteRef?.document(noteID) {
            recordRef?.document(recordID).updateData(
                ["notes" : FieldValue.arrayUnion([newNoteRef])])
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
    // MARK: - Firebase Controller Specific m=Methods
//    func getRecordsByID(_ id: String) -> Records? {
//        for record in recordList {
//            if record.id == id {
//                return record
//            }
//        }
//        return nil
//    }

    func getHobbyByID(_ id: String) -> Hobby? {
        for hobby in hobbyList {
            if hobby.id == id {
                return hobby
            }
        }
        return nil
    }
//    func setupUserListener() {
//        userRef = database.collection("users")
//        userRef?.whereField("name", isEqualTo: DEFAULT_USERNAME).addSnapshotListener {(querySnapshot, error) in
//            guard let querySnapshot = querySnapshot, let hobbySnapShot = querySnapshot.documents.first else {
//                print("Error fetching teams: \(error!)")
//                return
//            }
//            self.setupHobbyListener()
//            self.parseUserSnapshot(snapshot: hobbySnapShot)
//        }
//    }
//    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) {
//        defaultUser = User()
//        defaultUser.name = snapshot.data()["name"] as? String
//        defaultUser.id = snapshot.documentID
//        if let hobbiesReference = snapshot.data()["hobbies"] as? [DocumentReference] {
//            for reference in hobbiesReference {
//                if let hobby = getHobbyByID(reference.documentID) {
//                    defaultUser.hobbies?.append(hobby)
//                }
//            }
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
//                listener.onUserChange(change: .update, hobbies: defaultUser.hobbies ?? [])
//            }
//        }
//    }
    func setupHobbyListener() {
        hobbyRef = database.collection("hobbies")
        hobbyRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseHobbySnapshot(snapshot: querySnapshot)
        }
    }
    func parseHobbySnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            
            var parsedHobby: Hobby?
            do {
                parsedHobby = try change.document.data(as: Hobby.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            guard let hobby = parsedHobby else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                hobbyList.insert(hobby, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                hobbyList[Int(change.oldIndex)] = hobby
            }
            else if change.type == .removed {
                hobbyList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                    listener.onHobbyChange(change: .update, hobbies: hobbyList)
                }
            }

        }
    }
//    func setupHobbyListener() {
//        hobbyRef = database.collection("hobbies")
//        hobbyRef?.whereField("name", isEqualTo: self.hobbyName ?? DEFAULT_HOBBY_NAME).addSnapshotListener {(querySnapshot, error) in
//            guard let querySnapshot = querySnapshot, let hobbySnapShot = querySnapshot.documents.first else {
//                print("Error fetching teams: \(error!)")
//                return
//            }
//            self.parseHobbySnapshot(snapshot: hobbySnapShot)
//        }
//    }
//    func parseHobbySnapshot(snapshot: QueryDocumentSnapshot) {
//        defaultHobby = Hobby()
//        defaultHobby.name = snapshot.data()["name"] as? String
//        defaultHobby.id = snapshot.documentID
//        if let recordReferences = snapshot.data()["records"] as? [DocumentReference] {
//            for reference in recordReferences {
//                if let record = getRecordsByID(reference.documentID) {
//                defaultHobby.records.append(record)
//                }
//            }
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
//                listener.onHobbyChange(change: .update, record: defaultHobby.records)
//            }
//        }
//    }
    func setupRecordListener() {
        recordRef = database.collection("records")
        recordRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseRecordsSnapshot(snapshot: querySnapshot)
        }
    }
    func parseRecordsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            
            var parsedRecord: Records?
            do {
                parsedRecord = try change.document.data(as: Records.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            guard let record = parsedRecord else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                recordList.insert(record, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                recordList[Int(change.oldIndex)] = record
            }
            else if change.type == .removed {
                recordList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                    listener.onNoteChange(change: .update, notes: notesList)
                }
            }
        }
    }
    func setupNotesListener() {
        noteRef = database.collection("notes")
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
                print("Unable to decode hero. Is the hero malformed?")
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
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.note || listener.listenerType == ListenerType.all {
                    listener.onNoteChange(change: .update, notes: notesList)
                }
            }
        }
    }
    
//    func setupRecordListener() {
//        recordRef = database.collection("records")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        var timesstamp:Timestamp
//        if let myDate = dateFormatter.date(from: "19/04/2023") {
//            let timestamp = Timestamp(date: myDate)
//            print(timestamp) // Output: 2023-04-13 22:00:00 +0000
//        } else {
//            print("Invalid date format")
//        }
//        recordRef?.whereField("date", isEqualTo: self.currentRecord?.date ?? timesstamp).addSnapshotListener {(querySnapshot, error) in
//            guard let querySnapshot = querySnapshot, let hobbySnapShot = querySnapshot.documents.first else {
//                print("Error fetching teams: \(error!)")
//                return
//            }
//            self.parseRecordSnapshot(snapshot: hobbySnapShot)
//        }
//    }
//    func parseRecordSnapshot(snapshot: QueryDocumentSnapshot) {
//        defaultHobby = Hobby()
//        defaultHobby.name = snapshot.data()["name"] as? String
//        defaultHobby.id = snapshot.documentID
//        if let recordReferences = snapshot.data()["records"] as? [DocumentReference] {
//            for reference in recordReferences {
//                if let record = getRecordsByID(reference.documentID) {
//                defaultHobby.records.append(record)
//                }
//            }
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
//                listener.onHobbyChange(change: .update, record: defaultHobby.records)
//            }
//        }
//    }
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
