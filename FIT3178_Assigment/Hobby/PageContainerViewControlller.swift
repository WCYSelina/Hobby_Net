import UIKit
import FirebaseStorage
//class PageContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    var pageViewController: UIPageViewController!
    
    let sampleData = ["Page 1", "Page 2", "Page 3"]
    var pageControl = UIPageControl()
    var currentViewController: UIViewController!
    var notesText: [(String,String?)] = []
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        

//        self.view.frame = view.bounds
//        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.didMove(toParent: self)
        
        // Set the initial view controller
        if let initialViewController = viewController(at: 0) {
            self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        }
        
        // Additional configuration of the page view controller
        configurePageControl()
     }
    func configurePageControl() {
        pageControl.numberOfPages = notesText.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.systemBlue
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = viewControllerIndex(visibleViewController) {
            pageControl.currentPage = index
        }
    }
    func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < notesText.count else {
            return nil
        }
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        
        viewController.title = notesText[index].0 // Set the title for the view controller
        print(notesText[index].0)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
//        label.numberOfLines = 0
//        label.text = notesText[index].0
//        viewController.view.addSubview(label)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let image = notesText[index].1
        print(image)
        if image != ""{
            let storageRef = Storage.storage().reference(forURL: image!)
            storageRef.getData(maxSize: 10*1024*1024){ data,error in
                if let error = error{
                    print(error.localizedDescription)
                } else{
                    let image = UIImage(data: data!)
                    print("download hahahah")
                    imageView.image = image
                    
                    // Add constraints to maintain the aspect ratio of the image
                    imageView.translatesAutoresizingMaskIntoConstraints = false
//                    NSLayoutConstraint.activate([
//                        imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor,constant: 8),
//                        imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor,constant: 20),
//                        imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor,constant: 20)
////                        imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
//                    ])
                    
//                    // Calculate the appropriate dimensions based on the image's aspect ratio
//                    let aspectRatio = image!.size.width / image!.size.height
//                    let maxWidth: CGFloat = 200 // Maximum width for the imageView
//                    let maxHeight = maxWidth / aspectRatio
//                    let imageSize = CGSize(width: maxWidth, height: maxHeight)
//
//                    // Scale and set the image with the adjusted dimensions
//                    let scaledImage = image!.scaleToSize(imageSize)
//                    imageView.image = scaledImage
//                    imageView.frame = CGRect(origin: .zero, size: imageSize)
//                    imageView.center = viewController.view.center
                }
            }
        }
//        viewController.view.addSubview(imageView)
        
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let label = UILabel()
        label.numberOfLines = 0
        label.text = notesText[index].0
//        viewController.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 20),
//            label.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor,constant: 20),
//            label.trailingAnchor.constraint(equalTo: viewController.view.leadingAnchor,constant: 20)
////                        imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
//        ])
//
        
        let stack = UIStackView()
        stack.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stack.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])
        stack.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: stack.leadingAnchor)
        ])
        
        viewController.view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        print( stack.constraints[0])
        print( stack.constraints[1])
        print( stack.constraints[2])
        print( stack.constraints[3])
       
//        view.addSubview(viewController.view)
        
        let viewController2 = RecordCellImageViewController(path: notesText[index].1!)
        
        self.currentViewController = viewController2
        
        return viewController2
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex > 0 else {
            return nil
        }
        return self.viewController(at: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex < notesText.count - 1 else {
            return nil
        }
        return self.viewController(at: currentIndex + 1)
    }
    
    func viewControllerIndex(_ viewController: UIViewController) -> Int? {
        guard let title = viewController.title else {
            return nil
        }
        
        return sampleData.firstIndex(of: title)
    }
}
