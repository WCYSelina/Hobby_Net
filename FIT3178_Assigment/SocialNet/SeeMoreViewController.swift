//
//  SeeMoreViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/6/2023.
//

import UIKit
import FirebaseStorage
class SeeMoreViewController: UIViewController {

    var post:Post?
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var descriptiopn: UITextView!
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    var images:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.text = post?.publisherName
        descriptiopn.text = post?.postDetail
        if let post = post{
            if post.images.isEmpty{
                //            tableView.rowHeight = 400
                downloadImages()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func downloadImages(){
        var counter = 0
        self.images = []
        post!.images.forEach{ image in
            if image != ""{
                let storageRef = Storage.storage().reference(forURL: image)
                storageRef.getData(maxSize: 10*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
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
    
    func setupImages(completion:@escaping () -> Void){
        var counter = 0
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        self.images.forEach{ image in
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .systemGray
            stackView.addArrangedSubview(separatorView)
            
            NSLayoutConstraint.activate([
                stackView.heightAnchor.constraint(equalToConstant: 300)
            ])
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            let aspectRatio = image.size.width / image.size.height
            NSLayoutConstraint.activate([
                separatorView.widthAnchor.constraint(equalToConstant: 10),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio),
            ])
            counter += 1
            if counter == self.images.count{
                self.relax()
                completion()
            }
        }
    }
    func relax(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
        self.scrollView.topAnchor.constraint(equalTo: self.username.bottomAnchor,constant: 8),
        self.scrollView.bottomAnchor.constraint(equalTo: self.descriptiopn.topAnchor, constant: -8),
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -8),
        self.scrollView.heightAnchor.constraint(equalToConstant: 300),
        
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
    }
}
