//
//  AddRecordViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import UIKit

class AddRecordViewController: UIViewController {
    
    weak var databaseConroller:DatabaseProtocol?
    var currentHobby:Hobby?
    var passedDate:String?
    var selectedDate:String?
    
    @IBAction func datePickedAddRecord(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        selectedDate = dateFormatter.string(from: sender.date)
        print("Selected date: \(selectedDate)")
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let sheetPresentationControler = storyboard.instantiateViewController(withIdentifier: "SheetAddRecordViewController") as! SheetAddRecordViewController
        performSegue(withIdentifier: "addRecordNavigate", sender: nil)
//        sheetPresentationControler.hobbyDelegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRecordNavigate", let destinationVC = segue.destination as? SheetAddRecordViewController{
            destinationVC.hobby = currentHobby
            destinationVC.choosenDate = selectedDate
        }
            
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
