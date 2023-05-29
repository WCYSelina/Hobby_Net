//
//  ViewCommentTableViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 14/5/2023.
//

import UIKit
import FirebaseAuth
class ViewCommentViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentNum: UILabel!
    
    
    @IBOutlet weak var comment: UITextField!
    
    @IBAction func sendComment(_ sender: Any) {
        if self.comment.text != ""{
            let comment = databaseController?.addComment(commentDetail: self.comment.text!)
            self.comment.text = ""
            databaseController?.addCommentToPost(comment: comment!,post: databaseController!.defaultPost)
        }
    }
    
    var listenerType = ListenerType.comment
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: Records?) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onCreateAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser: User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
        commentList = comments
        commentNum.text = "\(String(commentList!.count)) comments"
        tableView.reloadData()
    }
    
    let CELL_COMMENT = "commentCell"
    weak var databaseController:DatabaseProtocol?
    var commentList:[Comment]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the table view's delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.separatorStyle = .none
        tableView.register(CardTableViewCellForComment.self, forCellReuseIdentifier: CELL_COMMENT)
        
        commentNum.text = "\(String(commentList!.count)) comments"
    }

    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.commentList!.count)
        return commentList!.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let commentCell = tableView.dequeueReusableCell(withIdentifier: CELL_COMMENT, for: indexPath) as! CardTableViewCellForComment
         let comment = commentList![indexPath.row]
         commentCell.descriptionLabel.text = comment.commentDetail
         commentCell.userName.text = comment.publisherName
         
         return commentCell
    }
}

class CardTableViewCellForComment: UITableViewCell {
    let userName = UILabel()
    let descriptionLabel = UILabel()

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
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.tintColor = .lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            
            userName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

