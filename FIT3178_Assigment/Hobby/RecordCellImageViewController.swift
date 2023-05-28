//
//  RecordCellImageViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 29/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class RecordCellImageViewController: UIViewController {
    
    var iamgeView: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    var path: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.path != ""{
            let storageRef = Storage.storage().reference(forURL: self.path!)
            storageRef.getData(maxSize: 10*1024*1024){ data,error in
                if let error = error{
                    print(error.localizedDescription)
                } else{
                    let image = UIImage(data: data!)
                    print("download hahahah")
                    self.iamgeView.image = image
                }
            }
        }
        print("sdhoaushdouashoud")
        label.text = "hello!"
        
        view.addSubview(self.iamgeView)
        iamgeView.clipsToBounds = true
        iamgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iamgeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            iamgeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            iamgeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20)
        ])
        
        view.addSubview(self.label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: iamgeView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        
        
        
    }
    
    init(path: String) {
        
        self.path = path
        iamgeView.contentMode = .scaleAspectFit
        
        print(path)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
