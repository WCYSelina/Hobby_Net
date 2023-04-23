//
//  HobbyTableViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 23/4/2023.
//

import UIKit
import SwiftUI

class HobbyTableViewController: UITableViewController,CreateHobbyDelegate{
    
    func createHobby(_ newHobby: Hobby) -> Bool {
        if let name = newHobby.name{
            if name.isEmpty{
                return false
            }
        }
        tableView.performBatchUpdates({
        // Safe because search can't be active when Add button is tapped.
        allHobbies.append(newHobby)
        tableView.insertRows(at: [IndexPath(row: allHobbies.count - 1, section:0)], with: .automatic)
        tableView.reloadSections([0], with: .automatic)
        }, completion: nil)
        return true
    }
    
    
    weak var hobbyDelegate:CreateHobbyDelegate?
    weak var viewHobbyDelegate:ViewHobbyDelegate?
    let CELL_HOBBY = "hobbyCell"
    var allHobbies: [Hobby] = []
    var currentHobby:Hobby?
    
    @IBAction func addHobby(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetPresentationControler = storyboard.instantiateViewController(withIdentifier: "SheetViewController") as! SheetViewController
        sheetPresentationControler.hobbyDelegate = self
        present(sheetPresentationControler, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        viewHobbyDelegate?.viewHobby(currentHobby!)
        let swiftUIView = ViewHobbyPage(hobbyRecords: currentHobby!)
        let hostingController = UIHostingController(rootView: swiftUIView)
        present(hostingController, animated: true, completion: nil)
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.performBatchUpdates({
                self.allHobbies.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([0], with: .automatic)
            }, completion: nil)
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
