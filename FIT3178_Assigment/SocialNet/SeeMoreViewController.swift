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
                downloadImages()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func downloadImages(){
        var counter = 0
        self.images = []
        post!.images.forEach{ image in
            if image != ""{ //only download if it not empty
                let storageRef = Storage.storage().reference(forURL: image) // get the storage ref of the image
                storageRef.getData(maxSize: 10*1024*1024){ data,error in // then get the image from it
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        let image = UIImage(data: data!)
                        self.images.append(image!)
                        counter += 1
                        
                        if counter == self.post?.images.count{ // only setup when all the images has been downloaded, asynchronous handling
                            self.setupImages(){ () in
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupImages(completion:@escaping () -> Void){
        // add the images to the stackView
        var counter = 0
        for view in stackView.arrangedSubviews { // make sure it is empty before add the view into the stack view to avoid duplicate view
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
            if counter == self.images.count{// only add it into the scrollView once all the view has been added into stackView
                self.relax()
                completion()
            }
        }
    }
    func relax(){
        // set the constraint
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
