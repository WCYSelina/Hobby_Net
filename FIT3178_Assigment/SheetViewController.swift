//
//  SheetViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit

class SheetViewController: UIViewController,UISheetPresentationControllerDelegate{
    
    weak var hobbyDelegate:CreateHobbyDelegate?
    @IBOutlet weak var hobbyName: UITextField!
    
    
    @IBAction func createHobby(_ sender: Any) {
        guard let name = hobbyName.text else{
            return
        }
        let hobby = Hobby(name: name)
        let createHobbyDel = hobbyDelegate?.createHobby(hobby)
        if createHobbyDel == false{
            displayMessage(title: "Failed", message: "Unable to create hobby")
            return
        }
        self.dismiss(animated: true)
    }
    
    
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
