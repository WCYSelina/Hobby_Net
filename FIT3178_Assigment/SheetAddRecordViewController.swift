//
//  SheetAddRecordViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import UIKit

class SheetAddRecordViewController: UIViewController {

    weak var hobbyDelegate:CreateHobbyDelegate?
    @IBOutlet weak var notesRecord: UITextField!
    
    
    @IBAction func addRecord(_ sender: Any) {
//        guard let name = notesRecord.text else{
//            return
//        }
//        let _ = databaseController?.addRecordToHobby(record: <#T##Records#>, hobby: <#T##Hobby#>)
    }
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetPresentationController?.detents = [.custom{
            _ in return 200
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