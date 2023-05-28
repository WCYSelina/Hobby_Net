import UIKit

//class PageContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    var pageViewController: UIPageViewController!
    
    let sampleData = ["Page 1", "Page 2", "Page 3"]
    var pageControl = UIPageControl()
    var currentViewController: UIViewController!
    
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
        pageControl.numberOfPages = sampleData.count
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
        guard index >= 0 && index < sampleData.count else {
            return nil
        }
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        viewController.title = sampleData[index] // Set the title for the view controller
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.text = sampleData[index]
        label.textAlignment = .center
        label.center = viewController.view.center
        viewController.view.addSubview(label)
        
        self.currentViewController = viewController
        
        return viewController
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex > 0 else {
            return nil
        }
        return self.viewController(at: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllerIndex(viewController), currentIndex < sampleData.count - 1 else {
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
