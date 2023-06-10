//
//  UpdatePostViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 9/6/2023.
//

import UIKit
import FirebaseStorage

class UpdatePostViewController: UIViewController, UITextViewDelegate{
    @IBOutlet weak var yourPostLabel: UILabel!
    @IBOutlet weak var squareBox: UIView!
    @IBOutlet weak var postDetails: UITextView!
    
    @IBAction func updatePost(_ sender: Any) {
        print("heiheihei")
        Task{
            do{
                tagRemoved.forEach{ tag in
                    self.removedImage.append((post?.images![tag])!)
                }
                var counter = 0
                let folderPath = "images/"
//                let image = databaseController?.selectedImage
                if !self.newAddedImage.isEmpty{
                    self.newAddedImage.forEach{ image in
                        databaseController?.uploadImageToStorage(folderPath: folderPath, image: image){ imageString in
                            self.imagesString.append(imageString)
                            
                            counter += 1
                            if counter == self.newAddedImage.count{
                                self.databaseController?.updatePost(post: self.post!, postDetail: self.postDetails.text, addedImageString: self.imagesString, removedImageString: self.removedImage)
                            }
                        }
                    }
                    
                }else{
                    self.databaseController?.updatePost(post: self.post!, postDetail: self.postDetails.text, addedImageString: [], removedImageString: self.removedImage)
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    let placeholderText = "Enter text here..."
    var post:Post?
    weak var databaseController:DatabaseProtocol?
    var imagesString:[String] = []
    var images:[UIImage] = []
    var scrollView:UIScrollView = UIScrollView()
    var stackView:UIStackView = UIStackView()
    var tagRemoved:[Int] = []
    var removedImage:[String] = []
    var newAddedImage:[UIImage] = []
    var oldImage:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set placeholder text initially
        postDetails.text = post?.postDetail
        
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
    
    func setupPageImage(){
        post?.images?.forEach{ image in
            if image != ""{
                let storageRef = Storage.storage().reference(forURL: image)
                storageRef.getData(maxSize: 10*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        let image = UIImage(data: data!)
                        print("download hahahah")
                        self.images.append(image!)
                        self.oldImage.append(image!)
                        if self.images.count == self.post?.images?.count{
                            self.displayImage(images: self.images)
                        }
                    }
                }
            }
        }
    }
    
    
        
    @objc func selectImage() {
        let imagePicker = SelectPhotosViewController()
        imagePicker.updatePostController = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func addImage(images:[UIImage]){
        if !images.isEmpty{
            self.images.append(contentsOf: images)
            self.newAddedImage.append(contentsOf: images)
        }
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        displayImage(images: self.images)
    }
    
    func displayImage(images:[UIImage]){
        self.images = images
        var counter = 0
        images.forEach{ image in
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .systemGray
            stackView.addArrangedSubview(separatorView)
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(imageView)
            
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
//           postDetails.textColor = .bla
       }
   }
   
   // UITextViewDelegate method called when text view ends editing
   func textViewDidEndEditing(_ textView: UITextView) {
       if postDetails.text!.isEmpty {
           postDetails.text = placeholderText
           postDetails.textColor = .systemGray3
       }
   }

    @objc func deleteImage(sender: UIButton) {
        // Implement the functionality to delete the image
        let image = self.images[sender.tag]
        if sender.tag < oldImage.count{
            if image == oldImage[sender.tag]{
                tagRemoved.append(sender.tag)
            }
        }
        if sender.tag < newAddedImage.count{
            if image == newAddedImage[sender.tag]{
                self.newAddedImage.remove(at: sender.tag)
            }
        }
        self.images.remove(at: sender.tag)
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        self.displayImage(images: self.images)
    }
}
