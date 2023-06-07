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
        var cell = tableView.dequeueReusableCell(withIdentifier: "dailyRecordCell", for: indexPath) as! PageViewTableViewCell
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
        containerSetupPage(cell: cell, containerViewController: containerViewController){ returnCell in
            cell = returnCell
        }
        return cell
    }
    
    func containerSetupPage(cell:PageViewTableViewCell,containerViewController:PageContainerViewController,completion: @escaping (PageViewTableViewCell) -> Void){
        cell.pageViewControlObj.setUpPage(){ () in
            print("done")
            cell.contentView.addSubview(containerViewController.view)
            containerViewController.view.frame = cell.contentView.bounds
            completion(cell)
        }
    }
    
    func onRecordChange(change: DatabaseChange, record: Records?) {
        self.record = record
//        tableView.reloadData()
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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "dailyRecord", sender: self.hobby)
        }
        else if sender.selectedSegmentIndex == 1{
            performSegue(withIdentifier: "weeklyRecord", sender: self.hobby)
        }
        else{
            performSegue(withIdentifier: "customRecord", sender: self.hobby)
        }
    }
    @IBAction func datePickerValueChange(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print(formattedDate)
        dateRecord.text = formattedDate
        self.record = nil
        databaseController?.showCorrespondingRecord(hobby: self.hobby!, date: formattedDate){ record in
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
        

        databaseController?.showCorrespondingRecord(hobby: self.hobby!, date: formattedDate){ record in
            self.tableView.reloadData()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0
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
        else if segue.identifier == "weeklyRecord", let destinationVC = segue.destination as? WeeklyRecordViewController{
            if let hobby = sender as? Hobby{
                destinationVC.hobby = hobby
            }
        }
        else if segue.identifier == "customRecord", let destinationVC = segue.destination as? CustomViewHobbyViewController{
            if let hobby = sender as? Hobby{
                destinationVC.hobby = hobby
            }
        }
        else if segue.identifier == "addRecordChooseDate", let destinationVC = segue.destination as? AddRecordViewController{
            destinationVC.currentHobby = hobby
        }
    }
}
