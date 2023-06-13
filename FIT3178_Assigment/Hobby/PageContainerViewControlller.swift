import UIKit
import FirebaseStorage
//class PageContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    var pageViewController: UIPageViewController!
    
    var pageControl = UIPageControl()
    var currentViewController: UIViewController!
    var notesText: [(String,String?)] = []
    var uniqueURL:String?
    var swipedFirstTime = false
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        // set the transitionStyle to scroll
    }

    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        // Set the initial view controller
        if let initialViewController = viewController(at: 0) {
            self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        }
        else{
            // set the viewController to blank if there is no any data
            if let initialViewControllerBlank = blankViewController(){
                self.setViewControllers([initialViewControllerBlank], direction: .forward, animated: false)
            }
        }
        
        // configuration of the page view controller
        configurePageControl()
     }
    
    func configurePageControl() {
        // configurePageControl
        pageControl.numberOfPages = notesText.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.systemBlue
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // called everytime when there is swipe action
        // set the pageControl to that image
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = viewControllerIndex(visibleViewController) {
            pageControl.currentPage = index
        }
    }
    func blankViewController() -> UIViewController? {
        // blank controller when there is no data
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        self.currentViewController = viewController
        return viewController
    }
    func viewController(at index: Int) -> UIViewController? {
        // this function set the view controller corresponding to the index and return it
        guard index >= 0 && index < notesText.count else {
            return nil
        }
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        uniqueURL = notesText[index].1

        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.notesText[index].0
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(containerView)
        
        // download the image and set its contentMode to scaleAspectFit
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let image = notesText[index].1 // the image path store in the second element of the tuple
        if image != ""{
            let storageRef = Storage.storage().reference(forURL: image!)
//            DispatchQueue.main.async {
                storageRef.getData(maxSize: 10*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
//            }
        }
        viewController.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(pageControl)
        
        //set the constraint
        Task{
            do{
                DispatchQueue.main.async {
                    NSLayoutConstraint.activate([
                        containerView.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 8),
                        containerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
                        containerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
                        containerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                        
                        imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                        
                        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                        label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                        label.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor, constant: -20),
                        

                        self.pageControl.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: -20),
                        self.pageControl.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
                    ])
                }
            }
        }
        self.currentViewController = viewController
        return viewController
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // this function will be called when the user swipe to the right,which will turn the page to the right
        guard let currentIndex = viewControllerIndex(viewController), currentIndex > 0 else {
            if !swipedFirstTime{
                swipedFirstTime = true
                if 1 < notesText.count{
                    return self.viewController(at: 1)
                }
            }
            return nil
        }
        return self.viewController(at: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // this will be called when user swipe to the left, which will turn the page to the left
        guard let currentIndex = viewControllerIndex(viewController), currentIndex < notesText.count - 1 else {
            return nil
        }
        return self.viewController(at: currentIndex + 1)
    }
    
    func viewControllerIndex(_ viewController: UIViewController) -> Int? {
        // find the controller index by comparing the uniqueURL
        guard let uniqueURL = self.uniqueURL else {
            return nil
        }
        let index = notesText.firstIndex(where:{ $0.1 == uniqueURL})
        return index
    }
}
