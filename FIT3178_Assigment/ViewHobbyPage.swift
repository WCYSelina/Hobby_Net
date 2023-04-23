//
//  ViewHobbyPage.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit

class ViewHobbyPage: UIView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var hobbyRecord:Hobby?
    weak var viewHobbyDelegate:ViewHobbyDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
