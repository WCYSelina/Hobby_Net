//
//  Event.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 18/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class Event: NSObject, Codable{
    @DocumentID var id:String?
    var eventDescription:String?
    var eventName:String?
    var eventLocation:String?
    var eventDate:Timestamp?
    var participants:[DocumentReference]? = []
    var publisher:DocumentReference?
    var publisherName:String?
}
