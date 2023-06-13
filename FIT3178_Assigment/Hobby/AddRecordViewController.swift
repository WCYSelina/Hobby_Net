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
        dateFormatter.dateFormat = "dd MMM yyyy"
        selectedDate = dateFormatter.string(from: sender.date)
        performSegue(withIdentifier: "addRecordNavigate", sender: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // transfer the data to the view controller that is going to navigate to
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRecordNavigate", let destinationVC = segue.destination as? SheetAddRecordViewController{
            destinationVC.hobby = currentHobby
            destinationVC.choosenDate = selectedDate
        }
            
    }
}
