//
//  Hobby.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 25/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Hobby: NSObject,Codable{
    @DocumentID var id:String?
    var name:String?
    var records:[Records] = []
    
    enum CodingKeys: String,CodingKey{
        case name
//        case records
    }
}
