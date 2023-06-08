//
//  Post.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
class Post: NSObject,Codable{
    @DocumentID var id:String?
    var comment:[Comment] = []
    var likeNum:Int?
    var postDetail:String?
    var publisher:String?
    var publisherName:String?
}
