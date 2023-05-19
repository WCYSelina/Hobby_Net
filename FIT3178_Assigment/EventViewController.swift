//
//  EventViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 12/5/2023.
//

import UIKit
import FirebaseAuth

class EventViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    var listenerType = ListenerType.event
    weak var databaseController:DatabaseProtocol?
    func onEventChange(change: DatabaseChange, events: [Event]) {
        eventList = events
        tableView.reloadData()
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser:User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onCreateAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records:[Records]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    
    var eventList:[Event] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the table view's delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.gray // Customize the separator color
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Customize the separator insets
        tableView.register(CardTableViewCellForEvent.self, forCellReuseIdentifier: "eventCell")
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
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! CardTableViewCellForEvent
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
        
            let userHasJoined = databaseController?.checkIfUserHasJoined(event: event)
            if userHasJoined!{
                eventCell.joinEventButton.setTitle("Unjoined Event", for:.normal)
            }
            else{
                eventCell.joinEventButton.setTitle("Join Event", for:.normal)
            }
            
            eventCell.joinEventButton.addTarget(self, action: #selector(self.joinEvent(_:)), for: .touchUpInside)
            eventCell.joinEventButton.tag = indexPath.section
            return eventCell
    }
    
    @objc func moreDetailTapped(_ sender: CustomTapGesture){
        if let event = sender.event{
            databaseController?.defaultEvent = event
            performSegue(withIdentifier: "moreDetailsIdentifier", sender: event)
        }
    }
    
    @objc func joinEvent(_ sender: UIButton){
        let section = sender.tag
        let event = eventList[section]
        let _ = databaseController?.userJoinEvent(event: event)
    }
}

class CardTableViewCellForEvent: UITableViewCell {
    let eventTitle = UILabel()
    let descriptionLabel = UILabel()
    let eventTime = UILabel()
    let eventDate = UILabel()
    let eventLocation = UILabel()
    let weather = UILabel()
    let joinEventButton = UIButton(type: .system)
    let subscribeButton = UIButton()
    let moreDetails = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize cell layout
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        eventTitle.font = UIFont.boldSystemFont(ofSize: eventTitle.font.pointSize)
        eventTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventTitle)
        
        // Configure description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.tintColor = .lightGray
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        eventTime.font = UIFont.systemFont(ofSize: 15)
        eventTime.tintColor = .lightGray
        eventTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventTime)
        
        eventDate.font = UIFont.systemFont(ofSize: 15)
        eventDate.tintColor = .lightGray
        eventDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventDate)
        
        eventLocation.font = UIFont.systemFont(ofSize: 15)
        eventLocation.tintColor = .lightGray
        eventLocation.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventLocation)
        
        weather.font = UIFont.systemFont(ofSize: 15)
        weather.tintColor = .lightGray
        weather.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weather)
        
        moreDetails.text = "More Details"
        moreDetails.isUserInteractionEnabled = true
        moreDetails.textColor = .systemBlue
        moreDetails.font = UIFont.systemFont(ofSize: 12)
        moreDetails.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moreDetails)
        
        joinEventButton.layer.cornerRadius = 10
        joinEventButton.setTitleColor(UIColor.white, for: .normal)
        joinEventButton.backgroundColor = .systemBlue
        joinEventButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(joinEventButton)
        
        // Configure send button
        subscribeButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        subscribeButton.tintColor = .black
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subscribeButton)
        
        
        // Set up constraints
        NSLayoutConstraint.activate([
            eventTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            eventTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            eventTime.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            eventTime.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            eventTime.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            eventDate.topAnchor.constraint(equalTo: eventTime.bottomAnchor, constant: 8),
            eventDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            eventDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            eventLocation.topAnchor.constraint(equalTo: eventDate.bottomAnchor, constant: 8),
            eventLocation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            eventLocation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            weather.topAnchor.constraint(equalTo: eventLocation.bottomAnchor, constant: 8),
            weather.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            weather.trailingAnchor.constraint(equalTo: moreDetails.leadingAnchor, constant: -8),
            
            moreDetails.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            moreDetails.centerYAnchor.constraint(equalTo: weather.centerYAnchor),
            
            joinEventButton.topAnchor.constraint(equalTo: weather.bottomAnchor, constant: 8),
            joinEventButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            joinEventButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            joinEventButton.trailingAnchor.constraint(equalTo: subscribeButton.leadingAnchor, constant: -8),

            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            subscribeButton.centerYAnchor.constraint(equalTo: joinEventButton.centerYAnchor),
            subscribeButton.widthAnchor.constraint(equalToConstant: 24),
            subscribeButton.heightAnchor.constraint(equalToConstant: 24),
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MoreDetailPage:UIViewController{
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var desText: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weather: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let event = databaseController?.defaultEvent
        eventTitle.text = event?.eventName
        desText.text = event?.eventDescription
        
        let eventDate = event?.eventDate?.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        if let date = eventDate{
            let dateString = dateFormatter.string(from:date)
            self.date.text = "Date: \(dateString)"
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from:date)
            time.text = "Time: \(timeString)"
        }
        
        location.text = event?.eventLocation
        weather.text = "\(event!.showWeather!)"
    }
    
    
    
}



