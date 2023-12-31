//
//  SocialNetTableViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
class SocialNetTableViewController: UITableViewController,DatabaseListener,UITextFieldDelegate{
    

    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    var listenerType = ListenerType.post
    weak var databaseController :DatabaseProtocol?
    let CELL_POST = "postCell"
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: Records?) {
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
        print("reload")
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    var postList:[Post] = []
    var defaultUser:User?
    var firstLoad = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // init the database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // customize the table view's separator style, color, and insets.
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.gray // Customize the separator color
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Customize the separator insets
        
        // register the custome table cell
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: "postCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // add listener into the database
        databaseController?.addListener(listener: self)
        // set the load state
        firstLoad = true
        print("hiiiii")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove listener from the database
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source
    // implements the UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return postList.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // customize each header for header in section
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray
        headerView.layer.cornerRadius = 5
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if containImage{
            containImage = false
            return 425
        }
        else{
            return 150
        }
    }
    
    var containImage = false

    // this method is called to configure and return a cell for the specified index path in the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create the cell
        let postCell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! CardTableViewCell
        let post = postList[indexPath.section]
        
        // set the data on cell
        postCell.tableView = self.tableView
        postCell.section = indexPath.section
        postCell.post = post

        // check if the post contains images
        if !post.images.isEmpty{
//            tableView.rowHeight = 400
            containImage = true
            postCell.downloadImages()
        }
        else{
            postCell.setupPostNoImage()
        }
        
        postCell.descriptionLabel.text = post.postDetail
        
        // configure the send button
        postCell.sendButton.cell = postCell
        postCell.sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        postCell.sendButton.tag = indexPath.section
        
        // Configure the thumbs-up button
        postCell.thumbsUpButton.addTarget(self,action: #selector(thumbsUpButtonTapped(_:)), for: .touchUpInside)
        postCell.thumbsUpButton.tag = indexPath.section// Set a unique tag to identify the button
        var isSet = false
        for likePost in defaultUser!.likes{
            if likePost.id == post.id{
                // set the thumbsUpButton
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

        let tapGesture2 = CustomTapGesture(target: self, action: #selector(seeMoreTapped(_:)))
        tapGesture2.post = post
        postCell.detail.addGestureRecognizer(tapGesture2)
        
        // Configure the comment text field
        postCell.commentTextField.placeholder = "Add a comment"
        postCell.commentTextField.delegate = self
        postCell.likesLabel.text = "\(post.likeNum!) likes"
        postCell.commentLabel.text = "View comments"
        postCell.userName.text = post.publisherName

        return postCell
    }
    
    // this method is called when the send button in a post cell is tapped
    @objc func sendButtonTapped(_ sender:CustomButton) {
        guard let postCell = sender.cell else{
            return
        }
        let section = sender.tag
        let post = postList[section]
        if postCell.commentTextField.text != ""{
            // add a new comment to the post
            let comment = databaseController?.addComment(commentDetail: postCell.commentTextField.text!)
            postCell.commentTextField.text = ""
            databaseController?.addCommentToPost(comment: comment!,post: post)
        }
    }
    
    // this method is called when the comment label in a post cell is tapped
    @objc func viewCommentTapped(_ sender: CustomTapGesture){
        if let post = sender.post{
            // set the default post for the database controller and perform segue to view comments
            databaseController!.defaultPost = post
            performSegue(withIdentifier: "viewCommentIdentifier", sender: post)
        }
    }
    
    @objc func seeMoreTapped(_ sender: CustomTapGesture){
        print("callllllllll")
        if let post = sender.post{
            // set the default post for the database controller and perform segue to see more details
            databaseController!.defaultPost = post
            performSegue(withIdentifier: "seeMoreIdentifier", sender: post)
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if postList[indexPath.section].publisher == defaultUser?.id{
            return true
        }
        return false
    }

    // this method is called when a trailing swipe gesture is performed on a specific row in the table view
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         // create a delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // perform the delete action when tapped
            self.databaseController?.deletePost(post: self.postList[indexPath.section])
            tableView.reloadData() // reload
            completionHandler(true)
        }
        // create a edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.performSegue(withIdentifier: "updatePost", sender: self.postList[indexPath.section])
            completionHandler(true)
        }
        // create a swipe actions configuration with delete and edit actions
        deleteAction.backgroundColor = .red // Customize the delete action background color
        editAction.backgroundColor = .blue // Customize the edit action background color
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to reveal actions
        
        return configuration
    }
    
    // transfer data to the view controller that is going to be navigated to
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCommentIdentifier", let destinationVC = segue.destination as? ViewCommentViewController{
            if let post = sender as? Post{
                destinationVC.commentList = post.comment
            }
        }
        if segue.identifier == "updatePost", let destinationVC = segue.destination as? UpdatePostViewController{
            if let post = sender as? Post{
                destinationVC.post = post
                destinationVC.setupPageImage()
            }
        }
        if segue.identifier == "seeMoreIdentifier", let destinationVC = segue.destination as?
            SeeMoreViewController{
            if let post = sender as? Post{
                destinationVC.post = post
                if !post.images.isEmpty{
                    destinationVC.downloadImages()
                }
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
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    let detail = UILabel()
    var post:Post?
    var images:[UIImage] = []
    var tableView:UITableView?
    var section:Int?
    var downloadFinished = false
    var isFirstReload = true
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    // this method is used to download the images associated with the post
    func downloadImages(){
        var counter = 0
        self.images = []
        // download all images
        post!.images.forEach{ image in
            if image != ""{
                // connect the storage bucket
                let storageRef = Storage.storage().reference(forURL: image)
                // start the download task
                storageRef.getData(maxSize: 10*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        // set the UIImage
                        let image = UIImage(data: data!)
                        print("download hahahah")
                        self.images.append(image!)
                        counter += 1
                        
                        if counter == self.post?.images.count{
                            self.setupImages(){ () in
                                
                            }
                        }
                    }
                }
            }
        }
    }
    // this method is used to setup the downloaded images in the cell's stack view
    func setupImages(completion:@escaping () -> Void){
        var counter = 0
        // remove all child view from stack view
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        // traverse all images
        self.images.forEach{ image in
            // set the blank view
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .systemGray
            stackView.addArrangedSubview(separatorView)
            
            // adjust the constraint
            NSLayoutConstraint.activate([
                stackView.heightAnchor.constraint(equalToConstant: 300)
            ])
    
            // set the UIImageView
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            let aspectRatio = image.size.width / image.size.height

            // adjust the constraint
            NSLayoutConstraint.activate([
                separatorView.widthAnchor.constraint(equalToConstant: 10),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio),
            ])
            counter += 1
            if counter == self.images.count{
                self.relax(){ () in
                    completion()
                }
            }
        }
        
        
        
    }
    //completion:@escaping () -> Void
    func relax(completion:@escaping () -> Void){
        DispatchQueue.main.async {
            // Customize cell layout
            self.contentView.backgroundColor = .systemBackground
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.masksToBounds = true
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.borderColor = UIColor.lightGray.cgColor
            self.userName.font = UIFont.boldSystemFont(ofSize: self.userName.font.pointSize)
            self.userName.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.userName)
            // Create a UIScrollView and add it to your view
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.scrollView)
            // Create the UIStackView and add it to the UIScrollView
            self.stackView.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.axis = .horizontal
            self.stackView.distribution = .fill
            self.scrollView.addSubview(self.stackView)
            // Configure description label
            self.descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            self.descriptionLabel.tintColor = .systemBackground
            self.descriptionLabel.numberOfLines = 0
            self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.descriptionLabel)
            
            self.detail.isUserInteractionEnabled = true
            self.detail.text = "See More"
            self.detail.textColor = .systemGray
            self.detail.font = UIFont.systemFont(ofSize: 12)
            self.detail.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.detail)
            

            self.thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.thumbsUpButton)
            // Configure comment text field
            self.commentTextField.placeholder = "Add a comment"
            self.commentTextField.borderStyle = .roundedRect
            self.commentTextField.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.commentTextField)
            // Configure send button
            self.sendButton.setImage(UIImage(systemName: "arrow.up.circle"), for: .normal)
            self.sendButton.tintColor = .systemBlue
            self.sendButton.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.sendButton)
            // Configure likes label
            self.likesLabel.textColor = .systemGray
            self.likesLabel.font = UIFont.systemFont(ofSize: 12) // Adjust the font size as desired
            self.likesLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.likesLabel)
            // Configure likes label
            self.commentLabel.isUserInteractionEnabled = true
            self.commentLabel.textColor = .systemBlue
            self.commentLabel.font = UIFont.systemFont(ofSize: 12) // Adjust the font size as desired
            self.commentLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.commentLabel)
            // Configure separator views
            self.separatorViewTop.backgroundColor = .lightGray
            self.separatorViewTop.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.separatorViewTop)
            self.separatorViewBottom.backgroundColor = .lightGray
            self.separatorViewBottom.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.separatorViewBottom)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                
                self.userName.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
                self.userName.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                
                self.scrollView.topAnchor.constraint(equalTo: self.userName.bottomAnchor,constant: 8),
                self.scrollView.bottomAnchor.constraint(equalTo: self.descriptionLabel.topAnchor, constant: -8),
                self.scrollView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.scrollView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -8),
                self.scrollView.heightAnchor.constraint(equalToConstant: 250),
                
                self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
                self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
                
                
                self.descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                
                self.detail.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor,constant: 5),
                self.detail.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -8),
                
                
                self.separatorViewTop.topAnchor.constraint(equalTo: self.detail.bottomAnchor, constant: 8),
                self.separatorViewTop.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.separatorViewTop.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.separatorViewTop.heightAnchor.constraint(equalToConstant: 1),
                
                self.likesLabel.topAnchor.constraint(equalTo: self.separatorViewTop.bottomAnchor, constant: 4),
                self.likesLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                
                self.commentLabel.topAnchor.constraint(equalTo: self.separatorViewTop.bottomAnchor, constant: 4),
                self.commentLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                
                self.separatorViewBottom.topAnchor.constraint(equalTo: self.likesLabel.bottomAnchor, constant: 4),
                self.separatorViewBottom.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.separatorViewBottom.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.separatorViewBottom.heightAnchor.constraint(equalToConstant: 1),
                
                self.thumbsUpButton.topAnchor.constraint(equalTo: self.separatorViewBottom.bottomAnchor, constant: 8),
                self.thumbsUpButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.thumbsUpButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
                self.thumbsUpButton.widthAnchor.constraint(equalToConstant: 24),
                self.thumbsUpButton.heightAnchor.constraint(equalToConstant: 24),
                
                self.commentTextField.topAnchor.constraint(equalTo: self.separatorViewBottom.bottomAnchor, constant: 8),
                self.commentTextField.leadingAnchor.constraint(equalTo: self.thumbsUpButton.trailingAnchor, constant: 8),
                self.commentTextField.trailingAnchor.constraint(equalTo: self.sendButton.leadingAnchor, constant: -8),
                self.commentTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
                
                self.sendButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.sendButton.centerYAnchor.constraint(equalTo: self.commentTextField.centerYAnchor),
                self.sendButton.widthAnchor.constraint(equalToConstant: 24),
                self.sendButton.heightAnchor.constraint(equalToConstant: 24),
                
            ])
            completion()
        }
    }
    
    func setupPostNoImage(){
        // Customize cell layout
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        userName.font = UIFont.boldSystemFont(ofSize: userName.font.pointSize)
        userName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userName)
        
        // Configure description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.tintColor = .systemBackground
        descriptionLabel.numberOfLines = 1
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        self.detail.isUserInteractionEnabled = true
        self.detail.text = "See More"
        self.detail.textColor = .systemGray
        self.detail.font = UIFont.systemFont(ofSize: 12)
        self.detail.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.detail)
        
        // Configure thumbs-up button
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
        likesLabel.textColor = .systemGray
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
        DispatchQueue.main.async {
            NSLayoutConstraint.activate([
                
                self.userName.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
                self.userName.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
              
                self.descriptionLabel.topAnchor.constraint(equalTo: self.userName.bottomAnchor, constant: 8),
                self.descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                
                self.detail.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor,constant: 5),
                self.detail.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -8),
                
                self.separatorViewTop.topAnchor.constraint(equalTo: self.detail.bottomAnchor, constant: 8),
                self.separatorViewTop.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.separatorViewTop.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.separatorViewTop.heightAnchor.constraint(equalToConstant: 1),
              
                self.likesLabel.topAnchor.constraint(equalTo: self.separatorViewTop.bottomAnchor, constant: 4),
                self.likesLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
             
                self.commentLabel.topAnchor.constraint(equalTo: self.separatorViewTop.bottomAnchor, constant: 4),
                self.commentLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
             
                self.separatorViewBottom.topAnchor.constraint(equalTo: self.likesLabel.bottomAnchor, constant: 4),
                self.separatorViewBottom.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.separatorViewBottom.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.separatorViewBottom.heightAnchor.constraint(equalToConstant: 1),
           
                self.thumbsUpButton.topAnchor.constraint(equalTo: self.separatorViewBottom.bottomAnchor, constant: 8),
                self.thumbsUpButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
                self.thumbsUpButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
                self.thumbsUpButton.widthAnchor.constraint(equalToConstant: 24),
                self.thumbsUpButton.heightAnchor.constraint(equalToConstant: 24),
                
                self.commentTextField.topAnchor.constraint(equalTo: self.separatorViewBottom.bottomAnchor, constant: 8),
                self.commentTextField.leadingAnchor.constraint(equalTo: self.thumbsUpButton.trailingAnchor, constant: 8),
                self.commentTextField.trailingAnchor.constraint(equalTo: self.sendButton.leadingAnchor, constant: -8),
                self.commentTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
                
                self.sendButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
                self.sendButton.centerYAnchor.constraint(equalTo: self.commentTextField.centerYAnchor),
                self.sendButton.widthAnchor.constraint(equalToConstant: 24),
                self.sendButton.heightAnchor.constraint(equalToConstant: 24),
            ])
        }
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

                                                
                                    
            


