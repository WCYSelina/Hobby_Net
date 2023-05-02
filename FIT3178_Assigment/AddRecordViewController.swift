//
//  AddRecordViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import UIKit

class AddRecordViewController: UIViewController {
    
    var currentHobby:Hobby?
    var passedDate:Date?
    
    @IBAction func datePickedAddRecord(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let selectedDate = dateFormatter.string(from: sender.date)
        passedDate = sender.date
        print("Selected date: \(selectedDate)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetPresentationControler = storyboard.instantiateViewController(withIdentifier: "SheetAddRecordViewController") as! SheetAddRecordViewController
        sheetPresentationControler.hobby = currentHobby
        sheetPresentationControler.choosenDate = passedDate
//        sheetPresentationControler.hobbyDelegate = self
        present(sheetPresentationControler, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
