//
//  MyViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit

class ViewHobbyController: UIViewController,UITableViewDataSource,, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    //    func viewHobby(_ newHobby: Hobby) {
    //        hobbyRecords = newHobby
    //        print("ffff")
    ////        performSegue(withIdentifier: "mySegue", sender: nil)
    //    }
    
    weak var viewHobbyDelegate:ViewHobbyDelegate?
    var hobbyRecords:Hobby?
    var hobbyView: ViewHobbyPage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a UIScrollView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    num
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
