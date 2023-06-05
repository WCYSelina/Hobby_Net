//
//  CustomViewHobbyViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 5/6/2023.
//

import UIKit
import FirebaseAuth

class CustomViewHobbyViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewRecordCell", for: indexPath) as! PageViewTableViewCell
        
        // Configure the cell
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
        let containerViewController = PageContainerViewController()
        cell.pageViewControlObj = containerViewController
        cell.pageViewControlObj.notesText = notesText
        containerViewController.setUpPage()
        cell.contentView.addSubview(containerViewController.view)
        containerViewController.view.frame = cell.contentView.bounds
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UIScreen.main.bounds.height * 0.5
        return 400
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var tableView: UITableView!
    
    var hobby:Hobby?
    var records:[Records]?
    var listenerType = ListenerType.record
    
    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    
    
    @IBAction func updateView(_ sender: Any) {
        if fromDate.date.compare(toDate.date) == .orderedAscending{
            databaseController?.showRecordWeekly(hobby: hobby!, startWeek: fromDate.date, endWeek: toDate.date){ (records,dateInRange) in
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
        else{
            displayMessage(title: "Error", message: "Please make sure the From Date is earlier than the To Date")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.register(PageViewTableViewCell.self, forCellReuseIdentifier: "viewRecordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = false
        
        databaseController?.showRecordWeekly(hobby: hobby!, startWeek: fromDate.date, endWeek: toDate.date){ (records,dateInRange) in
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
    
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
