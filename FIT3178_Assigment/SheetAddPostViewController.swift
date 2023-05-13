//
//  SheetAddPostViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit

class SheetAddPostViewController: UIViewController,UITextViewDelegate{
    weak var databaseController:DatabaseProtocol?
    let placeholderText = "Enter text here..."
    
    
    @IBOutlet weak var postDetails: UITextView!
    
    
    @IBAction func createPost(_ sender: Any) {
        let _ = databaseController?.addPost(postDetail: postDetails.text)
        navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set placeholder text initially
        postDetails.text = placeholderText
        postDetails.textColor = UIColor.lightGray
        
        // Adjust text view properties
        postDetails.contentInset = UIEdgeInsets.zero
        postDetails.delegate = self
    }
    
    // UITextViewDelegate method called when text view begins editing
       func textViewDidBeginEditing(_ textView: UITextView) {
           if postDetails.text == placeholderText {
               postDetails.text = ""
               postDetails.textColor = UIColor.black
           }
       }
       
       // UITextViewDelegate method called when text view ends editing
       func textViewDidEndEditing(_ textView: UITextView) {
           if postDetails.text!.isEmpty {
               postDetails.text = placeholderText
               postDetails.textColor = UIColor.lightGray
           }
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
