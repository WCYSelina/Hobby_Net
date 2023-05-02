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
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
        allHobbies = hobbies
        tableView.reloadData()
    }
    
    func onRecordChange(change: DatabaseChange, record: [Records]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    weak var databaseController:DatabaseProtocol?
    let CELL_HOBBY = "hobbyCell"
    var allHobbies: [Hobby] = []
    var currentHobby:Hobby?
    var listenerType = ListenerType.hobby
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let swiftUIView = ViewHobbyPage(hobbyRecords: currentHobby!)
        let hostingController = UIHostingController(rootView: swiftUIView) //UIHostingController allow swiftUI to be embedded into UIKit
        present(hostingController, animated: true, completion: nil)
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.databaseController?.deleteHobby(hobby: allHobbies[indexPath.row])
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "viewHobbyIdentifier" {
//            if let destination = segue.destination as? ViewHobbyController {
//                // Pass any necessary data to the destination view controller here
//                destination.hobbyRecords = currentHobby
//            }
//        }
//    }

}
