//
//  MyViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit

class ViewHobbyController: UIViewController {
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
        hobbyView = ViewHobbyPage(frame: view.bounds)//initialise the size screen, in this case, full screen
        hobbyView.hobbyRecord = hobbyRecords
//        hobbyView.viewHobbyDelegate = viewHobbyDelegate// set the delegate to the view controller
//        viewHobbyDelegate?.hobbyRecord = hobbyRecords
        view.addSubview(hobbyView)
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
