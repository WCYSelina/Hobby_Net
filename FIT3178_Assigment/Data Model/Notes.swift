//
//  Notes.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 25/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Notes: NSObject,Codable,Identifiable{
    @DocumentID var id:String?
    var noteDetails:String?
}
