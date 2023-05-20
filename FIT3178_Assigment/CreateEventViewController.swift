//
//  CreateEventViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 18/5/2023.
//

import UIKit
import Firebase
import CoreLocation
import Foundation

class CreateEventViewController: UIViewController {
    
    let geocoder = CLGeocoder()
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
            geocoder.geocodeAddressString(location) { (placemarks, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let placemark = placemarks?.first {
                    let location = placemark.location
                    self.getWeather(location: location!, date: self.eventDate.date)
                } else {
                    print("No location found")
                }
            }
            
        }
        else{
            displayMessage(title: "Error", message: "Please ensure that you have filled the information")
        }
        
    }
    
    func getWeather(location: CLLocation,date:Date){
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(),to: date)
        print(components.day)
        print("\(lat) \(long)")
        let url =  URL(string:"https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(long)&cnt=\(components.day!+1)&appid=c5fee144acaea76473685a10dc4069b9")
        let task = URLSession.shared.dataTask(with:url!) {(data,response,error) in
            if let data = data{
                do{
                    print("heyyyy")
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
                    let list = json["list"] as! [[String:Any]]
                    let weather = list[components.day!]["weather"] as? [[String:Any]]
                    if let weatherItem = weather?.first{
                        let main = weatherItem["main"] as? String
                        print(main)
                    }
                } catch{
                    print("Failed to parse weather")
                }
            }
        }
        task.resume()
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
