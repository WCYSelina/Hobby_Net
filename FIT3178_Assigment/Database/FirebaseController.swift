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
    var defaultEvent: Event?
    var email: String?
    var selectedImage: [UIImage]?
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
    var commentRef: CollectionReference?
    var postRef:CollectionReference?
    var eventRef:CollectionReference?
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
    var defaultPost: Post
    var postList: [Post] = []
    var eventList:[Event] = []
    
    override init(){
        // initialise the Firebase and also the attribute that is not optional and havent been auto initialised
        FirebaseApp.configure()
        authController = Auth.auth()
        firebaseStorage = Storage.storage()
        database = Firestore.firestore()
        hobbyList = [Hobby]()
        userList = [User]()
        defaultHobby = Hobby()
        defaultUser = User()
        notesList = [Notes]()
        defaultPost = Post()
        recordList = [Records]()
        super.init()
    }
    
    func addListener(listener: DatabaseListener){
        // this function add the view controller as listener
        listeners.addDelegate(listener)
        
        if listener.listenerType == .hobby || listener.listenerType == .all {
            listener.onHobbyChange(change: .update, hobbies: defaultUser.hobbies)
        }
        if listener.listenerType == .record || listener.listenerType == .all {
            // this part of code calculate the following 6 days and current day(today) and add the string of the dates to the datesInRange, these string will be used to find the records that is the same date to the string
            let records = defaultHobby.records
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
            if let record = records.first(where: {$0.date == currentDate}){
                listener.onRecordChange(change: .update, record: record) // this funtion will be called when there is any record changed
            }
            listener.onHobbyRecordFirstChange(change: .update, hobby: defaultHobby) // this function will be called when the record is first created
            //this function will be called if there is any changes been made to the records(weekly)
            listener.onWeeklyRecordChange(change: .update, records: recordsCorrespondToDates)
        }
        if listener.listenerType == .note || listener.listenerType == .all {
            //this function will be called if there is any changes been made to the notes
            listener.onNoteChange(change: .update, notes: notesList)
        }
        if listener.listenerType == .auth || listener.listenerType == .all {
            // this function will be called when the user log in to the app
            listener.onAuthAccount(change: .login, user: currentUser)
        }
        if listener.listenerType == .auth || listener.listenerType == .all {
            // this function will be called when the user create an account
            listener.onCreateAccount(change: .add, user: currentUser)
        }
        if listener.listenerType == .post || listener.listenerType == .all {
            //this function will be called if there is any changes been made to the posts
            listener.onPostChange(change: .add, posts: postList,defaultUser: defaultUser)
        }
        if listener.listenerType == .comment || listener.listenerType == .all {
            //this function will be called if there is any changes been made to the comments
            listener.onCommentChange(change: .add, comments: defaultPost.comment)
        }
        if listener.listenerType == .event || listener.listenerType == .all {
            //this function will be called if there is any changes been made to all the events
            listener.onEventChange(change: .add, events: eventList)
        }
        if listener.listenerType == .userEvents || listener.listenerType == .all {
            //this function will be called if there is any changes been made to the user's events
            listener.onYourEventChange(change: .add, user: defaultUser)
        }
        if listener.listenerType == .userEvents || listener.listenerType == .all {
            // this function will be called when they is any relavant changes between posts and user
            listener.onUserPostsDetail(change: .add, user: defaultUser)
        }
        
        
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener) // remove the view controller from the listeners
    }
    func uploadImageToStorage(folderPath:String, image:UIImage, completion:@escaping (String) -> Void) {
        Task{
            //build storage reference, the date and uuid is used to create a unique path that cannot have duplicate
            let path = folderPath + "images_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString).jpeg"
            
            // create a reference at this location path, where we can then store images at this location using this reference
            let storageRef = self.firebaseStorage.reference(withPath: path)
            //the quality of the image
            guard let imageData = image.jpegData(compressionQuality: 1) else{
                return
            }
            // Upload image to the reference we got above
            let uploadTask = storageRef.putData(imageData, metadata: nil) { metaData, error in
                // hanlde the error, if any error happens
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                
                // this part of code, downloads the url of the file, and return the path, so that it can be save in the firebase, like note and posts has images, and this images are represent in these string
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
                                let fullPath = "gs://fit3178-ass-v2.appspot.com/" + (metaData?.path)!
                                completion(fullPath)
                            }
                        }
                    }
                }
            }
            // this part of code use to track the progress of upload image, it is used for debugging
            uploadTask.observe(.progress) { storageTaskSnapshot in
                let progress = storageTaskSnapshot.progress
                let percentComplete = 100 * Double(progress!.completedUnitCount) / Double(progress!.totalUnitCount)
            }
        }
    }
    func addHobby(name: String) -> Hobby {
        // add hobby to the firebase, after that assign it to the user
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
    func deletePost(post:Post){
        // this function delete the post and also delete it from the user, and also delete all its comment
        if let postID = post.id{
            let postRef = self.database.collection("post").document(postID)
            postRef.getDocument{ (document,error) in
                let onePostComment = document!.data()!["comments"] as? [DocumentReference]
                if let onePostComment = onePostComment, !onePostComment.isEmpty{
                    // if it has comment, we need to decode the comment and delete it
                    self.parseSpecificComment(commentRefArray: onePostComment){ allComments in
                        let comments = allComments
                        self.postRef?.document(postID).delete(){ delete in
                            self.userRef?.document(self.defaultUser.id!).updateData(["posts" : FieldValue.arrayRemove([postRef])])
                            self.postList.removeAll(where: {$0.id == postID})
                            // remove the like of this post from user
                            self.filterLikes(user: self.defaultUser)
                            for comment in comments {
                                    self.deleteComment(comment: comment)
                                }
                                self.listeners.invoke{ listener in
                                    if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                                        listener.onPostChange(change: .update, posts: self.postList, defaultUser: self.defaultUser)
                                    }
                                }
                            }
                        }
                    }
                else{
                    self.postRef?.document(postID).delete { delete in
                        self.userRef?.document(self.defaultUser.id!).updateData(["posts" : FieldValue.arrayRemove([postRef])])
                        //remove it if the post id is the same
                        self.postList.removeAll(where: { $0.id == postID })
                        //remove the like of this post from the user
                        self.filterLikes(user: self.defaultUser)
                        self.listeners.invoke{ listener in
                            if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                                listener.onPostChange(change: .update, posts: self.postList, defaultUser: self.defaultUser)
                            }
                        }
                    }
                }
            }
        }
    }

    func deleteHobby(hobby: Hobby) {
        // delete hobby from the firebase as well as remove it from the user and delete every of its note, similar to the deletePost
        if let hobbyID = hobby.id {
            let recordRef = self.database.collection("hobby").document(hobbyID)
            recordRef.getDocument{ (document,error) in
                let oneHobbyRecords = document!.data()!["records"] as! [DocumentReference]
                if !oneHobbyRecords.isEmpty{
                    self.parseSpecificRecord(recordRefArray: oneHobbyRecords){ allRecords in
                        let records = allRecords
                        self.hobbyRef?.document(hobbyID).delete(){ delete in
                            self.userRef?.document(self.defaultUser.id!).updateData(["hobbies" : FieldValue.arrayRemove([recordRef])])
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
                        self.userRef?.document(self.defaultUser.id!).updateData(["hobbies" : FieldValue.arrayRemove([recordRef])])
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
    func deleteComment(comment:Comment){
        // delete comment from firebase
        if let commentID = comment.id{
            commentRef?.document(commentID).delete()
        }
    }
    func deleteRecord(record:Records){
        // delete the record from firebase
        if let recordID = record.id{
            recordRef?.document(recordID).delete()
        }
    }
    func deleteNote(note:Notes){
        // delete the note from the firebase
        if let noteID = note.id{
            noteRef?.document(noteID).delete()
        }
    }
    
    func addNote(noteDetails:String,date:String,hobby:Hobby,image:String, completion: @escaping (Hobby) -> Void) {
        let note = Notes()
        note.noteDetails = noteDetails
        note.image = image
        // add a new note into the firebase
        if let noteRef =  noteRef?.addDocument(data: ["noteDetails" : noteDetails, "image" : image]) {
            note.id = noteRef.documentID
        }
        // get the record's date
        var record = getRecordByTimestamp(date: date,hobby: hobby)
        // if there is no any record on the date, we have create a new one, otherwise just append it
        if record != nil {
            record?.notes.append(note)
            let _ = addNoteToRecord(note: note, date: date, record: record!){ oneRecord in
                completion(hobby)
            }
        }else{
            // create new record and add this record to the corresponding hobby
            record = self.addRecord(date: date)
            let _ = self.addNoteToRecord(note: note, date: date, record: record!){oneRecord in
                self.defaultRecord = oneRecord
                self.defaultRecordWeekly = oneRecord
                let _ = self.addRecordToHobby(record: oneRecord, hobby: hobby)
                        completion(hobby)
            }
        }
    }
    func changeUserName(username:String){
        // change the user name and inform the listeners to update their view
        self.defaultUser.name = username
        self.userRef?.document(self.defaultUser.id!).updateData(["name" : username])
        self.listeners.invoke { listener in
            if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                listener.onUserPostsDetail(change: .update, user: self.defaultUser)
            }
        }
        
    }
    func addNoteToRecord(note:Notes,date:String,record:Records, completion: @escaping (Records) -> Void){
        // add note to record in firebase
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
                                self.listeners.invoke { listener in
                                    if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                                        listener.onRecordChange(change: .update, record: record)
                                    }
                                }
                                completion(self.tempRecord!)
                                }
                            }
                        }
                    }
                }
            }
    
    func addRecordToHobby(record: Records, hobby: Hobby) -> Bool {
        // add record to hobby in firebase
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
        // add new record to firebase
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
        // add hobby to user in firebase
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
    
    func updatePost(post:Post,postDetail:String,addedImageString:[String],removedImageString:[String]){
        // update post, the addedImageString is an array of image path that has been newly added, and removedImageString is the image path that has been removed
        
        // we can just use these 2 array to do the add and delete operation
        if !removedImageString.isEmpty{
            self.postRef?.document(post.id!).updateData(["images" : FieldValue.arrayRemove(removedImageString)])
        }
        if !addedImageString.isEmpty{
            self.postRef?.document(post.id!).updateData(["images" : FieldValue.arrayUnion(addedImageString)])
        }
        self.postRef?.document(post.id!).updateData(["postDetail" : postDetail])
    }
    
    func addPost(postDetail:String,imagesString:[String]) -> Post{
        // add new post into the firebase
        var post = Post()
        post.comment = []
        post.likeNum = 0
        post.postDetail = postDetail
        post.images = imagesString
        post.publisher = currentUser?.uid
        post.publisherName = self.defaultUser.name
        do{
            if let postRef = try postRef?.addDocument(from: post) {
                post.id = postRef.documentID
                addPostToUser(post: post)
            }
        } catch {
            print("Failed to serialize hero")
        }
        return post
        
    }
    
    
    func addPostToUser(post: Post) -> Bool {
        // add post to the user in firebase
        guard let postID = post.id, let userID = self.defaultUser.id else {
            return false
        }

        if let newPostRef = postRef?.document(postID) {
            userRef?.document(userID).updateData(
                ["posts" : FieldValue.arrayUnion([newPostRef])])
        }
        return true
    }
    

    func addSubcription(subscriptionId:String) -> Bool {
        //add the event subscription from the user in the firebase
        guard let userID = self.defaultUser.id else {
            return false
        }

        userRef?.document(userID).updateData(
            ["subscriptions" : FieldValue.arrayUnion([subscriptionId])])
        return true
    }
    
    func removeSubscription(subscriptionId:String){
        //remove the event subscription from the user in the firebase
        guard let userID = self.defaultUser.id else {
            return
        }

        userRef?.document(userID).updateData(
            ["subscriptions" : FieldValue.arrayRemove([subscriptionId])])
    }
    func deleteLikeFromUser(like:Post) -> Bool {
        guard let postID = like.id, let userID = self.defaultUser.id else {
            return false
        }
        var inList = false
        for likeList in defaultUser.likes{ //check if they have liked the posts or not
            if like.id == likeList.id{
                inList = true
            }
        }
        if inList{ //only delete the like from user when they have liked before
            if let newPostRef = postRef?.document(postID) {
                userRef?.document(userID).updateData(
                    ["likes" : FieldValue.arrayRemove([newPostRef])])
                let post = decrementLikeNum(id: postID)
                post?.likeNum! -= 1
                removeLikeFromUser(like: post!)
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                        listener.onPostChange(change: .update, posts: self.postList, defaultUser: defaultUser)
                    }
                    if listener.listenerType == .post || listener.listenerType == .all {
                        listener.onUserPostsDetail(change: .add, user: defaultUser)
                    }
                }
                return true
            }
        }
        return false
    }
    
    //like field save an array of reference of what the user have like
    func addLikeToUser(like:Post) -> Bool {
        guard let postID = like.id, let userID = self.defaultUser.id else {
            return false
        }
        var inList = false
        for likeList in defaultUser.likes{ // check if the user has like before
            if like.id == likeList.id{
                inList = true
            }
        }
        if !inList{ //only add like to user if they havent liked the post
            if let newPostRef = postRef?.document(postID) {
                userRef?.document(userID).updateData(
                    ["likes" : FieldValue.arrayUnion([newPostRef])])
                let post = modifyLikeNum(id: postID)
                defaultUser.likes.append(post!)
                post?.likeNum! += 1
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                        listener.onPostChange(change: .update, posts: self.postList,defaultUser: defaultUser)
                    }
                    if listener.listenerType == .post || listener.listenerType == .all {
                        listener.onUserPostsDetail(change: .add, user: defaultUser)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func removeLikeFromUser(like:Post) {
        // remove the like from user
        for i in 0..<defaultUser.likes.count{
            if defaultUser.likes[i].id == like.id{
                defaultUser.likes.remove(at: i)
                return
            }
        }
    }
    
    func findPostByID(id:String) -> Post?{
        // find post by id
        for list in postList {
            if list.id == id{
                return list
            }
        }
        return nil
    }
    
    func decrementLikeNum(id:String) -> Post?{
        // decrease the like num of the post in the firebase
        database.collection("post").document(id).updateData(["likeNum":FieldValue.increment(Int64(-1))])
        for post in postList {
            if post.id == id{
                return post
            }
        }
        return nil
    }
    
    
    func modifyLikeNum(id:String) -> Post? {
        // increase the like num of the post in the firebase
        database.collection("post").document(id).updateData(["likeNum":FieldValue.increment(Int64(1))])
        for post in postList {
            if post.id == id{
                return post
            }
        }
        return nil
    }
    
    
    func removeNoteFromRecord(note: Notes, record: Records) {
        // remove the note from record in the firebase
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
        //get hobby by its id
        for hobby in hobbyList {
            if hobby.id == id {
                return hobby
            }
        }
        return nil
    }
    func getRecordByTimestamp(date:String,hobby:Hobby) -> Records? {
        // get the record with the same date given in the parameter
        for record in recordList {
            if record.date == date, hobby.records.contains(where: {$0.id == record.id}){
                return record
            }
        }
        return nil
    }
    func onWeeklyChange(records:[Records]){
        // inform listener the records has been updated
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onWeeklyRecordChange(change: .update, records: records)
            }
        }
    }
    
    func showRecordWeekly(hobby:Hobby,startWeek:Date, endWeek:Date,completion: @escaping ([Records],[String]) -> Void) {
        //show the record in weekly
        // this function finds all the records that is within the startWeek and endWeek by comparing the date of the record
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
    func showCorrespondingRecord(hobby:Hobby,date:String,completion: @escaping (Records?) -> Void) {
        // show the record in daily
        self.currentHobby = hobby
        let records = hobby.records
        let record:Records? = records.first(where: {$0.date == date})
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.record || listener.listenerType == ListenerType.all {
                listener.onRecordChange(change: .update, record: record ?? nil)
            }
        }
        completion(record ?? nil)
    }
    func setupUserListener(completion: @escaping () -> Void){
        // listen to the user collection
        userRef = database.collection("user")
        userRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseUserSnapshot(snapshot: querySnapshot){ (user,filteredList) in
                // the main filter like occurs in here, the reason of doing this has stated in parsedUserSnapshot function
                if !filteredList.isEmpty{
                    filteredList.forEach{ filteredLikeRef in
                        self.userRef?.document(user.id!).updateData(["likes" : FieldValue.arrayRemove([filteredLikeRef])])
                    }
                }
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                        listener.onHobbyChange(change: .update, hobbies: user.hobbies)
                    }
                    if listener.listenerType == ListenerType.userEvents || listener.listenerType == ListenerType.all{
                        if user.id == self.defaultUser.id{
                            listener.onYourEventChange(change: .update,user: self.defaultUser)
                        }
                    }
                    if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all{
                        if user.id == self.defaultUser.id{
                            listener.onUserPostsDetail(change: .update,user: self.defaultUser)
                        }
                    }
                    completion()
                }
            }
        }
    }
    func checkIfSubscribed(event:Event) -> String?{
        // check if the user subscribe to the event
        var isSubscribed = false
        var returnVal:String = ""
        defaultUser.subscriptionID?.forEach{ id in
            if id.contains(event.id!){
                isSubscribed = true
                returnVal = id
            }
        }
        if isSubscribed{
            return returnVal
        }
        else{
            return nil
        }
    }
    
     
    func parseUserSnapshot(snapshot: QuerySnapshot, completion: @escaping (User,[DocumentReference]) -> Void){
        // decode the user, to finish decoding the user, we has to first decode all its property manually that is not with the built in data types, user has 5 property that is not belong to the built in data type, hence, to handle the asychonous problem, it will only finish decoding once all the 5 property has been decode.
        
        // in the middle of decoding, it will filter the user's like that does not exists, this has to be done because, the posts could be deleted, and hence we need to handle that
        var filterList:[DocumentReference] = []
        var counter = 0
        let userFieldCount = 5
        var hasFilter = false
        snapshot.documentChanges.forEach{ (change) in
            var parsedUser = User()
            if change.document.exists{
                if currentUser?.uid == change.document.documentID{
                    parsedUser.id = change.document.documentID
                    parsedUser.name = change.document.data()["name"] as? String
                    parsedUser.subscriptionID = change.document.data()["subscriptions"] as? [String]
                    //decode user's hobby
                    let hobbyRef = change.document.data()["hobbies"] as? [DocumentReference]
                    if hobbyRef == nil{
                        parsedUser.hobbies = []
                        counter += 1
                        if counter == userFieldCount{
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                completion(parsedUser,filterList)
                            }
                        }
                    }
                    else{
                        self.parseSpecificHobby(hobbyRefArray: hobbyRef!){ resultHobbies in
                            parsedUser.hobbies = resultHobbies
                            counter += 1
                            if counter == userFieldCount{
                                self.addToUserList(change: change, parsedUser: parsedUser){
                                    completion(parsedUser,filterList)
                                }
                            }
                        }
                    }
                    
                    //decode user's post
                    let postRef = change.document.data()["posts"] as? [DocumentReference]
                    if postRef == nil{
                        counter += 1
                        if counter == userFieldCount{
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                completion(parsedUser,filterList)
                            }
                        }
                    }
                    else{
                        self.parseSpecificPost(postRefArray: postRef!){ (resultPosts,hasFiltered) in
                            parsedUser.posts = resultPosts
                            counter += 1
                            if counter == userFieldCount{
                                self.addToUserList(change: change, parsedUser: parsedUser){
                                    completion(parsedUser,filterList)
                                }
                            }
                        }
                    }
                    
                    //decode user's liked posts
                    let likePostRef = change.document.data()["likes"] as? [DocumentReference]
                    if likePostRef == nil{
                        parsedUser.likes = []
                        counter += 1
                        if counter == userFieldCount{
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                completion(parsedUser,filterList)
                            }
                        }
                    }
                    else{
                        self.parseSpecificPost(postRefArray: likePostRef!){ (resultLikePosts,filteredList) in
                            filterList = filteredList
                            parsedUser.likes = resultLikePosts
                            counter += 1
                            if counter == userFieldCount{
                                self.addToUserList(change: change, parsedUser: parsedUser){
                                    completion(parsedUser,filterList)
                                }
                            }
                        }
                    }
                    //decode user's events
                    let eventRef = change.document.data()["events"] as? [DocumentReference]
                    if eventRef == nil{
                        parsedUser.events = []
                        counter += 1
                        if counter == userFieldCount{
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                self.decodeLike(change: change, parsedUser: parsedUser)//filter the likes
                                completion(parsedUser,filterList)
                            }
                        }
                    }
                    else{
                        self.parseSpecificEvent(eventRefArray: eventRef!){ resultEvents in
                            parsedUser.events = resultEvents
                            counter += 1
                            if counter == userFieldCount{
                                self.addToUserList(change: change, parsedUser: parsedUser){
                                    completion(parsedUser,filterList)
                                }
                            }
                        }
                    }
                    //decode the events that the user has joined
                    let eventJoinedRef = change.document.data()["eventsJoined"] as? [DocumentReference]
                    if eventJoinedRef == nil{
                        parsedUser.eventJoined = []
                        counter += 1
                        if counter == userFieldCount{
                            self.addToUserList(change: change, parsedUser: parsedUser){
                                self.decodeLike(change: change, parsedUser: parsedUser)//filter the likes
                                completion(parsedUser,filterList)
                            }
                        }
                    }
                    else{
                        self.parseSpecificEvent(eventRefArray: eventJoinedRef!){ resultEventsJoined in
                            parsedUser.eventJoined = resultEventsJoined
                            counter += 1
                            if counter == userFieldCount{
                                self.addToUserList(change: change, parsedUser: parsedUser){
                                    self.decodeLike(change: change, parsedUser: parsedUser) //filter the likes
                                    completion(parsedUser,filterList)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func decodeLike(change:DocumentChange, parsedUser:User){
        // this function is to filter the like of the posts that does not exists
        let likePostRef = change.document.data()["likes"] as? [DocumentReference]
        if likePostRef == nil{
            var user = findUserById(id: parsedUser.id!)
            user?.likes = []
        }
        else{
            self.parseSpecificPost(postRefArray: likePostRef!){ (resultLikePosts,hasFiltered) in
                var user = self.findUserById(id: parsedUser.id!)
                self.filterLikes(user: user!)
            }
        }
    }
    
    
    func addToUserList(change:DocumentChange,parsedUser:User, completion: @escaping () -> Void){
        // sync the userList with the firebase
        let docRef = database.collection("user").document(parsedUser.id!)
        if currentUser?.uid == parsedUser.id{
            self.defaultUser = parsedUser
        }
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
    
    func checkIfUserHasJoined(event:Event) -> Bool {
        // it check if user has joined the event before or not
        var returnVal = false
        let oneUserRef = database.collection("user").document(self.defaultUser.id!)
        let oneEvent = findEventByID(id: event.id!)
        oneEvent?.participants?.forEach{ participant in
            if participant.documentID == oneUserRef.documentID{
                returnVal = true
            }
        }
        return returnVal
    }
    
    func findEventByID(id:String) -> Event?{
        // find and return event by if
        for list in eventList {
            if list.id == id{
                return list
            }
        }
        return nil
    }
    
    func setupCommentListener(){
        //listen to the comment collection
        commentRef = database.collection("comment")
    }
    
    func addEvent(eventDate:Timestamp, eventDescription:String, eventLocation:String,eventName:String) -> Event{
        // create a new event, decode it in advane then add it to the firebase, and user
        var event = Event()
        event.participants = []
        event.eventDate = eventDate
        event.eventDescription = eventDescription
        event.publisher = database.collection("user").document(currentUser!.uid)
        event.eventLocation = eventLocation
        event.eventName = eventName
        event.publisherName = defaultUser.name
        
        do{
            if let eventRef = try eventRef?.addDocument(from: event) {
                event.id = eventRef.documentID
//                self.defaultHobby.records.append(record)
                let _ = addEventToUser(event: event)
                eventList.append(event)
            }
        } catch {
            print("Failed to serialize hero")
        }
        return event
        
    }
    
    
    func addEventToUser(event: Event) -> Bool {
        // add event to the user in the firebase and ask listener to update their view
        guard let eventID = event.id, let userID = self.defaultUser.id else {
            return false
        }

        if let newEventRef = eventRef?.document(eventID) {
            userRef?.document(userID).updateData(
                ["events" : FieldValue.arrayUnion([newEventRef])])
        }
        self.listeners.invoke{ listener in
            if listener.listenerType == ListenerType.event || listener.listenerType == ListenerType.all {
                listener.onEventChange(change: .update, events: eventList)
            }
        }
        return true
    }
    
    func userJoinEvent(event:Event) -> Bool {
        // this function will call checkIFUserHasJoined to check if the user has joined before or not
        // if they have joined before, the event will be removed from them, otherwise, the event will add it to the user
        guard let eventID = event.id, let userID = self.defaultUser.id else {
            return false
        }
        let oneUserRef = database.collection("user").document(self.defaultUser.id!)
        let ifUserHasJoined =  checkIfUserHasJoined(event: event)
        if !ifUserHasJoined{
            if let newEventRef = eventRef?.document(eventID) {
                userRef?.document(userID).updateData(
                    ["eventsJoined" : FieldValue.arrayUnion([newEventRef])])
            }
            
            if let newParticipantRef = userRef?.document(userID){
                eventRef?.document(eventID).updateData(
                    ["participants" : FieldValue.arrayUnion([newParticipantRef])])
            }
            return true
        }
        else{
                if let newEventRef = eventRef?.document(eventID) {
                    userRef?.document(userID).updateData(
                        ["eventsJoined" : FieldValue.arrayRemove([newEventRef])])
                }
                
                if let newParticipantRef = userRef?.document(userID){
                    eventRef?.document(eventID).updateData(
                        ["participants" : FieldValue.arrayRemove([newParticipantRef])])
                }
                return true
        }
        return false
    }
    
    func setupEventListener(){
        // listen to event collection
        eventRef = database.collection("event")
        eventRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseEventSnapshot(snapshot: querySnapshot){ () in
                // nothing to do
                
            }
        }
    }
    
    func parseEventSnapshot(snapshot: QuerySnapshot, completion: @escaping () -> Void){
        // it listens to the collection, and if there is any changes, this function will be called and sync the local data(eventList)
        snapshot.documentChanges.forEach{ (change) in
            var parsedEvent = Event()
            if change.document.exists{
                parsedEvent.id = change.document.documentID
                parsedEvent.publisher = change.document.data()["publisher"] as? DocumentReference
                parsedEvent.eventName = change.document.data()["eventName"] as? String
                parsedEvent.eventDate = change.document.data()["eventDate"] as? Timestamp
                parsedEvent.publisherName = change.document.data()["publisherName"] as? String
                parsedEvent.eventDescription = change.document.data()["eventDescription"] as? String
                parsedEvent.eventLocation = change.document.data()["eventLocation"] as? String
                parsedEvent.publisherName = change.document.data()["publisherName"] as? String
                parsedEvent.participants = change.document.data()["participants"] as? [DocumentReference]
                self.addToEventList(change: change, parsedEvent: parsedEvent) { () in
                    self.listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.event || listener.listenerType == ListenerType.all {
                            listener.onEventChange(change: .update, events: self.eventList)
                        }
                        if listener.listenerType == ListenerType.userEvents || listener.listenerType == ListenerType.all {
                            listener.onYourEventChange(change: .update, user: self.defaultUser)
                        }
                        completion()
                    }
                }
            }
        }
    }
    
    func addToEventList(change:DocumentChange,parsedEvent:Event, completion: @escaping () -> Void){
        //sync local data with firebase
        let docRef = database.collection("event").document(parsedEvent.id!)
        docRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                if change.type == .added {
                    if let index = self.eventList.firstIndex(where: { $0.id == parsedEvent.id }) {
                        // If the parsedEvent already exists in the list, update it
                        self.eventList[index] = parsedEvent
                    } else {
                        // If the parsedEvent doesn't exist in the list, add it
                        self.eventList.append(parsedEvent)
                    }
                } else if change.type == .modified {
                    if let index = self.eventList.firstIndex(where: { $0.id == parsedEvent.id }) {
                        // If the parsedEvent exists in the list, update it
                        self.eventList[index] = parsedEvent
                    }
                } else if change.type == .removed {
                    if let index = self.eventList.firstIndex(where: { $0.id == parsedEvent.id }) {
                        // If the parsedEvent exists in the list, remove it
                        self.eventList.remove(at: index)
                    }
                }
            }
            completion() //return, finished executing
        }
    }
    func removeLikeFromUserFirebase(like:Post){
        // remove the like from user
        if let likeID = like.id{
            let likeRef = self.database.collection("post").document(likeID)
            self.userRef?.document(self.defaultUser.id!).updateData(["likes" : FieldValue.arrayRemove([likeRef])])
        }
        
    }
    func filterLikes(user:User) -> Int{
        // remove the like from the user once the posts is deleted
        var count = 0
        for like in user.likes{
            var likeExist = false
            for post in postList{
                if like.id == post.id{
                    likeExist = true
                }
            }
            if !likeExist{ // only remove it when it cant find the post
                count += 1
                removeLikeFromUserFirebase(like: like)
            }
        }
        return count
    }

    
    func parseSpecificEvent(eventRefArray:[DocumentReference], completion: @escaping ([Event]) -> Void){
        // decode the notes given in the parameter
        if eventRefArray.count == 0{ //nothing to decode if there is nothing passed in
            completion([])
        }
        var counter = 0
        var resultEventList:[Event] = []
        eventRefArray.forEach{ oneEventRef in
            oneEventRef.getDocument{ (oneEventDoc,error) in
                if let document = oneEventDoc, document.exists{
                    // decode events
                    var oneEventObj = Event()
                    oneEventObj.id = document.documentID
                    oneEventObj.eventDate = document.data()!["eventDate"] as? Timestamp
                    oneEventObj.eventDescription = document.data()!["eventDescription"] as? String
                    oneEventObj.eventLocation = document.data()!["eventLocation"] as? String
                    oneEventObj.publisher = document.data()!["publisher"] as? DocumentReference
                    oneEventObj.eventName = document.data()!["eventName"] as? String
                    oneEventObj.publisherName = document.data()!["publisherName"] as? String
                    oneEventObj.participants = document.data()!["publisher"] as? [DocumentReference]
                    resultEventList.append(oneEventObj)
                    counter += 1
                    if counter == eventRefArray.count{//only returns it when it decoded every thing, a handling for the asynchronous
                        completion(resultEventList)
                    }
                }
            }
        }
    }
    
    func setupPostListener(){// listens to the  post collection
        postRef = database.collection("post")
        postRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parsePostSnapshot(snapshot: querySnapshot){ () in
                // nothing to do
                
            }
        }
    }
    
    func addToPostList(change:DocumentChange,parsedPost:Post, completion: @escaping () -> Void){
        // sync local data with the firebase
        let docRef = database.collection("post").document(parsedPost.id!)
        docRef.getDocument{ (document, error) in
            if let document = document, document.exists{
                if change.type == .added {
                    if let index = self.postList.firstIndex(where: { $0.id == parsedPost.id }) {
                        // If the parsedPost already exists in the list, update it
                        self.postList[index] = parsedPost
                    } else {
                        // If the parsedPost doesn't exist in the list, add it
                        self.postList.append(parsedPost)
                    }
                } else if change.type == .modified {
                    if let index = self.postList.firstIndex(where: { $0.id == parsedPost.id }) {
                        // If the parsedPost exists in the list, update it
                        self.postList[index] = parsedPost
                        self.listeners.invoke{ listener in
                            if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                                listener.onPostChange(change: .update, posts: self.postList, defaultUser: self.defaultUser)
                            }
                        }
                    }
                } else if change.type == .removed {
                    if let index = self.postList.firstIndex(where: { $0.id == parsedPost.id }) {
                        // If the parsedPost exists in the list, remove it
                        self.postList.remove(at: index)
                    }
                }
            }
            completion() //return, finished executing
        }
    }
    
    func parseSpecificPost(postRefArray:[DocumentReference], completion: @escaping ([Post],[DocumentReference]) -> Void){
        // decode the notes given in the parameter
        if postRefArray.count == 0{//nothing to decode if there is nothing passed in
            completion([],[])
        }
        var filteredList:[DocumentReference] = []
        var filterCount = postRefArray.count
        var counter = 0
        var hasFiltered = false
        var resultPostList:[Post] = []
        postRefArray.forEach{ onePostRef in
            onePostRef.getDocument{ (onePostDoc,error) in
                if let document = onePostDoc, document.exists{
                    var onePostObj = Post()
                    onePostObj.id = document.documentID
                    onePostObj.likeNum = document.data()!["likeNum"] as? Int
                    onePostObj.postDetail = document.data()!["postDetail"] as? String
                    onePostObj.publisherName = document.data()!["publisherName"] as? String
                    onePostObj.publisher = document.data()!["publisher"] as? String
                    if let images = document.data()!["images"] as? [String]{
                        onePostObj.images = images
                    }
                    //decode comment
                    self.parseSpecificComment(commentRefArray: onePostDoc?.data()!["comments"] as? [DocumentReference] ?? []){ allComments in
                        onePostObj.comment = allComments
                        resultPostList.append(onePostObj)
                        counter += 1
                        if counter == filterCount{//only returns it when it decoded every thing, a handling for the asynchronous
                            if filterCount < postRefArray.count{
                                hasFiltered = true
                            }
                            completion(resultPostList,filteredList)
                        }
                    }
                }
                else{
                    filterCount -= 1 //to clear the likes which the post has been deleted from the user
                    filteredList.append(onePostRef)
                    if counter == filterCount{
                        if filterCount < postRefArray.count{
                            hasFiltered = true
                        }
                        completion(resultPostList,filteredList)
                    }
                }
            }
        }
    }
    
    func parsePostSnapshot(snapshot: QuerySnapshot, completion: @escaping () -> Void){
        snapshot.documentChanges.forEach{ (change) in
            // it listens to the collection, and if there is any changes, this function will be called and sync the local data(postList)
            
            //decode the post
            var parsedPost = Post()
            if change.document.exists{
                parsedPost.id = change.document.documentID
                parsedPost.publisher = change.document.data()["publisher"] as? String
                parsedPost.likeNum = change.document.data()["likeNum"] as? Int
                parsedPost.postDetail = change.document.data()["postDetail"] as? String
                parsedPost.publisherName = change.document.data()["publisherName"] as? String
                if let images = change.document.data()["images"] as? [String]{
                    parsedPost.images = images
                }
                let commentRef = change.document.data()["comments"] as? [DocumentReference]
                if commentRef == nil{ // the post does not have comment, just sync with the local data and ask the listener update their view
                    parsedPost.comment = []
                    self.addToPostList(change: change, parsedPost: parsedPost) { () in
                        self.listeners.invoke { (listener) in
                            if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                                listener.onPostChange(change: .update, posts: self.postList,defaultUser: self.defaultUser)
                                listener.onUserPostsDetail(change: .update,user: self.defaultUser)
                                completion()
                            }
                        }
                    }
                }
                else{
                    // if it has record, we have to manually decode it since it is not built in data type
                    self.parseSpecificComment(commentRefArray: commentRef!){ resultComments in
                        parsedPost.comment = resultComments
                        self.addToPostList(change: change, parsedPost: parsedPost){ () in
                            self.listeners.invoke { (listener) in
                                if listener.listenerType == ListenerType.post || listener.listenerType == ListenerType.all {
                                    listener.onPostChange(change: .update, posts: self.postList,defaultUser: self.defaultUser)
                                    listener.onUserPostsDetail(change: .update,user: self.defaultUser)
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func parseSpecificComment(commentRefArray:[DocumentReference], completion: @escaping ([Comment]) -> Void){
        // decode the notes given in the parameter
        if commentRefArray.count == 0{//nothing to decode if there is nothing passed in
            completion([])
        }
        var commentList:[Comment] = []
        var count = 0
        commentRefArray.forEach{ oneCommentRef in
            oneCommentRef.getDocument{ (oneCommentDoc,error) in
                if let document = oneCommentDoc, document.exists{
                    var parsedComment: Comment?
                    do {
                        parsedComment = try document.data(as: Comment.self)
                    } catch {
                        print("Unable to decode comments")
                        return
                    }
                    guard let comment = parsedComment else {
                        print("Document doesn't exist: Comment")
                        return
                    }
                    commentList.append(comment)
                    count += 1
                    if count == commentRefArray.count{//only returns it when it decoded every thing, a handling for the asynchronous
                        completion(commentList)
                    }
                }
            }
        }
    }
    
    func addComment(commentDetail:String) -> Comment{
        // fill the field of the comment that is going to be created
        var comment = Comment()
        comment.commentDetail = commentDetail
        comment.publisher = database.collection("user").document(defaultUser.id!)
        comment.publisherName = defaultUser.name
        do{
            // add this comment to the firebase as a new document
            if let commentRef = try commentRef?.addDocument(from: comment) {
                comment.id = commentRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        return comment
    }
    
    func addCommentToPost(comment:Comment, post:Post) {
        // if any of them does not exists we cant perform the add operation
        guard let commentID = comment.id, let postID = post.id else {
            return
        }
        // find the document reference and update the comments field
        if let newCommentRef = commentRef?.document(commentID) {
            postRef?.document(postID).updateData(
                ["comments" : FieldValue.arrayUnion([newCommentRef])])
        }
        defaultPost.comment.append(comment)
        // add operation has done, the view controller can update their view
        self.listeners.invoke{ listener in
            if listener.listenerType == ListenerType.comment || listener.listenerType == ListenerType.all {
                listener.onCommentChange(change: .update, comments: self.defaultPost.comment)
            }
        }
    }

    func setupHobbyListener() {
        // listen to the hobby collection
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
        // sync the local data (hobbyList)
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
        // it listens to the collection, and if there is any changes, this function will be called and sync the local data(hobbyList)
        snapshot.documentChanges.forEach{ (change) in
            var parsedHobby = Hobby()
            if change.document.exists{ //only proceed if the document exists
                
                //decode the hobby
                parsedHobby.id = change.document.documentID
                parsedHobby.name = change.document.data()["name"] as? String
                let recordRef = change.document.data()["records"] as? [DocumentReference]
                if recordRef == nil{ // the hobby does not have record
                    parsedHobby.records = []
                    self.addToHobbyList(change: change, parsedHobby: parsedHobby){ [weak self] in
                        //[weak self] and the next line make sure the following line execute after addToHobbyList finished executing
                        guard let self = self else { return }
                        self.listeners.invoke { (listener) in
                            // tell the listener, changes has been made, and ask them to update
                            if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                if let user = self.findUserById(id: self.currentUser!.uid){
                                    self.defaultUser = user
                                }
                                listener.onHobbyChange(change: .update, hobbies: self.defaultUser.hobbies)
                            }
                        }
                    }
                }
                else{
                    // if hobby has record, we need to decode by using this function, since it is not built in data type
                    self.parseSpecificRecord(recordRefArray: recordRef!){ resultRecords in
                        parsedHobby.records = resultRecords
                        self.addToHobbyList(change: change, parsedHobby: parsedHobby){ [weak self] in
                            guard let self = self else { return }
                            // tell the listener, changes has been made, and ask them to update
                            self.listeners.invoke { (listener) in
                                if listener.listenerType == ListenerType.hobby || listener.listenerType == ListenerType.all {
                                    if let user = self.findUserById(id: self.currentUser!.uid){
                                        self.defaultUser = user
                                    }
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
        // decode the notes given in the parameter
        if hobbyRefArray.count == 0{//nothing to decode if there is nothing passed in
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
                        if counter == hobbyRefArray.count{//only returns it when it decoded every thing, a handling for the asynchronous
                            completion(resultHobbyList)
                        }
                    }
                }
            }
        }
    }
    func parseSpecificRecord(recordRefArray:[DocumentReference], completion: @escaping ([Records]) -> Void){
        // decode the notes given in the parameter
        if recordRefArray.count == 0 { //nothing to decode if there is nothing passed in
            completion([])
        }
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
                        counter += 1
                        if counter == recordRefArray.count{//only returns it when it decoded every thing, a handling for the asynchronous
                            completion(resultRecordsList)
                        }
                    }
                }
            }
        }
    }
    func parseSpecificNote(noteRefArray:[DocumentReference], completion: @escaping ([Notes]) -> Void){
        // decode the notes given in the parameter
        if noteRefArray.count == 0{ //nothing to decode if there is nothing passed in
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
                    if count == noteRefArray.count{ //only returns it when it decoded every thing, a handling for the asynchronous
                        completion(NotesList)
                    }
                }
            }
        }
    }
    func setupRecordListener() {
        //listen to the records collection
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
        // it listens to the collection,and get the changes,and if there is any changes, this function will be called and sync the local data(recordList)
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
    func findRecordIndexById(id:String) -> Int?{
        // find the index of the record in recordLis
        for i in 0..<recordList.count{
            if recordList[i].id == id{
                return i
            }
        }
        return nil
    }
    func addToRecordList(change:DocumentChange,parsedRecord:Records){
        // to sync the local data(recordList) if there is any changes been made in the firebase
        if change.type == .added {
            if self.recordList.count == change.newIndex{
                self.recordList.insert(parsedRecord, at: Int(change.newIndex))
            }
        }
        else if change.type == .modified {
            // if it is been modified, we would want to update the view immediately after it update
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.string(from: Date())
            self.showCorrespondingRecord(hobby: self.currentHobby!,date: date){ record in
                if let record = record{
                    if let index = self.findRecordIndexById(id: record.id!){
                        self.recordList[index] = parsedRecord
                    }
                }
            }
        }
        else if change.type == .removed {
            self.recordList.remove(at: Int(change.oldIndex))
        }
    }
    func setupNotesListener() {
        // listen to the note collection
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
        // it listens to the collection, and if there is any changes, this function will be called and sync the local data(notesList)
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
        //
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
        // find and return the user by id
        for user in userList {
            if user.id == id{
                return user
            }
        }
        return nil
    }

    func loginAccount(email: String, password: String) async {
        do{
            self.email = email
            // this function accept the email and password and try to sign in to the firebase's auth
            let result = try await authController.signIn(withEmail: email, password: password)
            currentUser = result.user
        } catch{
            self.error = error.localizedDescription
            hasLogin = false
        }
        if hasLogin == nil{
            hasLogin = true
        }
        
        // user default is a data persistent to store the user login information, where the next time open the app, it signed in automatically
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasLogin")
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        
        //setup for the collections
        self.setupUserListener(){ () in
            self.setupHobbyListener()
            self.setupRecordListener()
            self.setupNotesListener()
            self.setupPostListener()
            self.setupCommentListener()
            self.setupEventListener()
        }
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
                listener.onAuthAccount(change:.login,user: self.currentUser)
            }
        }
    }
}
