//
//  SocialNetTableViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseAuth

class SocialNetTableViewController: UITableViewController,DatabaseListener,UITextFieldDelegate{
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
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
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser: User?) {
        self.defaultUser = defaultUser
        postList = posts
        tableView.reloadData()
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    var postList:[Post] = []
    var defaultUser:User?
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
        
        postCell.sendButton.cell = postCell
        postCell.sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        postCell.sendButton.tag = indexPath.row
        
        // Configure the thumbs-up button
        postCell.thumbsUpButton.addTarget(self,action: #selector(thumbsUpButtonTapped(_:)), for: .touchUpInside)
        postCell.thumbsUpButton.tag = indexPath.row// Set a unique tag to identify the button
        var isSet = false
        for likePost in defaultUser!.likes{
            if likePost.id == post.id{
                postCell.thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                postCell.thumbsUpButton.tintColor = .systemBlue
                isSet = true
            }
        }
        if !isSet{
            postCell.thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            postCell.thumbsUpButton.tintColor = .gray
        }
        
        // Add tap gesture recognizer to the label
        
        let tapGesture = CustomTapGesture(target: self, action: #selector(viewCommentTapped(_:)))
        tapGesture.post = post
        postCell.commentLabel.addGestureRecognizer(tapGesture)
        
        // Configure the comment text field
        postCell.commentTextField.placeholder = "Add a comment"
        postCell.commentTextField.delegate = self
        postCell.likesLabel.text = "\(post.likeNum!) likes"
        postCell.commentLabel.text = "View comments"
        postCell.userName.text = post.publisherName
        return postCell
    }
    
    @objc func sendButtonTapped(_ sender:CustomButton) {
        guard let postCell = sender.cell else{
            return
        }
        let row = sender.tag
        let post = postList[row]
        if postCell.commentTextField.text != ""{
            let comment = databaseController?.addComment(commentDetail: postCell.commentTextField.text!)
            postCell.commentTextField.text = ""
            databaseController?.addCommentToPost(comment: comment!,post: post)
        }
    }
    
    @objc func viewCommentTapped(_ sender: CustomTapGesture){
        if let post = sender.post{
            databaseController!.defaultPost = post
            performSegue(withIdentifier: "viewCommentIdentifier", sender: post)
        }
    }
    
    
    @objc func thumbsUpButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: 0)
        let post = postList[row]
        // Toggle the selected state of the button
            sender.isSelected = !sender.isSelected
            
            // Update the button's appearance based on the selected state
            if sender.isSelected {
                // Button is selected (filled)
                let _ = databaseController?.addLikeToUser(like: post)
                sender.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                sender.tintColor = .systemBlue

            } else {
                // Button is not selected (outline)
                let _ = databaseController?.deleteLikeFromUser(like: post)
                sender.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                sender.tintColor = .gray
            }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCommentIdentifier", let destinationVC = segue.destination as? ViewCommentViewController{
            if let post = sender as? Post{
                destinationVC.commentList = post.comment
            }
        }
            
    }
}

class CardTableViewCell: UITableViewCell {
    let userName = UILabel()
    let profileImage = UIImageView()
    let descriptionLabel = UILabel()
    let thumbsUpButton = UIButton()
    let commentTextField = UITextField()
    let sendButton = CustomButton(type: .system)
    let separatorViewTop = UIView()
    let separatorViewBottom = UIView()
    let likesLabel = UILabel()
    let commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize cell layout
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        userName.font = UIFont.boldSystemFont(ofSize: userName.font.pointSize)
        userName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userName)
        
        
        // Configure description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.tintColor = .lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        
        // Configure thumbs-up button
//        thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
//        thumbsUpButton.tintColor = .gray
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
        
        // Configure likes label
        likesLabel.textColor = .gray
        likesLabel.font = UIFont.systemFont(ofSize: 12) // Adjust the font size as desired
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likesLabel)
        
        // Configure likes label
        commentLabel.isUserInteractionEnabled = true
        commentLabel.textColor = .systemBlue
        commentLabel.font = UIFont.systemFont(ofSize: 12) // Adjust the font size as desired
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentLabel)
        
        // Configure separator views
        separatorViewTop.backgroundColor = .lightGray
        separatorViewTop.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorViewTop)
        
        separatorViewBottom.backgroundColor = .lightGray
        separatorViewBottom.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorViewBottom)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            
            userName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            separatorViewTop.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            separatorViewTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorViewTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorViewTop.heightAnchor.constraint(equalToConstant: 1),
            
            likesLabel.topAnchor.constraint(equalTo: separatorViewTop.bottomAnchor, constant: 4),
            likesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            commentLabel.topAnchor.constraint(equalTo: separatorViewTop.bottomAnchor, constant: 4),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            separatorViewBottom.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 4),
            separatorViewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorViewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorViewBottom.heightAnchor.constraint(equalToConstant: 1),
            
            thumbsUpButton.topAnchor.constraint(equalTo: separatorViewBottom.bottomAnchor, constant: 8),
            thumbsUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbsUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            thumbsUpButton.widthAnchor.constraint(equalToConstant: 24),
            thumbsUpButton.heightAnchor.constraint(equalToConstant: 24),
            
            commentTextField.topAnchor.constraint(equalTo: separatorViewBottom.bottomAnchor, constant: 8),
            commentTextField.leadingAnchor.constraint(equalTo: thumbsUpButton.trailingAnchor, constant: 8),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: commentTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24),
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomButton: UIButton {
    var cell: CardTableViewCell?
}

class CustomTapGesture: UITapGestureRecognizer {
    var post: Post?
    var event:Event?
}

                                                
                                    
            


