//
//  YourEventsViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 19/5/2023.
//

import UIKit
import FirebaseAuth
class YourEventsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DatabaseListener{
    func onRecordChange(change: DatabaseChange, record: Records?) {
    }
    
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    @IBOutlet weak var createJoinEvent: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    var listenerType = ListenerType.userEvents
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
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
            // register the custome cell, since it is not in the storyBoard
            self.tableView.register(CardTableViewCellForEvent.self, forCellReuseIdentifier: "yourEventsIdentifier")
            if self.createJoinEvent.selectedSegmentIndex != 1{
                self.createJoinEvent.selectedSegmentIndex = 0
            }
            self.segmentedControlValueChanged(self.createJoinEvent)
        }
    }
    
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // show the corresponding events to the selectedSegmentIndex
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
        let eventDate = event.eventDate?.dateValue() // get the date of the event
        if let date = eventDate{
            let dateString = dateFormatter.string(from:date)
            eventCell.eventDate.text = "Date: \(dateString)"
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from:date)
            eventCell.eventTime.text = "Time: \(timeString)"
        }
        eventCell.eventLocation.text = "Location: \(event.eventLocation!)"
        
        
        // add gesture for the event
        let tapGesture = CustomTapGesture(target: self, action: #selector(moreDetailTapped(_:)))
        tapGesture.event = event
        eventCell.moreDetails.addGestureRecognizer(tapGesture)
        
        // validate if the user has joined the event, shows the corresponding words for the button
        let userHasJoined = databaseController?.checkIfUserHasJoined(event: event)
        if userHasJoined!{
            eventCell.joinEventButton.setTitle("Unjoined Event", for:.normal)
        }
        else{
            eventCell.joinEventButton.setTitle("Join Event", for:.normal)
        }
        // initialise the button action
        eventCell.joinEventButton.addTarget(self, action: #selector(joinEvent(_:)), for: .touchUpInside)
        // give button a tag, this tag contains the information of which section has been clicked
        eventCell.joinEventButton.tag = indexPath.section
        
        return eventCell
    }
    
    //this will be called when the moreDetails label been pressed
    @objc func moreDetailTapped(_ sender: CustomTapGesture){
        if let event = sender.event{
            databaseController?.defaultEvent = event
            performSegue(withIdentifier: "moreDetailsIdentifier", sender: event)
        }
    }
    
    // this will be called when the joinEventButton been pressed
    @objc func joinEvent(_ sender: UIButton){
        let section = sender.tag
        let event = eventList[section]
        let _ = databaseController?.userJoinEvent(event: event)
    }
    
}
