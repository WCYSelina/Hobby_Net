//
//  User.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 25/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

struct User: Codable{
    @DocumentID var id:String?
    var name:String?
    var hobbies:[Hobby] = []
    var posts:[Post] = []
    var likes:[Post] = []
    
}
