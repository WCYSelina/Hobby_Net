//
//  CreateEventViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 18/5/2023.
//

import UIKit
import Firebase
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
            print("jhhhh")
            let _ = databaseController?.addEvent(eventDate: date, eventDescription: eventDes, eventLocation: location, eventName: name, showWeather: isShowWeather.isOn)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
