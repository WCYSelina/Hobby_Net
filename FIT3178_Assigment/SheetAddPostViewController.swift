//
//  SheetAddPostViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit

class SheetAddPostViewController: UIViewController,UISheetPresentationControllerDelegate{
    
    weak var databaseController:DatabaseProtocol?

    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        sheetPresentationController?.detents = [.custom{
            _ in return 220
        }]
        sheetPresentationController?.prefersGrabberVisible = true //show the line on top of the bottom sheet
        sheetPresentationController?.preferredCornerRadius = 24
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
