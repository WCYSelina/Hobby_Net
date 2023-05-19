//
//  YourEventsViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 19/5/2023.
//

import UIKit
import FirebaseAuth
class YourEventsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DatabaseListener{
    @IBOutlet weak var createJoinEvent: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    var listenerType = ListenerType.userEvents
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onCreateAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser: User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?){
        defaultUser = user
    }
    weak var databaseController:DatabaseProtocol?
    var defaultUser:User?
    var eventList:[Event] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.setupUserListener { () in
            self.tableView.delegate = self
            self.tableView.dataSource = self

            self.tableView.separatorStyle = .none
            self.tableView.register(CardTableViewCellForEvent.self, forCellReuseIdentifier: "yourEventsIdentifier")
            self.createJoinEvent.selectedSegmentIndex = 0
            self.segmentedControlValueChanged(self.createJoinEvent)
        }


    }
    
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        Task{
            if sender.selectedSegmentIndex == 0{
                if let events = defaultUser?.events{
                    eventList = events
                    tableView.reloadData()
                }
            }
            else{
                if let events = defaultUser?.eventJoined{
                    eventList = events
                    tableView.reloadData()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "yourEventsIdentifier", for: indexPath) as! CardTableViewCellForEvent
        let event = eventList[indexPath.section]
        eventCell.eventTitle.text = event.eventName
        eventCell.descriptionLabel.text = "Description: \(event.eventDescription!)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let eventDate = event.eventDate?.dateValue()
        if let date = eventDate{
            let dateString = dateFormatter.string(from:date)
            eventCell.eventDate.text = "Date: \(dateString)"
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from:date)
            eventCell.eventTime.text = "Time: \(timeString)"
        }
        eventCell.eventLocation.text = "Location: \(event.eventLocation!)"
        eventCell.weather.text = "Weather: \(event.showWeather!)"
        
        let tapGesture = CustomTapGesture(target: self, action: #selector(moreDetailTapped(_:)))
        tapGesture.event = event
        eventCell.moreDetails.addGestureRecognizer(tapGesture)
        
        eventCell.joinEventButton.addTarget(self, action: #selector(joinEvent(_:)), for: .touchUpInside)
        eventCell.joinEventButton.tag = indexPath.section
        
        return eventCell
    }
    
    @objc func moreDetailTapped(_ sender: CustomTapGesture){
        if let event = sender.event{
            databaseController?.defaultEvent = event
            performSegue(withIdentifier: "moreDetailsIdentifier2", sender: event)
        }
    }
    
    @objc func joinEvent(_ sender: UIButton){
        let section = sender.tag
        let event = eventList[section]
        print("event")
        let _ = databaseController?.userJoinEvent(event: event)
    }
    
}
