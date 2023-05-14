//
//  UserProfileViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 12/5/2023.
//

import UIKit

class UserProfileViewController: UIViewController{

    
    @IBOutlet weak var username: UILabel!
    weak var databaseController:DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        username.text = databaseController?.email
        // Do any additional setup after loading the view.
    }
    

}
