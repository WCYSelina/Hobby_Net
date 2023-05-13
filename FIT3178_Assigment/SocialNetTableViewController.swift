//
//  SocialNetTableViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseAuth

class SocialNetTableViewController: UITableViewController,DatabaseListener,UITextFieldDelegate{
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
        
        // Configure the thumbs-up button
        postCell.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonTapped(_:)), for: .touchUpInside)
        postCell.thumbsUpButton.tag = indexPath.row // Set a unique tag to identify the button
        
        // Configure the comment text field
        postCell.commentTextField.placeholder = "Add a comment"
        postCell.commentTextField.delegate = self
        
        return postCell
    }
    
    @objc func thumbsUpButtonTapped(_ sender: UIButton) {
           let row = sender.tag
           // Handle the thumbs-up button tap for the specific row
           // You can access the corresponding data or perform any desired action
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
    let thumbsUpButton = UIButton()
    let commentTextField = UITextField()
    let sendButton = UIButton()
    let separatorViewTop = UIView()
    let separatorViewBottom = UIView()

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
        
        // Configure thumbs-up button
        thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        thumbsUpButton.tintColor = .gray
        thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbsUpButton)
        
        // Configure comment text field
        commentTextField.placeholder = "Add a comment"
        commentTextField.borderStyle = .roundedRect
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentTextField)
        
        // Configure send button
        sendButton.setImage(UIImage(systemName: "arrow.up.circle"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sendButton)
        
        // Configure separator views
        separatorViewTop.backgroundColor = .lightGray
        separatorViewTop.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorViewTop)
        
        separatorViewBottom.backgroundColor = .lightGray
        separatorViewBottom.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorViewBottom)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            separatorViewTop.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            separatorViewTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorViewTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorViewTop.heightAnchor.constraint(equalToConstant: 1),
            
            thumbsUpButton.topAnchor.constraint(equalTo: separatorViewTop.bottomAnchor, constant: 8),
            thumbsUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbsUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            thumbsUpButton.widthAnchor.constraint(equalToConstant: 24),
            thumbsUpButton.heightAnchor.constraint(equalToConstant: 24),
            
            separatorViewBottom.topAnchor.constraint(equalTo: thumbsUpButton.topAnchor),
            separatorViewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorViewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorViewBottom.heightAnchor.constraint(equalToConstant: 1),
            
            commentTextField.topAnchor.constraint(equalTo: separatorViewTop.bottomAnchor, constant: 8),
            commentTextField.leadingAnchor.constraint(equalTo: thumbsUpButton.trailingAnchor, constant: 8),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: commentTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24),
            
            separatorViewBottom.topAnchor.constraint(equalTo: thumbsUpButton.bottomAnchor, constant: 8),
            separatorViewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorViewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorViewBottom.heightAnchor.constraint(equalToConstant: 1),
            
            commentTextField.topAnchor.constraint(equalTo: separatorViewBottom.bottomAnchor, constant: 8),
            commentTextField.leadingAnchor.constraint(equalTo: thumbsUpButton.trailingAnchor, constant: 8),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: commentTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

            
            


