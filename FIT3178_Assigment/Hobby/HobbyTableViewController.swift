//
//  HobbyTableViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit
import SwiftUI
import FirebaseAuth

class HobbyTableViewController: UITableViewController,DatabaseListener{
    func onPostChange(change: DatabaseChange, posts: [Post]) {
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
        allHobbies = hobbies
        tableView.reloadData()
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    weak var databaseController:DatabaseProtocol?
    let CELL_HOBBY = "hobbyCell"
    var allHobbies: [Hobby] = []
    var currentHobby:Hobby?
    var listenerType = ListenerType.hobby
    var tabBar: UITabBar!
    @IBAction func addHobby(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetPresentationControler = storyboard.instantiateViewController(withIdentifier: "SheetViewController") as! SheetViewController
//        sheetPresentationControler.hobbyDelegate = self
        present(sheetPresentationControler, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allHobbies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hobbyCell = tableView.dequeueReusableCell(withIdentifier: CELL_HOBBY, for: indexPath)
        var content = hobbyCell.defaultContentConfiguration()
        let hobby = allHobbies[indexPath.row]
        content.text = hobby.name
        hobbyCell.contentConfiguration = content
        return hobbyCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentHobby = allHobbies[indexPath.row]
        databaseController?.defaultHobby = currentHobby!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: Date())
        databaseController?.currentDate = date
        databaseController?.showCorrespondingRecord(hobby: currentHobby!,date: date){() in
            //
        }
        let currentDate = Date()
        print(currentDate.timeIntervalSinceNow)
        let calendar = Calendar.current
        let oneWeekAfter = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        let dateString = "\(dateFormatter.string(from: oneWeekAfter)) - \(dateFormatter.string(from: currentDate))"
        let swiftUIView = ViewHobbyPage(dateString: dateString,startOfWeek: currentDate,endOfWeek: oneWeekAfter, hobby: currentHobby!)
        let hostingController = UIHostingController(rootView: swiftUIView) //UIHostingController allow swiftUI to be embedded into UIKit
        present(hostingController, animated: true, completion: nil)
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print(allHobbies[indexPath.row])
            self.databaseController?.deleteHobby(hobby: allHobbies[indexPath.row])
        }
    }
}



