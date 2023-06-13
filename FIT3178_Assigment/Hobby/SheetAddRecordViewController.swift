//
//  SheetAddRecordViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import UIKit

class SheetAddRecordViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var notesRecord: UITextField!
    var hobby:Hobby?
    var choosenDate:String?
    var image:UIImage?
    
    
    @IBAction func uploadImage(_ sender: Any) {
        // show the image album for user to choose the image
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // set the image when the user has chose the image
        if let selectedImage = info[.originalImage] as? UIImage {
            image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addRecord(_ sender: Any) {
        // add record with those information
        guard let note = notesRecord.text else{
            return
        }
        Task{
            do{
                let folderPath = "images/"
                if let image = image{
                    // upload the image to the firebase storage and get the path of the image
                    databaseController?.uploadImageToStorage(folderPath: folderPath, image: image){ imageString in
                        self.addNote(noteDetails: note,imageString: imageString)
                    }
                }else{
                    self.addNote(noteDetails: note,imageString: "")
                }
            }
        }
    }
    
    func addNote(noteDetails:String,imageString:String){
        self.databaseController?.addNote(noteDetails: noteDetails,date: self.choosenDate!,hobby: self.hobby!,image: imageString){ hobby in
            var startWeek = self.databaseController?.startWeek
            var endWeek = self.databaseController?.endWeek
            if startWeek == nil, endWeek == nil{
                let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
                startWeek = week.start
                endWeek = week.end
            }
            self.databaseController?.showRecordWeekly(hobby: hobby, startWeek: startWeek!, endWeek: endWeek!){ (records,dateInRange) in
                var finalRecords:[Records] = []
                for range in dateInRange {
                    for record in records {
                        if record.date == range{
                            finalRecords.append(record)
                            break
                        }
                    }
                }
                self.databaseController?.onWeeklyChange(records: finalRecords)
                self.dismiss(animated: true)
            }
        }
    }
    
    override var sheetPresentationController: UISheetPresentationController?{
        presentationController as? UISheetPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        sheetPresentationController?.detents = [.custom{
            _ in return 220
        }]
        sheetPresentationController?.prefersGrabberVisible = true //show the line on top of the bottom sheet
        sheetPresentationController?.preferredCornerRadius = 24
    }
    
    func displayMessage(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
