//
//  UserAccViewController.swift
//  lab03
//
//  Created by Ching Yee Selina Wong on 11/4/2023.
//

import UIKit
import FirebaseAuth
class UserAccViewController: UIViewController,DatabaseListener{
    
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
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
    }
    
    
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
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
    }
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}