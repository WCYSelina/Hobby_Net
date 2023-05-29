//
//  PageViewTableViewCell.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 28/5/2023.
//

import UIKit

class PageViewTableViewCell: UITableViewCell{

    var containerView: UIView!
    var pageViewControlObj: PageContainerViewController!
    var imageViewContainer = UIView()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        isUserInteractionEnabled = true
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
//        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//        self.addGestureRecognizer(swipeRight)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//        self.addGestureRecognizer(swipeLeft)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizer.Direction.right:
//                print("Swiped right")
////                self.contentView.subviews.remove(at: 0)
////                imageViewContainer.removeFromSuperview()
//                let controller = pageViewControlObj.pageViewController(pageViewControlObj, viewControllerBefore: pageViewControlObj.currentViewController)
////                imageViewContainer = UIView()
////                imageViewContainer.addSubview((controller?.view)!)
////                self.contentView.addSubview(imageViewContainer)
////                for v in self.contentView.subviews{
////                    print(v)
////                }
//                self.contentView.addSubview((controller?.view)!)
//
//            case UISwipeGestureRecognizer.Direction.left:
//                print("Swiped left")
////                imageViewContainer.removeFromSuperview()
//                let controller = pageViewControlObj.pageViewController(pageViewControlObj, viewControllerAfter: pageViewControlObj.currentViewController)
////                for subview in self.contentView.subviews {
////                    subview.removeFromSuperview()
////                }
////                for v in  self.contentView.subviews{
////                    print(v)
////                }
//                self.contentView.addSubview((controller?.view)!)
//
//
//            default:
//                break
//            }
//        }
//    }
    
    
}
