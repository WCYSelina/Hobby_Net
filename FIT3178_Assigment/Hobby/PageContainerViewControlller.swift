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
            current += 1
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.didMove(toParent: self)
        
        self.view.isUserInteractionEnabled = true
        setUpPage()
        if pages.count == 0{
            if let initialNoRecord = blankViewController(){
                self.setViewControllers([initialNoRecord], direction: .forward, animated: false)
            }
        }
        else{
            self.currentViewController = self.pages[0]
            self.setViewControllers([pages[0]], direction: .forward, animated: false)
        }
        
//         Additional configuration of the page view controller
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
    
    func blankViewController() -> UIViewController? {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        self.currentViewController = viewController
        return viewController
    }
    
//
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewControllerIndex(viewController)
        
        if currentIndex! - 1 == -1{
            self.currentViewController = self.pages[0]
            return self.pages[0]
        }
        self.currentViewController = self.pages[currentIndex! - 1]
        return self.pages[currentIndex! - 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
