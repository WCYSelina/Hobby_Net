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
    var username:String?
    var hobbies:[Hobby]
    

    enum CodingKeys: String,CodingKey{
        case id
        case username
        case hobbies = "hobbies"
        
    }
}
