import UIKit
import FirebaseStorage
//class PageContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    var pageViewController: UIPageViewController!
    
    var pageControl = UIPageControl()
    var currentViewController: UIViewController!
    var notesText: [(String,String?)] = []
    var uniqueURL:String?
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
        // Set the initial view controller
        if let initialViewController = viewController(at: 0) {
            self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        }
        else{
            if let initialViewControllerBlank = blankViewController(){
                self.setViewControllers([initialViewControllerBlank], direction: .forward, animated: false)
            }
    
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
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = viewControllerIndex(visibleViewController) {
            pageControl.currentPage = index
        }
    }
    func blankViewController() -> UIViewController? {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        self.currentViewController = viewController
        return viewController
    }
    func viewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < notesText.count else {
            return nil
        }
        print("oooo\(index)")
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        uniqueURL = notesText[index].1
//        viewController.title = notesText[index].0 // Set the title for the view controller
        print(notesText[index].0)
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.notesText[index].0
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        
        let deleteButton = UIButton(type:.system)
        deleteButton.setImage(UIImage(named: "ellipsis"), for: .normal)
        deleteButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(deleteButton)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(containerView)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let image = notesText[index].1
        if image != ""{
            let storageRef = Storage.storage().reference(forURL: image!)
            print("iiiiiiiii")
//            DispatchQueue.main.async {
                storageRef.getData(maxSize: 100*1024*1024){ data,error in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        let image = UIImage(data: data!)
                        print("download hahahah")
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
        
        Task{
            do{
                DispatchQueue.main.async {
                    NSLayoutConstraint.activate([
                        containerView.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 8),
                        containerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
                        containerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
                        containerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                        
                        deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor),
                        deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        deleteButton.bottomAnchor.constraint(equalTo: label.topAnchor),
                        
                        imageView.topAnchor.constraint(equalTo: deleteButton.bottomAnchor),
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
    
    @objc func buttonTapped() {
        // Handle button tap event
        
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex > 0 else {
            return nil
        }
        print("ssss\(currentIndex - 1)")
        return self.viewController(at: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex < notesText.count - 1 else {
            return nil
        }
        print("dddd\(currentIndex + 1)")
        return self.viewController(at: currentIndex + 1)
    }
    
    func viewControllerIndex(_ viewController: UIViewController) -> Int? {
        guard let uniqueURL = self.uniqueURL else {
            return nil
        }
        let index = notesText.firstIndex(where:{ $0.1 == uniqueURL})
        print("eeee\(index)")
        return index
    }
}
