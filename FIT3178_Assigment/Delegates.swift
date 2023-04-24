//
//  CreateHobbyDelegate.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import Foundation

protocol CreateHobbyDelegate: AnyObject {
    func createHobby(_ newHobby: Hobby) -> Bool
}

protocol ViewHobbyDelegate: AnyObject {
    var hobbyRecord:Hobby?{get set}
    func viewHobby(_ newHobby:Hobby)
}
protocol AddRecordDelegate: AnyObject {
    func viewHobby(_ record:Hobby)
}
