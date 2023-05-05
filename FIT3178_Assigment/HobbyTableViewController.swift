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
        
        // Create the tab bar and set it as the table view's footer view
        tabBar = UITabBar()
        // add tab bar as subview of parent view
        if let parentView = self.parent?.view {
            tabBar.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(tabBar)
            // set constraints for tab bar
            NSLayoutConstraint.activate([
                tabBar.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                tabBar.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                tabBar.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor),
                tabBar.heightAnchor.constraint(equalToConstant: 49) // set height to standard 49 points
            ])
        }
        
        // Create the tab bar items
        let hobbyPageBarItem = UITabBarItem(title: "Your Hobby", image: UIImage(systemName: "calendar"), tag: 0)
        let socialPlatformPageBarItem = UITabBarItem(title: "Social Net", image: UIImage(systemName: "person.2.fill"), tag: 1)
        let eventPageBarItem = UITabBarItem(title: "Event", image: UIImage(systemName: "megaphone.fill"), tag: 2)
        let profilePage  = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        
        // Add the items to the tab bar
        tabBar.setItems([hobbyPageBarItem, socialPlatformPageBarItem, eventPageBarItem,profilePage], animated: false)
        // Set the initial tab bar item
        tabBar.selectedItem = hobbyPageBarItem
        
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
        databaseController?.showCorrespondingRecord(hobby: currentHobby!)
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
}



