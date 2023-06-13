//
//  SheetViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit

class SheetViewController: UIViewController,UISheetPresentationControllerDelegate{
    
    weak var databaseController:DatabaseProtocol?
    
    @IBOutlet weak var hobbyName: UITextField!
    @IBAction func createHobby(_ sender: Any) {
        // use the information to create the hobby
        guard let name = hobbyName.text else{
            return
        }
        let _ = databaseController?.addHobby(name: name)
        self.dismiss(animated: true)
    }
    
    
    // bottom sheet
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        sheetPresentationController?.detents = [.custom{
            _ in return 300
        }]
        sheetPresentationController?.prefersGrabberVisible = true //show the line on top of the bottom sheet
        sheetPresentationController?.preferredCornerRadius = 24
    }
    
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
