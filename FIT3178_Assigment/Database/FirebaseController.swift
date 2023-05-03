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
    var defaultRecord: Records
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
//    var record = Records()
    var records: [Records] = []
    var hobbyData: [String: Any]?
    var recordsFxxkU: [Records]?
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        hobbyList = [Hobby]()
        defaultHobby = Hobby()
        defaultUser = User()
        defaultRecord = Records()
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
//            self.setupRecordListener()
        }
    }
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        
        if listener.listenerType == .hobby || listener.listenerType == .all {
            listener.onHobbyChange(change: .update, hobbies: hobbyList)
        }
        if listener.listenerType == .record || listener.listenerType == .all {
            var notesList:[Notes] = []
            self.hobbyList.forEach{ hob in
                if hob.name == self.defaultHobby.name{
                    hob.records.forEach{ rec in
                        notesList.append(contentsOf: rec.notes)
                    }
                }
                
            }
//            let tempHob = self.hobbyList.first(where: {$0.name == self.defaultHobby.name})
//            tempHob?.records.forEach{ rec in
//                notesList.append(contentsOf: rec.notes)
//            }
            listener.onRecordChange(change: .update, record: notesList)
//            listener.onRecordChange(change: .update, record: defaultRecord.notes)
//            listener.onRecordChange(change: .update, record: self.notesList)
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
            hobbyRef?.document(hobbyID).delete()
        }
    }
    func addNote(noteDetails:String,date:String) -> Notes {
        let note = Notes()
        note.noteDetails = noteDetails
        if let noteRef = noteRef?.addDocument(data: ["noteDetails" : noteDetails]) {
            note.id = noteRef.documentID
        }
        var record = getRecordByTimestamp(date: date)
        if record != nil {
            let _ = addNoteToRecord(note: note, date: date, record: record!)
        }else{
            record = addRecord(date: date)
            let _ = addNoteToRecord(note: note, date: date, record: record!)

        }
        return note
    }
    func addNoteToRecord(note:Notes,date:String,record:Records) -> Bool {
        guard let noteID = note.id, let recordID = record.id else {
            return false
        }
        if let newNoteRef = noteRef?.document(noteID) {
            recordRef?.document(recordID).updateData(
                ["notes" : FieldValue.arrayUnion([newNoteRef])])
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
//        if hobby.records.contains(record), let hobbyID = hobby.id, let recordID = record.id {
//            if let removedRecordRef = recordRef?.document(recordID) {
//                hobbyRef?.document(hobbyID).updateData(
//                    ["records": FieldValue.arrayRemove([removedRecordRef])]
//                )
//            }
//        }
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
    func getNotesByID(_ id: String) -> Notes? {
        for note in notesList {
            if note.rootRecord == id {
                return note
            }
        }
        return nil
    }
    func getRecordByTimestamp(date:String) -> Records? {
        for record in recordList {
            print(record.date == date)
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

    func setupHobbyListener() {
        hobbyRef = database.collection("hobbies")
        hobbyRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
//            self.parseHobbySnapshot(snapshot: querySnapshot)
            self.parseHobbySnapshot2(snapshot: querySnapshot){ () in
                // nothing to do
                
            }
        }
    }
    
    
    
    
    
    func parseHobbySnapshot2(snapshot: QuerySnapshot, completion: @escaping () -> Void){
        Task{
            do{
                DispatchQueue.main.async {
                    snapshot.documentChanges.forEach{ (change) in
                        Task{
                            do{
                                DispatchQueue.main.async {
                                    var parsedHobby = Hobby()
                                    parsedHobby.id = change.document.documentID
                                    parsedHobby.name = change.document.data()["name"] as! String
                                    
                                    Task{
                                        do{
                                            DispatchQueue.main.async {
                                                self.parseSpecificRecord(recordRefArray: change.document.data()["records"] as! [DocumentReference]){ resultRecords in
                                                    parsedHobby.records = resultRecords
                                                    
                                                    if change.type == .added {
                                                        self.hobbyList.insert(parsedHobby, at: Int(change.newIndex))
                                                    }
                                                    else if change.type == .modified {
                                                        self.hobbyList[Int(change.oldIndex)] = parsedHobby
                                                    }
                                                    else if change.type == .removed {
                                                        self.hobbyList.remove(at: Int(change.oldIndex))
                                                    }
                                                    
                                                    self.listeners.invoke { (listener) in
                                                        if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                                            print("fxxkU hobby")
                                                            listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
                                                            listener.onRecordChange(change: .update, record: self.notesList)
                                                        }
                                                    }
                                                    self.listeners.invoke { (listener) in
                                                        if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                                                            print("fxxkU record")
                                                            listener.onRecordChange(change: .update, record: self.notesList)
                                                        }
                                                    }
                                                    
                                                    print("+++++++++++++")
                                                    self.hobbyList.forEach{ hoby in
                                                        print(hoby.name)
                                                        hoby.records.forEach{ rec in
                                                            print(rec.date)
                                                            rec.notes.forEach{ not in
                                                                print(not.noteDetails)
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    print("+++++++++++++")
                                                    
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                    
                                }
                            }
                            
                        
                        }
                        
                        
                        
                    }
                }
                
            }
        }
        
    }
    
    func parseSpecificRecord(recordRefArray:[DocumentReference], completion: @escaping ([Records]) -> Void){
        Task{
            
            do{
                DispatchQueue.main.async {
                    var resultRecordsList:[Records] = []
                    recordRefArray.forEach{ oneRecordRef in
                        Task{
                            do{
                                DispatchQueue.main.async {
//                                    parsedNote = try change.document.data(as: Notes.self)
                                    oneRecordRef.getDocument{ (oneRecordDoc,error)  in
                                        
                                        Task{
                                            do{
                                                DispatchQueue.main.async {
                                                    var oneRecordObj = Records()
                                                    oneRecordObj.id = oneRecordDoc?.documentID
                                                    oneRecordObj.date = oneRecordDoc?.data()!["date"] as? String
                                                    Task{
                                                        do{
                                                            DispatchQueue.main.async {
                                                                self.parseSpecificNote(noteRefArray: oneRecordDoc?.data()!["notes"] as! [DocumentReference]){ allNotes in
                                                                    oneRecordObj.notes = allNotes
                                                                    resultRecordsList.append(oneRecordObj)
                                                                    completion(resultRecordsList)
                                                                    print("resultRecordsList 4 :\(resultRecordsList)")
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
//                    completion(resultRecordsList)
                }
                
            }
        }
    }
    
    func parseSpecificNote(noteRefArray:[DocumentReference], completion: @escaping ([Notes]) -> Void){
        Task{
            
            do{
                DispatchQueue.main.async {
                    var NotesList:[Notes] = []
                    noteRefArray.forEach{ onoNoteRef in
                        Task{
                            do{
                                DispatchQueue.main.async {
                                    onoNoteRef.getDocument{ (oneNoteDoc,error) in
                                        Task{
                                            do{
                                                DispatchQueue.main.async {
                                                    var parsedNote: Notes?
                                                    do {
                                                        parsedNote = try oneNoteDoc!.data(as: Notes.self)
                                                    } catch {
                                                        print("Unable to decode notes.: Note")
                                                        return
                                                    }
                                                    guard let note = parsedNote else {
                                                        print("Document doesn't exist: Note")
                                                        return
                                                    }
                                                    NotesList.append(note)
                                                    print("NotesList 4 :\(note.noteDetails)")
                                                    completion(NotesList)
                                                    
                                                }
                                                print("NotesList 3 :\(NotesList)")
//                                                completion(NotesList)
                                            }
                                        }
                                        
                                    }
                                }
                                print("NotesList 2 :\(NotesList)")
//                                completion(NotesList)
                            }
                        }
                        
                    }
                    print("NotesList 1 :\(NotesList)")
//                    completion(NotesList)
                }
                
            }
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    func parseHobbySnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedHobby: Hobby?
            decodeRecord(change: change){ (data) in
//                print(data)
                let decoder = Firestore.Decoder()
                do {
//                    let parsedHobby = try decoder.decode(Hobby.self, from: data)
                    parsedHobby = Hobby()
                    parsedHobby?.name = data["name"] as? String
//                    parsedHobby?.records = data["records"] as? [Records]
                    print(parsedHobby)
                    print("ccc")
                
                } catch {
                    print("Unable to decode hobby.")
                    return
                }
                print("ddddd")
                guard let hobby = parsedHobby else {
                    print("Document doesn't exist")
                    return
                }
//                print("ccc")
                if change.type == .added {
                    self.hobbyList.insert(hobby, at: Int(change.newIndex))
                }
                else if change.type == .modified {
                    self.hobbyList[Int(change.oldIndex)] = hobby
                }
                else if change.type == .removed {
                    self.hobbyList.remove(at: Int(change.oldIndex))
                }

                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                        listener.onHobbyChange(change: .update, hobbies: self.hobbyList)
                    }
                }
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                        listener.onRecordChange(change: .update, record: self.notesList)
                    }
                }
            }
        }
    }
    func decodeRecord(change:DocumentChange,completion: @escaping ([String:Any]) -> Void){
//        var records: [Records] = []
//        var hobbyData = change.document.data()
        self.hobbyData = change.document.data()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        Task{
            do{
                DispatchQueue.main.async {
                    let recordRefArray = self.hobbyData!["records"] as! [DocumentReference]
                    
                    for recordRef in recordRefArray {
                        dispatchGroup.enter()
                        recordRef.getDocument { (document, error) in
                            dispatchGroup.enter()
                            if let document = document, document.exists {
                                let recordDoc = document.data()
        //                        var record = Records()
        //                        record.id = document.documentID
        //                        record.date = recordDoc!["date"] as? String
        //                        print(record)
                                self.defaultRecord.id = document.documentID
                                self.defaultRecord.date = recordDoc!["date"] as? String
                                print(self.defaultRecord)
                                dispatchGroup.enter()
                                Task{
                                    do{
                                        self.decodeNote(document: document){ notes in
                                            print("=============")
                                            print(notes[0].noteDetails)
                                            print("=============")
                                            DispatchQueue.main.async {
                                                self.defaultRecord.notes = notes
                                                self.records.append(self.defaultRecord)
                                                self.recordList.append(self.defaultRecord)
                                                self.hobbyData!["records"] = self.records
                                                print("dhasoiuhdiuasdhiouashduaihsuidhaiu\(self.records)")
                                                self.recordsFxxkU = self.records
        //                                        completion(self.hobbyData!)
                                            }
        //                                    hobbyData["records"] = self.records
                                            
                                            print("bbb")
                                            print(self.defaultRecord)
                                            
                                        }
                                    }
                                    
                                }
                                dispatchGroup.leave()
                                print("4hobby\(self.records)")
                                
        //                        records.append(record)
        //                        self.recordList.append(record)
                            }
                            dispatchGroup.leave()
                            print("3hobby\(self.records)")
                        }
        //                hobbyData["records"] = records
                        dispatchGroup.leave()
                        print("2hobby\(self.records)")
                    }
                    
                }

                
            }
        }
   
        dispatchGroup.leave()
//        print("1hobby\((self.hobbyData!["records"] as? [Records])?.count)")
        print("1hobby\(self.records)")
//        print("bbb")
//        completion(self.hobbyData!)
    }
    func decodeNote(document:DocumentSnapshot,completion: @escaping ([Notes]) -> Void){
        let dispatchGroup = DispatchGroup()
        var notes:[Notes] = []
        dispatchGroup.enter()
        if let noteArray = document.data()?["notes"] as? [DocumentReference] {
            dispatchGroup.enter()
            for noteRef in noteArray {
                noteRef.getDocument { (document, error) in
                    dispatchGroup.enter()
                    if let document = document, document.exists {
                        let noteDoc = document.data()
                        var note = Notes()
                        note.noteDetails = noteDoc!["noteDetails"] as? String
//                        record.notes.append(note)
                        notes.append(note)
                        self.notesList.append(note)
                        print("aaa")
//                        print(notes)
                        
                    }
                    dispatchGroup.leave()
                    completion(notes)
                    print("2\(notes)")
                }
            }
            dispatchGroup.leave()
//            print("1\(notes)")
        }
        dispatchGroup.leave()
//        print("aaa")
//        print(notes)
//        completion(notes)
    }
    
//    func setupDocumentHobbyListener(hobbyID: String) {
//        hobbyRef = database.collection("hobbies")
//        let hobbyDocRef = hobbyRef?.document(hobbyID)
//        hobbyDocRef?.getDocument{(document,error) in
//            if let document = document, document.exists{
//                if let recordArray = document.data()?["records"] as? [DocumentReference]{
//                    print("yyyyy")
//                    for recordRef in recordArray{
//                        recordRef.getDocument{(document,error) in
//                            if let document = document, document.exists{
//                                print("bbbbb")
//                                let recordDoc = document.data()
//                                var record = Records()
//                                record.id = document.documentID
//                                record.date = recordDoc!["date"] as? String
//                                if let noteArray = document.data()?["notes"] as? [DocumentReference]{
//                                    for noteRef in noteArray{
//                                        noteRef.getDocument{(document,error) in
//                                            if let document = document, document.exists{
//                                                print("cccc")
//                                                let noteDoc = document.data()
//                                                let note = Notes()
//                                                note.noteDetails = noteDoc!["noteDetails"] as? String
//                                                record.notes.append(note)
//                                            }
//                                        }
//                                    }
//                                }
//                                self.recordList.append(record)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        print("ggggg\(recordList)")
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
//                listener.onRecordChange(change: .update, record: defaultRecord.notes)
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
            self.parseRecordSnapshot(snapshot: querySnapshot)
        }
    }
    func parseRecordSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var notes: [Notes] = []
            var parsedRecord: Records?
            do {
                var recordData = change.document.data()
                let noteRefArray = recordData["notes"] as! [DocumentReference]
                
//                let dispatchGroup = DispatchGroup() // <-- Create a DispatchGroup
//                dispatchGroup.enter() // <-- Enter the dispatch group
                for noteRef in noteRefArray {
                    noteRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let noteDoc = document.data()
                            let note = Notes()
                            note.id = document.documentID
                            note.noteDetails = noteDoc!["noteDetails"] as? String
                            notes.append(note)
                            self.notesList.append(note)
                        }
                    }
                }
//                dispatchGroup.leave() // <-- Leave the dispatch group
                // Wait for all the tasks to finish
//                dispatchGroup.notify(queue: .main) {
                    recordData["notes"] = notes
                    let decoder = Firestore.Decoder()
                    do {
                        parsedRecord = try decoder.decode(Records.self, from: recordData)
                    } catch {
                        print("Unable to decode record.")
                        return
                    }

                    guard let record = parsedRecord else {
                        print("Document doesn't exist")
                        return
                    }
                    if change.type == .added {
                        self.recordList.insert(record, at: Int(change.newIndex))
                    }
                    else if change.type == .modified {
                        self.recordList[Int(change.oldIndex)] = record
                    }
                    else if change.type == .removed {
                        self.recordList.remove(at: Int(change.oldIndex))
                    }
                    self.listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                            listener.onRecordChange(change: .update, record: notes)
                        }
                    }
//                }

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
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.note || listener.listenerType == ListenerType.all {
                    listener.onNoteChange(change: .update, notes: notesList)
                }
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
