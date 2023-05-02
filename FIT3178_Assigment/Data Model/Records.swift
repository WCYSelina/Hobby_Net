//
//  Records.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 25/4/2023.
//

import UIKit
import Firebase

struct Records:Codable{
    var id:String?
    var date: String?
    var notes:[Notes]?
}
