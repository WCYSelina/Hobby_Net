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
    
    
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var squareBox: UIView!
    
    
    @IBOutlet weak var yourPostLabel: UILabel!
    
    @IBAction func createPost(_ sender: Any) {
        Task{
            do{
                var counter = 0
                let folderPath = "images/"
//                let image = databaseController?.selectedImage
                if let images = images{
                    images.forEach{ image in
                        databaseController?.uploadImageToStorage(folderPath: folderPath, image: image){ imageString in
                            self.imagesString.append(imageString)
                            print(imageString)
                            counter += 1
                            if counter == images.count{
                                self.databaseController?.addPost(postDetail: self.postDetails.text,imagesString: self.imagesString)
                            }
                        }
                    }
                    
                }else{
                    self.databaseController?.addPost(postDetail: postDetails.text,imagesString: [])
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    var imagesString:[String] = []
    var images:[UIImage]?
    let squareBoxSize: CGFloat = 100.0
    let plusSignSize: CGFloat = 40.0
    var scrollView:UIScrollView = UIScrollView()
    var stackView:UIStackView = UIStackView()
    
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
        
        // Create a UIScrollView and add it to your view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Create the UIStackView and add it to the UIScrollView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        scrollView.addSubview(stackView)

        // Set the constraints for the UIScrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: yourPostLabel.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: squareBox.topAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
        ])

        // Set the constraints for the UIStackView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        
//        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        stackView.axis = .horizontal
        stackView.distribution = .fill
        // Add the square box view
        
        // Add tap gesture recognizer to handle image selection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        squareBox.addGestureRecognizer(tapGesture)

    }
        
    @objc func selectImage() {
        let imagePicker = SelectPhotosViewController()
        imagePicker.addPostController = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func displayImage(images:[UIImage]?){
        self.images = images
        images?.forEach{ image in
            print("view")
            
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .systemGray
            stackView.addArrangedSubview(separatorView)
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
//            stackView.addArrangedSubview(imageView)
            containerView.addSubview(imageView)

//            let crossButton = UIButton(type: .custom)
//            crossButton.translatesAutoresizingMaskIntoConstraints = false
//            crossButton.setTitle("X", for: .normal) // or set a cross image
//            crossButton.setTitleColor(.red, for: .normal)
//            crossButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
//            containerView.addSubview(crossButton)
            
            let crossButton = UIButton(type: .custom)
            crossButton.translatesAutoresizingMaskIntoConstraints = false
            crossButton.setTitle("X", for: .normal)
            crossButton.setTitleColor(.white, for: .normal)
            crossButton.backgroundColor = .red
            crossButton.layer.cornerRadius = 15 
            crossButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
            containerView.addSubview(crossButton)
            
            stackView.addArrangedSubview(containerView)
            
            let aspectRatio = image.size.width / image.size.height
            NSLayoutConstraint.activate([
                separatorView.widthAnchor.constraint(equalToConstant: 10),
                
                containerView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio),
                containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio),
                imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                crossButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
                crossButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
                crossButton.widthAnchor.constraint(equalToConstant: 30),// setting width of button
                crossButton.heightAnchor.constraint(equalToConstant: 30) // setting height of
            ])
        }
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
    
        @objc func deleteImage(sender: UIButton) {
            // Implement the functionality to delete the image
        }

}
