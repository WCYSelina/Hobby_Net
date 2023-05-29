//
//  SheetAddRecordViewController.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import UIKit

class SheetAddRecordViewController: UIViewController {
    weak var databaseController:DatabaseProtocol?
    @IBOutlet weak var notesRecord: UITextField!
    var hobby:Hobby?
    var choosenDate:String?
    
    
    @IBAction func uploadImage(_ sender: Any) {
        let viewController = SelectPhotosViewController()
        present(viewController, animated: true){ () in
        }
    }
    
    @IBAction func addRecord(_ sender: Any) {
        guard let note = notesRecord.text else{
            return
        }
        Task{
            do{
                let folderPath = "images/"
                let image = databaseController?.selectedImage
                if let image = image{
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
                print(dateInRange)
                print(records)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
