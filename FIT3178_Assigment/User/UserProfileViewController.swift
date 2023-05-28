//
//  UserProfileViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 12/5/2023.
//

import UIKit
import FirebaseAuth
class UserProfileViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITabBarControllerDelegate{
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
        defaultUser = user
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var username: UILabel!
    weak var databaseController:DatabaseProtocol?
    let CELL_POST = "yourPostsLikes"
    var listenerType = ListenerType.post
    var postList:[Post] = []
    var defaultUser:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        username.text = databaseController?.email
        tabBarController?.delegate = self
        databaseController?.setupUserListener { () in
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(CardTableViewCell.self, forCellReuseIdentifier: self.CELL_POST)
            // Do any additional setup after loading the view.
            if self.segmentedControl.selectedSegmentIndex != 1{
                self.segmentedControl.selectedSegmentIndex = 0
            }
            self.segmentedControlValueChanged(self.segmentedControl)
        }
    }
    
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            if let posts = defaultUser?.posts{
                postList = posts
                tableView.reloadData()
            }
        }
        else{
            if let posts = defaultUser?.likes{
                postList = posts
                tableView.reloadData()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        databaseController?.removeListener(listener: self)
//    }
    
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
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
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?){
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: CELL_POST, for: indexPath) as! CardTableViewCell
        let post = postList[indexPath.section]
        postCell.descriptionLabel.text = post.postDetail
        
        postCell.sendButton.cell = postCell
        postCell.sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        postCell.sendButton.tag = indexPath.section
        
        // Configure the thumbs-up button
        postCell.thumbsUpButton.addTarget(self,action: #selector(thumbsUpButtonTapped(_:)), for: .touchUpInside)
        postCell.thumbsUpButton.tag = indexPath.section// Set a unique tag to identify the button
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
        let section = sender.tag
        let post = postList[section]
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
        let section = sender.tag
        let indexPath = IndexPath(row: 0, section: section)
        let post = postList[section]
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
                sender.tintColor = .systemGray
            }
           // Handle the thumbs-up button tap for the specific row
           // You can access the corresponding data or perform any desired action
       }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
