//
//  DailyRecordViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 29/5/2023.
//

import UIKit
import FirebaseAuth
class DailyRecordViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UIScreen.main.bounds.height * 0.5
        return 400
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyRecordCell", for: indexPath) as! PageViewTableViewCell
        
        // Configure the cell
        var notesText: [(String,String?)] = []
        if record != nil{
            record!.notes.forEach{ note in
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
        cell.contentView.addSubview(containerViewController.view)
        containerViewController.view.frame = cell.contentView.bounds
        containerViewController.didMove(toParent: self)
        return cell
    }
    
    func onRecordChange(change: DatabaseChange, record: Records) {
        self.record = record
    }
    
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser:User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onCreateAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange,records:[Records]) {
    }
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {

    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change:DatabaseChange, hobby:Hobby){
        self.hobby = hobby
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "dailyRecord", sender: self.hobby)
        }else{
            performSegue(withIdentifier: "weeklyRecord", sender: self.hobby)
        }
    }
    @IBAction func datePickerValueChange(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        dateRecord.text = formattedDate
        databaseController?.showCorrespondingRecord(hobby: self.hobby!, date: formattedDate){ () in
            self.record?.notes.forEach{ note in
                self.notesText.append((note.noteDetails!,note.image ?? ""))
            }
            print(self.notesText)
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dateRecord: UILabel!
    weak var databaseController:DatabaseProtocol?
    var listenerType = ListenerType.record
    var record:Records?
    var notesText:[(String,String?)] = []
    var hobby:Hobby?
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.title = hobby?.name
        
        tableView.register(PageViewTableViewCell.self, forCellReuseIdentifier: "dailyRecordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = false
        
        let selectedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        dateRecord.text = formattedDate
        

        databaseController?.showCorrespondingRecord(hobby: self.hobby!, date: formattedDate){ () in
        }
        tableView.reloadData()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dailyRecord", let destinationVC = segue.destination as? DailyRecordViewController{
            if let hobby = sender as? Hobby{
                destinationVC.hobby = hobby
            }
        }
        if segue.identifier == "weeklyRecord", let destinationVC = segue.destination as? WeeklyRecordViewController{
            if let hobby = sender as? Hobby{
                destinationVC.hobby = hobby
            }
        }
    }
}
