//
//  UserAccViewController.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 11/4/2023.
//

import UIKit
import FirebaseAuth
class UserAccViewController: UIViewController,DatabaseListener{
    func onRecordChange(change: DatabaseChange, record: Records?) {
    }
    
    func onUserPostsDetail(change: DatabaseChange, user: User?) {
    }
    
    func onYourEventChange(change: DatabaseChange, user: User?) {
    }
    
    func onEventChange(change: DatabaseChange, events: [Event]) {
    }
    
    func onAuthAccount(change: DatabaseChange, user: FirebaseAuth.User?) {
        if !loginHasCalledBefore{
            return
        }
        else{
            if let hasLogin = databaseController?.hasLogin{
                if !hasLogin{
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Error", message: self.databaseController?.error ?? "")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.databaseController?.email = self.email.text
                        self.performSegue(withIdentifier: "signUpIdentifier", sender: user)
                    }
                }
            }
            self.databaseController?.hasLogin = nil
        }
    }
    
    func onCreateAccount(change: DatabaseChange, user:  FirebaseAuth.User?) {
        if !signUpHasCalledBefore{
            return
        }
        else{
            if let hasCreated = databaseController?.hasCreated{
                if !hasCreated{
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Error", message: self.databaseController?.error ?? "")
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.displayMessage(title: "Successful", message: "Your account is successfully created")
                        }
                    }
                    self.databaseController?.hasCreated = nil
            }
        }
    }
    
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
    }
    
    func onPostChange(change: DatabaseChange, posts: [Post], defaultUser:User?) {
    }
    
    func onCommentChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    let indictor =  UIActivityIndicatorView(style: .large)
    var loginHasCalledBefore = false
    var signUpHasCalledBefore = false
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    weak var databaseController: DatabaseProtocol?
    var user:User?
    var listenerType:ListenerType = .auth
    
    
    @IBAction func signUp(_ sender: Any) {
        if !signUpHasCalledBefore{
            signUpHasCalledBefore = true
        }
        if let email = email.text,let password = password.text{
            Task{
                await databaseController?.createAccount(email: email, password: password)
            }
            
        }
    }
    
    @IBAction func logIn(_ sender: Any) {
        if !loginHasCalledBefore{
            loginHasCalledBefore = true
        }
        if let email = email.text,let password = password.text{
            Task{
                await databaseController?.loginAccount(email: email, password: password)
//                UserDefaults.standard.set(true, forKey: "isUserSignedIn")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indictor.startAnimating()
        databaseController?.addListener(listener: self)
        let userDefaults = UserDefaults.standard
        var hasLogin = userDefaults.bool(forKey: "hasLogin")
        
        print(hasLogin)
        if hasLogin{
            if !loginHasCalledBefore{
                loginHasCalledBefore = true
            }
            let email = userDefaults.string(forKey: "email")
            let password = userDefaults.string(forKey: "password")
            if let email = email, let password = password{
                Task{
                    await databaseController?.loginAccount(email: email, password: password)
                }
            }
        }
        else{
            self.indictor.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        navigationItem.setHidesBackButton(true, animated: false)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        indictor.color = .systemGray
        indictor.center = view.center
        indictor.hidesWhenStopped = true
        view.addSubview(indictor)
//
//        let isUserSignedIn = UserDefaults.standard.bool(forKey: "isUserSignedIn")
//        if isUserSignedIn{
//            self.databaseController?.email = self.email.text
//            self.performSegue(withIdentifier: "signUpIdentifier", sender: user)
//            print("hhhh")
//        }

        // Do any additional setup after loading the view.
    }
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
