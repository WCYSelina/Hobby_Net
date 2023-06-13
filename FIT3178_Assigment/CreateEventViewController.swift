//
//  CreateEventViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 18/5/2023.
//

import UIKit
import Firebase
import Foundation

class CreateEventViewController: UIViewController {
    
    
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    
    
    
    @IBAction func createEvent(_ sender: Any) {
        // take all the information, and use it to create the data
        let date = Timestamp(date: eventDate.date)
        if let eventDes = eventDescription.text,let location = eventLocation.text, let name = eventName.text{
            let _ = databaseController?.addEvent(eventDate: date, eventDescription: eventDes, eventLocation: location, eventName: name)
            navigationController?.popViewController(animated: true)
        }
        else{
            // error handling
            displayMessage(title: "Error", message: "Please ensure that you have filled the information")
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // limit the date to choose, because the API can only choose up to 16 days from current date
        if let sixteenDateFromNow = calendar.date(byAdding: .day, value: 16,to: currentDate){
            eventDate.minimumDate = currentDate
            eventDate.maximumDate = sixteenDateFromNow
        }
        // Do any additional setup after loading the view.
    }
    
    
    // the alert message
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}
