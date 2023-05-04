//
//  Notes.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 25/4/2023.
//

import UIKit

class Notes: NSObject,Codable,Identifiable{
    var id:String?
    var noteDetails:String?
    enum CodingKeys: String, CodingKey {
        case noteDetails
    }

}
