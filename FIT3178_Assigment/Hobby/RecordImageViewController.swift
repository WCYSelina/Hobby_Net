//
//  RecordImageViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 30/5/2023.
//

import UIKit
import FirebaseStorage

class RecordImageViewController: UIViewController {
    
    let path: String
    let labelText: UILabel = UILabel()
    let picView = UIImageView()
    let pageControl = UIPageControl()
    let pageControlIndex: Int
    let pageControlTotalPage: Int

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func downloadImage(completion: @escaping () -> Void){
//        Task{
            do{
                let storageRef = Storage.storage().reference(forURL: path)
                storageRef.getData(maxSize: 10*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        DispatchQueue.main.async {
                            let image = UIImage(data: data!)
                            print("download hahahah")
                            self.picView.image = image

                        
                            self.view.addSubview(self.labelText)
                            self.labelText.translatesAutoresizingMaskIntoConstraints = false
                            self.view.addSubview(self.picView)
                            self.picView.translatesAutoresizingMaskIntoConstraints = false
                            self.view.addSubview(self.pageControl)
                            self.pageControl.translatesAutoresizingMaskIntoConstraints = false

                            NSLayoutConstraint.activate([
                                self.picView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                self.picView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                self.picView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

                                self.labelText.topAnchor.constraint(equalTo: self.picView.bottomAnchor, constant: 20),
                                self.labelText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                self.labelText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                self.labelText.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor, constant: -20),


                                self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
                                self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
                            ])
                        }
//                    }
                        completion()
                }
            }
        }
    }
    
    init(path: String, pageControlIndex: Int, pageControlTotalPage: Int) {
        self.path = path
        self.pageControlIndex = pageControlIndex
        self.pageControlTotalPage = pageControlTotalPage
        self.pageControl.numberOfPages = self.pageControlTotalPage
        self.pageControl.currentPage = self.pageControlIndex
        self.pageControl.tintColor = UIColor.systemBlue
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        
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
