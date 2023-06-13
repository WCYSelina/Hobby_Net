//
//  WeeklyRecordViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 7/5/2023.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class WeeklyRecordViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    func onRecordChange(change: DatabaseChange, record: Records?) {
    }

    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post],defaultUser:User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onCreateAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let records = records{
            return records.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewRecord", for: indexPath) as! PageViewTableViewCell
        
        // initialise the notesText that has noteDetail and image in a tuple
        var notesText: [(String,String?)] = []
        if records != nil{
            records![indexPath.section].notes.forEach{ note in
                if let noteDetail = note.noteDetails, let image = note.image{
                    notesText.append((noteDetail,image))
                }
                else if let noteDetail = note.noteDetails,note.image == nil{
                    notesText.append((noteDetail,nil))
                }
            }
        }
        // init the PageContainerViewController
        let containerViewController = PageContainerViewController()
        cell.pageViewControlObj = containerViewController
        cell.pageViewControlObj.notesText = notesText
        // add the view of the containerViewController into cell's content view
        cell.contentView.addSubview(containerViewController.view)
        containerViewController.view.frame = cell.contentView.bounds
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // customize the header
        let headerView = UIView()
        headerView.backgroundColor = .systemGray4
        
        let titleLabel = UILabel()
        titleLabel.text = records![section].date
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
        self.records = records
        self.tableView.reloadData()
    }
    
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
        self.hobby = hobby
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var weekPickerstackView: UIStackView!
    weak var databaseController:DatabaseProtocol?
    var listenerType = ListenerType.record
    var records:[Records]?
    var startWeek:Date?
    var endWeek:Date?
    let weekRange = UILabel()
    var hobby:Hobby?
    var currentDate: Date = Date() {
        didSet {
            updateWeekLabel()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(PageViewTableViewCell.self, forCellReuseIdentifier: "viewRecord")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = false
        
 
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Create the left arrow button
        let leftArrowButton = UIButton(type: .system)
        leftArrowButton.setTitle("<", for: .normal)
        leftArrowButton.translatesAutoresizingMaskIntoConstraints = false
        leftArrowButton.addTarget(self, action: #selector(moveBackward), for: .touchUpInside) // add action for the button
        
        weekRange.numberOfLines = 0
        updateWeekLabel()
        
        // Create the right arrow button
        let rightArrowButton = UIButton(type: .system)
        rightArrowButton.setTitle(">", for: .normal)
        rightArrowButton.addTarget(self, action: #selector(moveForward), for: .touchUpInside) // add action for the button
        
        weekPickerstackView.addArrangedSubview(leftArrowButton)
        weekPickerstackView.addArrangedSubview(weekRange)
        weekPickerstackView.addArrangedSubview(rightArrowButton)
        
        databaseController?.startWeek = startWeek
        databaseController?.endWeek = endWeek
        
        view.addSubview(weekPickerstackView)
        // show record within the range of start and endweek
        databaseController?.showRecordWeekly(hobby: hobby!, startWeek: startWeek!, endWeek: endWeek!){ (records,dateInRange) in
            self.records = []
            for range in dateInRange {
                for record in records {
                    if record.date == range{
                        self.records?.append(record)
                        break
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @objc func moveForward() {
        // update the weekPicker to the next week
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        
    }
    
    @objc func moveBackward() {
        // update the weekPicker to the previous week
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
    }
    
    func updateWeekLabel() {
        let week = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let start = formatter.string(from: week.start)
        self.startWeek = week.start
        let end = formatter.string(from: week.end)
        self.endWeek = week.end
        self.weekRange.text = "\(start) - \(end)"
        // show record within the range of start and endweek
        databaseController?.showRecordWeekly(hobby: hobby!, startWeek: startWeek!, endWeek: endWeek!){(records,dateInRange) in
            self.records = []
            for range in dateInRange {
                for record in records {
                    if record.date == range{
                        self.records?.append(record)
                        break
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}
