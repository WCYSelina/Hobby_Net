//
//  SocialNetTableViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseAuth

class SocialNetTableViewController: UITableViewController,DatabaseListener{
    var listenerType = ListenerType.post
    weak var databaseController :DatabaseProtocol?
    let CELL_POST = "postCell"
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
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
    
    func onPostChange(change: DatabaseChange, posts: [Post]) {
        postList = posts
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    var postList:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Customize table view appearance
//        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: "postCell")
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
        return postList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! CardTableViewCell
        let post = postList[indexPath.row]
        postCell.descriptionLabel.text = post.postDetail
        return postCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            self.databaseController?.deleteHobby(hobby: allHobbies[indexPath.row])
        }
    }
}

class CardTableViewCell: UITableViewCell {
    let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize cell layout
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        // Configure description label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
