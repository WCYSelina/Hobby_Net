import UIKit
import FirebaseStorage
//class PageContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    var pageViewController: UIPageViewController!
    
    var pageControl = UIPageControl()
    var currentViewController: UIViewController!
    var notesText: [(String,String?)] = []
    var pages: [RecordImageViewController] = []
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    func setUpPage(){
        var current = 0
        for noteText in notesText{
            pages.append(RecordImageViewController(path: noteText.1!, pageControlIndex: current, pageControlTotalPage: notesText.count))
//            var page = RecordImageViewController()
//            page.path = noteText.1!
//            page.pageControlIndex = current
//            page.pageControlTotalPage = notesText.count
//            pages.append(page)
            current += 1
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.didMove(toParent: self)
        
        self.view.isUserInteractionEnabled = true
        // Set the initial view controller
//        if let initialViewController = viewController(at: 0) {
//            self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
//        }
//        else{
//            if let initialViewControllerBlank = blankViewController(){
//                self.setViewControllers([initialViewControllerBlank], direction: .forward, animated: false)
//            }
//        }
        self.currentViewController = self.pages[0]
        self.setViewControllers([pages[0]], direction: .forward, animated: false)
        
        // Additional configuration of the page view controller
//        configurePageControl()
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
        print("finished")
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = viewControllerIndex(visibleViewController) {
            pageControl.currentPage = index
        }
    }
//    func blankViewController() -> UIViewController? {
//        let viewController = UIViewController()
//        viewController.view.backgroundColor = UIColor.systemBackground
//        self.currentViewController = viewController
//        return viewController
//    }
    func viewController(at index: Int) -> UIViewController? {
//        guard index >= 0 && index < notesText.count else {
//            return nil
//        }
        print("index:\(index)")
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        
        viewController.title = notesText[index].0 // Set the title for the view controller
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.notesText[index].0
        print(label.text)
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(containerView)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let image = notesText[index].1
        Task{
            do{
                if image != ""{
                    let storageRef = Storage.storage().reference(forURL: image!)
                    await storageRef.getData(maxSize: 10*1024*1024){ data,error in
                        if let error = error{
                            print(error.localizedDescription)
                        } else{
                            let image = UIImage(data: data!)
                            print("download hahahah")
                            imageView.image = image
                            
                        }
                    }
                }
            }
        }
        
        viewController.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(pageControl)
        
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
            label.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            

            pageControl.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])
        self.currentViewController = viewController
        print("==S==")
        print("helllooo")
        print("label: \(label.text)")
        print("image: \(imageView.image)")
        print("==E==")
        return viewController
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        print("ddddd\(viewControllerIndex(viewController))")
//        guard let currentIndex = viewControllerIndex(viewController) else {
//            print("noooo")
//            return nil
//        }
//        if currentIndex - 1 == -1{
//            return self.viewController(at: 0)
//        }
//        print("????")
//        return self.viewController(at: currentIndex - 1)
        let currentIndex = viewControllerIndex(viewController)
        
        if currentIndex! - 1 == -1{
            self.currentViewController = self.pages[0]
            return self.pages[0]
        }
        self.currentViewController = self.pages[currentIndex! - 1]
        return self.pages[currentIndex! - 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        print("ssssss\(viewControllerIndex(viewController))")
//        guard let currentIndex = viewControllerIndex(viewController) else {
//            return nil
//        }
//        print("lalala")
//        if currentIndex + 1 == notesText.count{
//            return self.viewController(at: currentIndex)
//        }
//        return self.viewController(at: currentIndex + 1)
        let currentIndex = viewControllerIndex(viewController)
        
        if currentIndex! + 1 == pages.count{
            self.currentViewController = self.pages[pages.count-1]
            return self.pages[pages.count-1]
        }
        self.currentViewController = self.pages[currentIndex! + 1]
        return self.pages[currentIndex! + 1]
    }
    
    func viewControllerIndex(_ viewController: UIViewController) -> Int? {
        guard let viewController = viewController as? RecordImageViewController else{
            print("error")
            return -1
        }
        let index = notesText.firstIndex(where:{ $0.1 == viewController.path})
        return index
    }
}
