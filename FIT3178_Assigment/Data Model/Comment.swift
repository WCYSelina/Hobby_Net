//
//  Comment.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
struct Comment: Codable{
    @DocumentID var id:String?
    var commentDetail:String?
    var publisher:DocumentReference?
}
