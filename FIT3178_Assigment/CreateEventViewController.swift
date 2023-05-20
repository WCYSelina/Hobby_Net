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
    @IBOutlet weak var showWeather: UISwitch!
    
    
    
    @IBAction func createEvent(_ sender: Any) {
        let date = Timestamp(date: eventDate.date)
        if let eventDes = eventDescription.text,let location = eventLocation.text, let name = eventName.text, let isShowWeather = showWeather{
            let _ = databaseController?.addEvent(eventDate: date, eventDescription: eventDes, eventLocation: location, eventName: name, showWeather: isShowWeather.isOn)
            navigationController?.popViewController(animated: true)
        }
        else{
            displayMessage(title: "Error", message: "Please ensure that you have filled the information")
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        if let sixteenDateFromNow = calendar.date(byAdding: .day, value: 16,to: currentDate){
            eventDate.minimumDate = currentDate
            eventDate.maximumDate = sixteenDateFromNow
        }
        // Do any additional setup after loading the view.
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
