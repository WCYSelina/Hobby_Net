//
//  UserProfileViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 12/5/2023.
//

import UIKit
import FirebaseAuth
class UserProfileViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITabBarControllerDelegate{
    // implements the DatabaseListener
    // change the post detail
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
        defaultUser = user
        username.text = user?.name
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var username: UILabel!
    
    
    @IBAction func editUserName(_ sender: Any) {
        // go to editUsername page
        performSegue(withIdentifier: "editUsername", sender: defaultUser)
        
    }
    
    
    // init properties
    weak var databaseController:DatabaseProtocol?
    let CELL_POST = "yourPostsLikes"
    var listenerType = ListenerType.post
    var postList:[Post] = []
    var defaultUser:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // set the username
        username.text = defaultUser?.name
        print(defaultUser?.name)
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
    
    
    @IBAction func removeListener(_ sender: Any) {
        // remove listener
        databaseController?.removeListener(listener: self)
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "hasLogin")
        
        // using storyboard to go to new page
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationController = storyboard.instantiateViewController(withIdentifier: "UserProfileController") as? UINavigationController{
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate{
                sceneDelegate.window?.rootViewController = navigationController
            }
        }
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // when segmented control changes
        // reload corresponding detail
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
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
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
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?){
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections in the table view
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // return the view for the header of the specified section
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // return the height for the header of the specified section
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return the height for the row at the specified index path
        if containImage{
            containImage = false
            return 400
        }
        else{
            return 150
        }
    }
    
    var containImage = false

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return the cell for the row at the specified index path
        let postCell = tableView.dequeueReusableCell(withIdentifier: CELL_POST, for: indexPath) as! CardTableViewCell
        let post = postList[indexPath.section]
        
        // set the post cell
        postCell.tableView = self.tableView
        postCell.section = indexPath.section
        postCell.post = post
        if !post.images.isEmpty{
//            tableView.rowHeight = 400
            containImage = true
            postCell.downloadImages()
        }
        else{
            postCell.setupPostNoImage()
        }
        
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
        // if comment text field is not empty
        if postCell.commentTextField.text != ""{
            // add comment
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
        // go to new page cooresponding the identifier
        if segue.identifier == "viewCommentIdentifier", let destinationVC = segue.destination as? ViewCommentViewController{
            if let post = sender as? Post{
                destinationVC.commentList = post.comment
            }
        }
        if segue.identifier == "changeUsername", let destinationVC = segue.destination as? editUserNameViewController{
            if let user = sender as? User{
                destinationVC.defaultUser = user
            }
        }
            
    }

}

// change the user name controller
class editUserNameViewController: UIViewController,UISheetPresentationControllerDelegate{
    
    // init
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var username: UITextField!
    var defaultUser:User?
    
    @IBAction func changeUserName(_ sender: Any) {
        // call the changeUserName method to change user name
        databaseController?.changeUserName(username: username.text ?? defaultUser!.name!)
        navigationController?.popViewController(animated: true)
    }
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // get the databse controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        sheetPresentationController?.detents = [.custom{
            _ in return 100
        }]
        sheetPresentationController?.prefersGrabberVisible = true //show the line on top of the bottom sheet
        sheetPresentationController?.preferredCornerRadius = 24
    }
}
