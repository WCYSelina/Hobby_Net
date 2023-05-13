//
//  SocialNetViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 2/5/2023.
//

import UIKit

class SocialNetViewController: UIViewController {
    
    
    @IBOutlet weak var username: UILabel!
    
    @IBAction func barButtonItemTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sheetPresentationControler = storyboard.instantiateViewController(withIdentifier: "SheetAddPostViewController") as! SheetAddPostViewController
//        sheetPresentationControler.hobbyDelegate = self
        present(sheetPresentationControler, animated: true, completion: nil)
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
