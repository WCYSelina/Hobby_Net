//
//  SheetAddPostViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 13/5/2023.
//

import UIKit

// using this controller to add a new post
class SheetAddPostViewController: UIViewController,UITextViewDelegate{
    // init
    weak var databaseController:DatabaseProtocol?
    let placeholderText = "Enter text here..."
    
    
    @IBOutlet weak var postDetails: UITextView!
    @IBOutlet weak var squareBox: UIView!
    @IBOutlet weak var yourPostLabel: UILabel!
    @IBAction func createPost(_ sender: Any) {
        // create a new post and upload images
        Task{
            do{
                var counter = 0
                let folderPath = "images/"
                if !images.isEmpty{
                    // for each images, using databse to upload to the storage bucket
                    images.forEach{ image in
                        databaseController?.uploadImageToStorage(folderPath: folderPath, image: image){ imageString in
                            self.imagesString.append(imageString)
                            print(imageString)
                            counter += 1
                            if counter == self.images.count{
                                // add new post
                                let _ = self.databaseController?.addPost(postDetail: self.postDetails.text,imagesString: self.imagesString)
                            }
                        }
                    }
                    
                }else{
                    let _ = self.databaseController?.addPost(postDetail: postDetails.text,imagesString: [])
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    // init
    var imagesString:[String] = []
    var images:[UIImage] = []
    var scrollView:UIScrollView = UIScrollView()
    var stackView:UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the databse controller
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

        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        // Add the square box view
        
        // Add tap gesture recognizer to handle image selection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        squareBox.addGestureRecognizer(tapGesture)

    }
        
    @objc func selectImage() {
        // presents the image picker for image selection
        let imagePicker = SelectPhotosViewController()
        imagePicker.addPostController = self
        present(imagePicker, animated: true, completion: nil)
    }
    // add the selected images to the images array and displays them in the stack view
    func addImage(images:[UIImage]){
        // add image to the array
        if !images.isEmpty{
            self.images.append(contentsOf: images)
        }
        print(self.images.count)
        // remove all child subview for stackview
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        displayImage(images: self.images)
    }
    
    func displayImage(images:[UIImage]){
        // creates a separator view, image view, and delete button for each image, and adds them to the stack view
        self.images = images
        var counter = 0
        images.forEach{ image in
            // init the blank view
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .systemGray
            stackView.addArrangedSubview(separatorView)
            
            // init the container UI view
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            // init the UIImageView
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(imageView)
            
            // init the UIButton
            let crossButton = UIButton(type: .custom)
            crossButton.translatesAutoresizingMaskIntoConstraints = false
            crossButton.setTitle("X", for: .normal)
            crossButton.setTitleColor(.white, for: .normal)
            crossButton.backgroundColor = .red
            crossButton.layer.cornerRadius = 15
            crossButton.tag = counter
            counter += 1
            crossButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
            containerView.addSubview(crossButton)
            
            stackView.addArrangedSubview(containerView)
            
            // set their constraints
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
            self.images.remove(at: sender.tag)
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            self.displayImage(images: self.images)
        }
}
